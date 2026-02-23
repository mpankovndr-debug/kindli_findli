import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors, Material;
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'theme/app_colors.dart';
import 'theme/theme_provider.dart';
import 'onboarding_v2/onboarding_state.dart';
import 'onboarding_v2/welcome_v2_screen.dart';
import 'state/user_state.dart';
import 'screens/paywall_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/habit_completion_modal.dart';
import 'utils/profanity_filter.dart'; // Add this
import 'utils/responsive_utils.dart';
import 'utils/text_styles.dart';
import 'utils/ios_version.dart';
import 'services/notification_scheduler.dart';

// ✅ ADD THIS HELPER HERE (before the main() function):
Future<T?> showIntendedModal<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
}) {
  final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
  return showCupertinoDialog<T>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.modalBg1.withOpacity(0.96),
                    colors.modalBg2.withOpacity(0.96),
                    colors.modalBg3.withOpacity(0.96),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.modalShadow.withOpacity(0.35),
                    blurRadius: 70,
                    offset: const Offset(0, 25),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFFFFFF).withOpacity(0.6),
                    blurRadius: 0,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                  ),
                  BoxShadow(
                    color: colors.modalInnerShadow.withOpacity(0.15),
                    blurRadius: 0,
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: Spacing.modalPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h2(context),
                        textAlign: TextAlign.center,
                      ),

                      if (subtitle != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          subtitle,
                          style: AppTextStyles.body(context),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 32),

                      ...actions,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/* -------------------- INTENDED DIALOG BUILDER -------------------- */

void showIntendedDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
  Widget? content,
}) {
  final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
  showIntendedModal(
    context: context,
    title: title,
    subtitle: subtitle,
    actions: actions.map((action) {
      // Convert CupertinoDialogAction to styled buttons
      if (action is CupertinoDialogAction) {
        return CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 12),
          onPressed: action.onPressed,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: action.isDefaultAction
                  ? colors.textSecondary
                  : colors.textPrimary,
            ),
            child: action.child,
          ),
        );
      }
      return action;
    }).toList(),
  );
}

/// Styled popup modal with blur barrier, depth, and fade-in animation.
/// Use for all informational/confirmation modals shown via showCupertinoModalPopup.
Future<T?> showStyledPopup<T>({
  required BuildContext context,
  required Widget child,
}) {
  final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
  return showCupertinoModalPopup<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    builder: (context) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, value, animChild) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.95 + (0.05 * value),
            child: animChild,
          ),
        );
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.modalBg1,
                colors.modalBg2,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 0,
                spreadRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: child,
        ),
      ),
    ),
  );
}

/// Primary filled button for styled popups
Widget styledPrimaryButton({
  required String label,
  required VoidCallback onPressed,
  Color? color,
}) {
  return Builder(
    builder: (ctx) {
      final resolvedColor = color ?? Provider.of<ThemeProvider>(ctx, listen: false).colors.buttonDark;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: resolvedColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: CupertinoButton(
          color: resolvedColor,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      );
    },
  );
}

/// Secondary outline button for styled popups
Widget styledSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return Builder(
    builder: (ctx) {
      final colors = Provider.of<ThemeProvider>(ctx, listen: false).colors;
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.borderMedium, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 16),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ),
      );
    },
  );
}

/* -------------------- THEME COLORS -------------------- */
// Old module-level constants removed — use colors.buttonDark, colors.surfaceLightest, etc. via ThemeProvider

/* -------------------- APP BACKGROUND -------------------- */

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.colors;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image — fully visible, barely softened
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Image.asset(
            colors.backgroundSoft,
            fit: BoxFit.cover,
          ),
        ),

        // Warm gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                colors.bgGradientTop.withOpacity(0.15),
                colors.bgGradientMid.withOpacity(0.38),
                colors.bgGradientBottom.withOpacity(0.55),
              ],
            ),
          ),
        ),

        // Grey wash — desaturates the combined bg + gradient (Iris only)
        if (themeProvider.theme == AppTheme.iris)
          Container(color: const Color(0xFFF0EDF2).withOpacity(0.45)),

        child,
      ],
    );
  }
}

/* -------------------- MODELS -------------------- */

class Habit {
  final String id;
  final String title;
  final String emoji;

  const Habit({
    required this.id,
    required this.title,
    required this.emoji,
  });
}

const List<Habit> habits = [
  Habit(id: 'breath', title: 'Three slow breaths', emoji: '🌬️'),
  Habit(id: 'pause', title: 'Ten-second pause', emoji: '⏸️'),
  Habit(id: 'water', title: 'Mindful water', emoji: '💧'),
  Habit(id: 'stretch', title: 'Gentle stretch', emoji: '🧍'),
  Habit(id: 'priority', title: 'One priority', emoji: '🎯'),
  Habit(id: 'checkin', title: 'Honest check-in', emoji: '💬'),
];

/* -------------------- SERVICES -------------------- */

class HabitTracker {
  static String _key(String habitTitle, DateTime date) {
    final d = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    // Create a more robust ID from the title
    final id = habitTitle
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_') // Replace non-alphanumeric with underscore
        .replaceAll(RegExp(r'_+'), '_') // Remove duplicate underscores
        .replaceAll(RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores
    return 'habit_done_${id}_$d';
  }

  static Future<void> markDone(String habitTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(habitTitle, DateTime.now());
    await prefs.setBool(key, true);
  }

  static Future<bool> wasDone(String habitTitle, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(habitTitle, date);
    final result = prefs.getBool(key) ?? false;
    return result;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationScheduler.initialize();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialized (e.g. hot restart)
  }
  await IOSVersion.init();
  final prefs = await SharedPreferences.getInstance();
  
  // Check if this is first run
  final isFirstRun = prefs.getBool('first_run') ?? true;
  if (isFirstRun) {
    // Clear all data on first run
    await prefs.clear();
    await prefs.setBool('first_run', false);
  }
  
  // Load saved name
  final savedName = prefs.getString('user_name');
  
  // VALIDATE SAVED NAME FOR PROFANITY
  if (savedName != null && ProfanityFilter.containsProfanity(savedName)) {
    await prefs.remove('user_name');
    userNameNotifier.value = null;
  } else {
    userNameNotifier.value = savedName;
  }

  // Create OnboardingState instance and load saved habits
  final onboardingState = OnboardingState();
  await onboardingState.loadUserHabits();
  
  // Sync the saved name to OnboardingState
  if (savedName != null && savedName.isNotEmpty && !ProfanityFilter.containsProfanity(savedName)) {
    onboardingState.setName(savedName);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: onboardingState),
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const IntendedApp(),
    ),
  );
}

