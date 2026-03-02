import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/share_card_type.dart';
import '../services/milestone_service.dart';
import '../services/week_stats_service.dart';
import '../state/user_state.dart';
import '../theme/theme_provider.dart';
import 'share_card_screen.dart';
import '../widgets/boost_offer_sheet.dart';

class ShareCardPickerScreen extends StatefulWidget {
  final WeekStats stats;

  const ShareCardPickerScreen({super.key, required this.stats});

  @override
  State<ShareCardPickerScreen> createState() => _ShareCardPickerScreenState();
}

class _ShareCardPickerScreenState extends State<ShareCardPickerScreen> {
  MilestoneData _milestoneData = const MilestoneData(weekCount: 1);
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadMilestoneData();
  }

  Future<void> _loadMilestoneData() async {
    final data = await MilestoneService.get();
    if (mounted) {
      setState(() {
        _milestoneData = data;
        _loaded = true;
      });
    }
  }

  void _showUpsell() {
    final l10n = AppLocalizations.of(context);
    final userState = context.read<UserState>();
    showBoostOfferSheet(
      context: context,
      title: l10n.boostOfferShareTitle,
      description: l10n.boostOfferShareDesc,
      showBoostOption: !userState.hasBoost,
      source: 'share_milestone',
    );
  }

  void _navigateToCard(ShareCardSelection selection) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ShareCardScreen(
          stats: widget.stats,
          selection: selection,
          milestoneData: _milestoneData,
        ),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final userState = context.watch<UserState>();
    final isPremium = userState.hasSubscription || userState.hasBoost;

    final options = _buildOptions(l10n);

    return CupertinoPageScaffold(
      backgroundColor: colors.modalBg2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image — same as Moments screen
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                colors.backgroundMs,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Warm gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    colors.bgGradientTop.withOpacity(colors.bgGradientTopOpacity),
                    colors.bgGradientMid.withOpacity(colors.bgGradientMidOpacity),
                    colors.bgGradientBottom.withOpacity(colors.bgGradientBottomOpacity),
                  ],
                ),
              ),
            ),
          ),

          // Subtle dark overlay for card contrast
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withOpacity(0.08),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar — close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 22,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    l10n.sharePickerTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Option tiles
                ...options.map((o) => _buildOptionTile(o, colors, isPremium)),

                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_CardOption> _buildOptions(AppLocalizations l10n) {
    final options = <_CardOption>[
      _CardOption(
        selection: ShareCardSelection.weeklyCheckin,
        label: l10n.shareCardWeeklyCheckin,
        subtitle: l10n.shareWeeklySubtitle,
        premiumOnly: false,
      ),
    ];

    if (_loaded) {
      options.add(_CardOption(
        selection: ShareCardSelection.milestoneShowingUp,
        label: l10n.milestoneShowingUpLabel,
        subtitle: l10n.shareShowingUpSubtitle,
        premiumOnly: true,
      ));
      if (_milestoneData.topArea != null) {
        options.add(_CardOption(
          selection: ShareCardSelection.milestoneArea,
          label: l10n.milestoneAreaLabel,
          subtitle: l10n.shareFocusAreaSubtitle,
          premiumOnly: true,
        ));
      }
      if (_milestoneData.topHabitName != null) {
        options.add(_CardOption(
          selection: ShareCardSelection.milestoneIdentity,
          label: l10n.milestoneIdentityLabel,
          subtitle: l10n.shareYourThingSubtitle,
          premiumOnly: true,
        ));
      }
    }

    return options;
  }

  Widget _buildOptionTile(_CardOption option, dynamic colors, bool isPremium) {
    final isLocked = option.premiumOnly && !isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: GestureDetector(
        onTap: () {
          if (isLocked) {
            _showUpsell();
            return;
          }
          _navigateToCard(option.selection);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(isLocked ? 0.20 : 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CupertinoColors.white.withOpacity(isLocked ? 0.30 : 0.50),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? colors.textPrimary.withOpacity(0.55)
                                : colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isLocked
                                ? colors.textPrimary.withOpacity(0.38)
                                : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    option.premiumOnly
                        ? (isLocked
                            ? CupertinoIcons.lock
                            : CupertinoIcons.lock_open)
                        : CupertinoIcons.chevron_right,
                    size: isLocked ? 20 : 16,
                    color: isLocked
                        ? colors.textPrimary.withOpacity(0.5)
                        : colors.textSecondary.withOpacity(0.5),
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

class _CardOption {
  final ShareCardSelection selection;
  final String label;
  final String subtitle;
  final bool premiumOnly;

  const _CardOption({
    required this.selection,
    required this.label,
    required this.subtitle,
    required this.premiumOnly,
  });
}
