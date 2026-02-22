import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
// sign_in_with_apple and sign_in_button packages available for auth implementation

import '../main.dart';
import '../onboarding_v2/onboarding_state.dart';
import '../onboarding_v2/welcome_v2_screen.dart';
import '../state/user_state.dart';
import '../utils/profanity_filter.dart';
import '../utils/text_styles.dart';
import '../utils/responsive_utils.dart';
import 'paywall_screen.dart';
import 'subscription_management_modal.dart';
import '../services/auth_service.dart';
import '../services/moments_service.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_preferences_service.dart';
import 'moments_collection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final controller = TextEditingController();
  bool _isEditing = false;

  // Notification prefs state
  bool _dailyEnabled = false;
  int _notifHour = 9;
  int _notifMinute = 0;
  bool _weeklyEnabled = true;
  bool _notifPermissionDenied = false;
  bool _notifPrefsLoaded = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final enabled = await NotificationPreferencesService.isEnabled();
    final hour = await NotificationPreferencesService.getHour();
    final minute = await NotificationPreferencesService.getMinute();
    final weeklyEnabled = await NotificationPreferencesService.isWeeklyEnabled();
    if (mounted) {
      setState(() {
        _dailyEnabled = enabled;
        _notifHour = hour;
        _notifMinute = minute;
        _weeklyEnabled = weeklyEnabled;
        _notifPrefsLoaded = true;
      });
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
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

    if (ProfanityFilter.containsProfanity(name)) {
      showKindliDialog(
        context: context,
        title: 'Hmm',
        subtitle: 'Please choose a different name',
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);

    userNameNotifier.value = name;

    if (mounted) {
      context.read<OnboardingState>().setName(name);
    }

    controller.clear();
    setState(() {
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      controller.text = userNameNotifier.value ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      controller.clear();
    });
  }

  Future<void> _contactSupport() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mpankov.ndr@gmail.com',
      query: 'subject=Intended Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        showKindliModal(
          context: context,
          title: 'Cannot open email',
          subtitle: 'Please email us at\nmpankov.ndr@gmail.com',
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3C342A).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
        );
      }
    }
  }

  void _changeFocusAreas() {
    final onboardingState = context.read<OnboardingState>();

    if (!onboardingState.canChangeFocusAreas()) {
      _showFocusAreaLimitDialog();
      return;
    }

    _showChangeFocusAreasConfirmation();
  }

  void _showChangeFocusAreasConfirmation() {
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
                          'Change focus areas?',
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
                        const SizedBox(height: 12),

                        // Description
                        const Text(
                          'Your habits will refresh based on new areas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Primary button
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (_) => _FocusAreaChangeScreen(),
                                      ),
                                    );
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Text(
                                    'Change areas',
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

                        const SizedBox(height: 16),

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

  void _showFocusAreaLimitDialog() {
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
                          'Change focus areas?',
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
                        const SizedBox(height: 12),

                        // Description
                        const Text(
                          'You\'ve used your free change this month.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Options
                        const Text(
                          '• One-time: €0.99\n• Intended+: Unlimited',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B7563),
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Primary button (Pay)
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showPaymentPlaceholder();
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Text(
                                    'Pay €0.99',
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

                        const SizedBox(height: 14),

                        // Secondary button (Unlock Intended+)
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.4),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3C342A).withOpacity(0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CupertinoButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showUpgradeScreen();
                                  },
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Text(
                                    'Unlock Intended+',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B7563),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

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

  void _showPaymentPlaceholder() {
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Payment',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'In-app purchase coming soon!',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
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

  void _showSubscriptionManagement() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SubscriptionManagementModal(),
    );
  }

  void _showRefreshConfirmation() {
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Refresh habits?',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You\'ll get a new set of habits based on your focus areas.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: 'Refresh',
            onPressed: () async {
              Navigator.pop(context);
              final onboardingState = context.read<OnboardingState>();
              await onboardingState.refreshHabits();
              if (mounted) {
                _showRefreshSuccess();
              }
            },
          ),
          const SizedBox(height: 14),
          styledSecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showRefreshSuccess() {
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Habits refreshed',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You have a new set of habits waiting for you.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: 'Great',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHabits() async {
    final onboardingState = context.read<OnboardingState>();

    if (!onboardingState.canRefreshHabits()) {
      showKindliDialog(
        context: context,
        title: 'Daily limit reached',
        subtitle:
            'You\'ve refreshed your habits 3 times today. Try again tomorrow, or upgrade to Intended+ for unlimited refreshes.',
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    _showRefreshConfirmation();
  }

  void _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://kindli.app/privacy');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showKindliDialog(
          context: context,
          title: 'Cannot open link',
          subtitle: 'Please visit kindli.app/privacy in your browser',
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    }
  }

  void _openTermsOfService() async {
    final Uri url = Uri.parse('https://kindli.app/terms');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        showKindliDialog(
          context: context,
          title: 'Cannot open link',
          subtitle: 'Please visit kindli.app/terms in your browser',
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      }
    }
  }

  void _deleteProfileData() {
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete all data?',
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This will permanently delete all your habits, progress, and settings. This action cannot be undone.',
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (mounted) {
                  await context.read<OnboardingState>().reset();
                  userNameNotifier.value = null;

                  Navigator.pushReplacement(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const WelcomeV2Screen(),
                    ),
                  );
                }
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
          styledSecondaryButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.watch<OnboardingState>();
    final hasHabits = onboardingState.userHabits.isNotEmpty;
    final focusAreas = onboardingState.focusAreas;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (fixed)
                Padding(
                  padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 20),
                  child: const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3C342A),
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 140),
                    children: [
                // Profile Info Card (Main Card with 4 sections)
                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Your Name
                      const Text(
                        'Your name',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A8A78),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (!_isEditing) ...[
                        ValueListenableBuilder<String?>(
                          valueListenable: userNameNotifier,
                          builder: (context, name, _) {
                            final displayName =
                                (name != null && name.isNotEmpty) ? name : 'Add your name';
                            final hasName = name != null && name.isNotEmpty;

                            return Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          hasName ? const Color(0xFF3C342A) : const Color(0xFFB5A89A),
                                    ),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _startEditing,
                                  child: const Icon(
                                    CupertinoIcons.pencil,
                                    size: 20,
                                    color: Color(0xFF8B7563),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        CupertinoTextField(
                          controller: controller,
                          placeholder: 'Enter your name',
                          autofocus: true,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3C342A),
                          ),
                          placeholderStyle: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            color: Color(0xFFB5A89A),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE8E3DB),
                              width: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                color: canSave
                                    ? const Color(0xFF6B5B4A)
                                    : const Color(0xFFD8D2C8),
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                onPressed: canSave ? _saveName : null,
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: canSave
                                        ? const Color(0xFFF6F5F1)
                                        : const Color(0xFFB5A89A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              onPressed: _cancelEditing,
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8B7563),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Divider
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        color: const Color(0xFF8B7563).withOpacity(0.1),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Plan
                      const Text(
                        'Plan',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A8A78),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Consumer<UserState>(
                              builder: (context, userState, child) {
                                return Text(
                                  userState.hasSubscription ? 'Intended+' : 'Core',
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3C342A),
                                  ),
                                );
                              },
                            ),
                          ),
                          Consumer<UserState>(
                            builder: (context, userState, child) {
                              if (userState.hasSubscription) {
                                // Show "Manage" button for subscribed users
                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _showSubscriptionManagement,
                                  child: const Text(
                                    'Manage',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8B7563),
                                    ),
                                  ),
                                );
                              } else {
                                // Show "UNLOCK INTENDED+" button for free users
                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _showUpgradeScreen,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD7BAA3).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: const Color(0xFFD7BAA3).withOpacity(0.6),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'UNLOCK INTENDED+',
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B7563),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      if (focusAreas.isNotEmpty) ...[
                        // Divider
                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: const Color(0xFF8B7563).withOpacity(0.1),
                        ),
                        const SizedBox(height: 24),

                        // Section 3: Focus Areas
                        const Text(
                          'Focus areas',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9A8A78),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                focusAreas.join(', '),
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3C342A),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _changeFocusAreas,
                              child: const Icon(
                                CupertinoIcons.pencil,
                                size: 20,
                                color: Color(0xFF8B7563),
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Divider
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        color: const Color(0xFF8B7563).withOpacity(0.1),
                      ),
                      const SizedBox(height: 24),

                      // Section: Your Moments
                      const Text(
                        'Your moments',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A8A78),
                        ),
                      ),
                      const SizedBox(height: 8),

                      FutureBuilder<int>(
                        future: MomentsService.getCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          final label = count == 0
                              ? 'None yet'
                              : count == 1
                                  ? '1 moment'
                                  : '$count moments';
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C342A),
                                  ),
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => const MomentsCollectionScreen(),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 20,
                                  color: Color(0xFF8B7563),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // SETTINGS label
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 4),
                  child: Text(
                    'SETTINGS',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9A8A78),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Notifications Card
                _GlassCard(
                  child: Column(
                    children: [
                      // Row 1: Daily reminders toggle
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4B782).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.bell,
                              size: 18,
                              color: Color(0xFF9A8566),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Daily reminders',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C342A),
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _dailyEnabled,
                            activeTrackColor: const Color(0xFF7A8B6F),
                            thumbColor: const Color(0xFFFFFFFF),
                            onChanged: (value) async {
                              if (value) {
                                final granted = await NotificationScheduler.requestPermission();
                                if (granted) {
                                  await NotificationPreferencesService.setEnabled(true);
                                  await NotificationScheduler.scheduleDaily();
                                  if (mounted) {
                                    setState(() {
                                      _dailyEnabled = true;
                                      _notifPermissionDenied = false;
                                    });
                                  }
                                } else {
                                  await NotificationPreferencesService.setEnabled(false);
                                  if (mounted) {
                                    setState(() {
                                      _notifPermissionDenied = true;
                                    });
                                  }
                                }
                              } else {
                                await NotificationPreferencesService.setEnabled(false);
                                await NotificationScheduler.cancelAll();
                                if (mounted) {
                                  setState(() {
                                    _dailyEnabled = false;
                                    _notifPermissionDenied = false;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),

                      // Time picker row (visible when daily is ON)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        child: _dailyEnabled
                            ? Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 52),
                                    const Expanded(
                                      child: Text(
                                        'Remind me at',
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF8B7563),
                                        ),
                                      ),
                                    ),
                                    CupertinoButton(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      minSize: 0,
                                      onPressed: () {
                                        DateTime tempTime = DateTime(
                                          2024, 1, 1, _notifHour, _notifMinute,
                                        );
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (ctx) => Container(
                                            height: 280,
                                            color: const Color(0xFFF5ECE0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    CupertinoButton(
                                                      child: const Text(
                                                        'Done',
                                                        style: TextStyle(
                                                          fontFamily: 'Sora',
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xFF8B7563),
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        await NotificationPreferencesService.setHour(tempTime.hour);
                                                        await NotificationPreferencesService.setMinute(tempTime.minute);
                                                        final enabled = await NotificationPreferencesService.isEnabled();
                                                        if (enabled) {
                                                          await NotificationScheduler.rescheduleAll();
                                                        }
                                                        if (mounted) {
                                                          setState(() {
                                                            _notifHour = tempTime.hour;
                                                            _notifMinute = tempTime.minute;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: CupertinoDatePicker(
                                                    mode: CupertinoDatePickerMode.time,
                                                    initialDateTime: tempTime,
                                                    onDateTimeChanged: (dt) {
                                                      tempTime = dt;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEDE8E0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _formatTime(_notifHour, _notifMinute),
                                          style: const TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF3C342A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                          height: 1,
                          color: const Color(0xFF8B7563).withOpacity(0.1),
                        ),
                      ),

                      // Row 2: Weekly summary toggle
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4B782).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.calendar,
                              size: 18,
                              color: Color(0xFF9A8566),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weekly summary',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C342A),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Every Sunday evening',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9A8A78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _weeklyEnabled,
                            activeTrackColor: const Color(0xFF7A8B6F),
                            thumbColor: const Color(0xFFFFFFFF),
                            onChanged: (value) async {
                              await NotificationPreferencesService.setWeeklyEnabled(value);
                              await NotificationScheduler.rescheduleAll();
                              if (mounted) {
                                setState(() {
                                  _weeklyEnabled = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      // Permission denied message
                      if (_notifPermissionDenied)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'No worries — you can enable notifications in your device Settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF9B8A7A),
                              height: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SUPPORT label
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    'SUPPORT',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9A8A78),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Support Card (Multi-Item)
                Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3C342A).withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC5A395).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  CupertinoIcons.question_circle,
                                  size: 20,
                                  color: Color(0xFFA08876),
                                ),
                              ),
                              title: 'Help & Support',
                              onTap: _contactSupport,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: const Color(0xFF8B7563).withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B7563).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  CupertinoIcons.shield,
                                  size: 20,
                                  color: Color(0xFF8B7563),
                                ),
                              ),
                              title: 'Privacy Policy',
                              onTap: _openPrivacyPolicy,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: const Color(0xFF8B7563).withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9A8A78).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  CupertinoIcons.doc_text,
                                  size: 20,
                                  color: Color(0xFF9A8A78),
                                ),
                              ),
                              title: 'Terms of Service',
                              onTap: _openTermsOfService,
                            ),
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 16),

                // CONNECT ACCOUNT label (dimmed)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: Opacity(
                    opacity: 0.6,
                    child: const Text(
                      'CONNECT ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9A8A78),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Sign-In Card (Multi-Button)
                Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF).withOpacity(0.50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3C342A).withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Google Sign In Button
                          CupertinoButton(
                            padding: const EdgeInsets.all(16),
                            onPressed: () async {
                              try {
                                await AuthService.signInWithGoogle();
                              } catch (e) {
                                // handle error
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google "G" logo
                                SvgPicture.asset(
                                  'assets/images/google_logo.svg',
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C342A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: const Color(0xFF8B7563).withOpacity(0.1),
                          ),
                          // Apple Sign In Button
                          CupertinoButton(
                            padding: const EdgeInsets.all(16),
                            onPressed: () async {
                              try {
                                await AuthService.signInWithApple();
                              } catch (e) {
                                // handle error
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                // Apple logo
                                Text(
                                  '\uF8FF',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Color(0xFF3C342A),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Sign in with Apple',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3C342A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                ),

                const SizedBox(height: 40),

                // Footer Section
                Column(
                  children: [
                    // Sign Out Button
                    Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withOpacity(0.50),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFFFFFFF).withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3C342A).withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            onPressed: () async {
                              await AuthService.signOut();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  CupertinoIcons.arrow_right_square,
                                  size: 18,
                                  color: Color(0xFFA08876),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sign out',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFA08876),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    const SizedBox(height: 32),

                    // Delete Profile Data Link
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _deleteProfileData,
                      child: const Text(
                        'Delete profile data',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A8A78),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version Label
                    const Text(
                      'Intended v1.0.0',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA08876),
                      ),
                    ),
                  ],
                ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C342A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final Widget iconContainer;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.iconContainer,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          iconContainer,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3C342A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9A8A78),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: Color(0xFF8B7563),
          ),
        ],
      ),
    );
  }
}

