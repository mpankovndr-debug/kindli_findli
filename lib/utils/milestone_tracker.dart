import 'package:shared_preferences/shared_preferences.dart';

/// Milestone categories for organization
enum MilestoneCategory {
  journey, // Your Journey milestones (Flower icons)
  habits, // Your Habits milestones (Tree icons)
}

/// All 12 milestones in Kindli
enum Milestone {
  // YOUR JOURNEY (6 milestones - Flower icons)
  firstStep, // First habit completed
  sevenDays, // 7 days using app
  fourteenDays, // 14 days using app
  thirtyDays, // 30 days using app
  sixtyDays, // 60 days using app
  ninetyDays, // 90 days using app

  // YOUR HABITS (6 milestones - Tree icons)
  fiveCompletions, // 5 habit completions
  fifteenCompletions, // 15 habit completions
  thirtyCompletions, // 30 habit completions
  sixtyCompletions, // 60 habit completions
  ninetyCompletions, // 90 habit completions
  hundredFiftyCompletions, // 150 habit completions
}

class MilestoneTracker {
  // Keys for SharedPreferences
  static const String _keyFirstStep = 'milestone_first_step';
  static const String _keySevenDays = 'milestone_seven_days';
  static const String _keyFourteenDays = 'milestone_fourteen_days';
  static const String _keyThirtyDays = 'milestone_thirty_days';
  static const String _keySixtyDays = 'milestone_sixty_days';
  static const String _keyNinetyDays = 'milestone_ninety_days';

  static const String _keyFiveCompletions = 'milestone_five_completions';
  static const String _keyFifteenCompletions = 'milestone_fifteen_completions';
  static const String _keyThirtyCompletions = 'milestone_thirty_completions';
  static const String _keySixtyCompletions = 'milestone_sixty_completions';
  static const String _keyNinetyCompletions = 'milestone_ninety_completions';
  static const String _keyHundredFiftyCompletions = 'milestone_hundred_fifty_completions';

  static const String _keyFirstUseDate = 'first_use_date';
  static const String _keyCurrentMilestone = 'current_milestone';

