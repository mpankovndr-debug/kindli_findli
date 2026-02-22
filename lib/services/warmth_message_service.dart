import 'package:shared_preferences/shared_preferences.dart';

class WarmthMessageService {
  static const String _indexKey = 'warmth_message_index';

  static const List<String> _messages = [
    "That's okay. Tomorrow is still yours.",
    "Rest counts too.",
    "You don't have to every day. Just sometimes.",
    "Not today — and that's allowed.",
    "Be as kind to yourself as you'd be to a friend.",
    "The habit will be here when you're ready.",
    "Even stepping back gently is still showing up.",
    "Nothing is lost. You're still here.",
    "Some days are for resting. This might be one of them.",
    "Kindness toward yourself is a habit worth keeping.",
    "No streak to break. No score to lose. Just you.",
    "The gentlest days matter too.",
    "You showed up enough today just by being here.",
    "It's okay to let this one go.",
    "Progress isn't only visible. Sometimes it's just surviving.",
  ];

  /// Returns the next message in the rotation, persisted across sessions.
  static Future<String> getNext() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_indexKey) ?? 0;
    final message = _messages[current % _messages.length];
    await prefs.setInt(_indexKey, current + 1);
    return message;
  }
}