import 'dart:math';
import 'package:flutter/material.dart';
import 'game_over_screen.dart';

class Obstacle {
  int lane; // 0, 1, 2, or 3
  double y; // Vertical position
  double size;

  Obstacle({
    required this.lane,
    required this.y,
    required this.size,
  });
}

class GameScreen extends StatefulWidget {
  final String difficulty;
  final String map;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.map,
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
  late AnimationController _animationController;
  final Random _random = Random();
  
  // Screen dimensions (updated in build)
  double screenWidth = 0;
  double screenHeight = 0;
  
  // Game parameters
  double obstacleSpeed = 2.0; // pixels per frame
  double obstacleSpawnRate = 0.02; // probability per frame
  double obstacleSize = 40.0;

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
            obstacles.add(Obstacle(
              lane: lane,
              y: -obstacleSize,
              size: obstacleSize,
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

      // Remove obstacles that are off screen
      obstacles.removeWhere((obstacle) => obstacle.y > screenHeight);

      // Check for collisions
      _checkCollisions();
    });
  }

  void _checkCollisions() {
    if (isGameOver || screenWidth == 0 || screenHeight == 0) return;

    final double laneWidth = screenWidth / 4;
    final double carY = screenHeight * 0.8;
    final double carSize = laneWidth * 0.8;

    for (var obstacle in obstacles) {
      // Check collision with left car
      if (obstacle.lane == leftCarLane) {
        final double obstacleBottom = obstacle.y + obstacle.size;
        final double carTop = carY;
        final double carBottom = carY + carSize;

        if (obstacleBottom >= carTop && obstacle.y <= carBottom) {
          _endGame();
          return;
        }
      }

      // Check collision with right car
      if (obstacle.lane == rightCarLane) {
        final double obstacleBottom = obstacle.y + obstacle.size;
        final double carTop = carY;
        final double carBottom = carY + carSize;

        if (obstacleBottom >= carTop && obstacle.y <= carBottom) {
          _endGame();
          return;
        }
      }
    }
  }

  void _endGame() {
    setState(() {
      isGameOver = true;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverScreen(
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
    });
  }

  void _goToMainMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _onTapDown(TapDownDetails details) {
    if (isGameOver) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(details.globalPosition);
    final double screenWidth = MediaQuery.of(context).size.width;

    setState(() {
      // If tap is on left half of screen, swap left car between lanes 0 and 1
      if (localPosition.dx < screenWidth / 2) {
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
      appBar: AppBar(
        title: const Text('TwoCars'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTapDown: _onTapDown,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Update screen dimensions
              screenWidth = constraints.maxWidth;
              screenHeight = constraints.maxHeight;
              
              final double laneWidth = constraints.maxWidth / 4;
              
              return Stack(
                children: [
                  // Draw 4 lanes with dividers
                  Row(
                    children: List.generate(4, (index) {
                      return Container(
                        width: laneWidth,
                        height: screenHeight,
                        decoration: BoxDecoration(
                          color: index % 2 == 0
                              ? Colors.grey.shade800
                              : Colors.grey.shade700,
                          border: Border(
                            right: BorderSide(
                              color: Colors.grey.shade600,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Draw obstacles (triangles)
                  ...obstacles.map((obstacle) {
                    return Positioned(
                      left: obstacle.lane * laneWidth + (laneWidth - obstacle.size) / 2,
                      top: obstacle.y,
                      child: CustomPaint(
                        size: Size(obstacle.size, obstacle.size),
                        painter: TrianglePainter(
                          color: Colors.orange.shade400,
                        ),
                      ),
                    );
                  }).toList(),
                  // Left car (square)
                  Positioned(
                    left: leftCarLane * laneWidth + laneWidth * 0.1,
                    top: screenHeight * 0.8,
                    child: Container(
                      width: laneWidth * 0.8,
                      height: laneWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.blue.shade300,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  // Right car (square)
                  Positioned(
                    left: rightCarLane * laneWidth + laneWidth * 0.1,
                    top: screenHeight * 0.8,
                    child: Container(
                      width: laneWidth * 0.8,
                      height: laneWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.red.shade300,
                          width: 2,
                        ),
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
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
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

