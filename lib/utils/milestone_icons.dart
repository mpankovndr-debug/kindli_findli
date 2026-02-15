import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'milestone_tracker.dart';

/// Custom painters for milestone icons
/// Both Journey and Habits categories use the same flower progression (6 stages)
/// All icons have stem + leaves at base + flower at top

/// Get the appropriate icon painter for a milestone
/// Uses position-based mapping (1-6) for both categories
CustomPainter getMilestoneIconPainter(Milestone milestone, bool isEarned) {
  // Get position (1-6) based on milestone order within its category
  final category = MilestoneTracker.getCategory(milestone);
  final milestones = MilestoneTracker.getMilestonesByCategory(category);
  final position = milestones.indexOf(milestone) + 1;

  // Both categories use the same flower progression based on position
  switch (position) {
    case 1:
      return FlowerIcon1Painter(isEarned: isEarned); // 7 days: Three petals
    case 2:
      return FlowerIcon2Painter(isEarned: isEarned); // 14 days: Tulip bud
    case 3:
      return FlowerIcon3Painter(isEarned: isEarned); // 30 days: Opening
    case 4:
      return FlowerIcon4Painter(isEarned: isEarned); // 60 days: Half-open
    case 5:
      return FlowerIcon5Painter(isEarned: isEarned); // 90 days: Nearly full
    case 6:
      return FlowerIcon6Painter(isEarned: isEarned); // 1 year: Peak bloom
    default:
      return FlowerIcon1Painter(isEarned: isEarned);
  }
}

//
// HELPER METHODS - Stem and Leaves (used by all icons)
//

void drawStemAndLeaves(Canvas canvas, Size size, double opacity) {
  final center = Offset(size.width / 2, size.height / 2);
  final stemColor = const Color(0xFF8B9B88).withOpacity(opacity);
  final leafColor = const Color(0xFF9AA896).withOpacity(opacity);

  // Draw stem (vertical line from bottom to center)
  final stemPaint = Paint()
    ..color = stemColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    Offset(center.dx, size.height * 0.85),
    Offset(center.dx, center.dy + 2),
    stemPaint,
  );

  // Draw left leaf at base
  final leftLeafPath = Path()
    ..moveTo(center.dx, size.height * 0.70)
    ..quadraticBezierTo(
      center.dx - 8,
      size.height * 0.72,
      center.dx - 10,
      size.height * 0.78,
    )
    ..quadraticBezierTo(
      center.dx - 6,
      size.height * 0.76,
      center.dx,
      size.height * 0.70,
    );

  final leafPaint = Paint()
    ..color = leafColor
    ..style = PaintingStyle.fill;

  canvas.drawPath(leftLeafPath, leafPaint);

  // Draw right leaf at base
  final rightLeafPath = Path()
    ..moveTo(center.dx, size.height * 0.75)
    ..quadraticBezierTo(
      center.dx + 8,
      size.height * 0.77,
      center.dx + 10,
      size.height * 0.83,
    )
    ..quadraticBezierTo(
      center.dx + 6,
      size.height * 0.81,
      center.dx,
      size.height * 0.75,
    );

  canvas.drawPath(rightLeafPath, leafPaint);
}

//
// FLOWER ICONS (Used by both Journey and Habits categories)
//

/// Flower Icon 1 - Three petals (7 days design)
class FlowerIcon1Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon1Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final petalColor = const Color(0xFFE0B5A8).withOpacity(opacity);
    final petalDark = const Color(0xFFD4A09A).withOpacity(opacity);

    // Draw 3 petals at top (clover arrangement)
    for (int i = 0; i < 3; i++) {
      final angle = (i * 120.0 - 90) * math.pi / 180.0;

      final petalCenter = Offset(
        center.dx + 6 * math.cos(angle),
        center.dy - 8 + 6 * math.sin(angle),
      );

      final petalPaint = Paint()
        ..shader = RadialGradient(
          colors: [petalColor, petalDark],
          radius: 0.7,
        ).createShader(
          Rect.fromCircle(center: petalCenter, radius: 6),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(petalCenter, 6, petalPaint);
    }

    // Draw small center
    final centerPaint = Paint()
      ..color = const Color(0xFFF4D4A8).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 8), 2.5, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerIcon1Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}

