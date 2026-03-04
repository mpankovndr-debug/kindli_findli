import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class WeekStats {
  final int completionCount;
  final List<String> completedHabits;
  final List<bool> dailyActivity;

  WeekStats({
    required this.completionCount,
    required this.completedHabits,
    required this.dailyActivity,
  });
}

class WeekStatsService {
  /// Calculate stats for the current week (Mon–Sun).
  ///
  /// Scans ALL completions recorded during the week, regardless of
  /// whether the habits are still in the user's active list.
  /// [habits] is used only to cache display-name mappings.
  static Future<WeekStats> calculate(List<String> habits, DateTime now) async {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Cache title mappings for current habits so they survive habit changes.
    final prefs = await SharedPreferences.getInstance();
    for (final habit in habits) {
      final id = HabitTracker.habitId(habit);
      prefs.setString('habit_title_$id', habit);
    }

    int totalCompletions = 0;
    final Map<String, int> habitCounts = {};
    final List<bool> dailyActivity = List.filled(7, false);

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final completedIds = await HabitTracker.allCompletedIdsForDate(date);

      if (completedIds.isNotEmpty) {
        dailyActivity[i] = true;
      }

      for (final id in completedIds) {
        totalCompletions++;
        final title = await HabitTracker.titleForId(id);
        habitCounts[title] = (habitCounts[title] ?? 0) + 1;
      }
    }

    final sortedHabits = habitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return WeekStats(
      completionCount: totalCompletions,
      completedHabits: sortedHabits.map((e) => e.key).toList(),
      dailyActivity: dailyActivity,
    );
  }
}
