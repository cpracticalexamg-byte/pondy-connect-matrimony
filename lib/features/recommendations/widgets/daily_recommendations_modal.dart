import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/pondy_watermark.dart';
import '../../../domain/location/location_service.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/profile_model.dart';
import '../../../domain/recommendations/daily_recommendations_engine.dart';
import '../../matches/providers/matches_provider.dart';
import '../../profile/widgets/contact_paywall_sheet.dart';

class DailyRecommendationsModal extends ConsumerStatefulWidget {
  final List<MatchResult> recommendations;
  final VoidCallback? onDismiss;

  const DailyRecommendationsModal({
    super.key,
    required this.recommendations,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required List<MatchResult> recommendations,
    VoidCallback? onDismiss,
  }) {
    if (recommendations.isEmpty) return Future.value();
    return showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (_) => DailyRecommendationsModal(
        recommendations: recommendations,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  ConsumerState<DailyRecommendationsModal> createState() => _DailyRecommendationsModalState();
}

class _DailyRecommendationsModalState extends ConsumerState<DailyRecommendationsModal> {
  int _currentIndex = 0;
  bool _isCardExpanded = false;
  Offset _dragOffset = Offset.zero;

  MatchResult? get _currentMatch =>
      _currentIndex < widget.recommendations.length ? widget.recommendations[_currentIndex] : null;

  String _formatMatrimonyId(String profileId) {
    if (profileId.startsWith('PC')) return profileId;
    final clean = profileId.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length >= 6) {
      return 'PC${clean.substring(clean.length - 6)}';
    }
    return 'PC${clean.padLeft(6, '0')}';
  }

  String _formatHeight(int cm) {
    if (cm <= 0) return '5\'4"';
    final inches = (cm / 2.54).round();
    final ft = inches ~/ 12;
    final inch = inches % 12;
    return '$ft\'$inch"';
  }

  void _nextCard(String action) async {
    final current = _currentMatch;
    if (current != null) {
      final userProfileId = ref.read(matchesProvider).allMatches.isNotEmpty
          ? 'CURRENT_USER'
          : 'PC_USER';
      await DailyRecommendationsEngine.instance.recordRecommendationAction(
        userProfileId: userProfileId,
        targetProfileId: current.profile.profileId,
        action: action,
      );
    }

    setState(() {
      _dragOffset = Offset.zero;
      _isCardExpanded = false;
      _currentIndex++;
    });
  }

  void _handleSkip() {
    HapticFeedback.lightImpact();
    _nextCard('skipped');
  }

  void _handleSendInterest() async {
    HapticFeedback.mediumImpact();
    final current = _currentMatch;
    if (current != null) {
      await ref.read(matchesProvider.notifier).sendInterest(current.profile.profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Interest sent to ${current.profile.name}!'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    _nextCard('interest_sent');
  }

  void _handleDontShow() {
    final current = _currentMatch;
    if (current != null) {
      ref.read(matchesProvider.notifier).toggleShortlist(current.profile.profileId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${current.profile.name} will not be shown again'),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.amber,
              onPressed: () {},
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    _nextCard('dont_show');
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.recommendations.length;
    final isDone = _currentIndex >= total;

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(220),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Title "Daily Recommendation (1/N)" + ✕ Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isDone ? 'Daily Recommendations' : 'Daily Recommendation (${_currentIndex + 1}/$total)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDismiss?.call();
                    },
                  ),
                ],
              ),
            ),

            // Card Stack Body
            Expanded(
              child: isDone ? _buildEndState() : _buildCardStack(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStack() {
    final current = _currentMatch!;
    final profile = current.profile;
    final matrimonyId = _formatMatrimonyId(profile.profileId);
    final isShortlisted = ref.watch(matchesProvider).shortlistedIds.contains(profile.profileId);

    // Compute distance
    final distStr = LocationService.instance.getFormattedDistance(
      profile.profileId,
      targetDistrict: profile.district,
      targetCity: profile.city,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          // Main Swipeable Card
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _dragOffset += details.delta;
                });
              },
              onPanEnd: (details) {
                if (_dragOffset.dx > 100) {
                  _handleSendInterest();
                } else if (_dragOffset.dx < -100) {
                  _handleSkip();
                } else {
                  setState(() => _dragOffset = Offset.zero);
                }
              },
              child: Transform.translate(
                offset: _dragOffset,
                child: Transform.rotate(
                  angle: _dragOffset.dx * 0.0008,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // Large Photo (4:5 or height 320) with Pondy Watermark and Edge-Blur Fill
                        Stack(
                          children: [
                            SizedBox(
                              height: 320,
                              width: double.infinity,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Photo or blurred background
                                  if (profile.primaryPhoto != null && profile.primaryPhoto!.isNotEmpty)
                                    ImageFiltered(
                                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Image.network(profile.primaryPhoto!, fit: BoxFit.cover),
                                    ),
                                  // Foreground photo
                                  PondyWatermark(
                                    opacity: 0.15,
                                    fontSize: 18,
                                    child: profile.primaryPhoto != null && profile.primaryPhoto!.isNotEmpty
                                        ? Image.network(
                                            profile.primaryPhoto!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(profile),
                                          )
                                        : _buildPlaceholderPhoto(profile),
                                  ),
                                  // Scrim
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 80,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Colors.transparent, Colors.black.withAlpha(200)],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom ID & Match Score
                                  Positioned(
                                    left: 14,
                                    bottom: 10,
                                    right: 14,
                                    child: Row(
                                      children: [
                                        Text(
                                          matrimonyId,
                                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.saffronOrange,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${current.score}% Match',
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Shortlist Bookmark Pill (Top Right)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: ActionChip(
                                avatar: Icon(
                                  isShortlisted ? Icons.bookmark : Icons.bookmark_border,
                                  color: isShortlisted ? Colors.amber : Colors.white,
                                  size: 16,
                                ),
                                label: Text(isShortlisted ? 'Shortlisted' : 'Shortlist'),
                                labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                backgroundColor: Colors.black.withAlpha(120),
                                side: BorderSide.none,
                                onPressed: () {
                                  ref.read(matchesProvider.notifier).toggleShortlist(profile.profileId);
                                },
                              ),
                            ),
                          ],
                        ),

                        // Profile Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + Call and WhatsApp Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile.name,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Call icon button (orange outline)
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: AppColors.saffronOrange, width: 1.5),
                                      minimumSize: const Size(38, 38),
                                    ),
                                    onPressed: () {
                                      ContactPaywallSheet.show(context, targetProfile: profile);
                                    },
                                    child: const Icon(Icons.phone_outlined, size: 18, color: AppColors.saffronOrange),
                                  ),
                                  const SizedBox(width: 8),
                                  // WhatsApp icon button (green outline)
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      shape: const CircleBorder(),
                                      side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                                      minimumSize: const Size(38, 38),
                                    ),
                                    onPressed: () {
                                      ContactPaywallSheet.show(context, targetProfile: profile);
                                    },
                                    child: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF25D366)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Last seen bucket & marital status
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.successGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Active today • ${profile.maritalStatus.replaceAll('_', ' ')}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Info Line: Age, Height, Religion, Caste
                              Text(
                                '${profile.age} yrs • ${_formatHeight(profile.heightCm)} • ${profile.religion} • ${profile.caste.replaceAll('caste_', '').replaceAll('_', ' ')}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),

                              // Education & Occupation
                              Text(
                                '${profile.occupation} • ${profile.education}',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 4),

                              // Location + Distance Chip
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${profile.city}, ${profile.district}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ),
                                  if (distStr != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.near_me, size: 10, color: Colors.blue.shade700),
                                          const SizedBox(width: 3),
                                          Text(
                                            distStr,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Expandable detail trigger chip
                              const SizedBox(height: 12),
                              Center(
                                child: ActionChip(
                                  avatar: Icon(
                                    _isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    size: 16,
                                  ),
                                  label: Text(_isCardExpanded ? 'Show Less' : 'View Full Details'),
                                  onPressed: () => setState(() => _isCardExpanded = !_isCardExpanded),
                                ),
                              ),

                              // In-card full details if expanded
                              if (_isCardExpanded) ...[
                                const Divider(height: 24),
                                if (profile.aboutMe.isNotEmpty) ...[
                                  const Text('About Me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(profile.aboutMe, style: const TextStyle(fontSize: 12, height: 1.4)),
                                  const SizedBox(height: 12),
                                ],
                                const Text('Family Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  'Family Status: ${profile.familyStatus.replaceAll('_', ' ')} • Family Values: ${profile.familyValues}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 12),
                                const Text('Horoscope & Star', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  'Star: ${profile.star} • Raasi: ${profile.rasi}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Fixed Action Bar (§2): Don't Show · Skip · Send Interest
          Row(
            children: [
              // Don't Show (outlined grey)
              OutlinedButton.icon(
                icon: const Icon(Icons.visibility_off_outlined, size: 16),
                label: const Text("Don't Show"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade400,
                  side: BorderSide(color: Colors.grey.shade600),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _handleDontShow,
              ),
              const SizedBox(width: 10),

              // Skip (outlined orange)
              OutlinedButton.icon(
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Skip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.saffronOrange,
                  side: const BorderSide(color: AppColors.saffronOrange),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _handleSkip,
              ),
              const SizedBox(width: 10),

              // Send Interest (filled orange with heart icon)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text('Send Interest', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.saffronOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _handleSendInterest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, size: 64, color: AppColors.successGreen),
            ),
            const SizedBox(height: 20),
            const Text(
              "You're all caught up!",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'New hand-picked daily recommendations will arrive tomorrow.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDismiss?.call();
              },
              child: const Text('View All Matches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto(ProfileModel profile) {
    return Container(
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              profile.gender.toLowerCase() == 'male' ? Icons.face : Icons.face_3,
              size: 72,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 8),
            Text(
              profile.name,
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
