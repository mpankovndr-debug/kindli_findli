import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/share_card_type.dart';
import '../services/app_usage_service.dart';
import '../services/share_service.dart';
import '../services/week_stats_service.dart';
import '../state/user_state.dart';
import '../theme/theme_provider.dart';
import '../widgets/intention_share_card.dart';
import '../widgets/milestone_share_card.dart';

class ShareCardScreen extends StatefulWidget {
  final WeekStats stats;

  const ShareCardScreen({super.key, required this.stats});

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  ShareCardType _selectedType = ShareCardType.intention;
  int _weekCount = 1;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadWeekCount();
  }

  Future<void> _loadWeekCount() async {
    final count = await AppUsageService.getWeekCount();
    if (mounted) {
      setState(() => _weekCount = count);
    }
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final size = MediaQuery.of(context).size;
      await ShareService.shareCard(
        _repaintKey,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeProvider>().colors;
    final l10n = AppLocalizations.of(context);
    final isPremium = context.watch<UserState>().hasSubscription;

    return CupertinoPageScaffold(
      backgroundColor: Colors.transparent,
      child: AppBackground(
        child: ColoredBox(
          color: Colors.black.withOpacity(0.18),
          child: SafeArea(
          child: Column(
            children: [
              // Top bar — close button only
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

              // Card type selector (premium only)
              if (isPremium) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildSegmentedControl(colors, l10n),
                ),
              ],

              // Hidden full-size card for capture
              ClipRect(
                child: SizedBox(
                  width: 0,
                  height: 0,
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    maxWidth: 1080,
                    maxHeight: 1920,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: _buildCaptureCard(),
                    ),
                  ),
                ),
              ),

              // Card preview
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    child: _buildCardPreview(),
                  ),
                ),
              ),

              // Share button — solid warm brown
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C4A3A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(20),
                    onPressed: _isSharing ? null : _share,
                    child: _isSharing
                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                CupertinoIcons.share,
                                size: 18,
                                color: CupertinoColors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Share',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildSegmentedControl(dynamic colors, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: colors.profileCard.withOpacity(colors.profileCardOpacity * 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.cardBrowse.withOpacity(colors.cardBrowseOpacity * 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildSegmentTab(
                label: l10n.shareCardWeeklyCheckin,
                isSelected: _selectedType == ShareCardType.intention,
                onTap: () => setState(() => _selectedType = ShareCardType.intention),
                colors: colors,
              ),
              _buildSegmentTab(
                label: l10n.shareCardMilestone,
                isSelected: _selectedType == ShareCardType.milestone,
                onTap: () => setState(() => _selectedType = ShareCardType.milestone),
                colors: colors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic colors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.profileCard.withOpacity(colors.profileCardOpacity)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.textPrimary.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? colors.textPrimary : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureCard() {
    final l10n = AppLocalizations.of(context);
    return _selectedType == ShareCardType.intention
        ? IntentionShareCard(
            completionCount: widget.stats.completionCount,
            showedUpText: l10n.shareCardShowedUp,
            timesText: l10n.shareCardTimes,
            thisWeekText: l10n.shareCardThisWeek,
            taglineText: l10n.shareCardTagline,
          )
        : MilestoneShareCard(
            weekCount: _weekCount,
            weeksText: l10n.shareCardWeeks,
            subtitleText: l10n.shareCardMilestoneSubtext,
            taglineText: l10n.shareCardMilestoneTagline,
          );
  }

  Widget _buildCardPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const cardAspect = 1080 / 1920;
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final previewAspect = maxWidth / maxHeight;

        double previewWidth;
        double previewHeight;

        if (previewAspect > cardAspect) {
          previewHeight = maxHeight;
          previewWidth = previewHeight * cardAspect;
        } else {
          previewWidth = maxWidth;
          previewHeight = previewWidth / cardAspect;
        }

        return Container(
          width: previewWidth,
          height: previewHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: FittedBox(
              fit: BoxFit.contain,
              child: _buildCaptureCard(),
            ),
          ),
        );
      },
    );
  }
}
