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

    // Simple skyline rectangles (very tall buildings), centered horizontally with larger gaps
    final buildings = [
      Rect.fromLTWH(size.width * 0.06 - 30, baseY - 320, 60, 320),
      Rect.fromLTWH(size.width * 0.22 - 37.5, baseY - 480, 75, 480),
      Rect.fromLTWH(size.width * 0.40 - 33.75, baseY - 400, 67.5, 400),
      Rect.fromLTWH(size.width * 0.60 - 41.25, baseY - 560, 82.5, 560),
      Rect.fromLTWH(size.width * 0.78 - 37.5, baseY - 440, 75, 440),
      Rect.fromLTWH(size.width * 0.94 - 30, baseY - 360, 60, 360),
    ];

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
