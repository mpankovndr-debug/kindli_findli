import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/milestone_tracker.dart';
import '../utils/milestone_icons.dart';

/// Full-screen Milestone History showing all 12 milestones
class MilestoneHistoryScreen extends StatelessWidget {
  const MilestoneHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8DFD3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_ms.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFD7C8B4).withOpacity(0.60),
                    const Color(0xFFC8B9A5).withOpacity(0.70),
                  ],
                ),
              ),
            ),
          ),

          // Content layer (z-10)
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 128),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        // Back button - glassmorphic circle
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFFFFF).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3C342A).withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.chevron_back,
                                  size: 20,
                                  color: Color(0xFF6B5D52),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        const Text(
                          'Milestones',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C342A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "Your Journey" section
                  const SizedBox(height: 8),
                  _buildSection(
                    context: context,
                    label: 'YOUR JOURNEY',
                    category: MilestoneCategory.journey,
                  ),

                  // "Your Habits" section
                  const SizedBox(height: 24),
                  _buildSection(
                    context: context,
                    label: 'YOUR HABITS',
                    category: MilestoneCategory.habits,
                  ),
                ],
              ),
            ),
          ),

          // Bottom gradient (fades content above nav bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFE8DFD3).withOpacity(0.0),
                      const Color(0xFFE8DFD3).withOpacity(0.92),
                      const Color(0xFFE8DFD3).withOpacity(0.98),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String label,
    required MilestoneCategory category,
  }) {
    final milestones = MilestoneTracker.getMilestonesByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B7563),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),

        // 3-column grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            return _MilestoneCard(milestone: milestones[index]);
          },
        ),
      ],
    );
  }
}

/// Individual milestone card (earned or locked)
class _MilestoneCard extends StatefulWidget {
  final Milestone milestone;

  const _MilestoneCard({required this.milestone});

  @override
  State<_MilestoneCard> createState() => _MilestoneCardState();
}

class _MilestoneCardState extends State<_MilestoneCard> {
  bool _isEarned = false;
  DateTime? _earnedDate;

  @override
  void initState() {
    super.initState();
    _checkMilestone();
  }

  Future<void> _checkMilestone() async {
    final earned = await MilestoneTracker.hasAchieved(widget.milestone);
    final date = await MilestoneTracker.getAchievementDate(widget.milestone);

    if (mounted) {
      setState(() {
        _isEarned = earned;
        _earnedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = MilestoneTracker.info[widget.milestone]!;
    final dateStr = _earnedDate != null ? DateFormat('MMM d').format(_earnedDate!) : null;

    final double blurAmount = _isEarned ? 25 : 15;
    final double bgOpacity = _isEarned ? 0.38 : 0.12;
    final double borderOpacity = _isEarned ? 0.35 : 0.15;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, bgOpacity),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.fromRGBO(255, 255, 255, borderOpacity),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(60, 52, 42, _isEarned ? 0.05 : 0.03),
                blurRadius: _isEarned ? 20 : 10,
                offset: Offset(0, _isEarned ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon — 48x48, 40% opacity when locked
              Opacity(
                opacity: _isEarned ? 1.0 : 0.4,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: getMilestoneIconPainter(widget.milestone, _isEarned),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                info.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isEarned
                      ? const Color(0xFF3C342A)
                      : const Color(0xFFC4B8A8),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),

              // Date or "Keep going..."
              Text(
                _isEarned && dateStr != null ? dateStr : 'Keep going...',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: _isEarned
                      ? const Color(0xFF9A8A78)
                      : const Color(0xFFC4B8A8),
                  fontStyle: _isEarned ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