class IntendedApp extends StatelessWidget {
  const IntendedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      theme: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'Sora',
            fontFamilyFallback: ['SF Pro', 'SF Pro Rounded'],
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          Responsive.init(context);
          return const WelcomeV2Screen();
        },
      ),
    );
  }
}

/* -------------------- WELCOME -------------------- */

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;

      _fadeController.forward();

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, animation, __) => const MainTabs(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),

          Container(
            color: colors.surfaceLightest.withOpacity(0.45),
          ),

          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fadeController),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: userNameNotifier,
                        builder: (context, name, _) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            name == null || name.isEmpty
                                ? l10n.welcomeTitle
                                : l10n.welcomeTitleWithName(name),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              letterSpacing: -0.6,
                              color: colors.textPrimary,
                              fontFamilyFallback: const [
                                'SF Pro Rounded',
                                'SF Pro',
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      Text(
                        AppLocalizations.of(context).welcomeSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          letterSpacing: -0.15,
                          color: colors.textSubtitle,
                          fontFamilyFallback: const [
                            'SF Pro Rounded',
                            'SF Pro',
                          ],
                          shadows: [
                            Shadow(
                              blurRadius: 6,
                              color: const Color(0xFFFFFFFF).withOpacity(0.9),
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              blurRadius: 20,
                              color: colors.surfaceLightest.withOpacity(0.9),
                              offset: const Offset(0, 2),
                            ),
                            Shadow(
                              blurRadius: 30,
                              color: const Color(0xFF000000).withOpacity(0.05),
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------- TABS -------------------- */

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Screens
          IndexedStack(
            index: _currentIndex,
            children: [
              const HabitsScreen(),
              ProgressScreen(),
              const ProfileScreen(),
            ],
          ),

          // Gradient fade behind tab bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.tabBarFade.withOpacity(0.0),
                      colors.tabBarFade.withOpacity(0.85),
                      colors.tabBarFade.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Floating pill tab bar
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: _CustomTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CustomTabBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: colors.modalBg1.withOpacity(0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TabItem(icon: CupertinoIcons.checkmark_circle, iconSelected: CupertinoIcons.checkmark_circle_fill, index: 0, currentIndex: currentIndex, onTap: onTap),
              _TabItem(icon: CupertinoIcons.chart_bar, iconSelected: CupertinoIcons.chart_bar_fill, index: 1, currentIndex: currentIndex, onTap: onTap),
              _TabItem(icon: CupertinoIcons.person_circle, iconSelected: CupertinoIcons.person_circle_fill, index: 2, currentIndex: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData iconSelected;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.icon,
    required this.iconSelected,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    final colors = context.watch<ThemeProvider>().colors;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? iconSelected : icon,
            key: ValueKey(isSelected),
            size: 24,
            color: isSelected
                ? colors.ctaPrimary
                : colors.textDisabled,
          ),
        ),
      ),
    );
  }
}

