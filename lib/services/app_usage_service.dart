import 'package:shared_preferences/shared_preferences.dart';

class AppUsageService {
  static const _firstLaunchKey = 'first_launch_date';

  /// Returns the first launch date, storing it on the very first call.
  static Future<DateTime> getFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_firstLaunchKey);

    if (stored != null) {
      return DateTime.parse(stored);
    }

    final now = DateTime.now();
    await prefs.setString(_firstLaunchKey, now.toIso8601String());
    return now;
  }

  /// Returns the number of full weeks since first launch (minimum 1).
  static Future<int> getWeekCount() async {
    final firstLaunch = await getFirstLaunchDate();
    final now = DateTime.now();
    final days = now.difference(firstLaunch).inDays;
    return days ~/ 7 < 1 ? 1 : days ~/ 7;
  }
}
