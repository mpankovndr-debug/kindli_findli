import 'package:flutter/material.dart';

enum AppTheme { warmClay, iris, clearSky, morningSlate }

class AppColorScheme {
  final Color bgGradientTop;
  final Color bgGradientMid;
  final Color bgGradientBottom;
  final double bgGradientTopOpacity;
  final double bgGradientMidOpacity;
  final double bgGradientBottomOpacity;
  final Color cardBackground;
  final double cardBackgroundOpacity;
  final Color cardPinned;
  final double cardPinnedOpacity;
  final Color cardDone;
  final double cardDoneOpacity;
  final Color cardBrowse;
  final double cardBrowseOpacity;
  final Color ctaPrimary;
  final Color ctaSecondary;
  final Color accentPinned;
  final Color accentRegular;
  final Color accentCustom;
  final Color accentMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLabel;
  final Color textSubtitle;
  final Color textTertiary;
  final Color textDisabled;
  final Color textMutedBrown;
  final Color borderCard;
  final double borderCardOpacity;
  final Color borderMedium;
  final Color borderWarm;
  final Color divider;
  final double dividerOpacity;
  final Color checkmarkFill;
  final Color checkmarkBackground;
  final double checkmarkBackgroundOpacity;
  final Color profileCard;
  final double profileCardOpacity;
  final Color momentsCard;
  final double momentsCardOpacity;
  final Color modalBg1;
  final Color modalBg2;
  final Color modalBg3;
  final Color modalShadow;
  final Color modalInnerShadow;
  final Color buttonDark;
  final Color buttonText;
  final Color surfaceLight;
  final Color surfaceLightest;
  final Color tabBarFade;
  final Color barrierColor;
  final double barrierOpacity;
  final Color destructive;
  final Color destructiveDark;
  final Color error;
  final Color success;
  final Color toastText;
  final Color onboardingBg1;
  final Color onboardingBg2;
  final Color onboardingBg3;
  final Color onboardingBg4;
  final Color catHealth;
  final Color catMood;
  final Color catProductivity;
  final Color catHome;
  final Color catRelationships;
  final Color catCreativity;
  final Color catFinances;
  final Color catSelfCare;
  final String backgroundSoft;  // habits + progress screens
  final String backgroundMs;    // moments screen
  final Color ctaAlternative;
  final Color completionHeart;
  final Color heartHighlight;
  final Color heartDeep;

  const AppColorScheme({
    required this.bgGradientTop,
    required this.bgGradientMid,
    required this.bgGradientBottom,
    required this.bgGradientTopOpacity,
    required this.bgGradientMidOpacity,
    required this.bgGradientBottomOpacity,
    required this.cardBackground,
    required this.cardBackgroundOpacity,
    required this.cardPinned,
    required this.cardPinnedOpacity,
    required this.cardDone,
    required this.cardDoneOpacity,
    required this.cardBrowse,
    required this.cardBrowseOpacity,
    required this.ctaPrimary,
    required this.ctaSecondary,
    required this.accentPinned,
    required this.accentRegular,
    required this.accentCustom,
    required this.accentMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLabel,
    required this.textSubtitle,
    required this.textTertiary,
    required this.textDisabled,
    required this.textMutedBrown,
    required this.borderCard,
    required this.borderCardOpacity,
    required this.borderMedium,
    required this.borderWarm,
    required this.divider,
    required this.dividerOpacity,
    required this.checkmarkFill,
    required this.checkmarkBackground,
    required this.checkmarkBackgroundOpacity,
    required this.profileCard,
    required this.profileCardOpacity,
    required this.momentsCard,
    required this.momentsCardOpacity,
    required this.modalBg1,
    required this.modalBg2,
    required this.modalBg3,
    required this.modalShadow,
    required this.modalInnerShadow,
    required this.buttonDark,
    required this.buttonText,
    required this.surfaceLight,
    required this.surfaceLightest,
    required this.tabBarFade,
    required this.barrierColor,
    required this.barrierOpacity,
    required this.destructive,
    required this.destructiveDark,
    required this.error,
    required this.success,
    required this.toastText,
    required this.onboardingBg1,
    required this.onboardingBg2,
    required this.onboardingBg3,
    required this.onboardingBg4,
    required this.catHealth,
    required this.catMood,
    required this.catProductivity,
    required this.catHome,
    required this.catRelationships,
    required this.catCreativity,
    required this.catFinances,
    required this.catSelfCare,
    required this.backgroundSoft,
    required this.backgroundMs,
    required this.ctaAlternative,
    required this.completionHeart,
    required this.heartHighlight,
    required this.heartDeep,
  });
}