/// Flower Icon 2 - Tulip bud (14 days design)
class FlowerIcon2Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon2Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final budColor = const Color(0xFFE0B5A8).withOpacity(opacity);
    final budDark = const Color(0xFFD4A09A).withOpacity(opacity);

    // Draw closed tulip bud (elongated vertical oval)
    final budPath = Path()
      ..moveTo(center.dx, center.dy - 15)
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - 12,
        center.dx + 4,
        center.dy - 2,
      )
      ..quadraticBezierTo(
        center.dx + 2,
        center.dy + 2,
        center.dx,
        center.dy + 3,
      )
      ..quadraticBezierTo(
        center.dx - 2,
        center.dy + 2,
        center.dx - 4,
        center.dy - 2,
      )
      ..quadraticBezierTo(
        center.dx - 5,
        center.dy - 12,
        center.dx,
        center.dy - 15,
      );

    final budPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [budColor, budDark],
      ).createShader(
        Rect.fromLTRB(
          center.dx - 5,
          center.dy - 15,
          center.dx + 5,
          center.dy + 3,
        ),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(budPath, budPaint);
  }

  @override
  bool shouldRepaint(FlowerIcon2Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}

/// Flower Icon 3 - Opening tulip (30 days design)
class FlowerIcon3Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon3Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final petalColor1 = const Color(0xFFE0B5A8).withOpacity(opacity);
    final petalColor2 = const Color(0xFFD4A09A).withOpacity(opacity);
    final centerColor = const Color(0xFFF4D4A8).withOpacity(opacity);

    // Draw 4 petals slightly opening
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90.0 - 90) * math.pi / 180.0;

      final petalPath = Path();
      final baseX = center.dx + 1.5 * math.cos(angle);
      final baseY = center.dy - 6 + 1.5 * math.sin(angle);

      final tipX = center.dx + 9 * math.cos(angle);
      final tipY = center.dy - 6 + 9 * math.sin(angle);

      final leftX = center.dx + 6 * math.cos(angle - 0.4);
      final leftY = center.dy - 6 + 6 * math.sin(angle - 0.4);

      final rightX = center.dx + 6 * math.cos(angle + 0.4);
      final rightY = center.dy - 6 + 6 * math.sin(angle + 0.4);

      petalPath.moveTo(baseX, baseY);
      petalPath.quadraticBezierTo(leftX, leftY, tipX, tipY);
      petalPath.quadraticBezierTo(rightX, rightY, baseX, baseY);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [petalColor1, petalColor2],
        ).createShader(
          Rect.fromCircle(center: Offset(tipX, tipY), radius: 8),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, petalPaint);
    }

    // Draw center
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 6), 3, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerIcon3Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}

/// Flower Icon 4 - Half-open flower (60 days design)
class FlowerIcon4Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon4Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final petalColor1 = const Color(0xFFE0B5A8).withOpacity(opacity);
    final petalColor2 = const Color(0xFFD4A09A).withOpacity(opacity);
    final centerColor = const Color(0xFFF4D4A8).withOpacity(opacity);

    // Draw 5 petals more open
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72.0 - 90) * math.pi / 180.0;
      final petalPath = Path();

      final startX = center.dx + 2.5 * math.cos(angle);
      final startY = center.dy - 6 + 2.5 * math.sin(angle);

      final controlX1 = center.dx + 9 * math.cos(angle - 0.35);
      final controlY1 = center.dy - 6 + 9 * math.sin(angle - 0.35);

      final endX = center.dx + 11 * math.cos(angle);
      final endY = center.dy - 6 + 11 * math.sin(angle);

      final controlX2 = center.dx + 9 * math.cos(angle + 0.35);
      final controlY2 = center.dy - 6 + 9 * math.sin(angle + 0.35);

      petalPath.moveTo(startX, startY);
      petalPath.quadraticBezierTo(controlX1, controlY1, endX, endY);
      petalPath.quadraticBezierTo(controlX2, controlY2, startX, startY);

      final petalPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [petalColor1, petalColor2],
        ).createShader(
          Rect.fromCircle(center: Offset(endX, endY), radius: 9),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, petalPaint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 6), 4, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerIcon4Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}

