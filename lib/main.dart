import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors;
import 'dart:ui' show ImageFilter;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
import 'utils/milestone_tracker.dart';
import 'utils/milestone_icons.dart';
import 'utils/ios_version.dart';

// ✅ ADD THIS HELPER HERE (before the main() function):
Future<T?> showKindliModal<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
}) {
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
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color.fromRGBO(245, 236, 224, 0.96),
                    Color.fromRGBO(237, 228, 216, 0.96),
                    Color.fromRGBO(229, 220, 208, 0.96),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF32281E).withOpacity(0.35),
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
                    color: const Color(0xFFB4A591).withOpacity(0.15),
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

/* -------------------- KINDLI DIALOG BUILDER -------------------- */

void showKindliDialog({
  required BuildContext context,
  required String title,
  String? subtitle,
  required List<Widget> actions,
  Widget? content,
}) {
  showKindliModal(
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
                  ? const Color(0xFF9A8A78)
                  : const Color(0xFF3C342A),
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F0E8),
                Color(0xFFEDE6DC),
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
  Color color = const Color(0xFF6B5B4A),
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: CupertinoButton(
      color: color,
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
}

/// Secondary outline button for styled popups
Widget styledSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFD8D2C8), width: 1),
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
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3C342A),
        ),
      ),
    ),
  );
}

/* -------------------- THEME COLORS -------------------- */

const Color primaryBrown = AppColors.buttonPrimary;
const Color lightBrown  = AppColors.cardBackground;
const Color appBackground = AppColors.pageBackground;

/* -------------------- APP BACKGROUND -------------------- */

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base background color
        Container(
          color: const Color(0xFFE8DFD3),
        ),

        // Textured background image
        Image.asset(
          'assets/images/background_soft.png',
          fit: BoxFit.cover,
        ),

        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(215, 200, 180, 0.45),
                Color.fromRGBO(200, 185, 165, 0.6),
              ],
            ),
          ),
        ),

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
    print('✅ Marked done: $key'); // Debug log
  }

  static Future<bool> wasDone(String habitTitle, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _key(habitTitle, date);
    final result = prefs.getBool(key) ?? false;
    print('🔍 Checking: $key = $result'); // Debug log
    return result;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      ],
      child: const GentlyApp(),
    ),
  );
}

