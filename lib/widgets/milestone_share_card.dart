import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// Spec brand colors
const _deepBrown = Color(0xFF3D2E1F);
const _warmClay = Color(0xFFC4A98C);
const _mutedSage = Color(0xFFB5C4B1);
const _softSand = Color(0xFFE8DDD3);
const _sageGradientStart = Color(0xFFF2F5F0);

class MilestoneShareCard extends StatelessWidget {
  final int weekCount;
  final String weeksText;
  final String subtitleText;
  final String taglineText;

  const MilestoneShareCard({
    super.key,
    required this.weekCount,
    required this.weeksText,
    required this.subtitleText,
    required this.taglineText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          // == BACKGROUND LAYER ==

          // 0. Solid opaque base to prevent transparency
          Positioned.fill(
            child: Container(color: _sageGradientStart),
          ),

          // 1. Base gradient (~155° angle)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.5, -0.85),
                  end: const Alignment(0.5, 0.85),
                  colors: [
                    _sageGradientStart,
                    _mutedSage.withOpacity(0.33),
                    _softSand.withOpacity(0.53),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient depth blobs
          Positioned(
            top: 160,
            left: -60,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _mutedSage.withOpacity(0.40),
                    blurRadius: 210,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 320,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _mutedSage.withOpacity(0.35),
                    blurRadius: 200,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 650,
            right: 180,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _mutedSage.withOpacity(0.32),
                    blurRadius: 190,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // 3. Flowing curves (3 ribbons, one sage-tinted)
          Positioned.fill(
            child: CustomPaint(
              painter: _FlowingCurvesPainter(),
            ),
          ),

          // 4. Decorative vine art (organic vine + leaf offshoots + growth rings)
          Positioned.fill(
            child: CustomPaint(
              painter: _DecorativeVinePainter(),
            ),
          ),

          // 5. Radial glow behind hero number — centered
          Positioned(
            left: 1080 / 2 - 220,
            top: 450,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 440,
                height: 440,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withOpacity(0.15),
                ),
              ),
            ),
          ),

          // == CONTENT LAYER — center-aligned ==
          Positioned(
            left: 80,
            top: 200,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glass badge — 100→300px circle with organic leaf/seed shape
                _buildGlassBadge(),
                const SizedBox(height: 60),

                // "4 weeks" — Playfair Display 72→216px, weight 600, gradient text
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_deepBrown, _warmClay],
                  ).createShader(bounds),
                  child: Text(
                    '$weekCount $weeksText',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 216,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                      height: 1.0,
                      letterSpacing: -0.02 * 216,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // "of being gentle with myself" — Inter 17→51px, deep brown at 65%
                SizedBox(
                  width: 600,
                  child: Text(
                    subtitleText,
                    style: GoogleFonts.inter(
                      fontSize: 51,
                      fontWeight: FontWeight.w400,
                      color: _deepBrown.withOpacity(0.65),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Glassmorphism pill — centered
          Positioned(
            left: 0,
            right: 0,
            top: 1380,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: CupertinoColors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.08),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _mutedSage,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          taglineText,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w400,
                            color: _deepBrown.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom branding
          Positioned(
            left: 0,
            right: 0,
            bottom: 240,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/kindli_icon.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'INTENDED',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 5,
                    color: _deepBrown.withOpacity(0.60),
                    fontFeatures: const [FontFeature.enable('smcp')],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Glass badge: 100→300px circle with abstract leaf/seed SVG shape
  Widget _buildGlassBadge() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: CupertinoColors.white.withOpacity(0.2),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _mutedSage.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(150, 150),
          painter: _LeafSeedPainter(),
        ),
      ),
    );
  }
}

/// Abstract leaf/seed organic shape in muted sage
class _LeafSeedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Leaf/seed shape
    final paint = Paint()
      ..color = _mutedSage.withOpacity(0.60)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..cubicTo(w * 0.75, h * 0.15, w * 0.9, h * 0.4, w * 0.85, h * 0.65)
      ..cubicTo(w * 0.8, h * 0.85, w * 0.6, h * 0.95, w * 0.5, h * 0.95)
      ..cubicTo(w * 0.4, h * 0.95, w * 0.2, h * 0.85, w * 0.15, h * 0.65)
      ..cubicTo(w * 0.1, h * 0.4, w * 0.25, h * 0.15, w * 0.5, h * 0.05)
      ..close();
    canvas.drawPath(path, paint);

