import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/* -------------------- THEME COLORS -------------------- */

const Color primaryBrown = Color(0xFF6B5B4A); // тёмно-бежевый
const Color lightBrown  = Color(0xFFEDE8E2); // светлый беж
const Color appBackground = Color(0xFFF3F4EF);

final ValueNotifier<String?> userNameNotifier = ValueNotifier(null);

/* -------------------- APP BACKGROUND -------------------- */

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/background_soft.png',
          fit: BoxFit.cover,
        ),

        // лёгкий слой для читаемости текста
        Container(
          color: const Color(0xFFF6F5F1).withOpacity(0.55),
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
  static String _key(String habitId, DateTime date) {
    final d = date.toIso8601String().substring(0, 10);
    return 'habit_${habitId}_$d';
  }

  static Future<void> markDone(String habitId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(habitId, DateTime.now()), true);
  }

  static Future<bool> wasDone(String habitId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(habitId, date)) ?? false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  userNameNotifier.value = prefs.getString('user_name');

  runApp(const GentlyApp());
}

class GentlyApp extends StatelessWidget {
  const GentlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
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
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (clear, no blur)
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
          ),

          // Light contrast overlay
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
                            // inner light
                            Shadow(
                              blurRadius: 6,
                              color: const Color(0xFFFFFFFF).withOpacity(0.9),
                              offset: const Offset(0, 0),
                            ),
                            // outer glow
                            Shadow(
                              blurRadius: 20,
                              color: const Color(0xFFF6F5F1).withOpacity(0.9),
                              offset: const Offset(0, 2),
                            ),
                            // subtle contrast lift
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
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          CupertinoTabScaffold(
  tabBar: CupertinoTabBar(
    items: const [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.circle),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.circle),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.circle),
        label: '',
      ),
    ],
    backgroundColor: const Color(0x00000000),
    activeColor: const Color(0x00000000),
    inactiveColor: const Color(0x00000000),
    border: const Border(
      top: BorderSide(color: Color(0x00000000)),
    ),
  ),
  tabBuilder: (context, index) {
    switch (_currentIndex) {
      case 0:
        return const HabitsScreen();
      case 1:
        return const ProgressScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const HabitsScreen();
    }
  },
),

          // 👇 НАШ КАСТОМНЫЙ TAB BAR
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
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
    const tabCount = 3;

    return ClipRRect(
  borderRadius: BorderRadius.circular(28),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4EF).withOpacity(0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFD8D2C8),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;

          return Stack(
            children: [
              // 🔹 ПЛАВНЫЙ ИНДИКАТОР
              TweenAnimationBuilder<double>(
  tween: Tween<double>(
    begin: 0,
    end: currentIndex.toDouble(),
  ),
  duration: const Duration(milliseconds: 520),
  curve: Curves.easeOutExpo, // 👈 КЛЮЧ
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
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  },
),

              Row(
                children: [
                  _TabItem(
                    index: 0,
                    currentIndex: currentIndex,
                    icon: CupertinoIcons.check_mark_circled,
                    label: 'Habits',
                    onTap: onTap,
                  ),
                  _TabItem(
                    index: 1,
                    currentIndex: currentIndex,
                    icon: CupertinoIcons.chart_bar,
                    label: 'Progress',
                    onTap: onTap,
                  ),
                  _TabItem(
                    index: 2,
                    currentIndex: currentIndex,
                    icon: CupertinoIcons.person,
                    label: 'Profile',
                    onTap: onTap,
                  ),
                ],
              ),
            ],
          );
        },
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
  final String label;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? const Color(0xFF1C1C1E)
                    : const Color(0xFF9A9A9A),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayLabel =
        DateFormat('MMMM d').format(DateTime.now()); // February 1

    return CupertinoPageScaffold(
      child: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today, $todayLabel',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 24),

                ...habits.map(
                  (habit) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) =>
                                HabitActionScreen(habit: habit),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 22,
                            sigmaY: 22,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFFFFFFF)
                                      .withOpacity(0.45),
                                  const Color(0xFFFFFFFF)
                                      .withOpacity(0.25),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFFFFFFF)
                                    .withOpacity(0.4),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              '${habit.emoji} ${habit.title}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HabitActionScreen extends StatelessWidget {
  final Habit habit;

  const HabitActionScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: AppBackground(
        child: SafeArea(
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
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  CupertinoButton(
                    color: primaryBrown,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () async {
                      await HabitTracker.markDone(habit.id);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) =>
                              const HabitResultScreen(success: true),
                        ),
                      );
                    },
                    child: const Text(
                      'I did it',
                      style: TextStyle(color: Color(0xFFF6F5F1)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  CupertinoButton(
                    color: lightBrown,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) =>
                              const HabitResultScreen(success: false),
                        ),
                      );
                    },
                    child: const Text(
                      'Not today',
                      style: TextStyle(color: primaryBrown),
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


class HabitResultScreen extends StatelessWidget {
  final bool success;

  const HabitResultScreen({super.key, required this.success});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    success ? '💚 Well done' : 'That’s okay',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    success
                        ? 'Small actions matter.'
                        : 'You didn’t fail.\nYou’re still allowed to come back.',
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  CupertinoButton(
                    color: const Color(0xFF6B5B4A),
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        (route) => route.isFirst,
                      );
                    },
                    child: const Text(
                      'Back to habits',
                      style: TextStyle(color: Color(0xFFF6F5F1)),
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

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return CupertinoPageScaffold(
      child: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: habits.map((habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${habit.emoji} ${habit.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: List.generate(7, (index) {
                          final date =
                              now.subtract(Duration(days: 6 - index));
                          final label = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun'
                          ][date.weekday - 1];

                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                FutureBuilder<bool>(
                                  future: HabitTracker.wasDone(
                                      habit.id, date),
                                  builder: (_, snapshot) {
                                    final done =
                                        snapshot.data ?? false;
                                    return Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: done
                                            ? const Color(0xFF6B8E6E)
                                            : const Color(0xFFD8DAD3),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 8),

                                SizedBox(
                                  width: 32,
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9A9A9A),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- PROFILE -------------------- */

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool get canSave {
    final text = controller.text.trim();
    final currentName = userNameNotifier.value;
    if (text.isEmpty) return false;
    if (text == currentName) return false;
    return true;
  }

  Future<void> _saveName() async {
    final name = controller.text.trim();
    if (!canSave) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    userNameNotifier.value = name;
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: userNameNotifier,
                  builder: (context, name, _) {
                    if (name == null || name.isEmpty) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),

                CupertinoTextField(
                  controller: controller,
                  placeholder: userNameNotifier.value == null
                      ? 'Enter your name'
                      : 'Change your name',
                ),

                const SizedBox(height: 24),

                CupertinoButton(
                  color: canSave
                      ? primaryBrown
                      : const Color(0xFFD8D2C8),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: canSave ? _saveName : null,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: canSave
                          ? const Color(0xFFF6F5F1)
                          : const Color(0xFF9A9A9A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}