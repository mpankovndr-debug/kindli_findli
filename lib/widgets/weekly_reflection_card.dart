import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/reflection_data.dart';
import '../screens/moments_collection_screen.dart';
import '../screens/paywall_screen.dart';
import '../services/reflection_service.dart';
import '../services/share_service.dart';
import '../services/week_stats_service.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import '../utils/habit_l10n.dart';
import '../utils/responsive_utils.dart';
import '../utils/text_styles.dart';
import '../widgets/app_toast.dart';
import 'reflection_share_card.dart';

class WeeklyReflectionCard extends StatefulWidget {
  final WeekStats stats;

  const WeeklyReflectionCard({super.key, required this.stats});

  @override
  State<WeeklyReflectionCard> createState() => _WeeklyReflectionCardState();
}

class _WeeklyReflectionCardState extends State<WeeklyReflectionCard>
    with SingleTickerProviderStateMixin {
  ReflectionData? _data;
  bool _loading = true;
  bool _isSharing = false;
  final GlobalKey _repaintKey = GlobalKey();
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _load();
  }

  @override
  void didUpdateWidget(covariant WeeklyReflectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Force-regenerate when stats change (e.g. tab became active after check-in)
    if (widget.stats != oldWidget.stats) {
      _refresh();
    }
  }

  /// Normal load — returns cached reflection if still valid (respects validUntil).
  Future<void> _load() async {
    final data = await ReflectionService.getCurrentReflection();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
    if (!_animController.isCompleted) {
      _animController.forward();
    }
  }

  /// Force-regenerate reflection with fresh data (on stats change).
  Future<void> _refresh() async {
    final data = await ReflectionService.generateReflection();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    final size = MediaQuery.of(context).size;
    try {
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareCard(
        _repaintKey,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } catch (_) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context).shareError);
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    if (_loading || _data == null) {
      return const SizedBox.shrink();
    }

    final userState = context.watch<UserState>();
    final isPremium = userState.hasSubscription;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Hidden capture card for share
            if (isPremium)
              ClipRect(
                child: SizedBox(
                  width: 0,
                  height: 0,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: 1080,
                    maxHeight: 1920,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: ReflectionShareCard(data: _data!),
                    ),
                  ),
                ),
              ),
            if (isPremium)
              _buildFullCard(context, _data!)
            else
              _buildTeaserCard(context, _data!),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Full card (Intended+ users)
  // ---------------------------------------------------------------------------

  Widget _buildFullCard(BuildContext context, ReflectionData data) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().theme.isDark
                ? colors.cardBackground.withValues(alpha: colors.cardBackgroundOpacity)
                : CupertinoColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.watch<ThemeProvider>().theme.isDark
                  ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
                  : CupertinoColors.white.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRange(context, data, colors),
              const SizedBox(height: 12),
              // Section 1: THIS WEEK
              _buildSectionLabel(l10n.reflectionSectionThisWeek, colors),
              const SizedBox(height: 8),
              _reflectionText(context, _anchorText(l10n, data), colors),
              const SizedBox(height: 14),
              _buildHabitsList(context, colors, l10n),
              const SizedBox(height: 8),
              _buildDayDots(context, colors, l10n),
              // Premium sections with labeled dividers
              ..._buildPremiumSections(context, data, colors, l10n),
              if (widget.stats.completionCount >= 3 || widget.stats.dailyActivity.where((d) => d).length >= 2) ...[
                const SizedBox(height: 16),
                _buildShareButton(context, colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Teaser card (free users)
  // ---------------------------------------------------------------------------

  Widget _buildTeaserCard(BuildContext context, ReflectionData data) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().theme.isDark
                ? colors.cardBackground.withValues(alpha: colors.cardBackgroundOpacity)
                : CupertinoColors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.watch<ThemeProvider>().theme.isDark
                  ? colors.borderCard.withValues(alpha: colors.borderCardOpacity)
                  : CupertinoColors.white.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRange(context, data, colors),
              const SizedBox(height: 12),
              // Section 1: THIS WEEK
              _buildSectionLabel(l10n.reflectionSectionThisWeek, colors),
              const SizedBox(height: 8),
              _reflectionText(context, _anchorText(l10n, data), colors),
              const SizedBox(height: 14),
              _buildHabitsList(context, colors, l10n),
              const SizedBox(height: 8),
              _buildDayDots(context, colors, l10n),
              const SizedBox(height: 16),
              // Upsell prompt with dynamic teaser
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.5),
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    builder: (_) =>
                        const PaywallScreen(source: 'reflection_card'),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _teaserText(l10n, data),
                        style: AppTextStyles.caption(context).copyWith(
                          color: colors.ctaPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.ctaPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: colors.ctaPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsList(
      BuildContext context, AppColorScheme colors, AppLocalizations l10n) {
    final habits = widget.stats.completedHabits;
    if (habits.isEmpty) return const SizedBox.shrink();

    final habitsToShow = habits.take(3).toList();
    final hiddenCount = habits.length - 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...habitsToShow.map((habit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    '\u2713',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.ctaPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizeHabitName(habit, l10n),
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: colors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 2),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => const MomentsCollectionScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.progressMore(hiddenCount),
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Day dots (M T W T F S S)
  // ---------------------------------------------------------------------------

  Widget _buildDayDots(
      BuildContext context, AppColorScheme colors, AppLocalizations l10n) {
    final dayLabels = [
      l10n.dayShortMon, l10n.dayShortTue, l10n.dayShortWed,
      l10n.dayShortThu, l10n.dayShortFri, l10n.dayShortSat,
      l10n.dayShortSun,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isCompleted = widget.stats.dailyActivity[index];
          return Column(
            children: [
              Container(
                width: isCompleted ? 10 : 6,
                height: isCompleted ? 10 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colors.ctaAlternative
                      : colors.textDisabled.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayLabels[index],
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: isCompleted
                      ? colors.textSecondary
                      : colors.textDisabled,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Premium-only sections (2, 3, 4)
  // ---------------------------------------------------------------------------

  List<Widget> _buildPremiumSections(BuildContext context, ReflectionData data,
      AppColorScheme colors, AppLocalizations l10n) {
    final sections = <Widget>[];

    final hasPattern = data.hasPatternData;
    final hasFocus = data.topFocusArea != null;
    final reframe = _reframeText(l10n, data);
    final hasReframe = reframe != null;

    // Section 2: YOUR RHYTHM (pattern)
    if (hasPattern) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionDivider(colors));
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionLabel(l10n.reflectionSectionYourRhythm, colors));
      sections.add(const SizedBox(height: 8));
      sections.add(_reflectionText(context, _patternText(l10n, data), colors));
    }

    // Section 3: YOUR FOCUS
    if (hasFocus) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionDivider(colors));
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionLabel(l10n.reflectionSectionYourFocus, colors));
      sections.add(const SizedBox(height: 8));
      sections.add(_reflectionText(
        context,
        _focusText(l10n, data),
        colors,
        opacity: 0.85,
      ));
    }

    // Section 4: SOMETHING TO NOTICE (reframe)
    if (hasReframe) {
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionDivider(colors));
      sections.add(const SizedBox(height: 16));
      sections.add(_buildSectionLabel(l10n.reflectionSectionNotice, colors));
      sections.add(const SizedBox(height: 8));
      sections.add(_reflectionText(
        context,
        reframe,
        colors,
        opacity: 0.85,
      ));
    }

    return sections;
  }

  // ---------------------------------------------------------------------------
  // Shared building blocks
  // ---------------------------------------------------------------------------

  Widget _buildSectionLabel(String label, AppColorScheme colors) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        color: colors.textSecondary,
      ),
    );
  }

  Widget _buildSectionDivider(AppColorScheme colors) {
    return Container(
      height: 0.5,
      color: colors.textSecondary.withValues(alpha: 0.15),
    );
  }

  Widget _buildDateRange(
      BuildContext context, ReflectionData data, dynamic colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        data.weekRange,
        style: AppTextStyles.caption(context),
      ),
    );
  }

  Widget _reflectionText(BuildContext context, String text, dynamic colors,
      {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Text(
        text,
        style: AppTextStyles.body(context).copyWith(
          color: colors.textPrimary,
          height: 1.55,
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, dynamic colors) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _isSharing ? null : _share,
        child: _isSharing
            ? CupertinoActivityIndicator(color: colors.textSecondary)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.share,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.reflectionShare,
                    style: AppTextStyles.buttonSecondary(context),
                  ),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Localized copy
  // ---------------------------------------------------------------------------

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

  String _anchorText(AppLocalizations l10n, ReflectionData data) {
    final n = data.daysActive;
    if (n == 7) return l10n.reflectionAnchor7;
    if (n >= 5) return l10n.reflectionAnchor56(n);
    if (n >= 3) return l10n.reflectionAnchor34(n);
    if (n >= 1) return l10n.reflectionAnchor12(n);
    return l10n.reflectionAnchor0;
  }

  String _patternText(AppLocalizations l10n, ReflectionData data) {
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

  String _focusText(AppLocalizations l10n, ReflectionData data) {
    if (data.secondFocusArea != null) {
      return l10n.reflectionFocusBalanced(
          data.topFocusArea!, data.secondFocusArea!);
    }
    return l10n.reflectionFocusDominant(data.topFocusArea!);
  }

  String _teaserText(AppLocalizations l10n, ReflectionData data) {
    return l10n.reflectionTeaser;
  }

  String? _reframeText(AppLocalizations l10n, ReflectionData data) {
    if (data.isComeback) return l10n.reflectionReframeComeback;
    if (data.refreshCount > 0) {
      return l10n.reflectionReframeRefresh(data.refreshCount);
    }
    if (data.swapCount > 0) return l10n.reflectionReframeSwap;
    return null;
  }
}
