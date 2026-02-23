import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.warmClay;

  AppTheme get theme => _theme;
  AppColorScheme get colors => AppColors.of(_theme);

  static const _key = 'selected_theme';

  static const List<AppTheme> premiumThemes = [
    AppTheme.clearSky,
    AppTheme.morningSlate,
  ];

  bool isPremiumTheme(AppTheme t) => premiumThemes.contains(t);

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _theme = AppTheme.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppTheme.warmClay,
      );
      notifyListeners();
    }
  }

  Future<void> setTheme(AppTheme t) async {
    _theme = t;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, t.name);
  }
}
