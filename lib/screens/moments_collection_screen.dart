import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/moment.dart';
import '../services/moments_service.dart';

class MomentsCollectionScreen extends StatefulWidget {
  const MomentsCollectionScreen({super.key});

  @override
  State<MomentsCollectionScreen> createState() =>
      _MomentsCollectionScreenState();
}

class _MomentsCollectionScreenState extends State<MomentsCollectionScreen> {
  Map<String, List<Moment>> _grouped = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grouped = await MomentsService.getGroupedByMonth();
    if (mounted) {
      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8DFD3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image — barely softened
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Image.asset(
                'assets/images/background_ms.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Warm gradient overlay — matches Habits screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    const Color(0xFFF2D4B0).withOpacity(0.15),
                    const Color(0xFFE8BFA0).withOpacity(0.38),
                    const Color(0xFFD4A888).withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          _loading
              ? const Center(child: CupertinoActivityIndicator())
              : _grouped.isEmpty
                  ? _buildEmptyState()
                  : _buildList(),

          // Bottom fade above tab bar
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
                      const Color(0xFFC4B0A0).withOpacity(0.0),
                      const Color(0xFFC4B0A0).withOpacity(0.85),
                      const Color(0xFFC4B0A0).withOpacity(0.95),
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

  Widget _buildList() {
    final months = _grouped.keys.toList();

    return CustomScrollView(
      slivers: [
        // Pinned Header
        SliverPersistentHeader(
          pinned: true,
          delegate: _MomentsHeaderDelegate(
            topPadding: MediaQuery.of(context).padding.top,
            onBack: () => Navigator.pop(context),
          ),
        ),

        // Month sections
        for (final month in months) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
              child: Text(
                month.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B7563),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final moment = _grouped[month]![index];
                return _MomentRow(moment: moment);
              },
              childCount: _grouped[month]!.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 140)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        // Back button row — matches _MomentsHeaderDelegate style
        Padding(
          padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 0),
          child: Row(
            children: [
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
                        ),
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
            ],
          ),
        ),
        // Centered empty state content
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✦',
                    style: TextStyle(
                      fontSize: 36,
                      color: const Color(0xFF8B7563).withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your moments will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B7563),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Every habit you complete becomes part of your collection — permanently.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFA89880),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MomentsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final VoidCallback onBack;

  _MomentsHeaderDelegate({required this.topPadding, required this.onBack});

  double get _headerHeight => topPadding + 16 + 56 + 8; // top padding + 16 gap + content + 8 bottom

  @override
  double get maxExtent => _headerHeight;

  @override
  double get minExtent => _headerHeight;

  @override
  bool shouldRebuild(covariant _MomentsHeaderDelegate oldDelegate) =>
      topPadding != oldDelegate.topPadding;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: shrinkOffset > 0 ? 20 : 0,
          sigmaY: shrinkOffset > 0 ? 20 : 0,
        ),
        child: Container(
          color: shrinkOffset > 0
              ? const Color(0xFFE8DFD3).withOpacity(0.85)
              : const Color(0x00000000),
          padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
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
                        ),
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your moments',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3C342A),
                      ),
                    ),
                    Text(
                      'Every habit you completed, kept forever.',
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MomentRow extends StatelessWidget {
  final Moment moment;

  const _MomentRow({required this.moment});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final momentDay = DateTime(
      moment.completedAt.year,
      moment.completedAt.month,
      moment.completedAt.day,
    );

    final String dateStr;
    if (momentDay == today) {
      dateStr = 'Today · ${DateFormat('h:mm a').format(moment.completedAt)}';
    } else if (momentDay == today.subtract(const Duration(days: 1))) {
      dateStr = 'Yesterday · ${DateFormat('h:mm a').format(moment.completedAt)}';
    } else {
      dateStr = DateFormat('MMM d · h:mm a').format(moment.completedAt);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.30),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Symbol
                Text(
                  moment.habitEmoji,
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF8B7563).withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 16),
                // Name + timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moment.habitName,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C342A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9A8A78),
                        ),
                      ),
                    ],
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