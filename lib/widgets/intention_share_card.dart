import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

const _warmCream = Color(0xFFF5F0EB);
const _dustyRose = Color(0xFFD4B5B0);
const _softSand = Color(0xFFE8DDD3);
const _deepBrown = Color(0xFF3D2E1F);
const _warmClay = Color(0xFFC4A98C);
const _mutedSage = Color(0xFFB5C4B1);

class IntentionShareCard extends StatelessWidget {
  final int completionCount;
  final String showedUpText;
  final String timesText;
  final String thisWeekText;
  final String taglineText;

  const IntentionShareCard({
    super.key,
    required this.completionCount,
    required this.showedUpText,
    required this.timesText,
    required this.thisWeekText,
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
            child: Container(color: _warmCream),
          ),

          // 1. Base gradient (~145°)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.6, -0.8),
                  end: const Alignment(0.6, 0.8),
                  colors: [
                    _warmCream,
                    _dustyRose.withOpacity(0.27),
                    _softSand,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient depth blobs (20-60% opacity, 60-80px blur → scaled 3x)
          Positioned(
            top: 140,
            right: -80,
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _dustyRose.withOpacity(0.42),
                    blurRadius: 210,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 340,
            left: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _warmClay.withOpacity(0.38),
                    blurRadius: 200,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 700,
            left: 250,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _dustyRose.withOpacity(0.35),
                    blurRadius: 190,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // 3. Flowing curves (3 ribbons, bottom-left to top-right)
          Positioned.fill(
            child: CustomPaint(
              painter: _FlowingCurvesPainter(),
            ),
          ),

          // 4. Decorative arcs (2 bezier paths in warm clay at 15-20% opacity)
          Positioned.fill(
            child: CustomPaint(
              painter: _DecorativeArcsPainter(),
            ),
          ),

          // 5. Radial glow behind hero number — centered
          Positioned(
            left: 1080 / 2 - 220,
            top: 420,
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
            top: 400,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "I showed up" — Inter, 36px, deepBrown at 50%
                Text(
                  showedUpText,
                  style: GoogleFonts.inter(
                    fontSize: 56,
                    fontWeight: FontWeight.w400,
                    color: _deepBrown.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 20),

                // Hero number — Playfair Display 300px, bold, gradient shader
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_deepBrown, _warmClay],
                  ).createShader(bounds),
                  child: Text(
                    '$completionCount',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 360,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                      height: 0.85,
                    ),
                  ),
                ),

                // "times" — Playfair Display, 100px, gradient shader
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_deepBrown, _warmClay],
                  ).createShader(bounds),
                  child: Text(
                    timesText,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 140,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // "for myself this week" — Playfair Display, 48px, weight 500, deepBrown
                Text(
                  thisWeekText,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 64,
                    fontWeight: FontWeight.w500,
                    color: _deepBrown,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Decorative gradient divider — 40px→120px wide, centered, 50% opacity
          Positioned(
            left: 0,
            right: 0,
            top: 1083,
            child: Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      _deepBrown.withOpacity(0.0),
                      _deepBrown.withOpacity(0.50),
                      _deepBrown.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Glassmorphism pill — centered
          Positioned(
            left: 0,
            right: 0,
            top: 1500,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: CupertinoColors.white.withOpacity(0.50),
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
                      horizontal: 48,
                      vertical: 24,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Green dot — 14px diameter
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: _mutedSage,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Pill text — Inter 32px, 65% opacity
                        Text(
                          taglineText,
                          style: GoogleFonts.inter(
                            fontSize: 40,
                            fontWeight: FontWeight.w400,
                            color: _deepBrown.withOpacity(0.80),
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
            top: 1700,
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
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'INTENDED',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 6,
                    color: _deepBrown.withOpacity(0.75),
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
}

/// Draws 3 flowing bezier curves — white at 18-28% opacity + one theme-tinted
class _FlowingCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Curve 1 — widest sweep, white at 28%
    final paint1 = Paint()
      ..color = CupertinoColors.white.withOpacity(0.28)
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

    // Curve 2 — middle sweep, warmClay tint at 22%
    final paint2 = Paint()
      ..color = _warmClay.withOpacity(0.22)
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

/// Draws 2 decorative arcs in warm clay at 15-20% opacity
class _DecorativeArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arc 1 — gentle sweep
    final paint1 = Paint()
      ..color = _warmClay.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(w * 0.15, h * 0.90)
      ..cubicTo(
        w * 0.40, h * 0.75,
        w * 0.70, h * 0.55,
        w * 0.95, h * 0.35,
      );
    canvas.drawPath(path1, paint1);

    // Arc 2 — shorter arc
    final paint2 = Paint()
      ..color = _warmClay.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path2 = Path()
      ..moveTo(w * 0.20, h * 0.80)
      ..cubicTo(
        w * 0.45, h * 0.68,
        w * 0.65, h * 0.52,
        w * 0.88, h * 0.40,
      );
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