// [Rest of your screens remain the same - HabitsScreen, HabitActionScreen, HabitResultScreen, ProgressScreen, ProfileScreen]

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with TickerProviderStateMixin {
  bool _shouldAnimateCards = false;

  // "Hold for options" tooltip
  AnimationController? _tooltipController;
  Animation<double>? _tooltipOpacity;
  bool _animationsInitialized = false;
  List<AnimationController> _cardControllers = [];
  List<Animation<double>> _cardFadeAnimations = [];
  List<Animation<Offset>> _cardSlideAnimations = [];

  // Greeting animation
  late AnimationController _greetingController;
  late Animation<double> _greetingFadeAnimation;
  late Animation<Offset> _greetingSlideAnimation;
  bool _greetingAnimationInitialized = false;

  static List<String> _getDailyMessages(AppLocalizations l10n) => [
    l10n.dailyMessage1, l10n.dailyMessage2, l10n.dailyMessage3,
    l10n.dailyMessage4, l10n.dailyMessage5, l10n.dailyMessage6,
    l10n.dailyMessage7, l10n.dailyMessage8, l10n.dailyMessage9,
    l10n.dailyMessage10, l10n.dailyMessage11, l10n.dailyMessage12,
    l10n.dailyMessage13, l10n.dailyMessage14, l10n.dailyMessage15,
    l10n.dailyMessage16, l10n.dailyMessage17, l10n.dailyMessage18,
    l10n.dailyMessage19, l10n.dailyMessage20, l10n.dailyMessage21,
    l10n.dailyMessage22, l10n.dailyMessage23, l10n.dailyMessage24,
    l10n.dailyMessage25,
  ];

  String _getTodaysMessage(AppLocalizations l10n) {
    final messages = _getDailyMessages(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return messages[dayOfYear % messages.length];
  }

  Future<void> _checkAndTriggerCardAnimations() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if we just completed onboarding (skip animation)
    final justCompletedOnboarding = prefs.getBool('just_completed_onboarding') ?? false;
    if (justCompletedOnboarding) {
      await prefs.setBool('just_completed_onboarding', false);
      return;
    }

    // Check last animation date
    final lastAnimationDate = prefs.getString('last_card_animation_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastAnimationDate != today) {
      // First open of the day - animate!
      await prefs.setString('last_card_animation_date', today);
      setState(() {
        _shouldAnimateCards = true;
      });
    }
  }

  void _initializeCardAnimations(int cardCount) {
    if (_animationsInitialized || !_shouldAnimateCards || cardCount == 0) return;

    _animationsInitialized = true;

    // Dispose any existing controllers
    for (var controller in _cardControllers) {
      controller.dispose();
    }

    _cardControllers = List.generate(
      cardCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _cardFadeAnimations = _cardControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _cardSlideAnimations = _cardControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Start staggered animations (80ms between each)
    for (var i = 0; i < _cardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted && i < _cardControllers.length) {
          _cardControllers[i].forward();
        }
      });
    }
  }

  Widget _buildAnimatedHabitCard(Widget card, int index) {
    if (!_shouldAnimateCards || index >= _cardFadeAnimations.length) {
      return card;
    }

    return FadeTransition(
      opacity: _cardFadeAnimations[index],
      child: SlideTransition(
        position: _cardSlideAnimations[index],
        child: card,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkHoldTip();
    _checkAndTriggerCardAnimations();
    _initializeGreetingAnimation();
  }

  void _initializeGreetingAnimation() {
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOut),
    );

    _greetingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05), // 10px equivalent slide up
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeOut),
    );

    _greetingAnimationInitialized = true;

    // Small delay before starting
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _greetingController.forward();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    if (_greetingAnimationInitialized) {
      _greetingController.dispose();
    }
    _tooltipController?.dispose();
    super.dispose();
  }

  void _showBrowseHabits(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.textPrimary.withOpacity(0.08),
      builder: (context) => const BrowseHabitsSheet(),
    );
  }


  Future<void> _checkHoldTip() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('has_seen_hold_tip') ?? false;
    if (seen || !mounted) return;

    final onboardingState = context.read<OnboardingState>();
    if (onboardingState.userHabits.isEmpty) return;

    // Create tooltip animation
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _tooltipOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tooltipController!, curve: Curves.easeOut),
    );

    // Fade in after 1 second
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {});
    _tooltipController!.forward();

    // Auto-dismiss after 4 seconds
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    _dismissHoldTip();
  }

  Future<void> _dismissHoldTip() async {
    if (_tooltipController == null || !_tooltipController!.isAnimating && _tooltipController!.value == 0) return;

    await _tooltipController!.reverse();
    if (!mounted) return;
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_hold_tip', true);
  }

  void _createCustomHabit(BuildContext context) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final onboardingState = context.read<OnboardingState>();
    
    if (!onboardingState.canAddCustomHabit()) {
      final l10n = AppLocalizations.of(context);
      showIntendedModal(
        context: context,
        title: l10n.customHabitLimitTitle,
        subtitle: l10n.customHabitLimitMessage,
        actions: [
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              onPressed: () {
                Navigator.pop(context);
                showCupertinoModalPopup(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.5),
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  builder: (context) => const PaywallScreen(),
                );
              },
              color: colors.buttonDark,
              borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.appUnlockPlus,
                style: AppTextStyles.buttonPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.commonNotNow,
              style: AppTextStyles.buttonSecondary(context),
            ),
          ),
        ],
      );
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => const _CreateCustomHabitScreen(),
      ),
    );
  }

  int _getAvailableHabitsCount(BuildContext context) {
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    final onboardingState = context.watch<OnboardingState>();
    final l10n = AppLocalizations.of(context);
    final allHabits = onboardingState.userHabits;
    final pinnedHabit = onboardingState.pinnedHabit;

    // Split habits into pinned and unpinned
    final pinned = pinnedHabit != null && allHabits.contains(pinnedHabit)
        ? [pinnedHabit]
        : <String>[];
    final unpinnedAll = allHabits.where((h) => h != pinnedHabit).toList();
    // Sort: unpinned custom habits first, then standard/completed
    final unpinnedCustom = unpinnedAll.where((h) => onboardingState.isCustomHabit(h)).toList();
    final unpinnedStandard = unpinnedAll.where((h) => !onboardingState.isCustomHabit(h)).toList();
    final unpinned = [...unpinnedCustom, ...unpinnedStandard];

    final now = DateTime.now();
    final dateStr = '${_getDayName(now.weekday, l10n)}, ${_getMonthName(now.month, l10n)} ${now.day}';

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header with date (animated)
              FadeTransition(
                opacity: _greetingAnimationInitialized
                    ? _greetingFadeAnimation
                    : const AlwaysStoppedAnimation(1.0),
                child: SlideTransition(
                  position: _greetingAnimationInitialized
                      ? _greetingSlideAnimation
                      : const AlwaysStoppedAnimation(Offset.zero),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTodaysMessage(l10n),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            fontFamily: 'Sora',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.checkmarkFill,
                            fontFamily: 'Sora',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // "Hold for options" tooltip
              if (_tooltipController != null && _tooltipOpacity != null)
                AnimatedBuilder(
                  animation: _tooltipOpacity!,
                  builder: (context, child) {
                    if (_tooltipOpacity!.value == 0) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: _dismissHoldTip,
                      child: Opacity(
                        opacity: _tooltipOpacity!.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 4, 32, 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: colors.modalBg1.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.35),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  l10n.habitsHoldForOptions,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colors.ctaPrimary,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // Habits content
              if (allHabits.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.habitsCompleteOnboarding,
                      style: AppTextStyles.buttonSecondary(context),
                    ),
                  ),
                )
              else ...[
                // Initialize card animations if needed
                if (_shouldAnimateCards && !_animationsInitialized)
                  Builder(builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _initializeCardAnimations(allHabits.length);
                    });
                    return const SizedBox.shrink();
                  }),

                // Pinned section (stays fixed, not scrollable)
                if (pinned.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            l10n.habitsPinned,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.ctaPrimary,
                              letterSpacing: 1.0,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...pinned.asMap().entries.map((entry) {
                          final index = entry.key;
                          final habit = entry.value;
                          return _buildAnimatedHabitCard(
                            _HabitCard(
                              key: ValueKey(habit),
                              habitTitle: habit,
                              isPinned: true,
                              accentColor: colors.accentPinned,  // Terracotta
                            ),
                            index,
                          );
                        }),
                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: colors.borderWarm,
                        ),
                      ],
                    ),
                  ),

                // Scrollable section (suggestions + browse + create)
                Expanded(
                  child: Listener(
                    onPointerDown: (_) => _dismissHoldTip(),
                    child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      24, pinned.isNotEmpty ? 24 : 16, 24, 140,
                    ),
                    children: [
                      // Today's Suggestions section
                      if (unpinned.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            l10n.habitsSuggestions,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.ctaPrimary,
                              letterSpacing: 1.0,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...unpinned.asMap().entries.map((entry) {
                          final index = entry.key;
                          final habit = entry.value;
                          final animationIndex = pinned.length + index; // Offset by pinned count
                          return _buildAnimatedHabitCard(
                            _HabitCard(
                              key: ValueKey(habit),
                              habitTitle: habit,
                              accentColor: colors.accentRegular,  // Warm taupe
                            ),
                            animationIndex,
                          );
                        }),
                      ],

                      // CREATE CUSTOM HABIT BUTTON / LOCKED SLOT
                      const SizedBox(height: 16),

                      Builder(builder: (context) {
                        final customCount = onboardingState.customHabits.length;
                        final isSubscribed = context.read<UserState>().hasSubscription;

                        if (customCount < 2 || isSubscribed)
                          return Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: GestureDetector(
                              onTap: () => _createCustomHabit(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(24),
                                    dashPattern: const [8, 4],
                                    color: colors.ctaPrimary.withOpacity(0.20),
                                    strokeWidth: 2,
                                    child: Container(
                                      width: double.infinity,
                                      height: 96,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colors.modalBg1.withOpacity(0.40),
                                            colors.modalBg1.withOpacity(0.20),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFFFFFFF).withOpacity(0.50),
                                            ),
                                            child: Icon(
                                              CupertinoIcons.add,
                                              size: 18,
                                              color: colors.ctaPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            l10n.habitsCreateCustom,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: colors.ctaPrimary,
                                              fontFamily: 'Sora',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                        // Limit reached & not subscribed: show locked slot
                        return Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: GestureDetector(
                            onTap: () {
                              showCupertinoModalPopup(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.5),
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                builder: (context) => const PaywallScreen(),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: colors.ctaPrimary.withOpacity(0.10),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: Container(
                                    width: double.infinity,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colors.modalBg1.withOpacity(0.9),
                                          colors.modalBg1.withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: const Color(0xFFFFFFFF).withOpacity(0.6),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.ctaPrimary.withOpacity(0.10),
                                          blurRadius: 32,
                                        ),
                                        BoxShadow(
                                          color: colors.ctaPrimary.withOpacity(0.10),
                                          blurRadius: 0,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.hardEdge,
                                      children: [
                                        Positioned(
                                          bottom: -20,
                                          right: -20,
                                          child: Container(
                                            width: 128,
                                            height: 128,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  colors.ctaPrimary.withOpacity(0.10),
                                                  colors.ctaPrimary.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.lock,
                                                  size: 16,
                                                  color: colors.ctaPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                l10n.habitsCreateCustom,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textPrimary.withOpacity(0.60),
                                                  fontFamily: 'Sora',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // BROWSE ALL HABITS CARD
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () => _showBrowseHabits(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.cardBrowse.withOpacity(colors.cardBrowseOpacity),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.20),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.textPrimary.withOpacity(0.04),
                                      blurRadius: 16,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.habitsBrowseAll,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: colors.textPrimary,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          l10n.habitsMoreAvailable(_getAvailableHabitsCount(context)),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textSecondary,
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 18,
                                      color: colors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday, AppLocalizations l10n) {
    final days = [l10n.dayMonday, l10n.dayTuesday, l10n.dayWednesday, l10n.dayThursday, l10n.dayFriday, l10n.daySaturday, l10n.daySunday];
    return days[weekday - 1];
  }

  String _getMonthName(int month, AppLocalizations l10n) {
    final months = [
      l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch, l10n.monthApril, l10n.monthMay, l10n.monthJune,
      l10n.monthJuly, l10n.monthAugust, l10n.monthSeptember, l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
    ];
    return months[month - 1];
  }
}

// ============================================================
// CREATE CUSTOM HABIT SCREEN
// ============================================================

class _CreateCustomHabitScreen extends StatefulWidget {
  const _CreateCustomHabitScreen();

  @override
  State<_CreateCustomHabitScreen> createState() => _CreateCustomHabitScreenState();
}

class _CreateCustomHabitScreenState extends State<_CreateCustomHabitScreen> {
  final _controller = TextEditingController();

  bool get _canSave {
    final text = _controller.text.trim();
    return text.isNotEmpty && 
           text.length >= 3 && 
           text.length <= 50 &&
           !ProfanityFilter.containsProfanity(text);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    final habitTitle = _controller.text.trim();
    if (!_canSave) return;

    final onboardingState = context.read<OnboardingState>();
    final navigator = Navigator.of(context);
    final navContext = navigator.context;

    await onboardingState.addCustomHabit(habitTitle);

    if (!mounted) return;

    navigator.pop();

    await Future.delayed(const Duration(milliseconds: 100));

    final l10nNav = AppLocalizations.of(navContext);
    showStyledPopup(
      context: navContext,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10nNav.customHabitCreatedTitle,
            style: AppTextStyles.h2(navContext),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10nNav.customHabitCreatedMessage(habitTitle),
            style: AppTextStyles.body(navContext),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: '${l10nNav.commonGreat}!',
            onPressed: () => Navigator.pop(navContext),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return CupertinoPageScaffold(
      // Use AppBackground for consistent warm background
      child: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ============================================================
              // CUSTOM NAVIGATION BAR
              // ============================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel button
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.commonCancel,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: colors.buttonDark,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                    // Title
                    Text(
                      l10n.customHabitTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontFamily: 'Sora',
                      ),
                    ),
                    // Spacer to balance the row
                    const SizedBox(width: 80),
                  ],
                ),
              ),

              // ============================================================
              // MAIN CONTENT
              // ============================================================
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        l10n.customHabitPrompt,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          fontFamily: 'Sora',
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        l10n.customHabitHint,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                          fontFamily: 'Sora',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ============================================================
                      // TEXT INPUT FIELD
                      // ============================================================
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: CupertinoTextField(
                            controller: _controller,
                            placeholder: l10n.customHabitPlaceholder,
                            autofocus: true,
                            maxLength: 50,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              fontSize: 17,
                              color: colors.textPrimary,
                              fontFamily: 'Sora',
                            ),
                            placeholderStyle: TextStyle(
                              fontSize: 17,
                              color: colors.textSecondary,
                              fontFamily: 'Sora',
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.buttonDark.withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Character count
                      Text(
                        l10n.customHabitCharCount(_controller.text.length),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                          fontFamily: 'Sora',
                        ),
                      ),

                      const Spacer(),

                      // ============================================================
                      // SUBMIT BUTTON
                      // ============================================================
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SizedBox(
                            width: double.infinity,
                            child: CupertinoButton(
                              onPressed: _canSave ? _saveHabit : null,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              color: _canSave
                                  ? colors.buttonDark
                                  : const Color(0xFFFFFFFF).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              child: Text(
                                l10n.customHabitSubmit,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _canSave
                                      ? colors.surfaceLightest
                                      : colors.textSecondary,
                                  fontFamily: 'Sora',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitCard extends StatefulWidget {
  final String habitTitle;
  final bool isPinned;
  final Color? accentColor;

  const _HabitCard({
    super.key,
    required this.habitTitle,
    this.isPinned = false,
    this.accentColor, // Default resolved from theme in build
  });

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isDoneToday = false;
  bool _isAnimating = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  // Checkmark animation controllers
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _checkmarkFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkIfDone();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );

    // Checkmark animation (scale from 80% to 100% with easeOutBack curve)
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _checkmarkScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOutBack),
    );

    _checkmarkFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOut),
    );

    _textFadeAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  Future<void> _checkIfDone() async {
    final done = await HabitTracker.wasDone(widget.habitTitle, DateTime.now());
    if (mounted) {
      setState(() {
        _isDoneToday = done;
      });
      if (done) {
        _checkmarkController.forward();
      }
    }
  }

  void _handleTap() async {
    if (_isDoneToday) return; // Don't open modal if already done

    HapticFeedback.lightImpact();

    // Show modal dialog
    final completed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HabitCompletionModal(habitTitle: widget.habitTitle),
    );

    // If completed, animate checkmark
    if (completed == true && mounted) {
      setState(() {
        _isDoneToday = true;
      });

      // Trigger checkmark animation
      _checkmarkController.forward();
    }
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showContextMenu();
  }

  // Action methods:
  // _showContextMenu(), _handlePinToggle(), _animatePin(),
  // _showReplacePinConfirmation(), _handleSwap(),
  // _showSwapDialog(), _performSwap(), _showSwapLimitDialog(),
  // _showNoAlternativesDialog(), _showDeleteConfirmation(), _showUpgradeScreen()

  void _showContextMenu() {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;
    final isCustom = onboardingState.isCustomHabit(widget.habitTitle);
    final category = onboardingState.getCategoryForHabit(widget.habitTitle);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                constraints: const BoxConstraints(maxWidth: 420),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.3, -0.5),
                          end: const Alignment(0.3, 0.5),
                          colors: [
                            colors.modalBg1.withOpacity(0.96),
                            colors.modalBg2.withOpacity(0.93),
                            colors.modalBg3.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pin / Unpin
                          _buildActionRow(
                            icon: isPinned ? CupertinoIcons.pin_slash : CupertinoIcons.pin,
                            label: isPinned ? l10n.menuUnpin : l10n.menuPinToTop,
                            onTap: () {
                              Navigator.pop(context);
                              _handlePinToggle();
                            },
                          ),

                          // Swap — only for curated habits with a category
                          if (category != null)
                            _buildActionRow(
                              icon: CupertinoIcons.arrow_2_squarepath,
                              label: l10n.menuSwap,
                              onTap: () {
                                Navigator.pop(context);
                                _handleSwap();
                              },
                              showDivider: true,
                            ),

                          // Delete — only for custom habits
                          if (isCustom)
                            _buildActionRow(
                              icon: CupertinoIcons.trash,
                              label: l10n.commonDelete,
                              isDestructive: true,
                              onTap: () {
                                Navigator.pop(context);
                                _showDeleteConfirmation();
                              },
                              showDivider: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Cancel button — separate pill
              Container(
                margin: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 12),
                constraints: const BoxConstraints(maxWidth: 420),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.3, -0.5),
                          end: const Alignment(0.3, 0.5),
                          colors: [
                            colors.modalBg1.withOpacity(0.97),
                            colors.modalBg2.withOpacity(0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l10n.commonCancel,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = false,
  }) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final iconColor = isDestructive ? colors.destructive : colors.ctaPrimary;
    final textColor = isDestructive ? colors.destructive : colors.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 0.5,
              color: colors.borderMedium.withOpacity(0.6),
            ),
          ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          onPressed: onTap,
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePinToggle() async {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;

    if (isPinned) {
      await onboardingState.unpinHabit();
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    } else {
      final isPremium = context.read<UserState>().hasSubscription;
      if (onboardingState.pinnedHabit != null) {
        if (isPremium) {
          // Premium users pin directly — no confirmation needed
          await _animatePin();
        } else {
          // Free users go straight to replace confirmation (one step)
          _showReplacePinConfirmation();
        }
      } else {
        await _animatePin();
      }
    }
  }

  Future<void> _animatePin() async {
    if (_isAnimating || !mounted) return;

    setState(() {
      _isAnimating = true;
    });

    final onboardingState = context.read<OnboardingState>();

    // Lift animation (scale down slightly to create "picked up" feel)
    if (!mounted) return;
    await _scaleController.forward();
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    // Small pause at the "lifted" state
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Pin the habit (triggers Hero animation via rebuild)
    // This may dispose this widget as the card moves to the pinned section
    await onboardingState.pinHabit(widget.habitTitle);
    if (!mounted) return;

    // Let Hero animation complete
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await _scaleController.reverse();
    if (!mounted) return;

    setState(() {
      _isAnimating = false;
    });

    HapticFeedback.lightImpact();
  }

  Future<void> _showReplacePinConfirmation() async {
    final onboardingState = context.read<OnboardingState>();
    final currentPinned = onboardingState.pinnedHabit;
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 384),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.4),
                          blurRadius: 70,
                          offset: const Offset(0, 25),
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          blurRadius: 0,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          l10n.replacePinTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          l10n.replacePinDescription(currentPinned!, widget.habitTitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Replace pin button
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.ctaPrimary.withOpacity(0.92),
                                colors.ctaSecondary.withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.textPrimary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              l10n.replacePinConfirm,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Cancel
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            l10n.commonCancel,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _animatePin();
    }
  }

  void _handleSwap() async {
    final onboardingState = context.read<OnboardingState>();
    final category = onboardingState.getCategoryForHabit(widget.habitTitle);

    if (category == null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedModal(
          context: context,
          title: l10n.swapCantTitle,
          subtitle: l10n.swapCantMessage,
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.pop(context),
              child: Builder(
                builder: (ctx) {
                  final clr = Provider.of<ThemeProvider>(ctx, listen: false).colors;
                  return Text(
                    l10n.commonOk,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: clr.ctaPrimary,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
      return;
    }

    final isPremium = context.read<UserState>().hasSubscription;
    if (!isPremium && !onboardingState.canSwapInCategory(category)) {
      _showSwapLimitDialog(category);
      return;
    }

    final alternatives = onboardingState.getAlternativeHabits(widget.habitTitle);
    
    if (alternatives.isEmpty) {
      _showNoAlternativesDialog();
      return;
    }

    _showSwapDialog(category, alternatives);
  }

  void _showSwapDialog(String category, List<String> alternatives) {
    final onboardingState = context.read<OnboardingState>();
    final isPremium = context.read<UserState>().hasSubscription;
    final remaining = onboardingState.getRemainingSwaps(category);
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 384),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.4),
                          blurRadius: 70,
                          offset: const Offset(0, 25),
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          blurRadius: 0,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          l10n.swapTitle(widget.habitTitle),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description (REVERTED to DM Sans)
                        Text(
                          l10n.swapCategoryHabits(category),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Habit alternatives buttons
                        ...alternatives.map((habit) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.buttonDark.withOpacity(0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.65),
                                          colors.surfaceLight.withOpacity(0.50),
                                        ],
                                      ),
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 1.5,
                                        ),
                                        left: BorderSide(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        right: BorderSide(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: CupertinoButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _performSwap(habit);
                                      },
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                      borderRadius: BorderRadius.circular(18),
                                      child: Text(
                                        habit,
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: colors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),

                        const SizedBox(height: 28),

                        // Free swaps remaining (hide for premium)
                        if (!isPremium)
                          Text(
                            l10n.swapFreeRemaining(remaining),
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                            ),
                          ),

                        const SizedBox(height: 26),

                        // Cancel button (ghost)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              l10n.commonCancel,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performSwap(String newHabit) async {
    final onboardingState = context.read<OnboardingState>();
    final isPremium = context.read<UserState>().hasSubscription;
    final success = await onboardingState.swapHabit(widget.habitTitle, newHabit, isPremium: isPremium);

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
      final l10n = AppLocalizations.of(context);

      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: colors.barrierColor.withOpacity(0.28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colors.modalShadow.withOpacity(0.4),
                      blurRadius: 70,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(-0.3, -0.5),
                          end: const Alignment(0.3, 0.5),
                          colors: [
                            colors.modalBg1.withOpacity(0.96),
                            colors.modalBg2.withOpacity(0.93),
                            colors.modalBg3.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              l10n.swapSuccessTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                letterSpacing: -0.4,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              l10n.swapSuccessMessage(newHabit),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.textSubtitle,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Primary button (Great)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colors.ctaPrimary.withOpacity(0.92),
                                    colors.ctaSecondary.withOpacity(0.88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.textPrimary.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  l10n.commonGreat,
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (mounted) {
      final l10n = AppLocalizations.of(context);
      showIntendedModal(
        context: context,
        title: l10n.swapErrorTitle,
        subtitle: l10n.swapErrorMessage,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            onPressed: () => Navigator.pop(context),
            child: Builder(
              builder: (ctx) {
                final clr = Provider.of<ThemeProvider>(ctx, listen: false).colors;
                return Text(
                  l10n.commonOk,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: clr.ctaPrimary,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  void _showSwapLimitDialog(String category) {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);
    showCupertinoModalPopup(
      context: context,
      barrierColor: colors.barrierColor.withOpacity(0.28),
      builder: (context) => Container(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 384),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.4),
                          blurRadius: 70,
                          offset: const Offset(0, 25),
                        ),
                        BoxShadow(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          blurRadius: 0,
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          l10n.swapLimitTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description (DM Sans)
                        Text(
                          l10n.swapLimitMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Primary button (Unlock Intended+)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.ctaPrimary.withOpacity(0.92),
                                colors.ctaSecondary.withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.textPrimary.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () {
                              Navigator.pop(context);
                              _showUpgradeScreen();
                            },
                            child: Text(
                              l10n.appUnlockPlus,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Cancel button (ghost)
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.commonCancel,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNoAlternativesDialog() {
    final l10n = AppLocalizations.of(context);
    showIntendedDialog(
      context: context,
      title: l10n.swapNoAltTitle,
      subtitle: l10n.swapNoAltMessage,
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }

  void _showUpgradeScreen() {
    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => const PaywallScreen(),
    );
  }

  void _showDeleteConfirmation() {
    final onboardingState = context.read<OnboardingState>();
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 384),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colors.modalShadow.withOpacity(0.4),
                blurRadius: 70,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(-0.3, -0.5),
                    end: const Alignment(0.3, 0.5),
                    colors: [
                      colors.modalBg1.withOpacity(0.96),
                      colors.modalBg2.withOpacity(0.93),
                      colors.modalBg3.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        l10n.deleteHabitTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          letterSpacing: -0.4,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        l10n.deleteHabitMessage(widget.habitTitle),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textSubtitle,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Delete button (muted red)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              colors.destructive.withOpacity(0.92),
                              colors.destructiveDark.withOpacity(0.88),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colors.destructiveDark.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: () async {
                            Navigator.pop(context);
                            await onboardingState.removeCustomHabit(widget.habitTitle);
                          },
                          child: Text(
                            l10n.commonDelete,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Cancel button (secondary glassmorphism)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.buttonDark.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.5),
                                      colors.surfaceLight.withOpacity(0.35),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  l10n.commonCancel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    final colors = context.watch<ThemeProvider>().colors;
    final isCustom = context.read<OnboardingState>().isCustomHabit(widget.habitTitle);

    // Determine accent color based on state
    final Color effectiveAccentColor;
    if (isCustom) {
      effectiveAccentColor = colors.accentCustom;  // Dusty rose
    } else if (widget.isPinned) {
      effectiveAccentColor = colors.accentPinned;  // Terracotta
    } else {
      effectiveAccentColor = widget.accentColor ?? colors.accentRegular;  // Warm taupe
    }

    Widget card = Hero(
      tag: 'habit_card_${widget.habitTitle}',
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(
                        0.04 + (0.12 * animation.value),
                      ),
                      blurRadius: 16 + (20 * animation.value),
                      offset: Offset(0, 2 + (6 * animation.value)),
                    ),
                  ],
                ),
                child: toHeroContext.widget,
              ),
            );
          },
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            height: _isDoneToday ? 64 : 72,
            child: Row(
              children: [
                // LEFT ACCENT BAR (only show if not completed)
                if (!_isDoneToday)
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: effectiveAccentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                
                // Spacing between accent bar and card
                SizedBox(width: _isDoneToday ? 20 : 16),
                
                // CARD
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _isDoneToday ? 20 : 25,
                        sigmaY: _isDoneToday ? 20 : 25,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: _isDoneToday ? 20 : 24,
                        ),
                        decoration: BoxDecoration(
                          // Glassmorphism background (pinned = lighter/cooler, regular = warmer)
                          color: _isDoneToday
                              ? colors.cardDone.withOpacity(colors.cardDoneOpacity)
                              : widget.isPinned
                                  ? colors.cardPinned.withOpacity(0.78)
                                  : colors.cardBackground.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isDoneToday
                                ? const Color(0xFFFFFFFF).withOpacity(0.10)
                                : colors.borderCard.withOpacity(colors.borderCardOpacity),
                            width: 0.5,
                          ),
                          boxShadow: [
                            // Outer shadow for depth
                            BoxShadow(
                              color: colors.textPrimary.withOpacity(
                                _isDoneToday ? 0.02 : widget.isPinned ? 0.06 : 0.04,
                              ),
                              blurRadius: _isDoneToday ? 8 : widget.isPinned ? 20 : 16,
                              offset: Offset(0, _isDoneToday ? 1 : widget.isPinned ? 4 : 2),
                            ),
                            // Top-edge bevel: white highlight
                            if (!_isDoneToday)
                              BoxShadow(
                                color: const Color(0xFFFFFFFF).withOpacity(0.70),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                                blurStyle: BlurStyle.inner,
                              ),
                            // Bottom-edge bevel: warm dark lip
                            if (!_isDoneToday)
                              BoxShadow(
                                color: colors.tabBarFade.withOpacity(0.25),
                                blurRadius: 1,
                                offset: const Offset(0, -1),
                                blurStyle: BlurStyle.inner,
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Checkmark (only when completed) with animation
                            if (_isDoneToday) ...[
                              FadeTransition(
                                opacity: _checkmarkFadeAnimation,
                                child: ScaleTransition(
                                  scale: _checkmarkScaleAnimation,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colors.checkmarkBackground.withOpacity(0.40),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.checkmark,
                                      size: 12,
                                      color: colors.checkmarkFill,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Habit title with animated fade
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _textFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _isDoneToday ? _textFadeAnimation.value : 1.0,
                                    child: Text(
                                      widget.habitTitle,
                                      style: TextStyle(
                                        fontSize: _isDoneToday ? 15 : 16,
                                        fontWeight: FontWeight.w500,
                                        color: _isDoneToday
                                            ? colors.textSecondary
                                            : colors.textPrimary,
                                        fontFamily: 'Sora',
                                        decoration: _isDoneToday
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: colors.textSecondary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final wrappedCard = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isCustom
          ? Dismissible(
              key: ValueKey('dismiss_${widget.habitTitle}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                _showDeleteConfirmation();
                return false; // Don't auto-dismiss; modal handles removal
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  CupertinoIcons.trash,
                  color: colors.error,
                  size: 22,
                ),
              ),
              child: card,
            )
          : card,
    );

    return wrappedCard;
  }
}

// ============================================================
// BROWSE HABITS BOTTOM SHEET
// ============================================================

class BrowseHabitsSheet extends StatefulWidget {
  const BrowseHabitsSheet({super.key});

  @override
  State<BrowseHabitsSheet> createState() => _BrowseHabitsSheetState();
}

class _BrowseHabitsSheetState extends State<BrowseHabitsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Category accent colors — static theme-independent
  static const Map<String, Color> categoryColors = {
    'Health': AppColors.catHealth,                 // Terracotta
    'Mood': AppColors.catMood,                     // Dusty Plum
    'Productivity': AppColors.catProductivity,     // Dusty Olive
    'Home & organization': AppColors.catHome,      // Warm Sage
    'Relationships': AppColors.catRelationships,   // Soft Clay
    'Creativity': AppColors.catCreativity,         // Dusty Mauve
    'Finances': AppColors.catFinances,             // Warm Amber
    'Self-care': AppColors.catSelfCare,            // Warm Sand
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addHabit(String habit) {
    final onboardingState = context.read<OnboardingState>();
    final l10n = AppLocalizations.of(context);

    // Check if habit is already in user's list
    if (onboardingState.userHabits.contains(habit)) {
      // Show already added message
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.browseAlreadyAddedTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.browseAlreadyAddedMessage(habit),
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10n.commonOk,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Always show swap confirmation when adding from Browse
    _showSwapConfirmation(habit);
  }

  void _showSwapConfirmation(String newHabit) {
    final onboardingState = context.read<OnboardingState>();
    final isPremium = context.read<UserState>().hasSubscription;
    final canSwap = isPremium || onboardingState.canSwapFromBrowse();
    final remainingSwaps = onboardingState.getRemainingBrowseSwaps();
    final l10n = AppLocalizations.of(context);

    if (!canSwap) {
      // Show upgrade modal when limit reached
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.browseSwapLimitTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.swapLimitMessage,
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10n.appUnlockPlus,
              onPressed: () {
                Navigator.pop(context);
                _showUpgradeScreen();
              },
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Builder(
                builder: (ctx) {
                  final clr = Provider.of<ThemeProvider>(ctx, listen: false).colors;
                  return Text(
                    l10n.commonCancel,
                    style: TextStyle(
                      fontSize: 16,
                      color: clr.ctaPrimary,
                      fontFamily: 'Sora',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
      return;
    }

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.browseSwapConfirmTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isPremium
                ? l10n.browseSwapConfirmMessage(newHabit)
                : '${l10n.browseSwapConfirmMessage(newHabit)}\n\n${l10n.browseSwapRemainingCount(remainingSwaps)}',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: l10n.browseChooseHabitToSwap,
            onPressed: () {
              Navigator.pop(context);
              _showHabitSelection(newHabit);
            },
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Builder(
              builder: (ctx) {
                final clr = Provider.of<ThemeProvider>(ctx, listen: false).colors;
                return Text(
                  l10n.commonCancel,
                  style: TextStyle(
                    fontSize: 16,
                    color: clr.ctaPrimary,
                    fontFamily: 'Sora',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitSelection(String newHabit) {
    final onboardingState = context.read<OnboardingState>();
    final currentHabits = onboardingState.userHabits;
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.browseWhichToReplace,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.browseChooseToReplaceMessage(newHabit),
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...currentHabits.map((oldHabit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
                _performSwap(oldHabit, newHabit);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withOpacity(0.45),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  oldHabit,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          )),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(
                fontSize: 16,
                color: colors.ctaPrimary,
                fontFamily: 'Sora',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSwap(String oldHabit, String newHabit) async {
    final onboardingState = context.read<OnboardingState>();
    final isPremium = context.read<UserState>().hasSubscription;
    final success = await onboardingState.swapHabit(oldHabit, newHabit, isPremium: isPremium);

    if (success && mounted) {
      HapticFeedback.mediumImpact();
      final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
      final l10n = AppLocalizations.of(context);

      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: colors.barrierColor.withOpacity(0.28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 384),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 36),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: const Alignment(0.0, 2.41),
                          end: const Alignment(0.0, -2.41),
                          colors: [
                            colors.modalBg1.withOpacity(0.96),
                            colors.modalBg2.withOpacity(0.93),
                            colors.modalBg3.withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.modalShadow.withOpacity(0.4),
                            blurRadius: 70,
                            offset: const Offset(0, 25),
                          ),
                          BoxShadow(
                            color: const Color(0xFFFFFFFF).withOpacity(0.6),
                            blurRadius: 0,
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            l10n.swapSuccessTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description (Sora to match Unpin modal)
                          Text(
                            l10n.swapSuccessMessage(newHabit),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colors.textSubtitle,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // OK button
                          SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colors.ctaPrimary.withOpacity(0.92),
                                        colors.ctaSecondary.withOpacity(0.88),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colors.ctaPrimary.withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.textPrimary.withOpacity(0.3),
                                        blurRadius: 24,
                                        offset: const Offset(0, 6),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFFFFFFFF).withOpacity(0.15),
                                        blurRadius: 0,
                                        offset: const Offset(0, 1),
                                        spreadRadius: 0,
                                        blurStyle: BlurStyle.inner,
                                      ),
                                    ],
                                  ),
                                  child: CupertinoButton(
                                    onPressed: () => Navigator.pop(context),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Text(
                                      l10n.commonGreat,
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (mounted) {
      final l10nErr = AppLocalizations.of(context);
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10nErr.swapErrorTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10nErr.swapErrorMessage,
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10nErr.commonOk,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  void _performDirectAdd(String habit) {
    final onboardingState = context.read<OnboardingState>();
    onboardingState.addHabitFromBrowse(habit);
    HapticFeedback.mediumImpact();

    // Close sheet and show confirmation
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.browseHabitAddedTitle,
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.browseHabitAddedMessage(habit),
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: l10n.browseHabitAddedConfirm,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  void _showUpgradeScreen() {
    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => const PaywallScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final onboardingState = context.watch<OnboardingState>();
    final l10n = AppLocalizations.of(context);

    // Get habits organized by category
    // Adjust this based on your actual data model
    final Map<String, List<String>> habitsByCategory = _getHabitsByCategory(onboardingState);
    
    // Filter by search query
    final filteredCategories = <String, List<String>>{};
    for (final entry in habitsByCategory.entries) {
      final filtered = entry.value
          .where((h) => h.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      if (filtered.isNotEmpty) {
        filteredCategories[entry.key] = filtered;
      }
    }

    // Count total available habits
    int totalHabits = 0;
    for (final habits in habitsByCategory.values) {
      totalHabits += habits.length;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceLight,  // Sheet top
            colors.modalBg2,  // Sheet bottom
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // HANDLE BAR
          // ============================================================
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.buttonDark.withOpacity(0.25),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),

          // ============================================================
          // HEADER
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.browseHabitsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: colors.ctaPrimary,
                        letterSpacing: -0.5,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.browseHabitsAvailable(totalHabits),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.commonClose,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                      fontFamily: 'DMSans',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // SEARCH BAR
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.buttonDark.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.textPrimary.withOpacity(0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.search,
                        size: 18,
                        color: colors.textSecondary.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _searchController,
                          placeholder: l10n.browseHabitsSearch,
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                            fontFamily: 'DMSans',
                          ),
                          placeholderStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary.withOpacity(0.6),
                            fontFamily: 'DMSans',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          // SCROLLABLE CONTENT
          // ============================================================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              itemCount: filteredCategories.length,
              itemBuilder: (context, categoryIndex) {
                final category = filteredCategories.keys.elementAt(categoryIndex);
                final habits = filteredCategories[category]!;
                final accentColor = categoryColors[category] ?? colors.accentMuted;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: categoryIndex < filteredCategories.length - 1 ? 32 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category header
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.buttonDark,
                            letterSpacing: 0.5,
                            fontFamily: 'Sora',
                          ),
                        ),
                      ),
                      
                      // Habit cards
                      ...habits.map((habit) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BrowseHabitCard(
                          habitTitle: habit,
                          accentColor: accentColor,
                          onAdd: () => _addHabit(habit),
                        ),
                      )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER: Get habits organized by category
  // Adjust this based on your actual OnboardingState data model
  // ============================================================
  Map<String, List<String>> _getHabitsByCategory(OnboardingState state) {
    // Get habits only from user's selected focus areas
    final Map<String, List<String>> result = {};

    for (final category in state.focusAreas) {
      final habits = OnboardingState.habitsByCategory[category];
      if (habits != null) {
        // Filter out habits the user already has
        final availableHabits = habits
            .where((habit) => !state.userHabits.contains(habit))
            .toList();

        if (availableHabits.isNotEmpty) {
          result[category] = availableHabits;
        }
      }
    }

    return result;
  }
}

// ============================================================
// BROWSE HABIT CARD (for the bottom sheet)
// ============================================================

class _BrowseHabitCard extends StatelessWidget {
  final String habitTitle;
  final Color accentColor;
  final VoidCallback onAdd;

  const _BrowseHabitCard({
    required this.habitTitle,
    required this.accentColor,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored left stripe - integrated into the card
              Container(
                width: 4,
                color: accentColor,
              ),

              // Card content with gradient background
              Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.7),
                      const Color(0xFFFFFFFF).withOpacity(0.5),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Habit title
                    Expanded(
                      child: Text(
                        habitTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                          height: 1.5,
                          fontFamily: 'DMSans',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add button
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.ctaPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.ctaPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.plus,
                          size: 20,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class HabitActionScreen extends StatefulWidget {
  final String habitTitle;

  const HabitActionScreen({super.key, required this.habitTitle});

  @override
  State<HabitActionScreen> createState() => _HabitActionScreenState();
}

class _HabitActionScreenState extends State<HabitActionScreen> {
  bool _isDone = false;
  bool _isProcessing = false;
  String _supportWord = '';

  // Warm, gentle support words
  static const List<String> _supportWords = [
    'Nice',
    'Well done',
    'You did it',
    'Great',
    'Way to go',
    'Good job',
    'Lovely',
    'That counts',
  ];

  Future<void> _markAsDone() async {
    if (_isProcessing) return;
    
    // Pick random support word
    final random = Random();
    _supportWord = _supportWords[random.nextInt(_supportWords.length)];
    
    setState(() {
      _isProcessing = true;
      _isDone = true;
    });
    
    HapticFeedback.heavyImpact();
    await HabitTracker.markDone(widget.habitTitle);
    
    // Show heart + support for 1 second
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _skipForToday() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.watch<ThemeProvider>().colors;
    return CupertinoPageScaffold(
      backgroundColor: colors.surfaceLightest, // Match app background
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.surfaceLightest,
                colors.modalBg2,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Did you do this today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: CupertinoButton(
                      color: _isDone
                          ? colors.success
                          : colors.buttonDark,
                      borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      onPressed: _isDone ? null : _markAsDone,
                      child: _isDone
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '❤️',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _supportWord,
                                  style: TextStyle(
                                    color: colors.surfaceLightest,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'I did it',
                              style: AppTextStyles.buttonPrimary(context),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (!_isDone)
                    CupertinoButton(
                      color: colors.surfaceLightest,
                      borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                      onPressed: _skipForToday,
                      child: Text(
                        'Not today',
                        style: TextStyle(
                          color: colors.buttonDark,
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}