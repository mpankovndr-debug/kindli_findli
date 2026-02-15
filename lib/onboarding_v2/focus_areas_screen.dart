import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'daily_reminder_screen.dart';
import 'onboarding_state.dart';

class FocusAreasScreen extends StatelessWidget {
  const FocusAreasScreen({super.key});

  static const List<String> areas = [
    'Health',
    'Mood',
    'Productivity',
    'Home & organization',
    'Relationships',
    'Creativity',
    'Finances',
    'Self-care',
  ];

  static const Map<String, IconData> areaIcons = {
    'Health': CupertinoIcons.heart,
    'Mood': CupertinoIcons.smiley,
    'Productivity': CupertinoIcons.checkmark_circle,
    'Home & organization': CupertinoIcons.house,
    'Relationships': CupertinoIcons.person_2,
    'Creativity': CupertinoIcons.paintbrush,
    'Finances': CupertinoIcons.money_dollar_circle,
    'Self-care': CupertinoIcons.sparkles,
  };

  static const int maxSelections = 2;

  void _handleAreaTap(BuildContext context, String area) {
    HapticFeedback.selectionClick();
    
    final state = context.read<OnboardingState>();
    
    if (state.isSelected(area) || state.focusAreas.length < maxSelections) {
      state.toggleFocusArea(area);
    } else {
      _showLimitReached(context);
    }
  }

  void _showLimitReached(BuildContext context) {
    HapticFeedback.lightImpact();
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.symmetric(horizontal: 48),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C342A).withOpacity(0.2),
                blurRadius: 60,
                spreadRadius: 8,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.55),
                      const Color(0xFFF8F5F2).withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withOpacity(0.45),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Limit Reached',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C342A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'You can select up to 2 areas. Deselect one to choose another.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7A6B5F),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF8B7563).withOpacity(0.85),
                                  const Color(0xFF7A6B5F).withOpacity(0.75),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF8B7563).withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3C342A).withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 16,
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
    );
  }

  void _handleContinue(BuildContext context) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DailyReminderScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingState>();
    final canContinue = state.focusAreas.isNotEmpty;
    final selectedCount = state.focusAreas.length;
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 40, 28, 16),
                  child: const Center(
                    child: Text(
                      'Focus areas',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B7563),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // Main content (scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 144),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasName
                              ? 'What matters to you right now, $userName?'
                              : 'What matters to you right now?',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Choose up to two areas ($selectedCount/$maxSelections)',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7A6B5F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You can change this later.',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9B8A7A),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Cards list
                        Column(
                          children: areas.map((area) {
                            final selected = state.isSelected(area);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _FocusAreaItem(
                                area: area,
                                icon: areaIcons[area]!,
                                selected: selected,
                                onTap: () => _handleAreaTap(context, area),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed button container
                if (canContinue)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFD5CCB8).withOpacity(0),
                          const Color(0xFFD5CCB8),
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
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
                              onPressed: () => _handleContinue(context),
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

class _FocusAreaItem extends StatefulWidget {
  final String area;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FocusAreaItem({
    required this.area,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_FocusAreaItem> createState() => _FocusAreaItemState();
}

class _FocusAreaItemState extends State<_FocusAreaItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.selected
                ? [
                    const Color(0xFFE3DAcf).withOpacity(0.7),
                    const Color(0xFFDAD1C6).withOpacity(0.5),
                  ]
                : [
                    const Color(0xFFFFFFFF).withOpacity(0.4),
                    const Color(0xFFF8F5F2).withOpacity(0.25),
                  ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.selected
                ? const Color(0xFF8B7563).withOpacity(0.3)
                : const Color(0xFFFFFFFF).withOpacity(0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3C342A).withOpacity(widget.selected ? 0.12 : 0.06),
              blurRadius: widget.selected ? 16 : 10,
              offset: widget.selected ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.selected
                          ? [
                              const Color(0xFF8B7563).withOpacity(0.2),
                              const Color(0xFF8B7563).withOpacity(0.1),
                            ]
                          : [
                              const Color(0xFFC8BEB4).withOpacity(0.2),
                              const Color(0xFFC8BEB4).withOpacity(0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 22,
                    color: widget.selected
                        ? const Color(0xFF8B7563)
                        : const Color(0xFFA89181),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.area,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3C342A),
                ),
              ),
            ),
            if (widget.selected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8B7563),
                      Color(0xFF7A6B5F),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3C342A).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.checkmark,
                  size: 13,
                  color: Color(0xFFFFFFFF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}