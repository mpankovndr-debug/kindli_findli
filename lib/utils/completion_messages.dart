import 'dart:math';

import '../l10n/app_localizations.dart';

/// System for managing habit completion messages with scientific insights
class CompletionMessages {
  static final Random _random = Random();

  // General supportive messages (used ~75% of the time)
  static List<String> _generalMessages(AppLocalizations l10n) => [
    l10n.completionMsg1,
    l10n.completionMsg2,
    l10n.completionMsg3,
    l10n.completionMsg4,
    l10n.completionMsg5,
    l10n.completionMsg6,
    l10n.completionMsg7,
    l10n.completionMsg8,
    l10n.completionMsg9,
    l10n.completionMsg10,
    l10n.completionMsg11,
    l10n.completionMsg12,
    l10n.completionMsg13,
    l10n.completionMsg14,
    l10n.completionMsg15,
    l10n.completionMsg16,
    l10n.completionMsg17,
    l10n.completionMsg18,
    l10n.completionMsg19,
    l10n.completionMsg20,
  ];

  // Scientific insights mapped to specific habit types
  // These are shown ~25% of the time for personalization
  static Map<String, List<String>> _habitInsights(AppLocalizations l10n) => {
    'water': [l10n.insightWater1, l10n.insightWater2, l10n.insightWater3],
    'exercise': [l10n.insightExercise1, l10n.insightExercise2, l10n.insightExercise3],
    'walk': [l10n.insightWalk1, l10n.insightWalk2, l10n.insightWalk3],
    'stretch': [l10n.insightStretch1, l10n.insightStretch2, l10n.insightStretch3],
    'sleep': [l10n.insightSleep1, l10n.insightSleep2, l10n.insightSleep3],
    'bed': [l10n.insightBed1, l10n.insightBed2, l10n.insightBed3],
    'breathe': [l10n.insightBreathe1, l10n.insightBreathe2, l10n.insightBreathe3],
    'meditate': [l10n.insightMeditate1, l10n.insightMeditate2, l10n.insightMeditate3],
    'read': [l10n.insightRead1, l10n.insightRead2, l10n.insightRead3],
    'call': [l10n.insightCall1, l10n.insightCall2, l10n.insightCall3],
    'friend': [l10n.insightFriend1, l10n.insightFriend2, l10n.insightFriend3],
    'write': [l10n.insightWrite1, l10n.insightWrite2, l10n.insightWrite3],
    'journal': [l10n.insightJournal1, l10n.insightJournal2, l10n.insightJournal3],
    'vegetable': [l10n.insightVegetable1, l10n.insightVegetable2, l10n.insightVegetable3],
    'breakfast': [l10n.insightBreakfast1, l10n.insightBreakfast2, l10n.insightBreakfast3],
    'phone': [l10n.insightPhone1, l10n.insightPhone2, l10n.insightPhone3],
    'screen': [l10n.insightScreen1, l10n.insightScreen2, l10n.insightScreen3],
    'clean': [l10n.insightClean1, l10n.insightClean2, l10n.insightClean3],
    'organize': [l10n.insightOrganize1, l10n.insightOrganize2, l10n.insightOrganize3],
    'draw': [l10n.insightDraw1, l10n.insightDraw2, l10n.insightDraw3],
    'music': [l10n.insightMusic1, l10n.insightMusic2, l10n.insightMusic3],
  };

  /// Get a completion message (75% general, 25% scientific insight)
  static String getMessage(String habitTitle, AppLocalizations l10n) {
    // 25% chance (1 in 4) for scientific insight
    final showInsight = _random.nextInt(4) == 0;

    if (showInsight) {
      final insight = _getScientificInsight(habitTitle, l10n);
      if (insight != null) {
        return insight;
      }
    }

    // Default to general message
    final messages = _generalMessages(l10n);
    return messages[_random.nextInt(messages.length)];
  }

  /// Get a scientific insight based on habit content
  static String? _getScientificInsight(String habitTitle, AppLocalizations l10n) {
    final lowerTitle = habitTitle.toLowerCase();
    final insights = _habitInsights(l10n);

    // Find matching insight category
    for (final entry in insights.entries) {
      if (lowerTitle.contains(entry.key)) {
        final categoryInsights = entry.value;
        return categoryInsights[_random.nextInt(categoryInsights.length)];
      }
    }

    return null; // No specific insight found
  }

  /// Get the celebration title (random warm word)
  static String getCelebrationTitle(AppLocalizations l10n) {
    final titles = [
      l10n.celebrationNice,
      l10n.celebrationWellDone,
      l10n.celebrationYouDidIt,
      l10n.celebrationGreat,
      l10n.celebrationWayToGo,
      l10n.celebrationGoodJob,
      l10n.celebrationLovely,
      l10n.celebrationThatCounts,
    ];
    return titles[_random.nextInt(titles.length)];
  }
}
