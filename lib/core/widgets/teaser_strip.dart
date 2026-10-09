import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TeaserProfileItem {
  final String ageHeight;
  final String city;
  final String religionDivision;
  final String occupation;
  final String avatarInitials;

  const TeaserProfileItem({
    required this.ageHeight,
    required this.city,
    required this.religionDivision,
    required this.occupation,
    required this.avatarInitials,
  });
}

class TeaserStrip extends StatefulWidget {
  final int matchCount;
  final List<TeaserProfileItem> sampleProfiles;

  const TeaserStrip({
    super.key,
    required this.matchCount,
    this.sampleProfiles = const [],
  });

  @override
  State<TeaserStrip> createState() => _TeaserStripState();
}

class _TeaserStripState extends State<TeaserStrip> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isUserTouching = false;
  final NumberFormat _fmt = NumberFormat('#,##,###');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  void _startMarquee() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!_isUserTouching && _scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        if (currentScroll >= maxScroll - 2) {
          _scrollController.jumpTo(0.0);
        } else {
          _scrollController.jumpTo(currentScroll + 0.8);
        }
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sampleProfiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final list = widget.sampleProfiles;

    // Multiply list for endless marquee illusion
    final infiniteList = [...list, ...list, ...list, ...list];

    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.teaserGradient,
          border: Border(
            top: BorderSide(color: Color(0xFFD1FAE5), width: 1),
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Header Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      ),
                      child: Text(
                        '${_fmt.format(widget.matchCount)} Matches Waiting for You',
                        key: ValueKey<int>(widget.matchCount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Complete your registration and see more matches',
                style: AppTypography.caption(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            // Blurred mini-cards carousel
            Listener(
              onPointerDown: (_) => setState(() => _isUserTouching = true),
              onPointerUp: (_) => setState(() => _isUserTouching = false),
              onPointerCancel: (_) => setState(() => _isUserTouching = false),
              child: SizedBox(
                height: 72,
                child: ListView.separated(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: infiniteList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final item = infiniteList[idx];
                    return _buildMiniCard(item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(TeaserProfileItem item) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  item.avatarInitials,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Blurred details
              Expanded(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.ageHeight,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        '${item.city} • ${item.religionDivision}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                      ),
                      Text(
                        item.occupation,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Locked badge overlay
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.lock_rounded,
              size: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
