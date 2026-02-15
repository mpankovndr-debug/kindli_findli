class ProfanityFilter {
  static const List<String> _profanities = [
    'fuck', 'shit', 'bitch', 'slut', 'whore', 'cunt', 'damn', 'ass',
    'bastard', 'dick', 'cock', 'pussy', 'asshole', 'piss', 'douche',
    'fag', 'retard', 'nigga', 'nigger', 'chink', 'spic', 'kike',
    'hell', 'crap', 'slag', 'twat', 'wanker', 'bollocks', 'prick',
  ];

  static bool containsProfanity(String text) {
    final lowerText = text.toLowerCase().trim();
    
    // Remove numbers and special characters for obfuscation detection
    final normalized = lowerText.replaceAll(RegExp(r'[0-9!@#$%^&*()\-_+=\[\]{};:,.?/\\|`~<>]'), '');
    
    for (final word in _profanities) {
      // Check exact match
      if (lowerText == word) {
        return true;
      }
      
      // Check word boundaries
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