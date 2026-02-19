import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../utils/profanity_filter.dart';
import 'focus_areas_screen.dart';
import 'onboarding_state.dart';
import '../state/user_state.dart';

class WelcomeV2Screen extends StatefulWidget {
  const WelcomeV2Screen({super.key});

  @override
  State<WelcomeV2Screen> createState() => _WelcomeV2ScreenState();
}

class _WelcomeV2ScreenState extends State<WelcomeV2Screen> 
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _isEnabled = false;

  static const int _maxNameLength = 30;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fade = CurvedAnimation(
      parent: _anim,
      curve: Curves.easeOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _anim,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _anim.forward();
    });

    controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final newIsEnabled = controller.text.trim().isNotEmpty;
    if (newIsEnabled != _isEnabled && mounted) {
      setState(() {
        _isEnabled = newIsEnabled;
      });
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    controller.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _navigateToFocusAreas({String? name}) {
    FocusScope.of(context).unfocus();

    final state = context.read<OnboardingState>();

    if (name != null && name.isNotEmpty) {
      state.setName(name);
      userNameNotifier.value = name;
    }

    state.markWelcomeSeen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FocusAreasScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _handleContinue() {
    final name = controller.text.trim();
    
    if (name.isEmpty) return;
    
    if (name.length > _maxNameLength) {
      _showError('Name should be under $_maxNameLength characters');
      return;
    }

    if (ProfanityFilter.containsProfanity(name)) {
      _showError('Please choose a more appropriate name');
      return;
    }

    _navigateToFocusAreas(name: name);
  }

  void _showError(String message) {
    showKindliDialog(
      context: context,
      title: 'Oops',
      subtitle: message,
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CupertinoPageScaffold(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.2, -1.0),
                  end: Alignment(-0.2, 1.0),
                  colors: [
                    Color(0xFFF5EDE0),
                    Color(0xFFE8DCC8),
                    Color(0xFFDDD1C0),
                    Color(0xFFD9CDB8),
                    Color(0xFFE0D4C4),
                  ],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),

            // Background orbs
            _buildBackgroundOrbs(size),

            // Floating glass cards
            _buildFloatingCards(size),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
                    child: Column(
                      children: [
                        // Logo container (glassmorphic)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              width: 160,
                              height: 160,
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFFFFF).withOpacity(0.2),
                                    const Color(0xFFF8F5F2).withOpacity(0.12),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.25),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3C342A).withOpacity(0.06),
                                    blurRadius: 32,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.4),
                                    blurRadius: 0,
                                    offset: const Offset(0, 1),
                                    blurStyle: BlurStyle.inner,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/kindli_icon_transparent.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          'Welcome to Kindli',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        const Text(
                          'Small steps. No pressure.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7A6B5F),
                            height: 1.6,
                          ),
                        ),

                        const Spacer(),

                        // Name input (glassmorphic)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 384),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFFFFFFFF).withOpacity(0.45),
                                      const Color(0xFFF8F5F2).withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.35),
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
                                child: CupertinoTextField(
                                  controller: controller,
                                  placeholder: 'What should we call you?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C342A),
                                  ),
                                  placeholderStyle: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF3C342A).withOpacity(0.4),
                                  ),
                                  decoration: const BoxDecoration(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Continue button (tinted glass)
                        AnimatedOpacity(
                          opacity: _isEnabled ? 1.0 : 0.45,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 384),
                            width: double.infinity,
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
                                        const Color(0xFF8B7563).withOpacity(0.75),
                                        const Color(0xFF7A6B5F).withOpacity(0.65),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8B7563).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF3C342A).withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CupertinoButton(
                                    onPressed: _isEnabled ? _handleContinue : null,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    borderRadius: BorderRadius.circular(20),
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
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Skip button
                        CupertinoButton(
                          padding: const EdgeInsets.all(12),
                          onPressed: () => _navigateToFocusAreas(),
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size) {
    return Stack(
      children: [
        // Orb 1 - Top Right (largest)
        Positioned(
          top: size.height * -0.1,
          right: size.width * 0.15,
          child: Container(
            width: 288,
            height: 288,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFF8F0).withOpacity(0.8),
                  const Color(0xFFE2CEB4).withOpacity(0.3),
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
          bottom: size.height * 0.05,
          left: size.width * -0.08,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  const Color(0xFFF0E4D2).withOpacity(0.7),
                  const Color(0xFFD2C3AF).withOpacity(0.25),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 3 - Center Right
        Positioned(
          top: size.height * 0.5,
          left: size.width * 0.6,
          child: Container(
            width: 224,
            height: 224,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.4),
                radius: 0.9,
                colors: [
                  const Color(0xFFFFF5EB).withOpacity(0.65),
                  const Color(0xFFC8B9A5).withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),

        // Orb 4 - Top Left
        Positioned(
          top: size.height * 0.25,
          left: size.width * 0.1,
          child: Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: [
                  const Color(0xFFEBDCC8).withOpacity(0.6),
                  const Color(0xFFC3B4A0).withOpacity(0.2),
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCards(Size size) {
    return Stack(
      children: [
        // Card 1 - Top Right
        Positioned(
          top: size.height * 0.15,
          right: size.width * 0.1,
          child: Transform.rotate(
            angle: 12 * (3.14159 / 180),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFFFFF).withOpacity(0.25),
                        const Color(0xFFFFFFFF).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * 0.15,
          child: Transform.rotate(
            angle: -6 * (3.14159 / 180),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFFFFF).withOpacity(0.2),
                        const Color(0xFFFFFFFF).withOpacity(0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Floating particles widget (KEEP FROM ORIGINAL)
class _FloatingParticles extends StatefulWidget {
  const _FloatingParticles();

  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final r = Random();

    _particles = List.generate(
      25,
      (_) => _Particle(
        base: Offset(r.nextDouble(), r.nextDouble()),
        radius: r.nextDouble() * 30 + 15,
        speed: r.nextDouble() * 0.5 + 0.3,
        phase: r.nextDouble() * pi * 2,
        opacity: r.nextDouble() * 0.25 + 0.15,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return IgnorePointer(
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Stack(
              children: _particles.map((p) {
                final dx = sin((_controller.value * 2 * pi * p.speed) + p.phase) * 35;
                final dy = cos((_controller.value * 2 * pi * p.speed) + p.phase) * 35;

                return Positioned(
                  left: p.base.dx * size.width + dx - p.radius,
                  top: p.base.dy * size.height + dy - p.radius,
                  child: Container(
                    width: p.radius * 2,
                    height: p.radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFFFFF).withOpacity(0.0),
                          const Color(0xFFB5C9BA).withOpacity(p.opacity * 0.4),
                          const Color(0xFF9FB5A3).withOpacity(p.opacity),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9FB5A3).withOpacity(p.opacity * 0.5),
                          blurRadius: p.radius * 1.0,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final Offset base;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;

  _Particle({
    required this.base,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}