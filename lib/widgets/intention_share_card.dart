import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class IntentionShareCard extends StatelessWidget {
  final int completionCount;
  final String showedUpPhrase;
  final String timesText;
  final String descriptorText;
  final String? userName;

  const IntentionShareCard({
    super.key,
    required this.completionCount,
    required this.showedUpPhrase,
    required this.timesText,
    required this.descriptorText,
    this.userName,
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
          // == BACKGROUND LAYER ==

          // 0. Solid opaque base to prevent transparency
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

          // Center: Hero number + "times"
          Positioned(
            left: 80,
            top: 480,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hero number — Sora, large, gradient via foreground paint
                Text(
                  '$completionCount',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 360,
                    fontWeight: FontWeight.w700,
                    foreground: Paint()
                      ..shader = ui.Gradient.linear(
                        const Offset(0, 0),
                        const Offset(0, 320),
                        [heroTop, accent],
                      ),
                    height: 0.85,
                  ),
                ),

                // "times" — Sora, gradient via foreground paint
                Text(
                  timesText,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 120,
                    fontWeight: FontWeight.w600,
                    foreground: Paint()
                      ..shader = ui.Gradient.linear(
                        const Offset(0, 0),
                        const Offset(0, 132),
                        [textDark, accent],
                      ),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // "I showed up for myself this week" — single Instrument Sans text
          Positioned(
            left: 80,
            right: 80,
            top: 1000,
            child: Text(
              showedUpPhrase,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'InstrumentSans',
                fontSize: 52,
                fontWeight: FontWeight.w400,
                color: textDark.withOpacity(0.65),
                height: 1.3,
              ),
            ),
          ),

          // Decorative gradient divider
          Positioned(
            left: 0,
            right: 0,
            top: 1120,
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

          // P.S. Name — only if user has a name
          if (userName != null && userName!.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              top: 1180,
              child: Center(
                child: Text(
                  'P.S. $userName',
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 52,
                    fontWeight: FontWeight.w400,
                    color: textDark.withOpacity(0.65),
                    height: 1.3,
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