  // Milestone display information
  static const Map<Milestone, MilestoneInfo> info = {
    // YOUR JOURNEY milestones
    Milestone.firstStep: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: 'Your first step',
      subtitle: 'A seed has been planted.',
    ),
    Milestone.sevenDays: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: '7 days',
      subtitle: 'Your flower is starting to bloom.',
    ),
    Milestone.fourteenDays: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: '14 days',
      subtitle: 'Watch your flower opening.',
    ),
    Milestone.thirtyDays: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: '30 days',
      subtitle: 'Your flower is in full bloom.',
    ),
    Milestone.sixtyDays: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: '60 days',
      subtitle: 'Petals glowing with strength.',
    ),
    Milestone.ninetyDays: MilestoneInfo(
      category: MilestoneCategory.journey,
      title: '90 days',
      subtitle: 'A radiant bloom.',
    ),

    // YOUR HABITS milestones
    Milestone.fiveCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '5 completions',
      subtitle: 'The beginning of growth.',
    ),
    Milestone.fifteenCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '15 completions',
      subtitle: 'Leaves unfurling.',
    ),
    Milestone.thirtyCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '30 completions',
      subtitle: 'Roots taking hold.',
    ),
    Milestone.sixtyCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '60 completions',
      subtitle: 'A sapling growing strong.',
    ),
    Milestone.ninetyCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '90 completions',
      subtitle: 'Branches reaching wide.',
    ),
    Milestone.hundredFiftyCompletions: MilestoneInfo(
      category: MilestoneCategory.habits,
      title: '150 completions',
      subtitle: 'You\'ve grown into a strong tree.',
    ),
  };

  // Get milestone category
  static MilestoneCategory getCategory(Milestone milestone) {
    return info[milestone]!.category;
  }

  // Get all milestones by category
  static List<Milestone> getMilestonesByCategory(MilestoneCategory category) {
    return Milestone.values.where((m) => getCategory(m) == category).toList();
  }

  // Check if a milestone has been achieved
  static Future<bool> hasAchieved(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(milestone);
    return prefs.getBool(key) ?? false;
  }

  // Get achievement date for a milestone
  static Future<DateTime?> getAchievementDate(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_getKey(milestone)}_date';
    final dateStr = prefs.getString(key);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  // Record milestone achievement
  static Future<void> recordMilestone(Milestone milestone) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey(milestone);
    await prefs.setBool(key, true);
    await prefs.setString('${key}_date', DateTime.now().toIso8601String());
    await prefs.setString(_keyCurrentMilestone, milestone.toString());
  }

  // Get current milestone to display (if any)
  static Future<Milestone?> getCurrentMilestone() async {
    final prefs = await SharedPreferences.getInstance();
    final milestoneStr = prefs.getString(_keyCurrentMilestone);
    if (milestoneStr == null) return null;

    for (var milestone in Milestone.values) {
      if (milestone.toString() == milestoneStr) {
        return milestone;
      }
    }
    return null;
  }

  // Dismiss current milestone
  static Future<void> dismissCurrentMilestone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentMilestone);
  }

  // Record first use date
  static Future<void> recordFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyFirstUseDate)) {
      await prefs.setString(_keyFirstUseDate, DateTime.now().toIso8601String());
    }
  }

  // Get days since first use
  static Future<int> getDaysSinceFirstUse() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUseDateStr = prefs.getString(_keyFirstUseDate);
    if (firstUseDateStr == null) return 0;

    final firstUseDate = DateTime.parse(firstUseDateStr);
    final now = DateTime.now();
    return now.difference(firstUseDate).inDays;
  }

  // Check and record milestones based on current state
  static Future<void> checkMilestones({
    required int totalCompletions,
  }) async {
    final daysSinceFirstUse = await getDaysSinceFirstUse();

    // Check JOURNEY milestones (days-based)
    if (daysSinceFirstUse >= 90 && !(await hasAchieved(Milestone.ninetyDays))) {
      await recordMilestone(Milestone.ninetyDays);
      return;
    }
    if (daysSinceFirstUse >= 60 && !(await hasAchieved(Milestone.sixtyDays))) {
      await recordMilestone(Milestone.sixtyDays);
      return;
    }
    if (daysSinceFirstUse >= 30 && !(await hasAchieved(Milestone.thirtyDays))) {
      await recordMilestone(Milestone.thirtyDays);
      return;
    }
    if (daysSinceFirstUse >= 14 && !(await hasAchieved(Milestone.fourteenDays))) {
      await recordMilestone(Milestone.fourteenDays);
      return;
    }
    if (daysSinceFirstUse >= 7 && !(await hasAchieved(Milestone.sevenDays))) {
      await recordMilestone(Milestone.sevenDays);
      return;
    }
    if (totalCompletions >= 1 && !(await hasAchieved(Milestone.firstStep))) {
      await recordMilestone(Milestone.firstStep);
      return;
    }

    // Check HABITS milestones (completion-based)
    if (totalCompletions >= 150 && !(await hasAchieved(Milestone.hundredFiftyCompletions))) {
      await recordMilestone(Milestone.hundredFiftyCompletions);
      return;
    }
    if (totalCompletions >= 90 && !(await hasAchieved(Milestone.ninetyCompletions))) {
      await recordMilestone(Milestone.ninetyCompletions);
      return;
    }
    if (totalCompletions >= 60 && !(await hasAchieved(Milestone.sixtyCompletions))) {
      await recordMilestone(Milestone.sixtyCompletions);
      return;
    }
    if (totalCompletions >= 30 && !(await hasAchieved(Milestone.thirtyCompletions))) {
      await recordMilestone(Milestone.thirtyCompletions);
      return;
    }
    if (totalCompletions >= 15 && !(await hasAchieved(Milestone.fifteenCompletions))) {
      await recordMilestone(Milestone.fifteenCompletions);
      return;
    }
    if (totalCompletions >= 5 && !(await hasAchieved(Milestone.fiveCompletions))) {
      await recordMilestone(Milestone.fiveCompletions);
      return;
    }
  }

  // Helper to get SharedPreferences key for milestone
  static String _getKey(Milestone milestone) {
    switch (milestone) {
      case Milestone.firstStep:
        return _keyFirstStep;
      case Milestone.sevenDays:
        return _keySevenDays;
      case Milestone.fourteenDays:
        return _keyFourteenDays;
      case Milestone.thirtyDays:
        return _keyThirtyDays;
      case Milestone.sixtyDays:
        return _keySixtyDays;
      case Milestone.ninetyDays:
        return _keyNinetyDays;
      case Milestone.fiveCompletions:
        return _keyFiveCompletions;
      case Milestone.fifteenCompletions:
        return _keyFifteenCompletions;
      case Milestone.thirtyCompletions:
        return _keyThirtyCompletions;
      case Milestone.sixtyCompletions:
        return _keySixtyCompletions;
      case Milestone.ninetyCompletions:
        return _keyNinetyCompletions;
      case Milestone.hundredFiftyCompletions:
        return _keyHundredFiftyCompletions;
    }
  }
}

class MilestoneInfo {
  final MilestoneCategory category;
  final String title;
  final String subtitle;

  const MilestoneInfo({
    required this.category,
    required this.title,
    required this.subtitle,
  });
}
