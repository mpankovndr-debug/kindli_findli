import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/moment.dart';

class MomentsService {
  static const String _key = 'moments_collection';

  /// Records a new moment. Call this every time a habit is completed.
  static Future<void> record(Moment moment) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.insert(0, moment); // newest first
    final encoded = jsonEncode(all.map((m) => m.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  /// Returns all moments, newest first.
  static Future<List<Moment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Moment.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns total number of moments — used on progress page.
  static Future<int> getCount() async {
    final all = await getAll();
    return all.length;
  }

  /// Returns the most recent moment — used on progress page.
  static Future<Moment?> getMostRecent() async {
    final all = await getAll();
    return all.isEmpty ? null : all.first;
  }

  /// Returns moments grouped by month label, e.g. "February 2026".
  static Future<Map<String, List<Moment>>> getGroupedByMonth() async {
    final all = await getAll();
    final Map<String, List<Moment>> grouped = {};

    for (final moment in all) {
      final key = _monthLabel(moment.completedAt);
      grouped.putIfAbsent(key, () => []).add(moment);
    }

    return grouped;
  }

  static String _monthLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}