class AppColors {
  static const Color catHealth =        Color(0xFFD96766);
  static const Color catMood =          Color(0xFF9B8299);
  static const Color catProductivity =  Color(0xFF8B9A6B);
  static const Color catHome =          Color(0xFF7B9E8A);
  static const Color catRelationships = Color(0xFFC4856E);
  static const Color catCreativity =    Color(0xFFB48BA3);
  static const Color catFinances =      Color(0xFFC49B5A);
  static const Color catSelfCare =      Color(0xFFB8A089);

  static const AppColorScheme warmClay = AppColorScheme(
    bgGradientTop:               Color(0xFFF2D4B0),
    bgGradientMid:               Color(0xFFE8BFA0),
    bgGradientBottom:            Color(0xFFD4A888),
    bgGradientTopOpacity:        0.15,
    bgGradientMidOpacity:        0.38,
    bgGradientBottomOpacity:     0.55,
    cardBackground:              Color(0xFFF9EBE0),
    cardBackgroundOpacity:       0.82,
    cardPinned:                  Color(0xFFFCF5EF),
    cardPinnedOpacity:           0.78,
    cardDone:                    Color(0xFFFFFFFF),
    cardDoneOpacity:             0.22,
    cardBrowse:                  Color(0xFFFFFFFF),
    cardBrowseOpacity:           0.40,
    ctaPrimary:                  Color(0xFF8B7563),
    ctaSecondary:                Color(0xFF7A6B5F),
    accentPinned:                Color(0xFFD96766),
    accentRegular:               Color(0xFFC19E8B),
    accentCustom:                Color(0xFFC49989),
    accentMuted:                 Color(0xFFA89181),
    textPrimary:                 Color(0xFF3C342A),
    textSecondary:               Color(0xFF9A8A78),
    textLabel:                   Color(0xFF8B7563),
    textSubtitle:                Color(0xFF6B5D52),
    textTertiary:                Color(0xFF9B8A7A),
    textDisabled:                Color(0xFFCFC0B0),
    textMutedBrown:              Color(0xFF9A8566),
    borderCard:                  Color(0xFFFFFFFF),
    borderCardOpacity:           0.18,
    borderMedium:                Color(0xFFD8D2C8),
    borderWarm:                  Color(0xFFE8E3DB),
    divider:                     Color(0xFF8B7563),
    dividerOpacity:              0.15,
    checkmarkFill:               Color(0xFF7A6A58),
    checkmarkBackground:         Color(0xFFD9CFC6),
    checkmarkBackgroundOpacity:  0.40,
    profileCard:                 Color(0xFFFFFFFF),
    profileCardOpacity:          0.50,
    momentsCard:                 Color(0xFFFFFFFF),
    momentsCardOpacity:          0.25,
    modalBg1:                    Color(0xFFF5ECE0),
    modalBg2:                    Color(0xFFEDE4D8),
    modalBg3:                    Color(0xFFE6DDD1),
    modalShadow:                 Color(0xFF32281E),
    modalInnerShadow:            Color(0xFFB4A591),
    buttonDark:                  Color(0xFF6B5B4A),
    buttonText:                  Color(0xFFF6F5F1),
    surfaceLight:                Color(0xFFF8F5F2),
    surfaceLightest:             Color(0xFFFAF7F2),
    tabBarFade:                  Color(0xFFC4B0A0),
    barrierColor:                Color(0xFF504638),
    barrierOpacity:              0.28,
    destructive:                 Color(0xFFC44B3F),
    destructiveDark:             Color(0xFFB5524D),
    error:                       Color(0xFFD84315),
    success:                     Color(0xFF6A8B6F),
    toastText:                   Color(0xFF4A3F35),
    onboardingBg1:               Color(0xFFF5EDE0),
    onboardingBg2:               Color(0xFFE8DCC8),
    onboardingBg3:               Color(0xFFDDD1C0),
    onboardingBg4:               Color(0xFFD9CDB8),
    catHealth:        Color(0xFFD96766),
    catMood:          Color(0xFF9B8299),
    catProductivity:  Color(0xFF8B9A6B),
    catHome:          Color(0xFF7B9E8A),
    catRelationships: Color(0xFFC4856E),
    catCreativity:    Color(0xFFB48BA3),
    catFinances:      Color(0xFFC49B5A),
    catSelfCare:      Color(0xFFB8A089),
    backgroundSoft:  'assets/images/background_soft_warm_clay.png',
    backgroundMs:    'assets/images/background_ms_warm_clay.png',
    ctaAlternative:  Color(0xFF6B8E6E),
    completionHeart: Color(0xFFC4908A),
    heartHighlight:  Color(0xFFE5B5B0),
    heartDeep:       Color(0xFFC99090),
  );

