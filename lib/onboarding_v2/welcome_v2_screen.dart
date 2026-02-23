import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/profanity_filter.dart';
import 'focus_areas_screen.dart';
import 'onboarding_state.dart';
import '../state/user_state.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class WelcomeV2Screen extends StatefulWidget {
  const WelcomeV2Screen({super.key});

  @override
  State<WelcomeV2Screen> createState() => _WelcomeV2ScreenState();
}

class _WelcomeV2ScreenState extends State<WelcomeV2Screen>
    with SingleTickerProviderStateMixin {
  final controller = TextEditingController();
  late final AnimationController _anim;
  late final Animation<double> _fadeBrand;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _fadeInput;
  late final Animation<Offset> _slideInput;

  bool _isEnabled = false;

  static const int _maxNameLength = 30;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeBrand = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _fadeTagline = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.35, 0.70, curve: Curves.easeOut),
    );

    _fadeInput = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
    );

    _slideInput = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
    ));

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
      final l10n = AppLocalizations.of(context);
      _showError(l10n.onboardingNameTooLong(_maxNameLength));
      return;
    }

    if (ProfanityFilter.containsProfanity(name)) {
      final l10n = AppLocalizations.of(context);
      _showError(l10n.onboardingNameInappropriate);
      return;
    }

    _navigateToFocusAreas(name: name);
  }

  void _showError(String message) {
    final l10n = AppLocalizations.of(context);
    showIntendedDialog(
      context: context,
      title: l10n.onboardingOops,
      subtitle: message,
      actions: [
        CupertinoDialogAction(
          child: Text(l10n.commonOk),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CupertinoPageScaffold(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.2, -1.0),
                  end: const Alignment(-0.2, 1.0),
                  colors: [
                    colors.onboardingBg1,
                    colors.onboardingBg2,
                    colors.onboardingBg3,
                    colors.onboardingBg4,
                    colors.onboardingBg3,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
              ),
            ),

            // Background orbs
            _buildBackgroundOrbs(size, colors),

            // Floating glass cards
            _FloatingCards(size: size),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height
                          - MediaQuery.of(context).padding.top
                          - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 200),

                          // Brand group (icon + title)
                          FadeTransition(
                            opacity: _fadeBrand,
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
                                            colors.surfaceLight.withOpacity(0.12),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color: const Color(0xFFFFFFFF).withOpacity(0.25),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.textPrimary.withOpacity(0.06),
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
                                Text(
                                  l10n.appNameIntended,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Tagline
                          FadeTransition(
                            opacity: _fadeTagline,
                            child: Text(
                              l10n.onboardingTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: colors.ctaSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Input group (name + continue + skip)
                          FadeTransition(
                            opacity: _fadeInput,
                            child: SlideTransition(
                              position: _slideInput,
                              child: Column(
                              children: [
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
                                              colors.surfaceLight.withOpacity(0.3),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: const Color(0xFFFFFFFF).withOpacity(0.35),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colors.textPrimary.withOpacity(0.08),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CupertinoTextField(
                                          controller: controller,
                                          placeholder: l10n.onboardingNamePrompt,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary,
                                          ),
                                          placeholderStyle: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary.withOpacity(0.4),
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
                                                colors.ctaPrimary.withOpacity(0.75),
                                                colors.ctaSecondary.withOpacity(0.65),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: colors.ctaPrimary.withOpacity(0.3),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.textPrimary.withOpacity(0.2),
                                                blurRadius: 20,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: CupertinoButton(
                                            onPressed: _isEnabled ? _handleContinue : null,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Text(
                                              l10n.commonContinue,
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
                                  child: Text(
                                    l10n.onboardingSkipForNow,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textTertiary,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),
                              ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundOrbs(Size size, AppColorScheme colors) {
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
                  colors.surfaceLightest.withOpacity(0.8),
                  colors.onboardingBg2.withOpacity(0.3),
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
                  colors.onboardingBg1.withOpacity(0.7),
                  colors.onboardingBg4.withOpacity(0.25),
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
                  colors.surfaceLightest.withOpacity(0.65),
                  colors.onboardingBg4.withOpacity(0.2),
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
                  colors.onboardingBg1.withOpacity(0.6),
                  colors.onboardingBg4.withOpacity(0.2),
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

}

class _FloatingCards extends StatefulWidget {
  final Size size;
  const _FloatingCards({required this.size});

  @override
  State<_FloatingCards> createState() => _FloatingCardsState();
}

class _FloatingCardsState extends State<_FloatingCards>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl1;
  late final AnimationController _ctrl2;
  late final AnimationController _ctrl3;
  late final AnimationController _ctrl4;
  late final AnimationController _ctrl5;
  late final Animation<Offset> _drift1;
  late final Animation<Offset> _drift2;
  late final Animation<Offset> _drift3;
  late final Animation<Offset> _drift4;
  late final Animation<Offset> _drift5;

  @override
  void initState() {
    super.initState();

    _ctrl1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );
    _drift1 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(20, 15),
    ).animate(CurvedAnimation(parent: _ctrl1, curve: Curves.easeInOut));

    _ctrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 11000),
    );
    _drift2 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-15, 20),
    ).animate(CurvedAnimation(parent: _ctrl2, curve: Curves.easeInOut));

    _ctrl3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9500),
    );
    _drift3 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(12, -10),
    ).animate(CurvedAnimation(parent: _ctrl3, curve: Curves.easeInOut));

    _ctrl4 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _drift4 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-10, 12),
    ).animate(CurvedAnimation(parent: _ctrl4, curve: Curves.easeInOut));

    _ctrl5 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _drift5 = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(8, -14),
    ).animate(CurvedAnimation(parent: _ctrl5, curve: Curves.easeInOut));

    _ctrl1.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _ctrl2.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _ctrl3.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) _ctrl4.repeat(reverse: true);
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _ctrl5.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl1.dispose();
    _ctrl2.dispose();
    _ctrl3.dispose();
    _ctrl4.dispose();
    _ctrl5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Stack(
      children: [
        // Card 1 - Top Right
        Positioned(
          top: size.height * 0.15,
          right: size.width * 0.1,
          child: AnimatedBuilder(
            animation: _drift1,
            builder: (context, child) => Transform.translate(
              offset: _drift1.value,
              child: child,
            ),
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
        ),

        // Card 2 - Bottom Left
        Positioned(
          bottom: size.height * 0.2,
          left: size.width * 0.15,
          child: AnimatedBuilder(
            animation: _drift2,
            builder: (context, child) => Transform.translate(
              offset: _drift2.value,
              child: child,
            ),
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
        ),
        // Card 3 - Top Left (small)
        Positioned(
          top: size.height * 0.08,
          left: size.width * 0.12,
          child: AnimatedBuilder(
            animation: _drift3,
            builder: (context, child) => Transform.translate(
              offset: _drift3.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: -18 * (3.14159 / 180),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withOpacity(0.2),
                          const Color(0xFFFFFFFF).withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
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
        ),

        // Card 4 - Mid Right (small)
        Positioned(
          top: size.height * 0.45,
          right: size.width * 0.05,
          child: AnimatedBuilder(
            animation: _drift4,
            builder: (context, child) => Transform.translate(
              offset: _drift4.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: 22 * (3.14159 / 180),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withOpacity(0.18),
                          const Color(0xFFFFFFFF).withOpacity(0.03),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Card 5 - Bottom Right (small)
        Positioned(
          bottom: size.height * 0.12,
          right: size.width * 0.2,
          child: AnimatedBuilder(
            animation: _drift5,
            builder: (context, child) => Transform.translate(
              offset: _drift5.value,
              child: child,
            ),
            child: Transform.rotate(
              angle: -10 * (3.14159 / 180),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withOpacity(0.22),
                          const Color(0xFFFFFFFF).withOpacity(0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.22),
                        width: 1,
                      ),
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
