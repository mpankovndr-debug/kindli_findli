import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class ThemePicker extends StatelessWidget {
  final bool isPremium;
  final VoidCallback onPremiumTap;
  final bool compact;

  const ThemePicker({
    super.key,
    required this.isPremium,
    required this.onPremiumTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final currentTheme = themeProvider.theme;
    final l10n = AppLocalizations.of(context);

    final themes = [
      (AppTheme.warmClay, l10n.themeWarmClay, const Color(0xFFF2EAE2), const Color(0xFF8C6652)),
      (AppTheme.iris, l10n.themeIris, const Color(0xFFEAE4F2), const Color(0xFF5547A0)),
      (AppTheme.clearSky, l10n.themeClearSky, const Color(0xFFE8EFF6), const Color(0xFF4A7BAD)),
      (AppTheme.morningSlate, l10n.themeMorningSlate, const Color(0xFFE9EEEC), const Color(0xFF4E7A75)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unlocked themes
        Row(
          children: [
            for (var i = 0; i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: compact ? 1.2 : 0.75,
                  child: Builder(builder: (context) {
                    final (theme, name, swatchColor, accentColor) = themes[i];
                    final isSelected = currentTheme == theme;
                    final isLocked = themeProvider.isPremiumTheme(theme) && !isPremium;
                    return _buildThemeCard(
                      context, theme, name, swatchColor, accentColor, isSelected, isLocked,
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        // Locked themes
        Row(
          children: [
            for (var i = 2; i < 4; i++) ...[
              if (i > 2) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: Builder(builder: (context) {
                    final (theme, name, swatchColor, accentColor) = themes[i];
                    final isSelected = currentTheme == theme;
                    final isLocked = themeProvider.isPremiumTheme(theme) && !isPremium;
                    return _buildThemeCard(
                      context, theme, name, swatchColor, accentColor, isSelected, isLocked,
                    );
                  }),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    AppTheme theme,
    String name,
    Color swatchColor,
    Color accentColor,
    bool isSelected,
    bool isLocked,
  ) {
    return GestureDetector(
      onTap: () {
        if (isLocked) {
          onPremiumTap();
        } else {
          context.read<ThemeProvider>().setTheme(theme);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: swatchColor,
              border: isSelected
                  ? Border.all(color: accentColor, width: 2.5)
                  : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
                child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
              ),
            ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: swatchColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 20,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Intended+',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withValues(alpha: 0.3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
