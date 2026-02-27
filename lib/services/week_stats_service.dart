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
  /// Calculate stats for the current week (Mon–Sun) given a list of habit titles.
  static Future<WeekStats> calculate(List<String> habits, DateTime now) async {
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

    final sortedHabits = habitCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return WeekStats(
      completionCount: totalCompletions,
      completedHabits: sortedHabits.map((e) => e.key).toList(),
      dailyActivity: dailyActivity,
    );
  }
}