class GentlyApp extends StatelessWidget {
  const GentlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
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
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),

          Container(
            color: const Color(0xFFF6F5F1).withOpacity(0.45),
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
                          return Text(
                            name == null || name.isEmpty
                                ? 'Welcome to Gently'
                                : 'Welcome to Gently,\n$name',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              letterSpacing: -0.6,
                              color: Color(0xFF2F2E2A),
                              fontFamilyFallback: [
                                'SF Pro Rounded',
                                'SF Pro',
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Small steps.\nNo pressure.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                          letterSpacing: -0.15,
                          color: const Color(0xFF4E4C45),
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
                              color: const Color(0xFFF6F5F1).withOpacity(0.9),
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
    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Screen content (no CupertinoTabScaffold)
          IndexedStack(
            index: _currentIndex,
            children: [
              const HabitsScreen(),
              ProgressScreen(),
              const ProfileScreen(),
            ],
          ),

          // Tab bar gradient
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
                      const Color(0xFFE8DFD3).withOpacity(0.0),
                      const Color(0xFFE8DFD3).withOpacity(0.92),
                      const Color(0xFFE8DFD3).withOpacity(0.98),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Tab bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: _CustomTabBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
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
    Responsive.init(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          // Outer soft shadow
          BoxShadow(
            color: const Color(0xFF3C342A).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.75),  // Changed from 0.15
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),  // Changed from 0.2
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3C342A).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Sliding pill indicator
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: currentIndex.toDouble(),
                  ),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, _) {
                    return Align(
                      alignment: Alignment(
                        -1 + (value * 1.0),
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / 3,
                        heightFactor: 1,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Tab items
                Row(
                  children: [
                    _TabItem(
                      index: 0,
                      currentIndex: currentIndex,
                      icon: CupertinoIcons.check_mark_circled,
                      onTap: onTap,
                    ),
                    _TabItem(
                      index: 1,
                      currentIndex: currentIndex,
                      icon: CupertinoIcons.chart_bar,
                      onTap: onTap,
                    ),
                    _TabItem(
                      index: 2,
                      currentIndex: currentIndex,
                      icon: CupertinoIcons.person,
                      onTap: onTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            icon,
            size: 22,
            color: isActive
                ? const Color(0xFF3C342A)  // Kindli dark brown
                : const Color(0xFF9A8A78), // Kindli muted brown
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

class _HabitsScreenState extends State<HabitsScreen> {
  bool _showTip = false;

  // 25 rotating daily header messages
  static const List<String> _dailyMessages = [
    'Do what feels right today',
    'Today is a fresh start',
    'Just one small thing counts',
    'Be kind to yourself today',
    'No rush. You\'re doing well',
    'Start small, stay gentle',
    'Your pace is your own',
    'Even one step is progress',
    'Take what works, leave the rest',
    'You don\'t have to do it all',
    'Small moments add up',
    'Be where you are right now',
    'There\'s no wrong way to begin',
    'Listen to what you need today',
    'Progress looks different every day',
    'You\'re allowed to take your time',
    'One thing at a time is enough',
    'Give yourself permission to rest',
    'Start wherever you are',
    'You don\'t need to be ready',
    'Trust your own rhythm',
    'It\'s okay to adjust as you go',
    'Gentle is good enough',
    'Small acts of care matter',
    'You\'re doing more than you think',
  ];

  String _getTodaysMessage() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _dailyMessages[dayOfYear % _dailyMessages.length];
  }

  Future<void> _checkMilestones() async {
    // Record first use date
    await MilestoneTracker.recordFirstUse();

    // Calculate current stats to check for new milestones
    final onboardingState = context.read<OnboardingState>();
    final userHabits = onboardingState.userHabits;
    final now = DateTime.now();

    // Count total completions and today's completions
    int totalCompletions = 0;
    int todayCompletions = 0;

    for (final habit in userHabits) {
      // Count today's completions
      if (await HabitTracker.wasDone(habit, now)) {
        todayCompletions++;
      }

      // Count total completions (last 30 days as a proxy for total)
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        if (await HabitTracker.wasDone(habit, date)) {
          totalCompletions++;
        }
      }
    }

    // Check and record any new milestones
    await MilestoneTracker.checkMilestones(
      totalCompletions: totalCompletions,
    );

    // Get current milestone to display
    final milestone = await MilestoneTracker.getCurrentMilestone();
    if (milestone != null && mounted) {
      _showMilestoneModal(milestone);
    }
  }

  void _showMilestoneModal(Milestone milestone) {
    final milestoneInfo = MilestoneTracker.info[milestone]!;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Center(
          child: Container(
            width: size.width * 0.82,
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color.fromRGBO(245, 236, 224, 0.97),
                  Color.fromRGBO(240, 232, 220, 0.97),
                  Color.fromRGBO(235, 227, 215, 0.97),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF32281E).withOpacity(0.25),
                  blurRadius: 50,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Milestone flower icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5ECD4).withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CustomPaint(
                          painter: getMilestoneIconPainter(milestone, true),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    milestoneInfo.title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C342A),
                      letterSpacing: -0.3,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  Text(
                    milestoneInfo.subtitle,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8B7563).withOpacity(0.9),
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Continue button (filled brown)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(139, 117, 99, 0.92),
                            Color.fromRGBO(122, 107, 95, 0.88),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3C342A).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        borderRadius: BorderRadius.circular(18),
                        onPressed: () async {
                          await MilestoneTracker.dismissCurrentMilestone();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Share this moment
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Implement share
                    },
                    child: Text(
                      'Share this moment',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B7563).withOpacity(0.8),
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkTip();
    _checkMilestones();
  }

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _checkTip();
      _checkMilestones();
    }

  void _showBrowseHabits(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0xFF3C342A).withOpacity(0.08),
      builder: (context) => const BrowseHabitsSheet(),
    );
  }


  Future<void> _checkTip() async {
    final onboardingState = context.read<OnboardingState>();
    
    // Show tip only if: 
    // 1. User hasn't seen it
    // 2. User has habits
    // 3. User hasn't pinned anything yet
    if (!onboardingState.hasSeenPinTip && 
        onboardingState.userHabits.isNotEmpty &&
        onboardingState.pinnedHabit == null) {
      setState(() {
        _showTip = true;
      });
    } else {
      setState(() {
        _showTip = false;
      });
    } 
  }

  void _createCustomHabit(BuildContext context) {
    final onboardingState = context.read<OnboardingState>();
    
    if (!onboardingState.canAddCustomHabit()) {
      showKindliModal(
        context: context,
        title: 'Create more habits?',
        subtitle: 'Kindly Core: 1 custom habit\nKindli Beyond: Unlimited custom habits',
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
              color: const Color(0xFF6B5B4A),
              borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Go Kindli Beyond',
                style: AppTextStyles.buttonPrimary(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Not now',
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

  void _dismissTip() async {
    final onboardingState = context.read<OnboardingState>();
    await onboardingState.markPinTipSeen();
    setState(() {
      _showTip = false;
    });
  }

  int _getAvailableHabitsCount(BuildContext context) {
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final onboardingState = context.watch<OnboardingState>();
    final allHabits = onboardingState.userHabits;
    final pinnedHabit = onboardingState.pinnedHabit;

    // Split habits into pinned and unpinned
    final pinned = pinnedHabit != null && allHabits.contains(pinnedHabit)
        ? [pinnedHabit]
        : <String>[];
    final unpinned = allHabits.where((h) => h != pinnedHabit).toList();

    final now = DateTime.now();
    final dateStr = '${_getDayName(now.weekday)}, ${_getMonthName(now.month)} ${now.day}';

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Header with date
              Padding(
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTodaysMessage(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C342A),
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7A6A58),
                        fontFamily: 'Sora',
                      ),
                    ),
                  ],
                ),
              ),

              // Dismissible tip
              if (_showTip)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                      border: Border.all(
                        color: const Color(0xFFE8E3DB),
                        width: 0.8,
                      ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C342A).withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                    child: Row(
                      children: [
                        const Text(
                          '💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Long-press any habit to pin your favorites or swap for another',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4E4C45),
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _dismissTip,
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 22,
                            color: Color(0xFFB5A89A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Habits content
              if (allHabits.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Complete onboarding to get started',
                      style: AppTextStyles.buttonSecondary(context),
                    ),
                  ),
                )
              else ...[
                // Pinned section (stays fixed, not scrollable)
                if (pinned.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Row(
                            children: [
                              const Text('📌', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              const Text(
                                'PINNED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8B7563),
                                  letterSpacing: 1.0,
                                  fontFamily: 'Sora',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...pinned.map((habit) => _HabitCard(
                              key: ValueKey(habit),
                              habitTitle: habit,
                              isPinned: true,
                              accentColor: const Color(0xFF8B7563),
                            )),
                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: const Color(0xFFE8E3DB),
                        ),
                      ],
                    ),
                  ),

                // Scrollable section (suggestions + browse + create)
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      24, pinned.isNotEmpty ? 24 : 16, 24, 140,
                    ),
                    children: [
                      // Today's Suggestions section
                      if (unpinned.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: const Text(
                            'TODAY\'S SUGGESTIONS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B7563),
                              letterSpacing: 1.0,
                              fontFamily: 'Sora',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...unpinned.map((habit) => _HabitCard(
                              key: ValueKey(habit),
                              habitTitle: habit,
                              accentColor: const Color(0xFFA89181),
                            )),
                      ],

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
                                  color: const Color(0xFFFFFFFF).withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.25),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3C342A).withOpacity(0.04),
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
                                        const Text(
                                          'Browse all habits',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3C342A),
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_getAvailableHabitsCount(context)} more available',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF9A8A78),
                                            fontFamily: 'Sora',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      CupertinoIcons.chevron_right,
                                      size: 18,
                                      color: Color(0xFF9A8A78),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // CREATE CUSTOM HABIT BUTTON
                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () => _createCustomHabit(context),
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(16),
                            dashPattern: const [8, 4],
                            color: const Color(0xFF8B7563).withOpacity(0.4),
                            strokeWidth: 1.5,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7563).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8B7563),
                                      fontFamily: 'Sora',
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create custom habit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8B7563),
                                      fontFamily: 'Sora',
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
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
    await onboardingState.addCustomHabit(habitTitle);

    if (!mounted) return;

    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Habit created',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '"$habitTitle" has been added to your habits.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: 'Great!',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B5B4A),
                          fontFamily: 'Sora',
                        ),
                      ),
                    ),
                    // Title
                    const Text(
                      'Create custom habit',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C342A),
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
                      const Text(
                        'What small action would you like to take?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C342A),
                          fontFamily: 'Sora',
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        'Keep it simple and specific.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9A8A78),
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
                            placeholder: 'e.g., Take a 5-minute walk',
                            autofocus: true,
                            maxLength: 50,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF3C342A),
                              fontFamily: 'Sora',
                            ),
                            placeholderStyle: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF9A8A78),
                              fontFamily: 'Sora',
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF6B5B4A).withOpacity(0.12),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Character count
                      Text(
                        '${_controller.text.length}/50 characters',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A8A78),
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
                                  ? const Color(0xFF6B5B4A)
                                  : const Color(0xFFFFFFFF).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              child: Text(
                                'Add to my habits',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _canSave 
                                      ? const Color(0xFFFAF7F2)
                                      : const Color(0xFF9A8A78),
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
  final Color accentColor;

  const _HabitCard({
    super.key,
    required this.habitTitle,
    this.isPinned = false,
    this.accentColor = const Color(0xFFA89181), // Default: muted brown for suggestions
  });

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> with TickerProviderStateMixin {
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

  // Keep all the existing methods from _HabitItemState:
  // _showContextMenu(), _handlePinToggle(), _animatePin(), 
  // _showPinLimitDialog(), _replacePin(), _handleSwap(),
  // _showSwapDialog(), _performSwap(), _showSwapLimitDialog(),
  // _showNoAlternativesDialog(), _showUpgradeScreen()
  // 
  // Just copy them from your existing _HabitItemState - they stay the same!

  void _showContextMenu() {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;
    final category = onboardingState.getCategoryForHabit(widget.habitTitle);

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
                color: const Color(0xFF32281E).withOpacity(0.4),
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
                      const Color(0xFFF5ECE0).withOpacity(0.96),
                      const Color(0xFFEDE4D8).withOpacity(0.93),
                      const Color(0xFFE6DDD1).withOpacity(0.95),
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
                        isPinned ? 'Unpin this habit?' : 'Pin this habit?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C342A),
                          letterSpacing: -0.4,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        isPinned
                            ? 'This will remove it from your pinned section.'
                            : 'Keep your favorite habits at the top.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B5D52),
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Primary button (Pin/Unpin)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF8B7563).withOpacity(0.92),
                              const Color(0xFF7A6B5F).withOpacity(0.88),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C342A).withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onPressed: () {
                            Navigator.pop(context);
                            _handlePinToggle();
                          },
                          child: Text(
                            isPinned ? 'Unpin' : 'Pin',
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Secondary button (Swap for another) - only show if not pinned
                      if (!isPinned && category != null) ...[
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _handleSwap();
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF645541).withOpacity(0.12),
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
                                        const Color(0xFFF8F5F2).withOpacity(0.35),
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
                                  child: const Text(
                                    'Swap for another',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3C342A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Cancel button (ghost)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9B8A7A),
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

  Future<void> _handlePinToggle() async {
    final onboardingState = context.read<OnboardingState>();
    final isPinned = onboardingState.pinnedHabit == widget.habitTitle;

    if (isPinned) {
      await onboardingState.unpinHabit();
      if (mounted) {
        HapticFeedback.lightImpact();
      }
    } else {
      if (onboardingState.pinnedHabit != null) {
        _showPinLimitDialog();
      } else {
        await _animatePin();
      }
    }
  }

  Future<void> _animatePin() async {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
    });

    final onboardingState = context.read<OnboardingState>();
    
    await _scaleController.forward();
    HapticFeedback.mediumImpact();
    
    await onboardingState.pinHabit(widget.habitTitle);
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    await _scaleController.reverse();
    
    setState(() {
      _isAnimating = false;
    });
    
    HapticFeedback.lightImpact();
  }

  void _showPinLimitDialog() {
    showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0xFF504638).withOpacity(0.28),
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
                      gradient: const LinearGradient(
                        begin: Alignment(0.0, 2.41),
                        end: Alignment(0.0, -2.41),
                        colors: [
                          Color.fromRGBO(245, 236, 224, 0.96),
                          Color.fromRGBO(237, 228, 216, 0.93),
                          Color.fromRGBO(230, 221, 209, 0.95),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32281E).withOpacity(0.4),
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
                        const Text(
                          'Pin more habits?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description (DM Sans)
                        const Text(
                          'Kindli Core: 1 pinned habit\nKindli Beyond: Unlimited\n\nYou can replace your current pin, or upgrade.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Secondary button (Replace)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _replacePin();
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF645541).withOpacity(0.12),
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
                                        const Color(0xFFF8F5F2).withOpacity(0.35),
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
                                  child: const Text(
                                    'Replace',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3C342A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Primary button (Go Kindli Beyond)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8B7563).withOpacity(0.92),
                                const Color(0xFF7A6B5F).withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3C342A).withOpacity(0.25),
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
                            child: const Text(
                              'Go Kindli Beyond',
                              style: TextStyle(
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
                          child: const Text(
                            'Not now',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9B8A7A),
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

  Future<void> _replacePin() async {
    final onboardingState = context.read<OnboardingState>();
    final currentPinned = onboardingState.pinnedHabit;
    
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      barrierColor: const Color(0xFF504638).withOpacity(0.28),
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
                      gradient: const LinearGradient(
                        begin: Alignment(0.0, 2.41),
                        end: Alignment(0.0, -2.41),
                        colors: [
                          Color.fromRGBO(245, 236, 224, 0.96),
                          Color.fromRGBO(237, 228, 216, 0.93),
                          Color.fromRGBO(230, 221, 209, 0.95),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32281E).withOpacity(0.4),
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
                        const Text(
                          'Replace pinned habit?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description (DM Sans)
                        Text(
                          'Current: $currentPinned\nNew: ${widget.habitTitle}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Primary button (Replace)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8B7563).withOpacity(0.92),
                                const Color(0xFF7A6B5F).withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3C342A).withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Replace',
                              style: TextStyle(
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
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9B8A7A),
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
    
    if (category == null) return;

    if (!onboardingState.canSwapInCategory(category)) {
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
    final remaining = onboardingState.getRemainingSwaps(category);

    showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0xFF504638).withOpacity(0.28),
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
                      gradient: const LinearGradient(
                        begin: Alignment(0.0, 2.41),
                        end: Alignment(0.0, -2.41),
                        colors: [
                          Color.fromRGBO(245, 236, 224, 0.96),
                          Color.fromRGBO(237, 228, 216, 0.93),
                          Color.fromRGBO(230, 221, 209, 0.95),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32281E).withOpacity(0.4),
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
                          'Replace "${widget.habitTitle}"?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description (REVERTED to DM Sans)
                        Text(
                          'More $category habits:',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
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
                                    color: const Color(0xFF645541).withOpacity(0.1),
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
                                          Colors.white.withOpacity(0.5),
                                          const Color(0xFFF8F5F2).withOpacity(0.35),
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
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF3C342A),
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

                        // Free swaps remaining
                        Text(
                          'Free swaps left: $remaining',
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9A8A78),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Cancel button (ghost)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9B8A7A),
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
    final success = await onboardingState.swapHabit(widget.habitTitle, newHabit);

    if (success && mounted) {
      HapticFeedback.mediumImpact();

      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: const Color(0xFF504638).withOpacity(0.28),
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
                      color: const Color(0xFF32281E).withOpacity(0.4),
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
                            const Color(0xFFF5ECE0).withOpacity(0.96),
                            const Color(0xFFEDE4D8).withOpacity(0.93),
                            const Color(0xFFE6DDD1).withOpacity(0.95),
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
                            const Text(
                              'Habit swapped',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C342A),
                                letterSpacing: -0.4,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              'Replaced with "$newHabit"',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B5D52),
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
                                    const Color(0xFF8B7563).withOpacity(0.92),
                                    const Color(0xFF7A6B5F).withOpacity(0.88),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3C342A).withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Great',
                                  style: TextStyle(
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
    }
  }

  void _showSwapLimitDialog(String category) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: const Color(0xFF504638).withOpacity(0.28),
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
                      gradient: const LinearGradient(
                        begin: Alignment(0.0, 2.41),
                        end: Alignment(0.0, -2.41),
                        colors: [
                          Color.fromRGBO(245, 236, 224, 0.96),
                          Color.fromRGBO(237, 228, 216, 0.93),
                          Color.fromRGBO(230, 221, 209, 0.95),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32281E).withOpacity(0.4),
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
                        const Text(
                          'Swap this habit?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description (DM Sans)
                        Text(
                          'You\'ve used your 2 free $category swaps this month.\n\nKindli Beyond: Unlimited swaps',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Primary button (Go Kindli Beyond)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8B7563).withOpacity(0.92),
                                const Color(0xFF7A6B5F).withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3C342A).withOpacity(0.25),
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
                            child: const Text(
                              'Go Kindli Beyond',
                              style: TextStyle(
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
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9B8A7A),
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
    showKindliDialog(
      context: context,
      title: 'No alternatives',
      subtitle: 'You\'re already using all available habits from this category.',
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
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
                color: const Color(0xFF32281E).withOpacity(0.4),
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
                      const Color(0xFFF5ECE0).withOpacity(0.96),
                      const Color(0xFFEDE4D8).withOpacity(0.93),
                      const Color(0xFFE6DDD1).withOpacity(0.95),
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
                      const Text(
                        'Delete habit?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 27,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C342A),
                          letterSpacing: -0.4,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        '"${widget.habitTitle}" will be removed and any progress lost.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B5D52),
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
                              const Color(0xFFC4605A).withOpacity(0.92),
                              const Color(0xFFB5524D).withOpacity(0.88),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB5524D).withOpacity(0.3),
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
                          child: const Text(
                            'Delete',
                            style: TextStyle(
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
                                color: const Color(0xFF645541).withOpacity(0.12),
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
                                      const Color(0xFFF8F5F2).withOpacity(0.35),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C342A),
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
    // Determine accent color based on state
    final Color effectiveAccentColor = widget.isPinned
        ? const Color(0xFF8B7563)  // Coral/salmon for pinned
        : widget.accentColor;      // Passed color or default muted brown

    final isCustom = context.read<OnboardingState>().isCustomHabit(widget.habitTitle);

    Widget card = GestureDetector(
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox(
            height: _isDoneToday ? 56 : 64,
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
                          vertical: _isDoneToday ? 16 : 20,
                        ),
                        decoration: BoxDecoration(
                          // Glassmorphism background
                          color: _isDoneToday
                              ? const Color(0xFFFFFFFF).withOpacity(0.18)
                              : const Color(0xFFFFFFFF).withOpacity(0.28),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isDoneToday
                                ? const Color(0xFFD9C9B8).withOpacity(0.25)
                                : const Color(0xFFFFFFFF).withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: _isDoneToday
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF3C342A).withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 2),
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
                                      color: const Color(0xFFD9C9B8).withOpacity(0.4),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.checkmark,
                                      size: 12,
                                      color: Color(0xFF7A6A58),
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
                                            ? const Color(0xFF9A8A78)
                                            : const Color(0xFF3C342A),
                                        fontFamily: 'Sora',
                                        decoration: _isDoneToday
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        decorationColor: const Color(0xFF9A8A78),
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
                  color: const Color(0xFFD84315).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: Color(0xFFD84315),
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

  // Category accent colors from Figma
  static const Map<String, Color> categoryColors = {
    'Health': Color(0xFFC49A8C),                 // Dusty Rose / Coral Pink
    'Mood': Color(0xFF9B8EA8),                   // Soft Lavender
    'Productivity': Color(0xFFA8B09A),           // Soft Sage Green
    'Home & organization': Color(0xFFB8A89B),    // Warm Taupe
    'Relationships': Color(0xFFD4A5A5),          // Blush Pink
    'Creativity': Color(0xFFB8A9C9),             // Dusty Mauve
    'Finances': Color(0xFFA8B5A0),               // Sage Brown
    'Self-care': Color(0xFFC4B9A8),              // Warm Sand
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addHabit(String habit) {
    final onboardingState = context.read<OnboardingState>();

    // Check if habit is already in user's list
    if (onboardingState.userHabits.contains(habit)) {
      // Show already added message
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Already added',
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"$habit" is already in your habits.',
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: 'OK',
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
    final canSwap = onboardingState.canSwapFromBrowse();
    final remainingSwaps = onboardingState.getRemainingBrowseSwaps();

    if (!canSwap) {
      // Show upgrade modal when limit reached
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Swap limit reached',
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ve used your 2 free swaps this month.\n\nKindli Beyond: Unlimited swaps',
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: 'Go Kindli Beyond',
              onPressed: () {
                Navigator.pop(context);
                _showUpgradeScreen();
              },
            ),
            const SizedBox(height: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8B7563),
                  fontFamily: 'Sora',
                ),
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
            'Swap an existing habit?',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Replace one of your current habits with "$newHabit".\n\nYou have $remainingSwaps swap${remainingSwaps == 1 ? '' : 's'} remaining this month.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          styledPrimaryButton(
            label: 'Choose habit to replace',
            onPressed: () {
              Navigator.pop(context);
              _showHabitSelection(newHabit);
            },
          ),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8B7563),
                fontFamily: 'Sora',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitSelection(String newHabit) {
    final onboardingState = context.read<OnboardingState>();
    final currentHabits = onboardingState.userHabits;

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Which habit to replace?',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose one of your current habits to replace with "$newHabit"',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...currentHabits.map((oldHabit) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: styledSecondaryButton(
              label: oldHabit,
              onPressed: () {
                Navigator.pop(context);
                _performSwap(oldHabit, newHabit);
              },
            ),
          )),
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8B7563),
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
    final success = await onboardingState.swapHabit(oldHabit, newHabit);

    if (success && mounted) {
      HapticFeedback.mediumImpact();

      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => Container(
          color: const Color(0xFF504638).withOpacity(0.28),
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
                        gradient: const LinearGradient(
                          begin: Alignment(0.0, 2.41),
                          end: Alignment(0.0, -2.41),
                          colors: [
                            Color.fromRGBO(245, 236, 224, 0.96),
                            Color.fromRGBO(237, 228, 216, 0.93),
                            Color.fromRGBO(230, 221, 209, 0.95),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF32281E).withOpacity(0.4),
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
                          const Text(
                            'Habit swapped',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C342A),
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Description (Sora to match Unpin modal)
                          Text(
                            'Replaced with "$newHabit"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B5D52),
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
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color.fromRGBO(139, 117, 99, 0.92),
                                        Color.fromRGBO(122, 107, 95, 0.88),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8B7563).withOpacity(0.4),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3C342A).withOpacity(0.3),
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
                                    child: const Text(
                                      'Great',
                                      style: TextStyle(
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
      showStyledPopup(
        context: context,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Habit added',
              style: AppTextStyles.h2(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"$habit" has been added to your habits.',
              style: AppTextStyles.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            styledPrimaryButton(
              label: 'Great!',
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
    final onboardingState = context.watch<OnboardingState>();
    
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F4EF),  // Sheet top
            Color(0xFFF0EBE3),  // Sheet bottom
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
                color: const Color(0xFF6B5B4A).withOpacity(0.25),
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
                    const Text(
                      'Browse Habits',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B7563),
                        letterSpacing: -0.5,
                        fontFamily: 'Sora',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalHabits habits available',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A8A78),
                        fontFamily: 'DMSans',
                      ),
                    ),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A8A78),
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
                      color: const Color(0xFF6B5B4A).withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C342A).withOpacity(0.04),
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
                        color: const Color(0xFF9A8A78).withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _searchController,
                          placeholder: 'Search habits...',
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3C342A),
                            fontFamily: 'DMSans',
                          ),
                          placeholderStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9A8A78).withOpacity(0.6),
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
                final accentColor = categoryColors[category] ?? const Color(0xFFA89181);

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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B5B4A),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C342A).withOpacity(0.08),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C342A),
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
                          color: const Color(0xFF8B7563),  // Sage green
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B7563).withOpacity(0.3),
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF3F4EF), // Match app background
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF3F4EF),
                Color(0xFFEDE8E2),
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
                  const Text(
                    'Did you do this today?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Sora',
                      color: Color(0xFF2F2E2A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: CupertinoButton(
                      color: _isDone
                          ? const Color(0xFF6A8B6F)
                          : primaryBrown,
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
                                  style: const TextStyle(
                                    color: Color(0xFFF6F5F1),
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
                      color: lightBrown,
                      borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                      onPressed: _skipForToday,
                      child: const Text(
                        'Not today',
                        style: TextStyle(
                          color: primaryBrown,
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