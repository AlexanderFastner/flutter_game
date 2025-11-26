import 'dart:math';
import 'package:flutter/material.dart';
import '../services/high_score_service.dart';
import 'game_over_screen.dart';

class Obstacle {
  int lane; // 0, 1, 2, or 3
  double y; // Vertical position
  double size;
  bool isStar;

  Obstacle({
    required this.lane,
    required this.y,
    required this.size,
    this.isStar = false,
  });
}

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // Track which lane each car is in (0 or 1 for left side, 2 or 3 for right side)
  int leftCarLane = 0; // 0 or 1 (left side lanes)
  int rightCarLane = 2; // 2 or 3 (right side lanes)

  // Game state
  List<Obstacle> obstacles = [];
  bool isGameOver = false;
  bool isPaused = false;
  int score = 0;
  int powerUpsCollected = 0;
  bool isImmune = false;
  double immunityTimeLeft = 0.0; // seconds
  DateTime? _immunityEndTime;
  static const Duration _immunityDuration = Duration(seconds: 5);
  late AnimationController _animationController;
  final Random _random = Random();
  final HighScoreService _highScoreService = HighScoreService.instance;
  
  // Screen dimensions (updated in build)
  double screenWidth = 0;
  double screenHeight = 0;
  
  // Game parameters
  double obstacleSpawnRate = 0.02; // probability per frame
  double obstacleSize = 40.0;
  double starSpawnChance = 0.05; // reduced chance for star powerups

  // Lane dash animation
  List<double> laneDashOffsets = List.filled(4, 0.0);
  final double dashLength = 24.0;
  final double dashGap = 24.0;
  final double dashWidth = 6.0;

  LaneTheme get _laneTheme {
    switch (widget.difficulty) {
      case 'Medium':
        return LaneTheme(
          backgroundColor: const Color(0xFF001F3F),
          laneColors: [const Color(0xFF003366), const Color(0xFF004080)],
          dividerColor: const Color(0xFF00CFFF),
          dashColor: const Color(0xFFFFFF00),
        );
      case 'Hard':
        return LaneTheme(
          backgroundColor: const Color(0xFF1A0029),
          laneColors: [const Color(0xFF330044), const Color(0xFF260033)],
          dividerColor: const Color(0xFFFF66CC),
          dashColor: const Color(0xFFFFB3F5),
        );
      default:
        return LaneTheme(
          backgroundColor: Colors.grey.shade900,
          laneColors: [Colors.grey.shade800, Colors.grey.shade700],
          dividerColor: Colors.grey.shade600,
          dashColor: Colors.yellow.shade400,
        );
    }
  }
  
  // Get base speed and max speed based on difficulty
  double get _baseSpeed {
    switch (widget.difficulty) {
      case 'Easy':
        return 4.0;
      case 'Medium':
        return 6.0;
      case 'Hard':
        return 8.0;
      default:
        return 4.0;
    }
  }
  
  double get _maxSpeed {
    switch (widget.difficulty) {
      case 'Easy':
        return 8.0;
      case 'Medium':
        return 10.0;
      case 'Hard':
        return 12.0;
      default:
        return 10.0;
    }
  }
  
  int get _maxScoreForSpeedIncrease {
    switch (widget.difficulty) {
      case 'Easy':
        return 100;
      case 'Medium':
        return 100;
      case 'Hard':
        return 1000;
      default:
        return 100;
    }
  }
  
  // Calculate current obstacle speed based on score and difficulty
  double get obstacleSpeed {
    if (score >= _maxScoreForSpeedIncrease) {
      return _maxSpeed;
    }
    // Linear interpolation: baseSpeed + (maxSpeed - baseSpeed) * (score / maxScore)
    return _baseSpeed + 
           (_maxSpeed - _baseSpeed) * (score / _maxScoreForSpeedIncrease);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60 FPS
    )..repeat();
    _animationController.addListener(_gameLoop);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _canSpawnInLane(int lane) {
    if (screenWidth == 0) return false;
    
    final double laneWidth = screenWidth / 4;
    final double carSize = laneWidth * 0.8;
    final double requiredSpacing = 2 * carSize; // 2 squares length offset
    
    // Check for obstacles in the same lane (prevent overlapping)
    final double newObstacleTop = -obstacleSize;
    final double newObstacleBottom = 0; // -obstacleSize + obstacleSize
    
    final sameLaneObstacles = obstacles.where((obs) => obs.lane == lane).toList();
    for (var sameLaneObstacle in sameLaneObstacles) {
      final double obstacleTop = sameLaneObstacle.y;
      final double obstacleBottom = sameLaneObstacle.y + sameLaneObstacle.size;
      
      // Check if they would overlap
      if (newObstacleBottom >= obstacleTop && newObstacleTop <= obstacleBottom) {
        return false; // Would overlap, can't spawn
      }
      
      // Check if there's enough spacing (for same lane, we want at least some spacing)
      // New obstacle is at the top, so check spacing to obstacles below
      if (newObstacleBottom < obstacleTop) {
        final double spacing = obstacleTop - newObstacleBottom;
        if (spacing < obstacleSize) { // At least one obstacle size of spacing
          return false; // Not enough spacing
        }
      }
    }
    
    // Determine the opposite lane
    int oppositeLane;
    if (lane == 0) {
      oppositeLane = 1;
    } else if (lane == 1) {
      oppositeLane = 0;
    } else if (lane == 2) {
      oppositeLane = 3;
    } else if (lane == 3) {
      oppositeLane = 2;
    } else {
      return true; // Invalid lane, but allow spawn
    }
    
    // Check if there are any obstacles in the opposite lane
    final oppositeLaneObstacles = obstacles.where((obs) => obs.lane == oppositeLane).toList();
    
    if (oppositeLaneObstacles.isEmpty) {
      // No obstacles in opposite lane, can spawn
      return true;
    }
    
    // Check if the new obstacle has enough spacing from all obstacles in the opposite lane
    for (var oppositeObstacle in oppositeLaneObstacles) {
      final double oppositeObstacleTop = oppositeObstacle.y;
      final double oppositeObstacleBottom = oppositeObstacle.y + oppositeObstacle.size;
      
      // Check if there's enough vertical spacing
      // The new obstacle will be at the top, so we need to check if there's
      // enough space between newObstacleBottom and oppositeObstacleTop
      // OR between oppositeObstacleBottom and newObstacleTop
      
      // Case 1: New obstacle is above the opposite obstacle
      if (newObstacleBottom < oppositeObstacleTop) {
        final double spacing = oppositeObstacleTop - newObstacleBottom;
        if (spacing < requiredSpacing) {
          return false; // Not enough spacing
        }
      }
      // Case 2: New obstacle would be below the opposite obstacle
      // (This shouldn't happen since we spawn at the top, but check anyway)
      else if (newObstacleTop > oppositeObstacleBottom) {
        final double spacing = newObstacleTop - oppositeObstacleBottom;
        if (spacing < requiredSpacing) {
          return false; // Not enough spacing
        }
      }
      // Case 3: They would overlap vertically (shouldn't happen, but safety check)
      else {
        return false; // Would overlap, can't spawn
      }
    }
    
    return true; // All checks passed
  }

  void _gameLoop() {
    if (isGameOver || isPaused) return;

    setState(() {
      // Spawn new obstacles randomly
      if (_random.nextDouble() < obstacleSpawnRate) {
        // Try to spawn in a random lane, but respect spacing rules
        List<int> lanes = [0, 1, 2, 3];
        lanes.shuffle(_random);
        
        for (int lane in lanes) {
          if (_canSpawnInLane(lane)) {
            final bool spawnStar = _random.nextDouble() < starSpawnChance;
            obstacles.add(Obstacle(
              lane: lane,
              y: -obstacleSize,
              size: obstacleSize,
              isStar: spawnStar,
            ));
            break; // Spawned successfully, exit loop
          }
        }
        // If no lane was available, skip spawning this frame
      }

      // Move obstacles down
      obstacles.forEach((obstacle) {
        obstacle.y += obstacleSpeed;
      });

      // Move lane dash offsets
      laneDashOffsets = laneDashOffsets
          .map((offset) =>
              (offset + obstacleSpeed) % (dashLength + dashGap))
          .toList();

      // Count and remove obstacles that made it to the bottom (increment score)
      int trianglesPassed = 0;
      obstacles.removeWhere((obstacle) {
        if (obstacle.y > screenHeight) {
          if (!obstacle.isStar) {
            trianglesPassed++;
          }
          return true;
        }
        return false;
      });
      score += trianglesPassed;

      // Check for collisions
      _checkCollisions();

      // Update immunity timer
      if (isImmune && _immunityEndTime != null) {
        final remaining =
            _immunityEndTime!.difference(DateTime.now()).inMilliseconds / 1000;
        if (remaining <= 0) {
          isImmune = false;
          immunityTimeLeft = 0;
          _immunityEndTime = null;
        } else {
          immunityTimeLeft = remaining;
        }
      }
    });
  }

  void _checkCollisions() {
    if (isGameOver || screenWidth == 0 || screenHeight == 0) return;

    final double laneWidth = screenWidth / 4;
    final double carHeight = laneWidth * 1.1;
    final double carY = screenHeight * 0.78;
    final double carBottom = carY + carHeight;

    for (int i = obstacles.length - 1; i >= 0; i--) {
      final obstacle = obstacles[i];

      bool collidedWithLeft =
          obstacle.lane == leftCarLane &&
          _isOverlap(obstacle.y, obstacle.y + obstacle.size, carY, carBottom);

      bool collidedWithRight =
          obstacle.lane == rightCarLane &&
          _isOverlap(obstacle.y, obstacle.y + obstacle.size, carY, carBottom);

      if (collidedWithLeft || collidedWithRight) {
        if (obstacle.isStar) {
          powerUpsCollected++;
          obstacles.removeAt(i);
          _activateImmunity();
        } else {
          if (isImmune) {
            score += 2;
            obstacles.removeAt(i);
          } else {
            _endGame();
            return;
          }
        }
      }
    }
  }

  bool _isOverlap(
    double aStart,
    double aEnd,
    double bStart,
    double bEnd,
  ) {
    return aEnd >= bStart && aStart <= bEnd;
  }

  void _activateImmunity() {
    isImmune = true;
    _immunityEndTime = DateTime.now().add(_immunityDuration);
    immunityTimeLeft = _immunityDuration.inSeconds.toDouble();
  }

  Future<void> _endGame() async {
    setState(() {
      isGameOver = true;
    });
    await _highScoreService.recordScore(widget.difficulty, score);
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverScreen(
        score: score,
        onRestart: _restartGame,
        onMainMenu: _goToMainMenu,
      ),
    );
  }

  void _restartGame() {
    Navigator.of(context).pop(); // Close game over dialog
    setState(() {
      obstacles.clear();
      leftCarLane = 0;
      rightCarLane = 2;
      isGameOver = false;
      isPaused = false;
      score = 0;
      laneDashOffsets = List.filled(4, 0.0);
      powerUpsCollected = 0;
      isImmune = false;
      immunityTimeLeft = 0;
      _immunityEndTime = null;
    });
  }

  void _goToMainMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (isGameOver) return;

    final double currentWidth =
        screenWidth > 0 ? screenWidth : MediaQuery.of(context).size.width;
    final double tapX = event.localPosition.dx;

    setState(() {
      // If tap is on left half of screen, swap left car between lanes 0 and 1
      if (tapX < currentWidth / 2) {
        leftCarLane = leftCarLane == 0 ? 1 : 0;
      }
      // If tap is on right half of screen, swap right car between lanes 2 and 3
      else {
        rightCarLane = rightCarLane == 2 ? 3 : 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _onPointerDown,
        child: Container(
          color: _laneTheme.backgroundColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Update screen dimensions
              screenWidth = constraints.maxWidth;
              screenHeight = constraints.maxHeight;
              final double safeTop = MediaQuery.of(context).padding.top;
              
              final double laneWidth = constraints.maxWidth / 4;
              final double carWidth = laneWidth * 0.7;
              final double carHeight = laneWidth * 1.1;
              final double carTop = screenHeight * 0.78;

              return Stack(
                children: [
                  // Draw lanes and animated dashed dividers
                  Positioned.fill(
                    child: CustomPaint(
                      painter: LaneBackgroundPainter(
                        laneCount: 4,
                        dashOffsets: laneDashOffsets,
                        dashLength: dashLength,
                        dashGap: dashGap,
                        dashWidth: dashWidth,
                        backgroundColors: _laneTheme.laneColors,
                        dividerColor: _laneTheme.dividerColor,
                        dashColor: _laneTheme.dashColor,
                      ),
                    ),
                  ),
                  // Draw obstacles (triangles / stars)
                  ...obstacles.map((obstacle) {
                    final triangleColor = isImmune
                        ? Colors.red.shade400
                        : Colors.orange.shade400;
                    return Positioned(
                      left: obstacle.lane * laneWidth + (laneWidth - obstacle.size) / 2,
                      top: obstacle.y,
                      child: CustomPaint(
                        size: Size(obstacle.size, obstacle.size),
                        painter: obstacle.isStar
                            ? StarPainter(
                                color: Colors.amber.shade300,
                              )
                            : TrianglePainter(
                                color: triangleColor,
                              ),
                      ),
                    );
                  }).toList(),
                  // Left car (rectangle) - Neon light blue
                  Positioned(
                    left: leftCarLane * laneWidth + laneWidth * 0.1,
                    top: carTop,
                    child: Container(
                      width: carWidth,
                      height: carHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9FF), // Neon light blue
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF00FFFF), // Brighter neon blue for border
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D9FF).withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
        ),
                        ],
                      ),
                    ),
                  ),
                  // Right car (rectangle) - Neon pink
                  Positioned(
                    left: rightCarLane * laneWidth + laneWidth * 0.1,
                    top: carTop,
                    child: Container(
                      width: carWidth,
                      height: carHeight,
        decoration: BoxDecoration(
                        color: const Color(0xFFFF1493), // Neon pink
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFFF00FF), // Brighter neon pink for border
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF1493).withOpacity(0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
            ],
          ),
        ),
                  ),
                  // Score display (top center)
                  Positioned(
                    top: safeTop + 16,
                    left: 0,
                    right: 0,
        child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
              ),
                        child: Text(
                          'Score: $score',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                            color: Colors.white,
                ),
              ),
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: safeTop + 12,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                ),
              ),
                  ),
                  if (isImmune)
                    Positioned(
                      top: safeTop + 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber.shade300,
              ),
                            const SizedBox(width: 8),
                            Text(
                              '${immunityTimeLeft.toStringAsFixed(1)}s',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                ),
              ),
            ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Draw triangle pointing down
    path.moveTo(size.width / 2, size.height); // Bottom point (tip)
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    canvas.drawPath(path, paint);

    // Add border
    final borderPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double halfWidth = size.width / 2;
    final double halfHeight = size.height / 2;
    final double top = 0;
    final double bottom = size.height;

    path
      ..moveTo(halfWidth, top)
      ..lineTo(halfWidth * 1.2, halfHeight * 0.7)
      ..lineTo(size.width, halfHeight * 0.8)
      ..lineTo(halfWidth * 1.4, halfHeight * 1.1)
      ..lineTo(halfWidth * 1.5, bottom)
      ..lineTo(halfWidth, halfHeight * 1.3)
      ..lineTo(halfWidth * 0.5, bottom)
      ..lineTo(halfWidth * 0.6, halfHeight * 1.1)
      ..lineTo(0, halfHeight * 0.8)
      ..lineTo(halfWidth * 0.8, halfHeight * 0.7)
      ..close();

    canvas.drawShadow(path, Colors.black, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LaneBackgroundPainter extends CustomPainter {
  final int laneCount;
  final List<double> dashOffsets;
  final double dashLength;
  final double dashGap;
  final double dashWidth;
  final List<Color> backgroundColors;
  final Color dividerColor;
  final Color dashColor;

  LaneBackgroundPainter({
    required this.laneCount,
    required this.dashOffsets,
    required this.dashLength,
    required this.dashGap,
    required this.dashWidth,
    required this.backgroundColors,
    required this.dividerColor,
    required this.dashColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final laneWidth = size.width / laneCount;
    final dividerPaint = Paint()
      ..color = dividerColor
      ..strokeWidth = 2;
    final dashPaint = Paint()..color = dashColor;

    for (int i = 0; i < laneCount; i++) {
      final lanePaint = Paint()
        ..color = backgroundColors[i % backgroundColors.length];
      final laneRect =
          Rect.fromLTWH(i * laneWidth, 0, laneWidth, size.height);
      canvas.drawRect(laneRect, lanePaint);

      if (i < laneCount - 1) {
        final dx = (i + 1) * laneWidth;
        canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), dividerPaint);
      }

      final centerX = i * laneWidth + laneWidth / 2;
      final dashOffset = dashOffsets.length > i ? dashOffsets[i] : 0.0;
      double y = -dashLength + dashOffset;
      while (y < size.height) {
        final dashRect = Rect.fromLTWH(
          centerX - dashWidth / 2,
          y,
          dashWidth,
          dashLength,
        );
        canvas.drawRect(dashRect, dashPaint);
        y += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant LaneBackgroundPainter oldDelegate) {
    return oldDelegate.dashOffsets != dashOffsets;
  }
}

class LaneTheme {
  final Color backgroundColor;
  final List<Color> laneColors;
  final Color dividerColor;
  final Color dashColor;

  const LaneTheme({
    required this.backgroundColor,
    required this.laneColors,
    required this.dividerColor,
    required this.dashColor,
  });
}

