import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_svg/flutter_svg.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlan = 'yearly'; // monthly, yearly, lifetime

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SafeArea(
          child: Container(
            width: size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 448),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
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
                    borderRadius: BorderRadius.circular(36),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTulipIcon(),
                            const SizedBox(height: 20),
                            const Text(
                              'Kindli Beyond',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3C342A),
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kindli is free forever. Beyond gives you more room to grow.',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8B7563).withOpacity(0.9),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                children: const [
                                  _FeatureItem(
                                    icon: CupertinoIcons.star_fill,
                                    text: 'Create habits that truly fit your life',
                                  ),
                                  SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: CupertinoIcons.arrow_2_circlepath,
                                    text: 'Unlimited swaps and refreshes',
                                  ),
                                  SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: CupertinoIcons.arrow_up_circle,
                                    text: 'Shareable weekly progress cards',
                                  ),
                                  SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: CupertinoIcons.chat_bubble,
                                    text: 'Unlimited pinned habits and focus area changes',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildPricingOptions(),
                            const SizedBox(height: 20),
                            _buildCTAButton(),
                            const SizedBox(height: 12),
                            _buildContinueFreeSection(),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B7563).withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF8B7563).withOpacity(0.2),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3C342A).withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.xmark,
                                size: 16,
                                color: Color(0xFF7A6B5F),
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

  Widget _buildTulipIcon() {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.4),
                Color.fromRGBO(255, 255, 255, 0.2),
              ],
            ),
            shape: BoxShape.circle,
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
          child: SizedBox(
            width: 48,
            height: 48,
            child: SvgPicture.asset(
              'assets/images/tulip_logo.svg',
              width: 48,
              height: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPricingOptions() {
    return Column(
      children: [
        // Monthly option
        _buildPricingCard(
          plan: 'monthly',
          label: 'Monthly',
          price: '€4.99',
          pricePerPeriod: 'per month',
          badge: null,
          isSelected: _selectedPlan == 'monthly',
          onTap: () => setState(() => _selectedPlan = 'monthly'),
        ),

        const SizedBox(height: 12),

        // Yearly option (default selected)
        _buildPricingCard(
          plan: 'yearly',
          label: 'Yearly',
          price: '€39.99',
          pricePerPeriod: 'per year',
          badge: const _PricingBadge(
            text: 'Save 33%',
            color: Color(0xFF8B7563),
          ),
          isSelected: _selectedPlan == 'yearly',
          onTap: () => setState(() => _selectedPlan = 'yearly'),
        ),

        const SizedBox(height: 12),

        // Lifetime option
        _buildPricingCard(
          plan: 'lifetime',
          label: 'Lifetime',
          price: '€69.99',
          pricePerPeriod: 'one-time',
          badge: const _PricingBadge(
            text: 'Launch special',
            color: Color(0xFF6B5B4A),
          ),
          isSelected: _selectedPlan == 'lifetime',
          onTap: () => setState(() => _selectedPlan = 'lifetime'),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String plan,
    required String label,
    required String price,
    required String pricePerPeriod,
    required _PricingBadge? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Color borderColor;
    Color backgroundColor;
    Color? priceColor;
    Color? suffixColor;
    List<BoxShadow>? boxShadow;

    if (isSelected) {
      borderColor = const Color(0xFF8B7563);
      backgroundColor = const Color(0xFF8B7563).withOpacity(0.12);
      priceColor = const Color(0xFF8B7563);
      suffixColor = const Color(0xFF8B7563);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF8B7563).withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      borderColor = const Color(0xFF8B7563).withOpacity(0.15);
      backgroundColor = const Color(0xFFFFFFFF).withOpacity(0.6);
      priceColor = const Color(0xFF8B7563);
      suffixColor = const Color(0xFFA08876);
      boxShadow = [
        BoxShadow(
          color: const Color(0xFF3C342A).withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: boxShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Label and price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C342A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: priceColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pricePerPeriod,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: suffixColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Right: Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B7563)
                          : const Color(0xFFC5BBAD),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF8B7563)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          CupertinoIcons.check_mark,
                          size: 12,
                          color: Color(0xFFFFFFFF),
                        )
                      : null,
                ),
              ],
            ),
          ),

          // Badge (if present)
          if (badge != null)
            Positioned(
              top: -8,
              left: 0,
              right: 0,
              child: Center(child: badge),
            ),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            borderRadius: BorderRadius.circular(20),
            onPressed: () {
              // TODO: Implement purchase flow
              Navigator.pop(context);
            },
            child: const Text(
              'Start your 7-day free trial',
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
    );
  }

  Widget _buildContinueFreeSection() {
    return Column(
      children: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Continue with Free',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9B8A7A),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You can upgrade anytime from your profile.',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB0A090).withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF8B7563),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF3C342A),
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

// Pricing badge widget
class _PricingBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _PricingBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isGreen = color == const Color(0xFF8B7563);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGreen
              ? [
                  const Color(0xFF8B7563).withOpacity(0.92),
                  const Color(0xFF6A8B6F).withOpacity(0.88),
                ]
              : [
                  const Color(0xFF6B5B4A).withOpacity(0.88),
                  const Color(0xFF5A4C3D).withOpacity(0.84),
                ],
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: isGreen
                ? const Color(0xFF8B7563).withOpacity(0.3)
                : const Color(0xFF6B5B4A).withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFFFFFF),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

