import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/share_card_type.dart';
import '../theme/theme_provider.dart';

class MilestoneShareCard extends StatelessWidget {
  final String heroText;
  final String subtitleText;
  final String descriptorText;
  final String? userName;
  final MilestoneVariant variant;

  const MilestoneShareCard({
    super.key,
    required this.heroText,
    required this.subtitleText,
    required this.descriptorText,
    this.userName,
    this.variant = MilestoneVariant.showingUp,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final baseColor = colors.onboardingBg1;
    final accentSoft = colors.accentCustom;
    final baseDarker = colors.onboardingBg2;
    final textDark = colors.textPrimary;
    final accent = colors.accentRegular;
    final heroTop = colors.ctaPrimary;

    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          // == BACKGROUND LAYER (matches intention card) ==

          // 0. Solid opaque base
          Positioned.fill(
            child: Container(color: baseColor),
          ),

          // 1. Base gradient (~145°)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.6, -0.8),
                  end: const Alignment(0.6, 0.8),
                  colors: [
                    baseColor,
                    accentSoft.withOpacity(0.27),
                    baseDarker,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient depth blobs
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
                    color: accentSoft.withOpacity(0.42),
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
                    color: accent.withOpacity(0.38),
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
                    color: accentSoft.withOpacity(0.35),
                    blurRadius: 190,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          // 3. Flowing curves
          Positioned.fill(
            child: CustomPaint(
              painter: _FlowingCurvesPainter(accent: accent),
            ),
          ),

          // 4. Decorative arcs
          Positioned.fill(
            child: CustomPaint(
              painter: _DecorativeArcsPainter(accent: accent),
            ),
          ),

          // == CONTENT LAYER ==

          // Center: Hero text + subtitle
          Positioned(
            left: 80,
            top: 420,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero text — Sora, gradient via ShaderMask for multi-line
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [heroTop, accent],
                  ).createShader(bounds),
                  child: Text(
                    heroText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: variant == MilestoneVariant.identity ? 110 : 160,
                      fontWeight: variant == MilestoneVariant.identity
                          ? FontWeight.w600
                          : FontWeight.w700,
                      color: CupertinoColors.white,
                      height: variant == MilestoneVariant.identity ? 1.0 : 0.95,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Subtitle — Instrument Sans (with name if available)
                Text(
                  (userName != null && userName!.isNotEmpty)
                      ? '$subtitleText, $userName'
                      : subtitleText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 52,
                    fontWeight: FontWeight.w400,
                    color: textDark.withOpacity(0.65),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Decorative gradient divider
          Positioned(
            left: 0,
            right: 0,
            top: 1160,
            child: Center(
              child: Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      textDark.withOpacity(0.0),
                      textDark.withOpacity(0.50),
                      textDark.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom branding — icon + "INTENDED" + descriptor
          Positioned(
            left: 0,
            right: 0,
            bottom: 240,
            child: Column(
              children: [
                Row(
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
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 6,
                        color: textDark.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  descriptorText,
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: textDark.withOpacity(0.50),
                    letterSpacing: 0.5,
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
  final Color accent;
  const _FlowingCurvesPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

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

    final paint2 = Paint()
      ..color = accent.withOpacity(0.22)
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
  bool shouldRepaint(covariant _FlowingCurvesPainter oldDelegate) =>
      accent != oldDelegate.accent;
}

/// Draws 2 decorative arcs at 15-20% opacity
class _DecorativeArcsPainter extends CustomPainter {
  final Color accent;
  const _DecorativeArcsPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint1 = Paint()
      ..color = accent.withOpacity(0.18)
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

    final paint2 = Paint()
      ..color = accent.withOpacity(0.15)
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
  bool shouldRepaint(covariant _DecorativeArcsPainter oldDelegate) =>
      accent != oldDelegate.accent;
}
