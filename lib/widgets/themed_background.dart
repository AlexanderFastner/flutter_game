import 'dart:math';
import 'package:flutter/material.dart';

import '../services/theme_service.dart';

Widget buildThemedBackground(String themeId, {required Widget child}) {
  switch (themeId) {
    case AppThemeIds.neonRainGlitch:
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF02020A),
              Color(0xFF1B0033),
            ],
          ),
        ),
        child: CustomPaint(
          painter: NeonRainGlitchPainter(),
          child: child,
        ),
      );
    case AppThemeIds.neoTokyoSkyline:
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050019),
              Color(0xFF220042),
            ],
          ),
        ),
        child: CustomPaint(
          painter: NeoTokyoSkylinePainter(),
          child: child,
        ),
      );
    case AppThemeIds.cyberRoad:
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFF000811), // Darker blue background (darker than buildings)
        ),
        child: CustomPaint(
          painter: CyberRoadPainter(),
          child: child,
        ),
      );
    default:
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050019),
              Color(0xFF220042),
            ],
          ),
        ),
        child: CustomPaint(
          painter: NeoTokyoSkylinePainter(),
          child: child,
        ),
      );
  }
}

class NeonRainGlitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Vertical neon rain streaks
    final streakXs = [
      size.width * 0.15,
      size.width * 0.3,
      size.width * 0.45,
      size.width * 0.6,
      size.width * 0.75,
      size.width * 0.9,
    ];
    for (var x in streakXs) {
      paint.color = Colors.cyanAccent.withOpacity(0.35);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height * 0.6),
        paint,
      );
    }

    // Horizontal glitch bars
    final barPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.pinkAccent.withOpacity(0.25);

    final barHeights = [0.2, 0.35, 0.5, 0.65, 0.8];
    for (var h in barHeights) {
      final y = size.height * h;
      final width = size.width * 0.6;
      final left = size.width * 0.2;
      canvas.drawRect(
        Rect.fromLTWH(left, y, width, 6),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeoTokyoSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skylinePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF120026);
    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF00FFFF);
    final windowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFF176); // soft neon yellow

    final baseY = size.height;

    // Simple skyline rectangles (all same size), evenly spaced with equal gaps
    const double buildingWidth = 50.0;
    const double buildingHeight = 450.0;
    const double gap = 10.0;
    const int numBuildings = 9;
    
    // Calculate total width and starting position to center the skyline
    final double totalWidth = (numBuildings * buildingWidth) + ((numBuildings - 1) * gap);
    final double startX = (size.width - totalWidth) / 2;
    
    // Background buildings (taller, drawn first so they appear behind)
    const double backgroundBuildingWidth = 45.0;
    const double backgroundBuildingHeight = 600.0;
    final backgroundBuildings = <Rect>[];
    // Position background buildings between and slightly behind front buildings
    for (int i = 0; i < numBuildings - 1; i++) {
      final double x = startX + (i * (buildingWidth + gap)) + buildingWidth + (gap / 2) - (backgroundBuildingWidth / 2);
      backgroundBuildings.add(Rect.fromLTWH(x, baseY - backgroundBuildingHeight, backgroundBuildingWidth, backgroundBuildingHeight));
    }
    
    // Draw background buildings first (so they appear behind)
    for (final rect in backgroundBuildings) {
      canvas.drawRect(rect, skylinePaint);
      
      // Neon accent line at the very top edge
      final accentRect = Rect.fromLTWH(
        rect.left + 4,
        rect.top + 2,
        rect.width - 8,
        3,
      );
      canvas.drawRect(accentRect, accentPaint);
      
      // Windows for background buildings
      const double windowWidth = 3;
      const double windowHeight = 5;
      const double windowHGap = 5;
      const double windowVGap = 7;
      
      double y = rect.top + 14;
      while (y + windowHeight < rect.bottom - 6) {
        double x = rect.left + 5;
        while (x + windowWidth < rect.right - 4) {
          if (((x + y).toInt() ~/ 8) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(x, y, windowWidth, windowHeight),
              windowPaint,
            );
          }
          x += windowWidth + windowHGap;
        }
        y += windowHeight + windowVGap;
      }
    }
    
    // Foreground buildings (drawn on top)
    final buildings = <Rect>[];
    for (int i = 0; i < numBuildings; i++) {
      final double x = startX + (i * (buildingWidth + gap));
      buildings.add(Rect.fromLTWH(x, baseY - buildingHeight, buildingWidth, buildingHeight));
    }

    for (final rect in buildings) {
      canvas.drawRect(rect, skylinePaint);

      // Neon accent line at the very top edge of each building
      final accentRect = Rect.fromLTWH(
        rect.left + 4,
        rect.top + 2,
        rect.width - 8,
        3,
      );
      canvas.drawRect(accentRect, accentPaint);

      // Window grid: small yellow rectangles inside each building
      const double windowWidth = 4;
      const double windowHeight = 6;
      const double windowHGap = 6;
      const double windowVGap = 8;

      // Start a bit below the accent line
      double y = rect.top + 14;
      while (y + windowHeight < rect.bottom - 6) {
        double x = rect.left + 6;
        while (x + windowWidth < rect.right - 4) {
          // Randomly skip some windows for a more organic look
          // (simple pattern instead of real randomness for determinism)
          if (((x + y).toInt() ~/ 8) % 2 == 0) {
            canvas.drawRect(
              Rect.fromLTWH(x, y, windowWidth, windowHeight),
              windowPaint,
            );
          }
          x += windowWidth + windowHGap;
        }
        y += windowHeight + windowVGap;
      }
    }

    // Ground strip
    canvas.drawRect(
      Rect.fromLTWH(0, baseY, size.width, size.height - baseY),
      skylinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CyberRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Northern lights in the background
    _drawNorthernLights(canvas, size);
    
    // Buildings (drawn first so road appears on top)
    _drawBuildings(canvas, size);
    
    // Windy road down the center
    _drawRoad(canvas, size);
  }
  
  void _drawNorthernLights(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Create flowing northern lights with gradient effect
    final path1 = Path();
    path1.moveTo(0, size.height * 0.15);
    path1.quadraticBezierTo(
      size.width * 0.2, size.height * 0.2,
      size.width * 0.4, size.height * 0.17,
    );
    path1.quadraticBezierTo(
      size.width * 0.6, size.height * 0.23,
      size.width * 0.8, size.height * 0.19,
    );
    path1.lineTo(size.width, size.height * 0.25);
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x44FF00A8), // neon pink with transparency
        Color(0x33FF66C4), // lighter pink
        Color(0x220088FF), // neon blue
        Color(0x11000000), // fade to transparent
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));
    canvas.drawPath(path1, paint);
    
    // Second layer of northern lights
    final path2 = Path();
    path2.moveTo(0, size.height * 0.2);
    path2.quadraticBezierTo(
      size.width * 0.3, size.height * 0.25,
      size.width * 0.5, size.height * 0.21,
    );
    path2.quadraticBezierTo(
      size.width * 0.7, size.height * 0.27,
      size.width, size.height * 0.23,
    );
    path2.lineTo(size.width, size.height * 0.3);
    path2.lineTo(0, size.height * 0.3);
    path2.close();
    
    paint.shader = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0x33FF0088), // neon pink
        Color(0x22FF66C4), // lighter pink
        Color(0x110088FF), // neon blue
        Color(0x00000000), // fade to transparent
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));
    canvas.drawPath(path2, paint);
    
    // Third subtle layer for depth
    final path3 = Path();
    path3.moveTo(0, size.height * 0.1);
    path3.quadraticBezierTo(
      size.width * 0.4, size.height * 0.18,
      size.width * 0.6, size.height * 0.14,
    );
    path3.quadraticBezierTo(
      size.width * 0.8, size.height * 0.2,
      size.width, size.height * 0.16,
    );
    path3.lineTo(size.width, size.height * 0.22);
    path3.lineTo(0, size.height * 0.22);
    path3.close();
    
    paint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x22FF66C4), // lighter pink
        Color(0x11FF00A8), // neon pink
        Color(0x00000000), // fade to transparent
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));
    canvas.drawPath(path3, paint);
  }
  
  void _drawBuildings(Canvas canvas, Size size) {
    final buildingPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF001122);
    
    // Window colors: green, blue, and turquoise
    final windowColors = [
      const Color(0xFF00FF88), // green
      const Color(0xFF0088FF), // blue
      const Color(0xFF00FFFF), // turquoise
    ];
    
    const double baseOffset = 100.0; // Shift bottom up by 100 pixels
    const double centerGap = 0.4; // Leave 40% of screen width in the middle for road
    
    // Buildings on the left side (staggered heights)
    final leftBuildings = [
      Rect.fromLTWH(size.width * 0.02, size.height * 0.2 - baseOffset, 35, size.height * 0.5),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.15 - baseOffset, 42, size.height * 0.55),
      Rect.fromLTWH(size.width * 0.15, size.height * 0.25 - baseOffset, 38, size.height * 0.45),
      Rect.fromLTWH(size.width * 0.22, size.height * 0.18 - baseOffset, 45, size.height * 0.52),
      Rect.fromLTWH(size.width * 0.28, size.height * 0.22 - baseOffset, 40, size.height * 0.48),
    ];
    
    // Buildings on the right side (staggered heights)
    final rightBuildings = [
      Rect.fromLTWH(size.width * 0.72, size.height * 0.19 - baseOffset, 43, size.height * 0.51),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.24 - baseOffset, 37, size.height * 0.47),
      Rect.fromLTWH(size.width * 0.85, size.height * 0.16 - baseOffset, 46, size.height * 0.54),
      Rect.fromLTWH(size.width * 0.92, size.height * 0.21 - baseOffset, 39, size.height * 0.49),
      Rect.fromLTWH(size.width * 0.96, size.height * 0.17 - baseOffset, 41, size.height * 0.53),
    ];
    
    final allBuildings = [...leftBuildings, ...rightBuildings];
    
    // Draw existing buildings first (so they appear behind)
    for (final building in allBuildings) {
      _drawBuilding(canvas, building, buildingPaint, windowColors);
    }
    
    // Add smaller buildings in front, split on both sides of the road
    // Left side buildings (positioned left of center road)
    final frontLeftBuildings = [
      Rect.fromLTWH(size.width * 0.15, size.height * 0.45 - baseOffset + 200, 45, size.height * 0.25),
      Rect.fromLTWH(size.width * 0.22, size.height * 0.5 - baseOffset + 200, 45, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.08, size.height * 0.48 - baseOffset + 200, 45, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.18, size.height * 0.37 - baseOffset + 200, 45, size.height * 0.22),
      Rect.fromLTWH(size.width * 0.12, size.height * 0.55 - baseOffset + 200, 45, size.height * 0.21),
    ];
    
    // Right side buildings (positioned right of center road)
    final frontRightBuildings = [
      Rect.fromLTWH(size.width * 0.74 - 50, size.height * 0.45 - baseOffset + 200, 45, size.height * 0.25),
      Rect.fromLTWH(size.width * 0.82 - 34, size.height * 0.5 - baseOffset + 200, 45, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.89 - 65, size.height * 0.48 - baseOffset + 200, 45, size.height * 0.15),
      Rect.fromLTWH(size.width * 0.71 - 74, size.height * 0.37 - baseOffset + 200, 45, size.height * 0.22),
      Rect.fromLTWH(size.width * 0.80 - 45, size.height * 0.55 - baseOffset + 200, 45, size.height * 0.21),
      // 5 additional buildings on right side
      Rect.fromLTWH(size.width * 0.75, size.height * 0.42 - baseOffset + 200, 40, size.height * 0.18),
      Rect.fromLTWH(size.width * 0.83, size.height * 0.52 - baseOffset + 200, 38, size.height * 0.19),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.58 - baseOffset + 200, 42, size.height * 0.16),
      Rect.fromLTWH(size.width * 0.86, size.height * 0.40 - baseOffset + 200, 36, size.height * 0.20),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.50 - baseOffset + 200, 44, size.height * 0.17),
    ];
    
    // Draw smaller buildings on top (in front) - left side first, then right side
    for (final building in frontLeftBuildings) {
      _drawBuilding(canvas, building, buildingPaint, windowColors);
    }
    for (final building in frontRightBuildings) {
      _drawBuilding(canvas, building, buildingPaint, windowColors);
    }
  }
  
  void _drawBuilding(Canvas canvas, Rect building, Paint buildingPaint, List<Color> windowColors) {
    canvas.drawRect(building, buildingPaint);
    
    // Add windows all the way up and down the buildings
    const double windowSpacing = 12.0;
    const double windowHeight = 8.0;
    const double windowWidth = 6.0;
    const double windowStartY = 5.0; // Start very close to top
    const double windowHGap = 6.0;
    
    // Calculate how many rows fit - fill the entire building height
    final int numRows = ((building.height - windowStartY - 5) / (windowHeight + windowSpacing)).floor();
    
    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < 3; col++) {
        // Vary window color based on position
        final colorIndex = (row + col) % windowColors.length;
        final windowPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = windowColors[colorIndex];
        
        canvas.drawRect(
          Rect.fromLTWH(
            building.left + 8 + (col * (windowWidth + windowHGap)),
            building.top + windowStartY + (row * (windowHeight + windowSpacing)),
            windowWidth,
            windowHeight,
          ),
          windowPaint,
        );
      }
    }
  }
  
  void _drawRoad(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF1A1A2E);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFD700); // gold/yellow road lines
    
    // Windy road down the center converging to a point in the distance
    // Start wide at the bottom, narrow at the top (perspective)
    final roadPath = Path();
    
    // Bottom of screen - road is wider
    final bottomLeft = Offset(size.width * 0.3, size.height);
    final bottomRight = Offset(size.width * 0.7, size.height);
    
    // Top of screen - road converges to a point at the bottom of northern lights
    final vanishingPoint = Offset(size.width * 0.5, size.height * 0.3);
    
    // Create smooth winding road using cubic bezier curves
    // Define the center line path with smooth curves
    final centerLinePath = Path();
    centerLinePath.moveTo(size.width * 0.5, size.height);
    
    // Use cubic bezier curves for smooth winding effect
    centerLinePath.cubicTo(
      size.width * 0.48, size.height * 0.9,  // control point 1
      size.width * 0.44, size.height * 0.75, // control point 2
      size.width * 0.45, size.height * 0.6,   // end point (curve left)
    );
    centerLinePath.cubicTo(
      size.width * 0.46, size.height * 0.5,  // control point 1
      size.width * 0.52, size.height * 0.45, // control point 2
      size.width * 0.55, size.height * 0.4,  // end point (curve right)
    );
    centerLinePath.cubicTo(
      size.width * 0.54, size.height * 0.35, // control point 1
      size.width * 0.48, size.height * 0.32, // control point 2
      vanishingPoint.dx, vanishingPoint.dy,   // end at vanishing point
    );
    
    // Draw the road by creating parallel curves for left and right edges
    // Use a stroke-based approach for smooth curves
    final roadStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.2 // wide at bottom
      ..color = const Color(0xFF1A1A2E)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Create a gradient stroke width (narrower at top)
    // We'll draw multiple strokes with decreasing width
    final strokes = [
      (size.width * 0.2, size.height * 0.0),   // bottom
      (size.width * 0.18, size.height * 0.2),
      (size.width * 0.15, size.height * 0.4),
      (size.width * 0.12, size.height * 0.6),
      (size.width * 0.08, size.height * 0.8),
      (size.width * 0.03, size.height * 0.95), // near top
    ];
    
    // Draw road as filled path by creating left and right edges
    // Sample points along the center line
    final metrics = centerLinePath.computeMetrics();
    final samplePoints = <Offset>[];
    for (final metric in metrics) {
      for (double t = 0.0; t <= 1.0; t += 0.02) {
        final tangent = metric.getTangentForOffset(metric.length * t);
        if (tangent != null) {
          samplePoints.add(tangent.position);
        }
      }
    }
    
    // Build road edges with varying width
    final leftEdge = <Offset>[];
    final rightEdge = <Offset>[];
    
    for (int i = 0; i < samplePoints.length; i++) {
      final point = samplePoints[i];
      final progress = i / samplePoints.length;
      final width = size.width * 0.2 * (1 - progress * 0.85); // narrows from 20% to 3%
      
      // Calculate perpendicular direction
      Offset direction;
      if (i < samplePoints.length - 1) {
        final next = samplePoints[i + 1];
        direction = Offset(next.dx - point.dx, next.dy - point.dy);
      } else if (i > 0) {
        final prev = samplePoints[i - 1];
        direction = Offset(point.dx - prev.dx, point.dy - prev.dy);
      } else {
        direction = const Offset(0, -1);
      }
      
      // Normalize and get perpendicular
      final length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy);
      if (length > 0) {
        direction = Offset(direction.dx / length, direction.dy / length);
      }
      final perpendicular = Offset(-direction.dy, direction.dx);
      
      leftEdge.add(Offset(point.dx - perpendicular.dx * width / 2, point.dy - perpendicular.dy * width / 2));
      rightEdge.add(Offset(point.dx + perpendicular.dx * width / 2, point.dy + perpendicular.dy * width / 2));
    }
    
    // Draw road as filled path
    roadPath.moveTo(leftEdge[0].dx, leftEdge[0].dy);
    for (int i = 1; i < leftEdge.length; i++) {
      roadPath.lineTo(leftEdge[i].dx, leftEdge[i].dy);
    }
    // Connect to right edge
    for (int i = rightEdge.length - 1; i >= 0; i--) {
      roadPath.lineTo(rightEdge[i].dx, rightEdge[i].dy);
    }
    roadPath.close();
    
    canvas.drawPath(roadPath, roadPaint);
    
    // Draw dashed center line
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFFFD700);
    
    // Simple dashed effect - draw segments (reuse metrics from above)
    for (final metric in metrics) {
      double distance = 0;
      const double dashLength = 20;
      const double dashGap = 15;
      
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance)?.position;
        distance += dashLength;
        final end = metric.getTangentForOffset(distance)?.position;
        
        if (start != null && end != null && distance <= metric.length) {
          final dashPath = Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(end.dx, end.dy);
          canvas.drawPath(dashPath, dashPaint);
        }
        distance += dashGap;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
