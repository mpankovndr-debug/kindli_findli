import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'onboarding_state.dart';

class HabitRevealScreen extends StatefulWidget {
  const HabitRevealScreen({super.key});

  @override
  State<HabitRevealScreen> createState() => _HabitRevealScreenState();
}

class _HabitRevealScreenState extends State<HabitRevealScreen>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<double>> _fadeAnimations = [];
  List<Animation<Offset>> _slideAnimations = [];

  @override
  void initState() {
    super.initState();

    // Generate habits first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<OnboardingState>();
      await state.generateUserHabits();

      // Initialize animations after habits are generated
      _initializeAnimations();
    });
  }

  void _initializeAnimations() {
    final state = context.read<OnboardingState>();
    final habitCount = state.userHabits.length;

    _controllers = List.generate(
      habitCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    // Start staggered animations
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleContinue() async {
    HapticFeedback.mediumImpact();

    final state = context.read<OnboardingState>();
    await state.completeOnboarding();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainTabs(),
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
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();
    final size = MediaQuery.of(context).size;

    if (state.userHabits.isEmpty) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background - same as Focus Areas / Reminder
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.15, -1.0),
                end: Alignment(-0.15, 1.0),
                colors: [
                  Color(0xFFF2E9DB),
                  Color(0xFFE6DDCF),
                  Color(0xFFDBD2C4),
                  Color(0xFFD5CCB8),
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),

          // Background orbs
          _buildBackgroundOrbs(size),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 80, 28, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Here\'s what we picked for you',
                          textAlign: TextAlign.center,
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
                        _buildSubheading(state),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Habits list (animated)
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.userHabits.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAnimatedHabitCard(
                            state.userHabits[index],
                            index,
                            state,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Reassurance message
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFFFFF).withOpacity(0.4),
                              const Color(0xFFF8F5F2).withOpacity(0.25),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFFFFF).withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C342A).withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'You can add, remove, or browse more habits anytime. There\'s no pressure to do them all.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7A6B5F),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CTA button
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
                                const Color(0xFF8B7563).withOpacity(0.9),
                                const Color(0xFF7A6B5F).withOpacity(0.85),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8B7563).withOpacity(0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3C342A).withOpacity(0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            onPressed: _handleContinue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            borderRadius: BorderRadius.circular(20),
                            child: const Text(
                              'Let\'s begin',
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
        ],
      ),
    );
  }

  Widget _buildSubheading(OnboardingState state) {
    if (state.focusAreas.isEmpty) {
      return const Text(
        'Based on your preferences',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7A6B5F),
          height: 1.5,
        ),
      );
    }

    final areas = state.focusAreas;
    final text = areas.length == 1
        ? 'Based on ${areas[0]}'
        : 'Based on ${areas[0]} & ${areas[1]}';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7A6B5F),
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'Based on '),
          TextSpan(
            text: areas[0],
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (areas.length > 1) ...[
            const TextSpan(text: ' & '),
            TextSpan(
              text: areas[1],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedHabitCard(String habit, int index, OnboardingState state) {
    if (_controllers.isEmpty || index >= _controllers.length) {
      return const SizedBox();
    }

    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3C342A).withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                habit,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C342A),
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size) {
    return Stack(
      children: [
        // Orb 1 - Top Right
        Positioned(
          top: size.height * 0.1,
          right: size.width * -0.05,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFF8F0).withOpacity(0.6),
                  const Color(0xFFDCCDB9).withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * -0.08,
          child: Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  const Color(0xFFF0E6D7).withOpacity(0.55),
                  const Color(0xFFD2C3AF).withOpacity(0.18),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

}
