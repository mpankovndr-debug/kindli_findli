import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../utils/completion_messages.dart';

/// Modal for completing a habit with smooth animations
/// Implements the full completion sequence from design specs
class HabitCompletionModal extends StatefulWidget {
  final String habitTitle;

  const HabitCompletionModal({
    super.key,
    required this.habitTitle,
  });

  @override
  State<HabitCompletionModal> createState() => _HabitCompletionModalState();
}

class _HabitCompletionModalState extends State<HabitCompletionModal>
    with TickerProviderStateMixin {
  late AnimationController _buttonScaleController;
  late AnimationController _colorController;
  late AnimationController _modalSlideController;
  late AnimationController _heartScaleController;

  late Animation<double> _buttonScaleAnimation;
  late Animation<Color?> _buttonColorAnimation;
  late Animation<Offset> _modalSlideAnimation;
  late Animation<double> _heartScaleAnimation;

  bool _isPressed = false;
  bool _showCelebration = false;
  String _celebrationTitle = '';
  String _celebrationMessage = '';

  @override
  void initState() {
    super.initState();

    // Button scale animation (95% on press)
    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeOut),
    );

    // Button color transition (brown → green)
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonColorAnimation = ColorTween(
      begin: const Color(0xFF8B7563), // Brown
      end: const Color(0xFF6A8B6F), // Sage green
    ).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeOut),
    );

    // Modal slide-down animation
    _modalSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _modalSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.0),
    ).animate(
      CurvedAnimation(parent: _modalSlideController, curve: Curves.easeInOut),
    );

    // Heart scale animation (celebration)
    _heartScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartScaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _buttonScaleController.dispose();
    _colorController.dispose();
    _modalSlideController.dispose();
    _heartScaleController.dispose();
    super.dispose();
  }

  void _handleButtonPress() {
    setState(() {
      _isPressed = true;
    });
    _buttonScaleController.forward();
  }

  void _handleButtonRelease() async {
    if (!_isPressed) return;

    // Release scale animation
    _buttonScaleController.reverse();

    // Start color transition
    _colorController.forward();

    HapticFeedback.mediumImpact();

    // Mark as done
    await HabitTracker.markDone(widget.habitTitle);

    // Wait for color transition to complete
    await Future.delayed(const Duration(milliseconds: 300));

    // Show celebration
    if (mounted) {
      setState(() {
        _showCelebration = true;
        _celebrationTitle = CompletionMessages.getCelebrationTitle();
        _celebrationMessage = CompletionMessages.getMessage(widget.habitTitle);
      });

      // Start heart animation
      _heartScaleController.forward();

      // Wait to show celebration
      await Future.delayed(const Duration(milliseconds: 1800));

      // Dismiss modal with slide-down animation
      if (mounted) {
        await _modalSlideController.forward();
        if (mounted) {
          Navigator.pop(context, true); // Return true = completed
        }
      }
    }
  }

  void _handleNotToday() {
    HapticFeedback.lightImpact();
    Navigator.pop(context, false); // Return false = skipped
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _modalSlideAnimation,
      child: Container(
        color: const Color(0xFF000000).withOpacity(0.35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: _showCelebration
                ? _buildCelebrationView()
                : _buildQuestionView(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    return Container(
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
                begin: Alignment(0.0, 1.0), // bottom
                end: Alignment(0.0, -1.0), // top
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
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Question text
                const Text(
                  'Did you do this today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3C342A),
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                // "I did it" button with animations
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _buttonScaleAnimation,
                    _buttonColorAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: GestureDetector(
                        onTapDown: (_) => _handleButtonPress(),
                        onTapUp: (_) => _handleButtonRelease(),
                        onTapCancel: () {
                          setState(() {
                            _isPressed = false;
                          });
                          _buttonScaleController.reverse();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _buttonColorAnimation.value ?? const Color(0xFF8B7563),
                                (_buttonColorAnimation.value ?? const Color(0xFF8B7563))
                                    .withOpacity(0.88),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: (_buttonColorAnimation.value ?? const Color(0xFF8B7563))
                                  .withOpacity(0.4),
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
                          child: const Text(
                            'I did it',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 14),

                // "Not today" button
                CupertinoButton(
                  onPressed: _handleNotToday,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    'Not today',
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
    );
  }

  Widget _buildCelebrationView() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 384),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.0, 1.0), // bottom
                end: Alignment(0.0, -1.0), // top
                colors: [
                  Color.fromRGBO(245, 236, 224, 0.96),
                  Color.fromRGBO(237, 228, 216, 0.94),
                  Color.fromRGBO(230, 221, 209, 0.95),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heart icon with scale animation
                ScaleTransition(
                  scale: _heartScaleAnimation,
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: CustomPaint(
                      painter: _HeartPainter(),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Celebration title
                Text(
                  _celebrationTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B5B4A),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Celebration message
                Text(
                  _celebrationMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8A8078),
                    letterSpacing: -0.1,
                    height: 1.5,
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

/// Custom painter for gradient heart icon
class _HeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE5B5B0),
          Color(0xFFD4A0A0),
          Color(0xFFC99090),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    paint.color = paint.color.withOpacity(0.92);

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Heart shape
    path.moveTo(width * 0.5, height * 0.3);

    // Left curve
    path.cubicTo(
      width * 0.2, height * 0.1,
      width * 0.1, height * 0.3,
      width * 0.1, height * 0.45,
    );
    path.cubicTo(
      width * 0.1, height * 0.7,
      width * 0.5, height * 0.9,
      width * 0.5, height * 0.95,
    );

    // Right curve
    path.cubicTo(
      width * 0.5, height * 0.9,
      width * 0.9, height * 0.7,
      width * 0.9, height * 0.45,
    );
    path.cubicTo(
      width * 0.9, height * 0.3,
      width * 0.8, height * 0.1,
      width * 0.5, height * 0.3,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
