import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import '../l10n/app_localizations.dart';
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
import '../theme/theme_provider.dart';
import 'paywall_screen.dart';
import 'subscription_management_modal.dart';
import '../widgets/theme_picker.dart';
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

  String _localizedAreaName(AppLocalizations l10n, String area) {
    switch (area) {
      case 'Health': return l10n.focusAreaHealth;
      case 'Mood': return l10n.focusAreaMood;
      case 'Productivity': return l10n.focusAreaProductivity;
      case 'Home & organization': return l10n.focusAreaHome;
      case 'Relationships': return l10n.focusAreaRelationships;
      case 'Creativity': return l10n.focusAreaCreativity;
      case 'Finances': return l10n.focusAreaFinances;
      case 'Self-care': return l10n.focusAreaSelfCare;
      default: return area;
    }
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
      final l10n = AppLocalizations.of(context);
      showIntendedDialog(
        context: context,
        title: l10n.profileNameError,
        subtitle: l10n.profileNameErrorMessage,
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.commonOk),
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
      path: 'support@intendedapp.com',
      query: 'subject=Intended App — Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
        showIntendedModal(
          context: context,
          title: l10n.profileCannotOpenEmail,
          subtitle: l10n.profileEmailFallback,
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withOpacity(0.2),
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
                          colors.ctaPrimary.withOpacity(0.85),
                          colors.ctaSecondary.withOpacity(0.75),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.ctaPrimary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.commonOk,
                        style: const TextStyle(
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
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        color: colors.barrierColor.withOpacity(colors.barrierOpacity),
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
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.4),
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
                          l10n.profileChangeFocusTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          l10n.profileChangeFocusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
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
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.ctaPrimary.withOpacity(0.92),
                                      colors.ctaSecondary.withOpacity(0.88),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colors.ctaPrimary.withOpacity(0.4),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.textPrimary.withOpacity(0.3),
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
                                  child: Text(
                                    l10n.profileChangeAreas,
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

                        // Cancel button (ghost)
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            onPressed: () => Navigator.pop(context),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              l10n.commonCancel,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
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
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Container(
        color: colors.barrierColor.withOpacity(colors.barrierOpacity),
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
                      gradient: LinearGradient(
                        begin: const Alignment(0.0, 2.41),
                        end: const Alignment(0.0, -2.41),
                        colors: [
                          colors.modalBg1.withOpacity(0.96),
                          colors.modalBg2.withOpacity(0.93),
                          colors.modalBg3.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF).withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.modalShadow.withOpacity(0.4),
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
                          l10n.profileChangeFocusTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          l10n.profileFocusLimitMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Options
                        Text(
                          l10n.profileFocusLimitOptions,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: colors.ctaPrimary,
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
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colors.ctaPrimary.withOpacity(0.92),
                                      colors.ctaSecondary.withOpacity(0.88),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colors.ctaPrimary.withOpacity(0.4),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.textPrimary.withOpacity(0.3),
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
                                  child: Text(
                                    l10n.profilePayAmount,
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
                                      color: colors.textPrimary.withOpacity(0.05),
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
                                  child: Text(
                                    l10n.appUnlockPlus,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: colors.ctaPrimary,
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
                            child: Text(
                              l10n.commonCancel,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textTertiary,
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
    final l10n = AppLocalizations.of(context);
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profilePaymentTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profilePaymentMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: l10n.commonOk,
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

  void _showAppearancePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userState = Provider.of<UserState>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final colors = themeProvider.colors;
          return Container(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.modalBg1.withOpacity(0.98),
                        colors.modalBg2.withOpacity(0.96),
                        colors.modalBg3.withOpacity(0.98),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Title
                          Text(
                            l10n.profileChangeSpace,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Theme picker
                          ThemePicker(
                            isPremium: userState.hasSubscription,
                            compact: true,
                            onPremiumTap: () {
                              Navigator.pop(context);
                              _showUpgradeScreen();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
    final l10n = AppLocalizations.of(context);
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileRefreshTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileRefreshMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: l10n.commonRefresh,
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
            label: l10n.commonCancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showRefreshSuccess() {
    final l10n = AppLocalizations.of(context);
    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileRefreshSuccessTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileRefreshSuccessMessage,
            style: AppTextStyles.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          styledPrimaryButton(
            label: l10n.commonGreat,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshHabits() async {
    final onboardingState = context.read<OnboardingState>();

    if (!onboardingState.canRefreshHabits()) {
      final l10n = AppLocalizations.of(context);
      showIntendedDialog(
        context: context,
        title: l10n.profileDailyLimitTitle,
        subtitle: l10n.profileDailyLimitMessage,
        actions: [
          CupertinoDialogAction(
            child: Text(l10n.commonOk),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
      return;
    }

    _showRefreshConfirmation();
  }

  void _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://intendedapp.com/privacy');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedDialog(
          context: context,
          title: l10n.profileCannotOpenLink,
          subtitle: l10n.profilePrivacyFallback,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      }
    }
  }

  void _openTermsOfService() async {
    final Uri url = Uri.parse('https://intendedapp.com/terms');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showIntendedDialog(
          context: context,
          title: l10n.profileCannotOpenLink,
          subtitle: l10n.profileTermsFallback,
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonOk),
            ),
          ],
        );
      }
    }
  }

  void _deleteProfileData() {
    final colors = Provider.of<ThemeProvider>(context, listen: false).colors;
    final l10n = AppLocalizations.of(context);

    showStyledPopup(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.profileDeleteAllTitle,
            style: AppTextStyles.h2(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.profileDeleteAllMessage,
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
                  colors.destructive.withOpacity(0.92),
                  colors.destructiveDark.withOpacity(0.88),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.destructiveDark.withOpacity(0.3),
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
              child: Text(
                l10n.commonDelete,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          styledSecondaryButton(
            label: l10n.commonCancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onboardingState = context.watch<OnboardingState>();
    final hasHabits = onboardingState.userHabits.isNotEmpty;
    final focusAreas = onboardingState.focusAreas;
    final colors = context.watch<ThemeProvider>().colors;

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
                  child: Text(
                    l10n.profileTitle,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
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
                      Text(
                        l10n.profileYourName,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (!_isEditing) ...[
                        ValueListenableBuilder<String?>(
                          valueListenable: userNameNotifier,
                          builder: (context, name, _) {
                            final displayName =
                                (name != null && name.isNotEmpty) ? name : l10n.profileAddName;
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
                                          hasName ? colors.textPrimary : colors.textDisabled,
                                    ),
                                  ),
                                ),
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: _startEditing,
                                  child: Icon(
                                    CupertinoIcons.pencil,
                                    size: 20,
                                    color: colors.ctaPrimary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        CupertinoTextField(
                          controller: controller,
                          placeholder: l10n.profileEnterName,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                          placeholderStyle: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 17,
                            color: colors.textDisabled,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceLightest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.borderWarm,
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
                                    ? colors.buttonDark
                                    : colors.borderMedium,
                                borderRadius: BorderRadius.circular(12),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                onPressed: canSave ? _saveName : null,
                                child: Text(
                                  l10n.commonSave,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: canSave
                                        ? colors.surfaceLightest
                                        : colors.textDisabled,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              onPressed: _cancelEditing,
                              child: Text(
                                l10n.commonCancel,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: colors.ctaPrimary,
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
                        color: colors.ctaPrimary.withOpacity(0.1),
                      ),
                      const SizedBox(height: 24),

                      // Section 2: Plan
                      Text(
                        l10n.profilePlan,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Consumer<UserState>(
                              builder: (context, userState, child) {
                                return Text(
                                  userState.hasSubscription ? l10n.appNameIntendedPlus : l10n.appPlanCore,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
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
                                  child: Text(
                                    l10n.profileManage,
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.ctaPrimary,
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
                                      color: colors.accentRegular.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: colors.accentRegular.withOpacity(0.6),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      l10n.profileUnlockPlus,
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colors.ctaPrimary,
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
                          color: colors.ctaPrimary.withOpacity(0.1),
                        ),
                        const SizedBox(height: 24),

                        // Section 3: Focus Areas
                        Text(
                          l10n.profileFocusAreas,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                focusAreas.map((a) => _localizedAreaName(l10n, a)).join(', '),
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _changeFocusAreas,
                              child: Icon(
                                CupertinoIcons.pencil,
                                size: 20,
                                color: colors.ctaPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Divider
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        color: colors.ctaPrimary.withOpacity(0.1),
                      ),
                      const SizedBox(height: 24),

                      // Section: Your Moments
                      Text(
                        l10n.profileYourMoments,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      FutureBuilder<int>(
                        future: MomentsService.getCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          final label = count == 0
                              ? l10n.profileMomentsNone
                              : l10n.profileMomentsCount(count);
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
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
                                child: Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 20,
                                  color: colors.ctaPrimary,
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4),
                  child: Text(
                    l10n.profileSettings,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
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
                              color: colors.ctaPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              CupertinoIcons.bell,
                              size: 18,
                              color: colors.textMutedBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.profileDailyReminders,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _dailyEnabled,
                            activeTrackColor: colors.success,
                            thumbColor: const Color(0xFFFFFFFF),
                            onChanged: (value) async {
                              if (value) {
                                final granted = await NotificationScheduler.requestPermission();
                                if (granted) {
                                  await NotificationPreferencesService.setEnabled(true);
                                  final l10n = AppLocalizations.of(context);
                                  await NotificationScheduler.scheduleDaily(l10n);
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
                                    Expanded(
                                      child: Text(
                                        l10n.profileRemindAt,
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: colors.ctaPrimary,
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
                                            color: colors.modalBg1,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    CupertinoButton(
                                                      child: Text(
                                                        l10n.commonDone,
                                                        style: TextStyle(
                                                          fontFamily: 'Sora',
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                          color: colors.ctaPrimary,
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        await NotificationPreferencesService.setHour(tempTime.hour);
                                                        await NotificationPreferencesService.setMinute(tempTime.minute);
                                                        final enabled = await NotificationPreferencesService.isEnabled();
                                                        if (enabled) {
                                                          final l10n = AppLocalizations.of(context);
                                                          await NotificationScheduler.rescheduleAll(l10n);
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
                                          color: colors.borderWarm,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _formatTime(_notifHour, _notifMinute),
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary,
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
                          color: colors.ctaPrimary.withOpacity(0.1),
                        ),
                      ),

                      // Row 2: Weekly summary toggle
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.ctaPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              CupertinoIcons.calendar,
                              size: 18,
                              color: colors.textMutedBrown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.profileWeeklySummary,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.profileWeeklySubtitle,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _weeklyEnabled,
                            activeTrackColor: colors.success,
                            thumbColor: const Color(0xFFFFFFFF),
                            onChanged: (value) async {
                              await NotificationPreferencesService.setWeeklyEnabled(value);
                              final l10n = AppLocalizations.of(context);
                              await NotificationScheduler.rescheduleAll(l10n);
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            l10n.profileNotifDenied,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: colors.textTertiary,
                              height: 1.5,
                            ),
                          ),
                        ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Container(
                          height: 1,
                          color: colors.ctaPrimary.withOpacity(0.1),
                        ),
                      ),

                      // Row 3: Appearance
                      GestureDetector(
                        onTap: () => _showAppearancePicker(context),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.ctaPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CupertinoIcons.paintbrush,
                                size: 18,
                                color: colors.textMutedBrown,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.profileAppearance,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              CupertinoIcons.chevron_right,
                              size: 16,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SUPPORT label
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Text(
                    l10n.profileSupport,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Support Card (Multi-Item)
                Container(
                      decoration: BoxDecoration(
                        color: colors.profileCard.withOpacity(colors.profileCardOpacity),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.04),
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
                                  color: colors.accentRegular.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.question_circle,
                                  size: 20,
                                  color: colors.textMutedBrown,
                                ),
                              ),
                              title: l10n.profileHelpSupport,
                              onTap: _contactSupport,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.ctaPrimary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.shield,
                                  size: 20,
                                  color: colors.ctaPrimary,
                                ),
                              ),
                              title: l10n.profilePrivacy,
                              onTap: _openPrivacyPolicy,
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: _ProfileButton(
                              iconContainer: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.textSecondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  CupertinoIcons.doc_text,
                                  size: 20,
                                  color: colors.textSecondary,
                                ),
                              ),
                              title: l10n.profileTerms,
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
                    child: Text(
                      l10n.profileConnectAccount,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),

                // Sign-In Card (Multi-Button)
                Container(
                      decoration: BoxDecoration(
                        color: colors.profileCard.withOpacity(colors.profileCardOpacity),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withOpacity(0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withOpacity(0.04),
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
                                Text(
                                  l10n.profileSignInGoogle,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: colors.ctaPrimary.withOpacity(0.1),
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
                              children: [
                                // Apple logo
                                Text(
                                  '\uF8FF',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.profileSignInApple,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textPrimary,
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
                            color: colors.profileCard.withOpacity(colors.profileCardOpacity),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFFFFFFF).withOpacity(0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.textPrimary.withOpacity(0.04),
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
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_right_square,
                                  size: 18,
                                  color: colors.textMutedBrown,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.profileSignOut,
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: colors.textMutedBrown,
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
                      child: Text(
                        l10n.profileDeleteData,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version Label
                    Text(
                      l10n.profileVersion,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textMutedBrown,
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
    final colors = context.watch<ThemeProvider>().colors;

    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.profileCard.withOpacity(colors.profileCardOpacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withOpacity(0.04),
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
    final colors = context.watch<ThemeProvider>().colors;

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
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: colors.ctaPrimary,
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

  Map<String, String> _localizedAreaNames(AppLocalizations l10n) => {
    'Health': l10n.focusAreaHealth,
    'Mood': l10n.focusAreaMood,
    'Productivity': l10n.focusAreaProductivity,
    'Home & organization': l10n.focusAreaHome,
    'Relationships': l10n.focusAreaRelationships,
    'Creativity': l10n.focusAreaCreativity,
    'Finances': l10n.focusAreaFinances,
    'Self-care': l10n.focusAreaSelfCare,
  };

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
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final areaNames = _localizedAreaNames(l10n);

    return CupertinoPageScaffold(
      backgroundColor: colors.surfaceLightest,
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
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      color: colors.buttonDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.profileChangeFocusAreasScreenTitle,
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
                    l10n.profileChooseUpTo2,
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
                                ? colors.buttonDark.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors.buttonDark
                                  : colors.borderWarm,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  areaNames[area] ?? area,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? colors.buttonDark
                                        : colors.textPrimary,
                                    fontFamily: 'Sora',
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  CupertinoIcons.checkmark_circle_fill,
                                  color: colors.buttonDark,
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
                      ? colors.buttonDark
                      : colors.borderMedium,
                  borderRadius: BorderRadius.circular(ComponentSizes.buttonRadius),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  onPressed: _selectedAreas.isNotEmpty ? _saveAreas : null,
                  child: Text(
                    l10n.profileSaveChanges,
                    style: TextStyle(
                      color: _selectedAreas.isNotEmpty
                          ? colors.surfaceLightest
                          : colors.textDisabled,
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
