import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'habit_reveal_screen.dart';
import 'onboarding_state.dart';

class DailyReminderScreen extends StatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  State<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen> {
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    final state = context.read<OnboardingState>();
    _timeController = TextEditingController(
      text: state.reminderTime ?? '09:00',
    );
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.mediumImpact();

    final state = context.read<OnboardingState>();

    // Navigate to Habit Reveal screen
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HabitRevealScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();
    final size = MediaQuery.of(context).size;

    final userName = state.name;
    final hasName = userName != null && userName.isNotEmpty;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.18, -1.0),
                end: Alignment(-0.18, 1.0),
                colors: [
                  Color(0xFFEFE6D8),
                  Color(0xFFE3D9CB),
                  Color(0xFFD8CEC0),
                  Color(0xFFD0C6B8),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),

          // Background orbs
          _buildBackgroundOrbs(size),

          // Content
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Column with Header + Expanded ScrollView
                Column(
                  children: [
                    // Header with back button and label
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Label (centered)
                          const Center(
                            child: Text(
                              'Reminder',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B7563),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),

                          // Back button (left aligned)
                          Positioned(
                            left: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFFFFFFFF).withOpacity(0.35),
                                        const Color(0xFFFFFFFF).withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3C342A).withOpacity(0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () => Navigator.pop(context),
                                    child: const Icon(
                                      CupertinoIcons.back,
                                      size: 20,
                                      color: Color(0xFF8B7563),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Want a gentle daily reminder?',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C342A),
                                height: 1.3,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Just once a day. No pressure.',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A6B5F),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Toggle card
                            _buildToggleCard(state),

                            // Helper message when OFF
                            if (!state.dailyReminderEnabled)
                              const Padding(
                                padding: EdgeInsets.only(top: 4, bottom: 20),
                                child: Center(
                                  child: Text(
                                    'Switch this on to pick the time for your daily reminder.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF9B8A7A),
                                      height: 1.5,
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

                // Gradient overlay
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 180,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFD0C6B8).withOpacity(0.0),
                            const Color(0xFFD0C6B8).withOpacity(0.92),
                            const Color(0xFFD0C6B8).withOpacity(0.98),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Buttons
                Positioned(
                  left: 28,
                  right: 28,
                  bottom: 48,
                  child: Column(
                    children: [
                      // Start button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C342A).withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
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
                              ),
                              child: CupertinoButton(
                                onPressed: _handleContinue,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                child: Text(
                                  hasName ? 'Let\'s go, $userName' : 'Start',
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
                      const SizedBox(height: 16),
                      // Skip button
                      CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        onPressed: _handleContinue,
                        child: const Text(
                          'Skip',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size) {
    return Stack(
      children: [
        // Orb 1 - Top Left
        Positioned(
          top: size.height * 0.05,
          left: size.width * -0.1,
          child: Container(
            width: 288,
            height: 288,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFFAF2).withOpacity(0.65),
                  const Color(0xFFDCD2C3).withOpacity(0.22),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 65, sigmaY: 65),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 2 - Bottom Right
        Positioned(
          bottom: size.height * 0.15,
          right: size.width * -0.08,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 0.9,
                colors: [
                  const Color(0xFFF5EBDC).withOpacity(0.6),
                  const Color(0xFFD2C8B9).withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 58, sigmaY: 58),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard(OnboardingState state) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFFFF).withOpacity(0.45),
                const Color(0xFFF8F5F2).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C342A).withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top section - Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gentle daily reminder',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C342A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Around ${_timeController.text}',
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8B7563),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildToggleSwitch(state),
                  ],
                ),
              ),

              // Divider and time picker (when ON)
              if (state.dailyReminderEnabled) ...[
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFFC8BEB4).withOpacity(0),
                        const Color(0xFFC8BEB4).withOpacity(0.3),
                        const Color(0xFFC8BEB4).withOpacity(0),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const Text(
                        'Remind me at',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B5B4A),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 48),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFFFFFF).withOpacity(0.6),
                                  const Color(0xFFFFFFFF).withOpacity(0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFC8BEB4).withOpacity(0.25),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3C342A).withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CupertinoTextField(
                              controller: _timeController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C342A),
                              ),
                              decoration: const BoxDecoration(),
                              onTap: () async {
                                DateTime tempTime = _parseTime(_timeController.text);

                                await showCupertinoModalPopup(
                                  context: context,
                                  barrierColor: Colors.black.withOpacity(0.5),
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  builder: (context) => Container(
                                    margin: EdgeInsets.only(
                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                                        child: Container(
                                          height: 340,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                const Color(0xFFF5ECE0).withOpacity(0.98),
                                                const Color(0xFFEDE4D8).withOpacity(0.96),
                                                const Color(0xFFE6DDD1).withOpacity(0.98),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.6),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              // Handle bar
                                              Container(
                                                margin: const EdgeInsets.only(top: 12),
                                                width: 36,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF8B7563).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                              
                                              // Header with Done button
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Set reminder time',
                                                      style: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xFF3C342A),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        HapticFeedback.lightImpact();
                                                        setState(() {
                                                          _timeController.text =
                                                              '${tempTime.hour.toString().padLeft(2, '0')}:${tempTime.minute.toString().padLeft(2, '0')}';
                                                          context.read<OnboardingState>().setReminderTime(_timeController.text);
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: [
                                                              const Color(0xFF8B7563).withOpacity(0.92),
                                                              const Color(0xFF7A6B5F).withOpacity(0.88),
                                                            ],
                                                          ),
                                                          borderRadius: BorderRadius.circular(14),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: const Color(0xFF3C342A).withOpacity(0.2),
                                                              blurRadius: 8,
                                                              offset: const Offset(0, 3),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Text(
                                                          'Done',
                                                          style: TextStyle(
                                                            fontFamily: 'Sora',
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Subtle divider
                                              Container(
                                                height: 1,
                                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF8B7563).withOpacity(0.0),
                                                      const Color(0xFF8B7563).withOpacity(0.15),
                                                      const Color(0xFF8B7563).withOpacity(0.0),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Time picker with custom styling
                                              Expanded(
                                                child: CupertinoTheme(
                                                  data: const CupertinoThemeData(
                                                    textTheme: CupertinoTextThemeData(
                                                      dateTimePickerTextStyle: TextStyle(
                                                        fontFamily: 'Sora',
                                                        fontSize: 22,
                                                        fontWeight: FontWeight.w500,
                                                        color: Color(0xFF3C342A),
                                                      ),
                                                    ),
                                                  ),
                                                  child: CupertinoDatePicker(
                                                    mode: CupertinoDatePickerMode.time,
                                                    use24hFormat: true,
                                                    initialDateTime: tempTime,
                                                    backgroundColor: Colors.transparent,
                                                    onDateTimeChanged: (DateTime newTime) {
                                                      tempTime = newTime;
                                                    },
                                                  ),
                                                ),
                                              ),
                                              
                                              // Bottom safe area padding
                                              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

  Widget _buildToggleSwitch(OnboardingState state) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<OnboardingState>().setDailyReminder(!state.dailyReminderEnabled);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: state.dailyReminderEnabled
                ? [
                    const Color(0xFF8B7563).withOpacity(0.9),
                    const Color(0xFF7A6B5F).withOpacity(0.85),
                  ]
                : [
                    const Color(0xFFE0D8CD).withOpacity(0.8),
                    const Color(0xFFD2CABF).withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.dailyReminderEnabled
                ? const Color(0xFF8B7563).withOpacity(0.3)
                : const Color(0xFFC8BEB4).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C342A).withOpacity(state.dailyReminderEnabled ? 0.2 : 0.08),
              blurRadius: state.dailyReminderEnabled ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: state.dailyReminderEnabled ? 22 : 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}