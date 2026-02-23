import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'moments_collection_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showAllHabits = false;
  Future<_WeekStats>? _weekStatsFuture;
  List<String>? _lastHabits;

  List<String> _getAffirmations(AppLocalizations l10n) => [
    l10n.affirmation1, l10n.affirmation2, l10n.affirmation3,
    l10n.affirmation4, l10n.affirmation5, l10n.affirmation6,
    l10n.affirmation7, l10n.affirmation8, l10n.affirmation9,
    l10n.affirmation10, l10n.affirmation11, l10n.affirmation12,
    l10n.affirmation13, l10n.affirmation14, l10n.affirmation15,
    l10n.affirmation16, l10n.affirmation17, l10n.affirmation18,
    l10n.affirmation19, l10n.affirmation20, l10n.affirmation21,
    l10n.affirmation22, l10n.affirmation23, l10n.affirmation24,
    l10n.affirmation25, l10n.affirmation26, l10n.affirmation27,
    l10n.affirmation28, l10n.affirmation29, l10n.affirmation30,
    l10n.affirmation31, l10n.affirmation32, l10n.affirmation33,
    l10n.affirmation34, l10n.affirmation35,
  ];

  String _getTodaysAffirmation(AppLocalizations l10n) {
    final affirmations = _getAffirmations(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return affirmations[dayOfYear % affirmations.length];
  }

  Future<_WeekStats> _calculateWeekStats(List<String> habits, DateTime now) async {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    int totalCompletions = 0;
    final Map<String, int> habitCounts = {};
    final List<bool> dailyActivity = List.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      bool hadActivityToday = false;

      for (final habit in habits) {
        final wasDone = await HabitTracker.wasDone(habit, date);
        if (wasDone) {
          totalCompletions++;
          habitCounts[habit] = (habitCounts[habit] ?? 0) + 1;
          hadActivityToday = true;
        }
      }

      dailyActivity[i] = hadActivityToday;
    }

    final completedHabits = <String>[];
    final sortedHabits = habitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedHabits) {
      completedHabits.add(entry.key);
    }

    return _WeekStats(
      completionCount: totalCompletions,
      completedHabits: completedHabits,
      dailyActivity: dailyActivity,
    );
  }

  void _refreshStats(List<String> habits) {
    _lastHabits = List.of(habits);
    _weekStatsFuture = _calculateWeekStats(habits, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.watch<OnboardingState>();
    final userHabits = onboardingState.userHabits;
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    // Only recalculate when habits list actually changes
    if (_weekStatsFuture == null || !listEquals(userHabits, _lastHabits)) {
      _refreshStats(userHabits);
    }

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
            top: false,
            bottom: false,
            child: userHabits.isEmpty
                ? Center(
                    child: Text(
                      l10n.progressOnboardingPrompt,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSubtitle,
                      ),
                    ),
                  )
                : FutureBuilder<_WeekStats>(
                    future: _weekStatsFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }

                      final stats = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header (fixed)
                          Padding(
                            padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 20),
                            child: Text(
                              l10n.progressTitle,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),

                          // Scrollable content
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                              children: [
                          // 2. Main Unified Card
                          _buildMainCard(stats, colors, l10n),
                          const SizedBox(height: 24),

                          // 3. Motivational Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _getTodaysAffirmation(l10n),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                                fontStyle: FontStyle.italic,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 4. Recent Moment
                          FutureBuilder<List<Moment>>(
                            future: MomentsService.getAll(),
                            builder: (context, snap) {
                              if (!snap.hasData || snap.data!.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              final moments = snap.data!;
                              final count = moments.length;
                              final recent = moments.first;
                              return _buildRecentMoment(count, recent, colors, l10n);
                            },
                          ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildMainCard(_WeekStats stats, AppColorScheme colors, AppLocalizations l10n) {
    final habitsToShow = _showAllHabits
        ? stats.completedHabits
        : stats.completedHabits.take(3).toList();
    final hiddenCount = stats.completedHabits.length - 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.profileCard.withOpacity(colors.profileCardOpacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.cardBrowse.withOpacity(colors.cardBrowseOpacity),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2a. Section Label
              Text(
                l10n.progressWeeklySummary,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: colors.ctaPrimary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // 2b. Main Stat Heading
              Text(
                stats.completionCount == 0
                    ? l10n.progressWeekBeginning
                    : stats.completionCount == 1
                        ? l10n.progressShowedUpOnce
                        : l10n.progressShowedUpCount(stats.completionCount),
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // 2c. Completed Habits List
              if (stats.completedHabits.isNotEmpty) ...[
                Column(
                  children: habitsToShow.map((habit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.ctaPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              habit,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: colors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                // 2d. "+X more" / "See all" OR 2e. "Show less"
                if (stats.completedHabits.length > 3) ...[
                  const SizedBox(height: 2),
                  if (!_showAllHabits)
                    GestureDetector(
                      onTap: () => setState(() => _showAllHabits = true),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.progressMore(hiddenCount),
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                              ),
                            ),
                            Text(
                              l10n.progressSeeAll,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() => _showAllHabits = false),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          l10n.progressShowLess,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ] else
                  const SizedBox(height: 12),
              ],

              // 2f. Divider
              if (stats.completedHabits.isNotEmpty)
                Container(
                  height: 1,
                  color: colors.ctaPrimary.withOpacity(0.15),
                ),
              if (stats.completedHabits.isNotEmpty)
                const SizedBox(height: 20),

              // 2g. Week Dots (animated)
              _AnimatedWeekDots(
                dailyActivity: stats.dailyActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMoment(int count, Moment recent, AppColorScheme colors, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final momentDay = DateTime(
      recent.completedAt.year,
      recent.completedAt.month,
      recent.completedAt.day,
    );

    final String timeLabel;
    if (momentDay == today) {
      timeLabel = l10n.progressEarlierToday;
    } else if (momentDay == today.subtract(const Duration(days: 1))) {
      timeLabel = l10n.progressYesterday;
    } else {
      final diff = today.difference(momentDay).inDays;
      timeLabel = l10n.progressDaysAgo(diff);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressYourMoments,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.ctaPrimary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),

        GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (_) => const MomentsCollectionScreen(),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.momentsCard.withOpacity(colors.momentsCardOpacity),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            l10n.progressMomentsCollected(count),
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· $timeLabel',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekStats {
  final int completionCount;
  final List<String> completedHabits;
  final List<bool> dailyActivity;

  _WeekStats({
    required this.completionCount,
    required this.completedHabits,
    required this.dailyActivity,
  });
}

class _AnimatedWeekDots extends StatefulWidget {
  final List<bool> dailyActivity;

  const _AnimatedWeekDots({
    required this.dailyActivity,
  });

  @override
  State<_AnimatedWeekDots> createState() => _AnimatedWeekDotsState();
}

class _AnimatedWeekDotsState extends State<_AnimatedWeekDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      7,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutBack,
        ),
      );
    }).toList();

    // Start staggered animations (30ms between each)
    for (var i = 0; i < 7; i++) {
      Future.delayed(Duration(milliseconds: i * 30), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final dayLabels = [
      l10n.dayShortMon, l10n.dayShortTue, l10n.dayShortWed,
      l10n.dayShortThu, l10n.dayShortFri, l10n.dayShortSat,
      l10n.dayShortSun,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final isCompleted = widget.dailyActivity[index];

          return Column(
            children: [
              // Animated Dot
              ScaleTransition(
                scale: _scaleAnimations[index],
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? colors.ctaAlternative
                        : colors.textDisabled,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Day label (no animation needed)
              Text(
                dayLabels[index],
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: colors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
