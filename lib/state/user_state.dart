import 'package:flutter/foundation.dart';
import '../onboarding_v2/onboarding_state.dart';

class UserState extends ChangeNotifier {
  String? _name;
  List<String> _focusAreas = [];
  bool _hasSubscription = false; // Track Kindli Beyond subscription

  // Getters
  String? get name => _name;
  List<String> get focusAreas => List.unmodifiable(_focusAreas);
  bool get hasSubscription => _hasSubscription;

  // Setters
  void setName(String? value) {
    _name = value;
    notifyListeners();
  }

  void setFocusAreas(List<String> areas) {
    _focusAreas = List.from(areas);
    notifyListeners();
  }

  void setSubscription(bool value) {
    _hasSubscription = value;
    notifyListeners();
  }
  
  void updateFromOnboarding(OnboardingState onboardingState) {
    _name = onboardingState.name;
    _focusAreas = List.from(onboardingState.focusAreas);
    notifyListeners();
  }
  
  void reset() {
    _name = null;
    _focusAreas = [];
    _hasSubscription = false;
    notifyListeners();
  }
}

// Keep the ValueNotifier for backwards compatibility
final ValueNotifier<String?> userNameNotifier = ValueNotifier(null);