// Focus Area Change Screen (preserved from original)
class _FocusAreaChangeScreen extends StatefulWidget {
  const _FocusAreaChangeScreen();

  @override
  State<_FocusAreaChangeScreen> createState() => _FocusAreaChangeScreenState();
}

class _FocusAreaChangeScreenState extends State<_FocusAreaChangeScreen> {
  final List<String> _selectedAreas = [];

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

  @override
  void initState() {
    super.initState();
    final onboardingState = context.read<OnboardingState>();
    _selectedAreas.addAll(onboardingState.focusAreas);
  }

  void _toggleArea(String area) {
    setState(() {
      if (_selectedAreas.contains(area)) {
        _selectedAreas.remove(area);
      } else {
        if (_selectedAreas.length < 2) {
          _selectedAreas.add(area);
        }
      }
    });
  }

  Future<void> _saveAreas() async {
    if (_selectedAreas.length < 1) return;

    final onboardingState = context.read<OnboardingState>();

    // Use the changeFocusAreas method which handles everything
    await onboardingState.changeFocusAreas(_selectedAreas);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF3F4EF),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.chevron_left,
                      color: Color(0xFF6B5B4A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Change Focus Areas',
                    style: AppTextStyles.h2(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Choose up to 2 areas',
                    style: AppTextStyles.body(context),
                  ),
                  const SizedBox(height: 24),
                  ...areas.map((area) {
                    final isSelected = _selectedAreas.contains(area);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _toggleArea(area),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF6B5B4A).withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF6B5B4A)
                                  : const Color(0xFFE8E3DB),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  area,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFF6B5B4A)
                                        : const Color(0xFF2F2E2A),
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: Color(0xFF6B5B4A),
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: _selectedAreas.isNotEmpty
                      ? const Color(0xFF6B5B4A)
                      : const Color(0xFFD8D2C8),
                  borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: _selectedAreas.isNotEmpty ? _saveAreas : null,
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: _selectedAreas.isNotEmpty
                          ? const Color(0xFFF6F5F1)
                          : const Color(0xFFB5A89A),
                      fontFamily: 'Sora',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
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
}