/// Flower Icon 5 - Nearly full flower (90 days design)
class FlowerIcon5Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon5Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final petalColor1 = const Color(0xFFE0B5A8).withOpacity(opacity);
    final petalColor2 = const Color(0xFFD4A09A).withOpacity(opacity);
    final centerColor = const Color(0xFFF4D4A8).withOpacity(opacity);

    // Draw 6 petals nearly fully open
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60.0 - 90) * math.pi / 180.0;
      final petalPath = Path();

      final startX = center.dx + 2.5 * math.cos(angle);
      final startY = center.dy - 6 + 2.5 * math.sin(angle);

      final controlX1 = center.dx + 10 * math.cos(angle - 0.3);
      final controlY1 = center.dy - 6 + 10 * math.sin(angle - 0.3);

      final endX = center.dx + 12 * math.cos(angle);
      final endY = center.dy - 6 + 12 * math.sin(angle);

      final controlX2 = center.dx + 10 * math.cos(angle + 0.3);
      final controlY2 = center.dy - 6 + 10 * math.sin(angle + 0.3);

      petalPath.moveTo(startX, startY);
      petalPath.quadraticBezierTo(controlX1, controlY1, endX, endY);
      petalPath.quadraticBezierTo(controlX2, controlY2, startX, startY);

      final petalPaint = Paint()
        ..shader = RadialGradient(
          colors: [petalColor1, petalColor2],
          radius: 0.8,
        ).createShader(
          Rect.fromCircle(center: Offset(endX, endY), radius: 10),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, petalPaint);
    }

    // Draw larger center circle
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 6), 5, centerPaint);
  }

  @override
  bool shouldRepaint(FlowerIcon5Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}

/// Flower Icon 6 - Peak bloom (1 year design)
class FlowerIcon6Painter extends CustomPainter {
  final bool isEarned;

  FlowerIcon6Painter({required this.isEarned});

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = isEarned ? 1.0 : 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw stem and leaves first
    drawStemAndLeaves(canvas, size, opacity);

    // Warm terracotta color palette
    final petalColor1 = const Color(0xFFE0B5A8).withOpacity(opacity);
    final petalColor2 = const Color(0xFFD4A09A).withOpacity(opacity);
    final centerColor = const Color(0xFFF4D4A8).withOpacity(opacity);

    // Draw 8 petals fully open (peak bloom)
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0 - 90) * math.pi / 180.0;
      final petalPath = Path();

      final startX = center.dx + 2.5 * math.cos(angle);
      final startY = center.dy - 6 + 2.5 * math.sin(angle);

      final controlX1 = center.dx + 11 * math.cos(angle - 0.25);
      final controlY1 = center.dy - 6 + 11 * math.sin(angle - 0.25);

      final endX = center.dx + 13 * math.cos(angle);
      final endY = center.dy - 6 + 13 * math.sin(angle);

      final controlX2 = center.dx + 11 * math.cos(angle + 0.25);
      final controlY2 = center.dy - 6 + 11 * math.sin(angle + 0.25);

      petalPath.moveTo(startX, startY);
      petalPath.quadraticBezierTo(controlX1, controlY1, endX, endY);
      petalPath.quadraticBezierTo(controlX2, controlY2, startX, startY);

      final petalPaint = Paint()
        ..shader = RadialGradient(
          colors: [petalColor1, petalColor2],
          radius: 0.7,
        ).createShader(
          Rect.fromCircle(center: Offset(endX, endY), radius: 11),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(petalPath, petalPaint);
    }

    // Draw detailed center with multiple circles
    final centerPaint = Paint()
      ..color = centerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 6), 6, centerPaint);

    // Draw center details (small dots in a ring)
    final dotPaint = Paint()
      ..color = const Color(0xFFD4A67B).withOpacity(opacity)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45.0) * math.pi / 180.0;
      final dotX = center.dx + 3 * math.cos(angle);
      final dotY = center.dy - 6 + 3 * math.sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), 0.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(FlowerIcon6Painter oldDelegate) =>
      oldDelegate.isEarned != isEarned;
}