  static const AppColorScheme iris = AppColorScheme(
    bgGradientTop:               Color(0xFFD4CCE8),
    bgGradientMid:               Color(0xFFC8BEE0),
    bgGradientBottom:            Color(0xFFB8AED4),
    bgGradientTopOpacity:        0.15,
    bgGradientMidOpacity:        0.38,
    bgGradientBottomOpacity:     0.55,
    cardBackground:              Color(0xFFEDE8F8),
    cardBackgroundOpacity:       0.82,
    cardPinned:                  Color(0xFFF5F1FB),
    cardPinnedOpacity:           0.78,
    cardDone:                    Color(0xFFFFFFFF),
    cardDoneOpacity:             0.22,
    cardBrowse:                  Color(0xFFFFFFFF),
    cardBrowseOpacity:           0.40,
    ctaPrimary:                  Color(0xFF5547A0),
    ctaSecondary:                Color(0xFF4A3D8F),
    accentPinned:                Color(0xFFD96766),
    accentRegular:               Color(0xFF8878C8),
    accentCustom:                Color(0xFF9888C8),
    accentMuted:                 Color(0xFF8878B0),
    textPrimary:                 Color(0xFF26204A),
    textSecondary:               Color(0xFF6E66A0),
    textLabel:                   Color(0xFF5547A0),
    textSubtitle:                Color(0xFF4A4270),
    textTertiary:                Color(0xFF7E74A8),
    textDisabled:                Color(0xFFBEB8D8),
    textMutedBrown:              Color(0xFF7A6E9A),
    borderCard:                  Color(0xFFFFFFFF),
    borderCardOpacity:           0.18,
    borderMedium:                Color(0xFFCCC6DC),
    borderWarm:                  Color(0xFFDDD8EC),
    divider:                     Color(0xFF5547A0),
    dividerOpacity:              0.15,
    checkmarkFill:               Color(0xFF5547A0),
    checkmarkBackground:         Color(0xFFCFC8E8),
    checkmarkBackgroundOpacity:  0.40,
    profileCard:                 Color(0xFFFFFFFF),
    profileCardOpacity:          0.50,
    momentsCard:                 Color(0xFFFFFFFF),
    momentsCardOpacity:          0.25,
    modalBg1:                    Color(0xFFECE6F8),
    modalBg2:                    Color(0xFFF0EBF8),
    modalBg3:                    Color(0xFFF4F0FA),
    modalShadow:                 Color(0xFF1E1840),
    modalInnerShadow:            Color(0xFF9A8EC8),
    buttonDark:                  Color(0xFF3E3478),
    buttonText:                  Color(0xFFF5F2FA),
    surfaceLight:                Color(0xFFF2EFF8),
    surfaceLightest:             Color(0xFFF8F6FC),
    tabBarFade:                  Color(0xFFBEB4D4),
    barrierColor:                Color(0xFF2E2650),
    barrierOpacity:              0.28,
    destructive:                 Color(0xFFC44B3F),
    destructiveDark:             Color(0xFFB5524D),
    error:                       Color(0xFFD84315),
    success:                     Color(0xFF6A8B6F),
    toastText:                   Color(0xFF332B58),
    onboardingBg1:               Color(0xFFEDE5F5),
    onboardingBg2:               Color(0xFFDDD4EC),
    onboardingBg3:               Color(0xFFD0C6E2),
    onboardingBg4:               Color(0xFFC8BCD8),
    catHealth:        Color(0xFFD96766),
    catMood:          Color(0xFF9B8299),
    catProductivity:  Color(0xFF8B9A6B),
    catHome:          Color(0xFF7B9E8A),
    catRelationships: Color(0xFFC4856E),
    catCreativity:    Color(0xFFB48BA3),
    catFinances:      Color(0xFFC49B5A),
    catSelfCare:      Color(0xFFB8A089),
    backgroundSoft:  'assets/images/background_soft_iris.png',
    backgroundMs:    'assets/images/background_ms_iris.png',
    ctaAlternative:  Color(0xFF7C6FC4),
    completionHeart: Color(0xFF9888C8),
    heartHighlight:  Color(0xFFBFB0E8),
    heartDeep:       Color(0xFF9070C8),
  );

