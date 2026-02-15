import 'package:flutter/widgets.dart';

/// Responsive utility class for Kindli
/// 
/// Initialize once at the top of your screen's build method:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   Responsive.init(context);
///   // ...
/// }
/// ```
/// 
/// Then use throughout:
/// ```dart
/// padding: EdgeInsets.all(Responsive.w(24)),
/// fontSize: Responsive.sp(17),
/// ```
class Responsive {
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleFactor;
  static late double _textScaleFactor;
  
  // Design baseline: iPhone 14/15 standard (393px)
  // Your Figma designs target Pro Max (430px) but we normalize to standard
  static const double _baseWidth = 393.0;
  
  /// Initialize responsive values. Call once per build.
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    
    _screenWidth = size.width;
    _screenHeight = size.height;
    
    // Scale factor for spacing/sizing
    // SE (375px) → 0.87, Standard (393px) → 1.0, Pro Max (430px) → 1.0
    // We cap at 1.0 so large screens don't get oversized elements
    _scaleFactor = (_screenWidth / _baseWidth).clamp(0.85, 1.0);
    
    // Text scale factor (respects system accessibility settings)
    _textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.3);
  }
  
  // ============ Scaled Values ============
  
  /// Scale a width/horizontal value
  static double w(double value) => value * _scaleFactor;
  
  /// Scale a height/vertical value
  static double h(double value) => value * _scaleFactor;
  
  /// Scale a font size (sp = scaled pixels)
  /// Respects system text scaling for accessibility
  static double sp(double value) => value * _scaleFactor;
  
  /// Scale a radius value
  static double r(double value) => value * _scaleFactor;
  
  // ============ Proportional to Screen ============
  
  /// Width as percentage of screen (0.0 - 1.0)
  static double wp(double percent) => _screenWidth * percent;
  
  /// Height as percentage of screen (0.0 - 1.0)
  static double hp(double percent) => _screenHeight * percent;
  
  // ============ Getters ============
  
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
  static double get scaleFactor => _scaleFactor;
  
  // ============ Device Helpers ============
  
  /// iPhone SE and similar small devices (< 380px)
  static bool get isSmallScreen => _screenWidth < 380;
  
  /// Standard iPhones (380-413px)
  static bool get isMediumScreen => _screenWidth >= 380 && _screenWidth < 414;
  
  /// Pro Max and large devices (≥ 414px)
  static bool get isLargeScreen => _screenWidth >= 414;
  
  /// Safe bottom padding (for devices with home indicator)
  static double get bottomSafeArea => _screenHeight > 800 ? 34 : 20;
}

/// Spacing constants using the responsive system
class Spacing {
  static double get xs => Responsive.w(4);
  static double get sm => Responsive.w(8);
  static double get md => Responsive.w(12);
  static double get base => Responsive.w(16);
  static double get lg => Responsive.w(20);
  static double get xl => Responsive.w(24);
  static double get xxl => Responsive.w(32);
  static double get xxxl => Responsive.w(48);
  
  /// Standard page padding (24px horizontal, 24px vertical)
  static EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: xl,
    vertical: xl,
  );
  
  /// Page padding with custom top
  static EdgeInsets pagePaddingTop(double top) => EdgeInsets.fromLTRB(
    xl, top, xl, xl,
  );
  
  /// Card internal padding (20px)
  static EdgeInsets get cardPadding => EdgeInsets.all(lg);
  
  /// Modal internal padding (28px)
  static EdgeInsets get modalPadding => EdgeInsets.all(xl + Spacing.xs);
  
  /// Habit card padding
  static EdgeInsets get habitCardPadding => EdgeInsets.symmetric(
    horizontal: lg,
    vertical: Responsive.w(18),
  );
  
  /// Gap between list items
  static double get listItemGap => base;
  
  /// Gap between sections
  static double get sectionGap => xxl;
}

/// Component size constants
class ComponentSizes {
  // Buttons
  static double get primaryButtonHeight => Responsive.w(52);
  static double get secondaryButtonHeight => Responsive.w(48);
  static double get buttonVerticalPadding => Responsive.w(16);
  static double get buttonHorizontalPadding => Responsive.w(32);
  
  // Minimum touch target (never scale below 44px for accessibility)
  static const double minTouchTarget = 44;
  
  // Border radius
  static double get modalRadius => Responsive.r(28);
  static double get cardRadius => Responsive.r(16);
  static double get buttonRadius => Responsive.r(20);
  static double get inputRadius => Responsive.r(12);
  static double get smallRadius => Responsive.r(8);
  static const double pillRadius = 9999;
  
  // Icons
  static double get iconSmall => Responsive.w(16);
  static double get iconMedium => Responsive.w(20);
  static double get iconLarge => Responsive.w(24);
  static double get iconXLarge => Responsive.w(48);
  
  // Tab bar
  static double get tabBarHeight => 56;
  static double get tabBarBottomPadding => 20;
  
  // Input fields
  static double get inputHeight => Responsive.w(52);
}

/// Kindli color palette
class AppColors {
  // Text colors
  static const Color textPrimary = Color(0xFF3C342A);
  static const Color textHeading = Color(0xFF3C342A);
  static const Color textSecondary = Color(0xFF8B7563);
  static const Color textMuted = Color(0xFFB5A89A);
  static const Color textLight = Color(0xFF9A8A78);
  static const Color textDisabled = Color(0xFFB5A89A);
  
  // Button colors
  static const Color buttonPrimary = Color(0xFF6B5B4A);
  static const Color buttonSecondary = Color(0xFFD8D2C8);
  static const Color buttonDisabled = Color(0xFFBEB6AA);
  static const Color buttonText = Color(0xFFF6F5F1);
  
  // Card & background colors
  static const Color cardBackground = Color(0xFFFAF9F6);
  static const Color pageBackground = Color(0xFFF3F4EF);
  static const Color modalBackground = Color(0xFFE8DDD0);
  
  // Border colors
  static const Color border = Color(0xFFE8E3DB);
  static const Color borderLight = Color(0xFFD8D2C8);
  
  // Accent colors
  static const Color success = Color(0xFF8B7563);
  static const Color successLight = Color(0xFFB5BAA3);
  static const Color error = Color(0xFFD84315);
  
  // Gradients
  static const List<Color> modalGradient = [
    Color(0xFFE8DDD0),
    Color(0xFFF0E5D8),
    Color(0xFFE3D6C7),
  ];
  
  static const List<Color> pageGradient = [
    Color(0xFFEDE8E2),
    Color(0xFFF3F4EF),
    Color(0xFFE8E3DB),
  ];
}