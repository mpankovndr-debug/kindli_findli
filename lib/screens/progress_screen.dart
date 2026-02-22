import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';
import 'moments_collection_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showAllHabits = false;

  // 35 rotating affirmation messages
  static const List<String> _affirmations = [
    'Missing days doesn\'t erase what you\'ve already done.',
    'You don\'t need to earn rest.',
    'Three habits or one — both are enough.',
    'The fact that you\'re here says something good about you.',
    'Progress isn\'t about perfection, it\'s about showing up.',
    'You\'re allowed to have off days.',
    'Small actions count, even when they feel small.',
    'You\'re not behind. You\'re exactly where you need to be.',
    'Consistency is important, but so is self-compassion.',
    'Your worth isn\'t measured by what you check off.',
    'Some weeks are harder than others. That\'s just being human.',
    'You don\'t need to do everything to be doing enough.',
    'Rest is part of progress, not the opposite of it.',
    'Showing up imperfectly is still showing up.',
    'You\'re doing better than you think you are.',
    'It\'s okay to start over as many times as you need.',
    'Your pace is your own. Comparison won\'t help.',
    'Every attempt matters, even the ones that feel small.',
    'You don\'t have to feel motivated to deserve kindness.',
    'Progress can look like simply trying again tomorrow.',
    'You\'re allowed to adjust your expectations.',
    'Taking breaks doesn\'t mean you\'ve failed.',
    'The hardest part is often just beginning. You did that.',
    'You don\'t need permission to take care of yourself.',
    'Your best today might look different than yesterday. That\'s okay.',
    'Struggling doesn\'t mean you\'re doing it wrong.',
    'You\'ve already done hard things. You can do this too.',
    'It\'s okay if your progress doesn\'t look like anyone else\'s.',
    'You don\'t have to prove anything to anyone.',
    'Sometimes just surviving the day is progress enough.',
    'You\'re learning, even when it doesn\'t feel like it.',
    'Being gentle with yourself is not giving up.',
    'You don\'t need a reason to be kind to yourself.',
    'What you\'re doing right now is enough.',
    'Tomorrow is always a chance to try again.',
  ];

  String _getTodaysAffirmation() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _affirmations[dayOfYear % _affirmations.length];
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final onboardingState = context.watch<OnboardingState>();
    final userHabits = onboardingState.userHabits;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
            top: false,
            bottom: false,
            child: userHabits.isEmpty
                ? Center(
                    child: Text(
                      'Complete onboarding to see your week',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B5B4F),
                      ),
                    ),
                  )
                : FutureBuilder<_WeekStats>(
                    future: _calculateWeekStats(userHabits, now),
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
                            child: const Text(
                              'Your week',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C342A),
                              ),
                            ),
                          ),

                          // Scrollable content
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                              children: [
                          // 2. Main Unified Card
                          _buildMainCard(stats),
                          const SizedBox(height: 24),

                          // 3. Motivational Text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _getTodaysAffirmation(),
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9A8A78),
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
                              return _buildRecentMoment(count, recent);
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

  Widget _buildMainCard(_WeekStats stats) {
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
            color: const Color(0xFFFFFFFF).withOpacity(0.50),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.40),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C342A).withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2a. Section Label
              const Text(
                'WEEKLY SUMMARY',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B7563),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),

              // 2b. Main Stat Heading
              Text(
                stats.completionCount == 0
                    ? 'Your week is just beginning.'
                    : stats.completionCount == 1
                        ? 'You showed up once this week.'
                        : 'You showed up ${stats.completionCount} times this week.',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3C342A),
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
                          const Padding(
                            padding: EdgeInsets.only(top: 1),
                            child: Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B7563),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              habit,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3C342A),
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
                              '+$hiddenCount more',
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9A8A78),
                              ),
                            ),
                            const Text(
                              'See all',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9A8A78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => setState(() => _showAllHabits = false),
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Text(
                          'Show less',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9A8A78),
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
                  color: const Color(0xFF8B7563).withOpacity(0.15),
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

  Widget _buildRecentMoment(int count, Moment recent) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final momentDay = DateTime(
      recent.completedAt.year,
      recent.completedAt.month,
      recent.completedAt.day,
    );

    final String timeLabel;
    if (momentDay == today) {
      timeLabel = 'Earlier today';
    } else if (momentDay == today.subtract(const Duration(days: 1))) {
      timeLabel = 'Yesterday';
    } else {
      final diff = today.difference(momentDay).inDays;
      timeLabel = '$diff days ago';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR MOMENTS',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B7563),
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
                  color: const Color(0xFFFFFFFF).withOpacity(0.25),
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
                            '$count ${count == 1 ? 'moment' : 'moments'} collected',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3C342A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '· $timeLabel',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9A8A78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: Color(0xFF9A8A78),
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
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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
                        ? const Color(0xFF7A8B6F)
                        : const Color(0xFFBFB9B0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Day label (no animation needed)
              Text(
                dayLabels[index],
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9A8A78),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
