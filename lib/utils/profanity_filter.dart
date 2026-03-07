class ProfanityFilter {
  static const List<String> _profanities = [
    'fuck', 'shit', 'bitch', 'slut', 'whore', 'cunt', 'damn', 'ass',
    'bastard', 'dick', 'cock', 'pussy', 'asshole', 'piss', 'douche',
    'fag', 'retard', 'nigga', 'nigger', 'chink', 'spic', 'kike',
    'hell', 'crap', 'slag', 'twat', 'wanker', 'bollocks', 'prick',
    // Russian
    'хуй', 'хуя', 'хуе', 'хуё', 'хуи', 'хуил',
    'бля', 'блять', 'блядь', 'блядин',
    'пизд', 'пизда', 'пиздец', 'пиздос',
    'ебать', 'ебан', 'ебал', 'ёб', 'ебуч',
    'сука', 'сучк', 'сучар',
    'мудак', 'мудил',
    'дебил',
    'пидор', 'пидар', 'пидр',
    'говно', 'говён',
    'залуп',
    'шлюх', 'шалав',
    'жопа', 'жоп',
    'дерьм',
    'гандон',
    'урод',
    'хер', 'хера', 'херов', 'херн',
    'сосат', 'сос',
    'член',
    'трах',
    'нахуй', 'нахер', 'похер', 'похуй',
    'отсос',
    'минет',
    'манда',
  ];

  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase().trim();
    
    // Remove numbers and special characters for obfuscation detection
    final stripped = lowerText.replaceAll(RegExp(r'[0-9!@#$%^&*()\-_+=\[\]{};:,.?/\\|`~<>]'), '');
    // Normalize Cyrillic lookalikes to Latin for cross-script obfuscation
    const cyrToLat = {'а': 'a', 'е': 'e', 'о': 'o', 'р': 'p', 'с': 'c', 'у': 'y', 'х': 'x'};
    final normalized = stripped.split('').map((c) => cyrToLat[c] ?? c).join();
    
    for (final word in _profanities) {
      // Check exact match
      if (lowerText == word) {
        return true;
      }

      // Substring match on stripped text (essential for Cyrillic where \b doesn't work)
      if (stripped.contains(word)) {
        return true;
      }

      // Check word boundaries (works for Latin)
      final pattern = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      if (pattern.hasMatch(lowerText)) {
        return true;
      }

      // Check normalized version (catches Sl0t, B!tch, etc.)
      if (normalized.contains(word)) {
        return true;
      }

      // Check with common letter substitutions
      final obfuscated = word
          .replaceAll('o', '[o0]')
          .replaceAll('i', '[i1!]')
          .replaceAll('e', '[e3]')
          .replaceAll('a', '[a4@]')
          .replaceAll('s', r'[s5\$]');
      final obfuscatedPattern = RegExp(obfuscated, caseSensitive: false);
      if (obfuscatedPattern.hasMatch(lowerText)) {
        return true;
      }
    }
    
    return false;
  }

  static String clean(String text) {
    String cleaned = text;
    
    for (final word in _profanities) {
      final pattern = RegExp(word, caseSensitive: false);
      cleaned = cleaned.replaceAll(pattern, '*' * word.length);
    }
    
    return cleaned;
  }
}