  static const AppColorScheme clearSky = AppColorScheme(
    bgGradientTop:               Color(0xFFBDD4E8),
    bgGradientMid:               Color(0xFFADC8E0),
    bgGradientBottom:            Color(0xFF9ABCD8),
    bgGradientTopOpacity:        0.15,
    bgGradientMidOpacity:        0.38,
    bgGradientBottomOpacity:     0.55,
    cardBackground:              Color(0xFFE5EEF8),
    cardBackgroundOpacity:       0.82,
    cardPinned:                  Color(0xFFF0F5FC),
    cardPinnedOpacity:           0.78,
    cardDone:                    Color(0xFFFFFFFF),
    cardDoneOpacity:             0.22,
    cardBrowse:                  Color(0xFFFFFFFF),
    cardBrowseOpacity:           0.40,
    ctaPrimary:                  Color(0xFF4A7BAD),
    ctaSecondary:                Color(0xFF3D6A9A),
    accentPinned:                Color(0xFFD96766),
    accentRegular:               Color(0xFF82B0D4),
    accentCustom:                Color(0xFF92B8D8),
    accentMuted:                 Color(0xFF88A4BE),
    textPrimary:                 Color(0xFF1E3145),
    textSecondary:               Color(0xFF637D96),
    textLabel:                   Color(0xFF4A7BAD),
    textSubtitle:                Color(0xFF3D5568),
    textTertiary:                Color(0xFF7B95AC),
    textDisabled:                Color(0xFFB8CAD8),
    textMutedBrown:              Color(0xFF6E8698),
    borderCard:                  Color(0xFFFFFFFF),
    borderCardOpacity:           0.18,
    borderMedium:                Color(0xFFC4D2DE),
    borderWarm:                  Color(0xFFD8E4EE),
    divider:                     Color(0xFF4A7BAD),
    dividerOpacity:              0.15,
    checkmarkFill:               Color(0xFF4A7BAD),
    checkmarkBackground:         Color(0xFFC4D5E6),
    checkmarkBackgroundOpacity:  0.40,
    profileCard:                 Color(0xFFFFFFFF),
    profileCardOpacity:          0.50,
    momentsCard:                 Color(0xFFFFFFFF),
    momentsCardOpacity:          0.25,
    modalBg1:                    Color(0xFFE6EFF8),
    modalBg2:                    Color(0xFFECF2F8),
    modalBg3:                    Color(0xFFF2F6FA),
    modalShadow:                 Color(0xFF162838),
    modalInnerShadow:            Color(0xFF8AACC8),
    buttonDark:                  Color(0xFF345878),
    buttonText:                  Color(0xFFF2F6FA),
    surfaceLight:                Color(0xFFF0F4F8),
    surfaceLightest:             Color(0xFFF6F9FC),
    tabBarFade:                  Color(0xFFACC0D4),
    barrierColor:                Color(0xFF243848),
    barrierOpacity:              0.28,
    destructive:                 Color(0xFFC44B3F),
    destructiveDark:             Color(0xFFB5524D),
    error:                       Color(0xFFD84315),
    success:                     Color(0xFF6A8B6F),
    toastText:                   Color(0xFF2A4458),
    onboardingBg1:               Color(0xFFE5EFF8),
    onboardingBg2:               Color(0xFFD4E2F0),
    onboardingBg3:               Color(0xFFC5D6E6),
    onboardingBg4:               Color(0xFFBAD0E0),
    catHealth:        Color(0xFFD96766),
    catMood:          Color(0xFF9B8299),
    catProductivity:  Color(0xFF8B9A6B),
    catHome:          Color(0xFF7B9E8A),
    catRelationships: Color(0xFFC4856E),
    catCreativity:    Color(0xFFB48BA3),
    catFinances:      Color(0xFFC49B5A),
    catSelfCare:      Color(0xFFB8A089),
    backgroundSoft:  'assets/images/background_soft_clear_sky.png',
    backgroundMs:    'assets/images/background_ms_clear_sky.png',
    ctaAlternative:  Color(0xFF4A7BAD),
    completionHeart: Color(0xFF82B0D4),
    heartHighlight:  Color(0xFFAAD0E8),
    heartDeep:       Color(0xFF6AA0C8),
  );

