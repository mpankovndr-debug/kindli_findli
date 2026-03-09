import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/reflection_data.dart';
import '../theme/theme_provider.dart';
import '../utils/text_styles.dart';

/// 1080×1920 share card for the weekly reflection.
/// Renders all visible sections as flowing text on the themed background.
class ReflectionShareCard extends StatelessWidget {
  final ReflectionData data;

  const ReflectionShareCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final baseColor = colors.onboardingBg1;
    final accentSoft = colors.accentCustom;
    final baseDarker = colors.onboardingBg2;
    final textDark = colors.textPrimary;
    final accent = colors.accentRegular;

    final sections = _buildSectionTexts(l10n);

    return SizedBox(
      width: 1080,
      height: 1920,
      child: Stack(
        children: [
          // Solid base
          Positioned.fill(child: Container(color: baseColor)),

          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.6, -0.8),
                  end: const Alignment(0.6, 0.8),
                  colors: [
                    baseColor,
                    accentSoft.withValues(alpha:0.27),
                    baseDarker,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Ambient blobs
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
                    color: accentSoft.withValues(alpha:0.42),
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
                    color: accent.withValues(alpha:0.38),
                    blurRadius: 200,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Positioned(
            left: 100,
            right: 100,
            top: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.reflectionTitle,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    Text(
                      data.weekRange,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 36,
                        fontWeight: FontWeight.w400,
                        color: textDark.withValues(alpha:0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Divider
                Container(
                  height: 2,
                  color: textDark.withValues(alpha:0.12),
                ),
                const SizedBox(height: 60),

                // Flowing sections
                ...sections.expand((text) => [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 46,
                      fontWeight: FontWeight.w400,
                      color: textDark.withValues(alpha:0.80),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 48),
                ]),
              ],
            ),
          ),

          // Bottom branding
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
                            color: const Color(0xFF000000).withValues(alpha:0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/images/intended_icon.png',
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
                        fontFamily: AppTextStyles.bodyFont(context),
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 6,
                        color: textDark.withValues(alpha:0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.shareCardDescriptor,
                  style: TextStyle(
                    fontFamily: 'InstrumentSans',
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: textDark.withValues(alpha:0.50),
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

  List<String> _buildSectionTexts(AppLocalizations l10n) {
    final texts = <String>[];

    // Section 1 — Anchor
    texts.add(_anchorText(l10n));

    // Section 2 — Pattern
    if (data.hasPatternData) {
      texts.add(_patternText(l10n));
    }

    // Section 3 — Focus
    if (data.topFocusArea != null) {
      texts.add(_focusText(l10n));
    }

    // Section 4 — Reframe
    final reframe = _reframeText(l10n);
    if (reframe != null) {
      texts.add(reframe);
    }

    return texts;
  }

  String _localizedDay(AppLocalizations l10n, String englishDay) {
    return switch (englishDay) {
      'Monday' => l10n.dayMonday,
      'Tuesday' => l10n.dayTuesday,
      'Wednesday' => l10n.dayWednesday,
      'Thursday' => l10n.dayThursday,
      'Friday' => l10n.dayFriday,
      'Saturday' => l10n.daySaturday,
      'Sunday' => l10n.daySunday,
      _ => englishDay,
    };
  }

  String _anchorText(AppLocalizations l10n) {
    final n = data.daysActive;
    if (n == 7) return l10n.reflectionAnchor7;
    if (n >= 5) return l10n.reflectionAnchor56(n);
    if (n >= 3) return l10n.reflectionAnchor34(n);
    if (n >= 1) return l10n.reflectionAnchor12(n);
    return l10n.reflectionAnchor0;
  }

  String _patternText(AppLocalizations l10n) {
    if (data.bestDay != null && data.secondBestDay != null) {
      return l10n.reflectionPatternTwoDays(
        _localizedDay(l10n, data.bestDay!),
        _localizedDay(l10n, data.secondBestDay!),
      );
    }
    if (data.bestDay != null) {
      return l10n.reflectionPatternOneDay(
        _localizedDay(l10n, data.bestDay!),
      );
    }
    return l10n.reflectionPatternNone;
  }

  String _focusText(AppLocalizations l10n) {
    if (data.secondFocusArea != null) {
      return l10n.reflectionFocusBalanced(
          data.topFocusArea!, data.secondFocusArea!);
    }
    return l10n.reflectionFocusDominant(data.topFocusArea!);
  }

  String? _reframeText(AppLocalizations l10n) {
    if (data.isComeback) return l10n.reflectionReframeComeback;
    if (data.refreshCount > 0) {
      return l10n.reflectionReframeRefresh(data.refreshCount);
    }
    if (data.swapCount > 0) return l10n.reflectionReframeSwap;
    return null;
  }
}
