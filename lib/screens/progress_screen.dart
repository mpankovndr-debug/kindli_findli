import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../utils/milestone_tracker.dart';
import 'milestone_history_screen.dart';

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

  Future<_RecentMilestone?> _getRecentMilestone() async {
    // Check all milestones, find the most recently earned
    DateTime? latestDate;
    Milestone? latestMilestone;

    for (final milestone in Milestone.values) {
      if (await MilestoneTracker.hasAchieved(milestone)) {
        final date = await MilestoneTracker.getAchievementDate(milestone);
        if (date != null && (latestDate == null || date.isAfter(latestDate))) {
          latestDate = date;
          latestMilestone = milestone;
        }
      }
    }

    if (latestMilestone == null || latestDate == null) return null;

    final now = DateTime.now();
    final diff = now.difference(latestDate);
    String timeLabel;
    if (diff.inDays == 0) {
      timeLabel = 'Earned today';
    } else if (diff.inDays == 1) {
      timeLabel = 'Earned yesterday';
    } else if (diff.inDays < 7) {
      timeLabel = 'Earned ${diff.inDays} days ago';
    } else {
      timeLabel = 'Earned ${diff.inDays ~/ 7}w ago';
    }

    final info = MilestoneTracker.info[latestMilestone]!;
    return _RecentMilestone(
      title: info.title,
      timeLabel: timeLabel,
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
                      final todayIndex = now.weekday - 1; // 0=Mon, 6=Sun

                      return ListView(
                        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 140),
                        children: [
                          // 1. Header
                          const Text(
                            'Your week',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C342A),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 2. Main Unified Card
                          _buildMainCard(stats, todayIndex),
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

                          // 4. Recent Milestone
                          FutureBuilder<_RecentMilestone?>(
                            future: _getRecentMilestone(),
                            builder: (context, milestoneSnap) {
                              if (!milestoneSnap.hasData || milestoneSnap.data == null) {
                                return const SizedBox.shrink();
                              }
                              final milestone = milestoneSnap.data!;
                              return _buildRecentMilestone(milestone);
                            },
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildMainCard(_WeekStats stats, int todayIndex) {
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
            color: const Color(0xFFFFFFFF).withOpacity(0.35),
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

              // 2g. Week Dots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final isCompleted = stats.dailyActivity[index];
                    final isToday = index == todayIndex;
                    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                    return Column(
                      children: [
                        // Dot
                        Container(
                          width: isToday ? 10 : 8,
                          height: isToday ? 10 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? const Color(0xFF6B5B4A)
                                : const Color(0xFF8B7563).withOpacity(0.2),
                            border: isToday
                                ? Border.all(
                                    color: const Color(0xFF6B5B4A),
                                    width: 1.5,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day label
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMilestone(_RecentMilestone milestone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Label
        const Text(
          'RECENT MILESTONE',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B7563),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),

        // Milestone Card
        GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              CupertinoPageRoute(
                builder: (_) => const MilestoneHistoryScreen(),
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
                  color: const Color(0xFFFFFFFF).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Left content
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            milestone.title,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF3C342A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '· ${milestone.timeLabel}',
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9A8A78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chevron
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

class _RecentMilestone {
  final String title;
  final String timeLabel;

  _RecentMilestone({required this.title, required this.timeLabel});
}
