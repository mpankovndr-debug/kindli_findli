import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WarmthMessageService {
  static const String _indexKey = 'warmth_message_index';

  static List<String> _messages(AppLocalizations l10n) => [
    l10n.warmthMsg1,
    l10n.warmthMsg2,
    l10n.warmthMsg3,
    l10n.warmthMsg4,
    l10n.warmthMsg5,
    l10n.warmthMsg6,
    l10n.warmthMsg7,
    l10n.warmthMsg8,
    l10n.warmthMsg9,
    l10n.warmthMsg10,
    l10n.warmthMsg11,
    l10n.warmthMsg12,
    l10n.warmthMsg13,
    l10n.warmthMsg14,
    l10n.warmthMsg15,
  ];

  /// Returns the next message in the rotation, persisted across sessions.
  static Future<String> getNext(AppLocalizations l10n) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_indexKey) ?? 0;
    final messages = _messages(l10n);
    final message = messages[current % messages.length];
    await prefs.setInt(_indexKey, current + 1);
    return message;
  }
}