  static const AppColorScheme morningSlate = AppColorScheme(
    bgGradientTop:               Color(0xFFB8C8C4),
    bgGradientMid:               Color(0xFFA8BCB8),
    bgGradientBottom:            Color(0xFF94ADAA),
    bgGradientTopOpacity:        0.15,
    bgGradientMidOpacity:        0.38,
    bgGradientBottomOpacity:     0.55,
    cardBackground:              Color(0xFFE0EAE8),
    cardBackgroundOpacity:       0.82,
    cardPinned:                  Color(0xFFEEF4F3),
    cardPinnedOpacity:           0.78,
    cardDone:                    Color(0xFFFFFFFF),
    cardDoneOpacity:             0.22,
    cardBrowse:                  Color(0xFFFFFFFF),
    cardBrowseOpacity:           0.40,
    ctaPrimary:                  Color(0xFF4E7A75),
    ctaSecondary:                Color(0xFF3D6560),
    accentPinned:                Color(0xFFD96766),
    accentRegular:               Color(0xFF8DB5B0),
    accentCustom:                Color(0xFF9DBFBA),
    accentMuted:                 Color(0xFF88A8A4),
    textPrimary:                 Color(0xFF253332),
    textSecondary:               Color(0xFF6B8580),
    textLabel:                   Color(0xFF4E7A75),
    textSubtitle:                Color(0xFF3E5855),
    textTertiary:                Color(0xFF7B9894),
    textDisabled:                Color(0xFFB8CAC8),
    textMutedBrown:              Color(0xFF6E8884),
    borderCard:                  Color(0xFFFFFFFF),
    borderCardOpacity:           0.18,
    borderMedium:                Color(0xFFC4D2D0),
    borderWarm:                  Color(0xFFD8E6E4),
    divider:                     Color(0xFF4E7A75),
    dividerOpacity:              0.15,
    checkmarkFill:               Color(0xFF4E7A75),
    checkmarkBackground:         Color(0xFFC8D6D4),
    checkmarkBackgroundOpacity:  0.40,
    profileCard:                 Color(0xFFFFFFFF),
    profileCardOpacity:          0.50,
    momentsCard:                 Color(0xFFFFFFFF),
    momentsCardOpacity:          0.25,
    modalBg1:                    Color(0xFFE4EEEC),
    modalBg2:                    Color(0xFFEAF2F0),
    modalBg3:                    Color(0xFFF0F6F5),
    modalShadow:                 Color(0xFF1A2E2C),
    modalInnerShadow:            Color(0xFF8AB0AC),
    buttonDark:                  Color(0xFF365854),
    buttonText:                  Color(0xFFF2F6F5),
    surfaceLight:                Color(0xFFEEF4F2),
    surfaceLightest:             Color(0xFFF5F9F8),
    tabBarFade:                  Color(0xFFACBEBC),
    barrierColor:                Color(0xFF283E3C),
    barrierOpacity:              0.28,
    destructive:                 Color(0xFFC44B3F),
    destructiveDark:             Color(0xFFB5524D),
    error:                       Color(0xFFD84315),
    success:                     Color(0xFF6A8B6F),
    toastText:                   Color(0xFF2C4442),
    onboardingBg1:               Color(0xFFE2EEE8),
    onboardingBg2:               Color(0xFFD0E0DA),
    onboardingBg3:               Color(0xFFC2D4CE),
    onboardingBg4:               Color(0xFFB8CCC6),
    catHealth:        Color(0xFFD96766),
    catMood:          Color(0xFF9B8299),
    catProductivity:  Color(0xFF8B9A6B),
    catHome:          Color(0xFF7B9E8A),
    catRelationships: Color(0xFFC4856E),
    catCreativity:    Color(0xFFB48BA3),
    catFinances:      Color(0xFFC49B5A),
    catSelfCare:      Color(0xFFB8A089),
    backgroundSoft:  'assets/images/background_soft_morning_slate.png',
    backgroundMs:    'assets/images/background_ms_morning_slate.png',
    ctaAlternative:  Color(0xFF4E7A75),
    completionHeart: Color(0xFF8DB5B0),
    heartHighlight:  Color(0xFFAAC8C4),
    heartDeep:       Color(0xFF6A9E99),
  );

  static AppColorScheme of(AppTheme theme) {
    switch (theme) {
      case AppTheme.warmClay:     return warmClay;
      case AppTheme.iris:         return iris;
      case AppTheme.clearSky:     return clearSky;
      case AppTheme.morningSlate: return morningSlate;
    }
  }
}