    // Central vein
    final veinPaint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final veinPath = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..cubicTo(w * 0.5, h * 0.4, w * 0.5, h * 0.6, w * 0.5, h * 0.85);
    canvas.drawPath(veinPath, veinPaint);

    // Side veins
    final sideVeinPaint = Paint()
      ..color = CupertinoColors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Left veins
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.35)
        ..cubicTo(w * 0.4, h * 0.32, w * 0.3, h * 0.35, w * 0.25, h * 0.42),
      sideVeinPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.55)
        ..cubicTo(w * 0.4, h * 0.52, w * 0.3, h * 0.55, w * 0.22, h * 0.62),
      sideVeinPaint,
    );

    // Right veins
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.35)
        ..cubicTo(w * 0.6, h * 0.32, w * 0.7, h * 0.35, w * 0.75, h * 0.42),
      sideVeinPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.55)
        ..cubicTo(w * 0.6, h * 0.52, w * 0.7, h * 0.55, w * 0.78, h * 0.62),
      sideVeinPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws 3 flowing bezier curves — white at 18-28% + one sage-tinted
class _FlowingCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curve 1 — widest sweep, white at 26%
    final paint1 = Paint()
      ..color = CupertinoColors.white.withOpacity(0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(w * -0.05, h * 0.85)
      ..cubicTo(
        w * 0.25, h * 0.65,
        w * 0.55, h * 0.45,
        w * 1.05, h * 0.20,
      );
    canvas.drawPath(path1, paint1);

    // Curve 2 — middle sweep, sage-tinted at 22%
    final paint2 = Paint()
      ..color = _mutedSage.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path2 = Path()
      ..moveTo(w * -0.10, h * 0.72)
      ..cubicTo(
        w * 0.30, h * 0.58,
        w * 0.60, h * 0.38,
        w * 1.10, h * 0.12,
      );
    canvas.drawPath(path2, paint2);

    // Curve 3 — tightest sweep, white at 20%
    final paint3 = Paint()
      ..color = CupertinoColors.white.withOpacity(0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path3 = Path()
      ..moveTo(w * 0.05, h * 0.95)
      ..cubicTo(
        w * 0.35, h * 0.72,
        w * 0.65, h * 0.50,
        w * 1.08, h * 0.30,
      );
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Organic vine path + 3 leaf offshoots (12-15% opacity) + 3 growth-ring circles (3-8%)
class _DecorativeVinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Vine path (sage, 18% opacity)
    final vinePaint = Paint()
      ..color = _mutedSage.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final vinePath = Path()
      ..moveTo(w * 0.80, h * 0.88)
      ..cubicTo(
        w * 0.70, h * 0.75,
        w * 0.75, h * 0.60,
        w * 0.65, h * 0.50,
      )
      ..cubicTo(
        w * 0.55, h * 0.40,
        w * 0.60, h * 0.28,
        w * 0.55, h * 0.15,
      );
    canvas.drawPath(vinePath, vinePaint);

    // 3 leaf-like offshoots (12-15% opacity)
    final leafPaint1 = Paint()
      ..color = _mutedSage.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.70, h * 0.68)
        ..cubicTo(w * 0.78, h * 0.63, w * 0.85, h * 0.60, w * 0.88, h * 0.55),
      leafPaint1,
    );

    final leafPaint2 = Paint()
      ..color = _mutedSage.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.67, h * 0.52)
        ..cubicTo(w * 0.58, h * 0.48, w * 0.50, h * 0.46, w * 0.45, h * 0.42),
      leafPaint2,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.58, h * 0.30)
        ..cubicTo(w * 0.65, h * 0.25, w * 0.72, h * 0.22, w * 0.76, h * 0.18),
      Paint()
        ..color = _mutedSage.withOpacity(0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // 3 concentric growth-ring circles (3-8% opacity)
    final center = Offset(w * 0.3, h * 0.4);
    for (int i = 0; i < 3; i++) {
      final radius = 100.0 + i * 60.0;
      final opacity = 0.08 - (i * 0.025);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = _mutedSage.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
