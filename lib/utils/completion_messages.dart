import 'dart:math';

/// System for managing habit completion messages with scientific insights
class CompletionMessages {
  static final Random _random = Random();

  // General supportive messages (used ~75% of the time)
  static const List<String> _generalMessages = [
    "Small steps like this matter.",
    "You showed up today.",
    "This is how change happens.",
    "One step closer.",
    "You did what you said you would.",
    "That took effort. Good.",
    "Another small victory.",
    "You made it happen.",
    "Progress is progress.",
    "You followed through.",
    "This counts.",
    "You kept your word to yourself.",
    "Well done.",
    "You made time for this.",
    "That's growth right there.",
    "You pushed through.",
    "Another habit built.",
    "You committed and you did it.",
    "This adds up.",
    "You honored your intention.",
  ];

  // Scientific insights mapped to specific habit types
  // These are shown ~25% of the time for personalization
  static const Map<String, List<String>> _habitInsights = {
    // Water/Hydration habits
    'water': [
      'Even mild dehydration can affect mood and concentration.',
      'Your brain is 75% water. Hydration affects cognitive function.',
      'Drinking water can reduce fatigue by up to 14%.',
    ],

    // Exercise/Movement habits
    'exercise': [
      'Just 10 minutes of movement increases blood flow to your brain.',
      'Exercise releases endorphins that improve mood for hours.',
      'Regular movement reduces anxiety as effectively as meditation.',
    ],
    'walk': [
      'Walking outdoors reduces cortisol levels within 20 minutes.',
      'A 10-minute walk can boost creativity by 60%.',
      'Walking improves memory recall by increasing hippocampal activity.',
    ],
    'stretch': [
      'Stretching increases blood flow and reduces muscle tension.',
      'Regular stretching can improve flexibility by 20% in just weeks.',
      'Stretching triggers the parasympathetic nervous system, reducing stress.',
    ],

    // Sleep habits
    'sleep': [
      "Quality sleep strengthens memory consolidation by 40%.",
      "Consistent sleep schedules regulate circadian rhythm and mood.",
      "Sleep deprivation reduces cognitive performance like alcohol does.",
    ],
    'bed': [
      "A consistent bedtime routine signals your brain to prepare for sleep.",
      "Going to bed at the same time improves sleep quality by 25%.",
      "Your body's natural melatonin production peaks with routine.",
    ],

    // Mindfulness/Breathing habits
    'breathe': [
      'Deep breathing activates the vagus nerve, calming your nervous system.',
      'Controlled breathing can reduce stress hormones within minutes.',
      'Box breathing is used by Navy SEALs to manage high-stress situations.',
    ],
    'meditate': [
      'Just 10 minutes of meditation increases gray matter in the brain.',
      'Regular meditation reduces the size of the amygdala (fear center).',
      'Mindfulness practice improves emotional regulation over time.',
    ],

    // Reading habits
    'read': [
      'Reading for 6 minutes can reduce stress levels by 68%.',
      'Regular reading strengthens neural pathways and connectivity.',
      'Reading before bed improves sleep quality more than screens.',
    ],

    // Social connection habits
    'call': [
      'Social connection is as important to health as exercise and diet.',
      'A 10-minute conversation can reduce feelings of loneliness.',
      'Voice contact releases oxytocin, the bonding hormone.',
    ],
    'friend': [
      'Strong social ties can increase longevity by 50%.',
      'Quality friendships reduce stress hormones significantly.',
      'Social connection boosts immune system function.',
    ],

    // Writing/Journaling habits
    'write': [
      'Writing about emotions activates the prefrontal cortex, reducing stress.',
      'Journaling can improve immune function and reduce symptoms.',
      'Expressive writing helps process difficult experiences.',
    ],
    'journal': [
      'Daily journaling increases self-awareness and emotional clarity.',
      'Writing down worries reduces rumination and anxiety.',
      'Gratitude journaling rewires the brain for positivity over time.',
    ],

    // Nutrition habits
    'vegetable': [
      'Eating vegetables increases gut bacteria diversity, improving mood.',
      'Plant nutrients support neurotransmitter production.',
      'Colorful vegetables contain antioxidants that protect brain cells.',
    ],
    'breakfast': [
      'Eating breakfast stabilizes blood sugar and improves focus.',
      'Morning nutrition jumpstarts your metabolism for the day.',
      'Breakfast eaters have better cognitive performance.',
    ],

    // Screen time/Digital habits
    'phone': [
      'Reducing screen time before bed improves sleep quality by 30%.',
      'Blue light suppresses melatonin production for up to 3 hours.',
      'Taking breaks from screens reduces eye strain and headaches.',
    ],
    'screen': [
      'Every hour away from screens improves mental clarity.',
      'Digital detoxes reduce anxiety and improve real-world connection.',
      'Screen breaks help maintain healthy dopamine regulation.',
    ],

    // Cleaning/Organization habits
    'clean': [
      'A tidy space reduces cortisol levels and mental clutter.',
      'Organized environments improve focus and productivity by 25%.',
      'Cleaning is a form of physical activity that reduces stress.',
    ],
    'organize': [
      'Organization reduces decision fatigue throughout your day.',
      'Clutter-free spaces improve cognitive processing.',
      'An organized environment correlates with better sleep quality.',
    ],

    // Creative habits
    'draw': [
      'Creative activities increase dopamine production naturally.',
      'Art engages both brain hemispheres, improving neural connectivity.',
      'Drawing reduces stress hormones within 45 minutes.',
    ],
    'music': [
      'Playing music strengthens the corpus callosum in the brain.',
      'Musical practice improves executive function and memory.',
      'Music activates the reward system, releasing dopamine.',
    ],
  };

  /// Get a completion message (75% general, 25% scientific insight)
  static String getMessage(String habitTitle) {
    // 25% chance (1 in 4) for scientific insight
    final showInsight = _random.nextInt(4) == 0;

    if (showInsight) {
      final insight = _getScientificInsight(habitTitle);
      if (insight != null) {
        return insight;
      }
    }

    // Default to general message
    return _generalMessages[_random.nextInt(_generalMessages.length)];
  }

  /// Get a scientific insight based on habit content
  static String? _getScientificInsight(String habitTitle) {
    final lowerTitle = habitTitle.toLowerCase();

    // Find matching insight category
    for (final entry in _habitInsights.entries) {
      if (lowerTitle.contains(entry.key)) {
        final insights = entry.value;
        return insights[_random.nextInt(insights.length)];
      }
    }

    return null; // No specific insight found
  }

  /// Get the celebration title (random warm word)
  static String getCelebrationTitle() {
    const titles = [
      'Nice',
      'Well done',
      'You did it',
      'Great',
      'Way to go',
      'Good job',
      'Lovely',
      'That counts',
    ];
    return titles[_random.nextInt(titles.length)];
  }
}
