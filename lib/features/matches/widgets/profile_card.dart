import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pondy_watermark.dart';
import '../../../domain/location/location_service.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/profile_model.dart';
import '../../profile/widgets/contact_paywall_sheet.dart';

class ProfileCard extends StatelessWidget {
  final MatchResult match;
  final bool isShortlisted;
  final bool isInterestSent;
  final VoidCallback? onTap;
  final VoidCallback? onShortlistToggle;
  final VoidCallback? onSendInterest;
  final VoidCallback? onChat;

  const ProfileCard({
    super.key,
    required this.match,
    this.isShortlisted = false,
    this.isInterestSent = false,
    this.onTap,
    this.onShortlistToggle,
    this.onSendInterest,
    this.onChat,
  });

  bool get _isNewlyJoined {
    final profile = match.profile;
    if (profile.isDemo) return true;
    final created = DateTime.tryParse(profile.createdAt);
    if (created == null) return false;
    return DateTime.now().difference(created).inDays <= 30;
  }

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

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return AppColors.saffronOrange;
    return Colors.amber.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final profile = match.profile;
    final matrimonyId = _formatMatrimonyId(profile.profileId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      shadowColor: Colors.black.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.cardBorder.withAlpha(120),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Header with Watermark & Newly Joined Ribbon
            Stack(
              children: [
                // Photo container (4:5 or banner aspect ratio)
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo wrapped with PondyWatermark
                      PondyWatermark(
                        opacity: 0.15,
                        fontSize: 16,
                        child: _buildCardPhoto(profile),
                      ),

                      // Bottom gradient scrim for readability
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withAlpha(180),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Bottom info on photo
                      Positioned(
                        left: 12,
                        bottom: 8,
                        right: 12,
                        child: Row(
                          children: [
                            Text(
                              matrimonyId,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            // Match percentage badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _scoreColor(match.score).withAlpha(180),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withAlpha(100)),
                              ),
                              child: Text(
                                '${match.score}% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Newly Joined Ribbon (Top Left)
                if (_isNewlyJoined)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.saffronOrange,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_new, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Newly joined',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Sample Profile Badge (§9)
                if (profile.isSample)
                  Positioned(
                    top: _isNewlyJoined ? 44 : 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade800.withAlpha(220),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Sample profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Shortlist Heart Button (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.black.withAlpha(100),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: Icon(
                        isShortlisted ? Icons.favorite : Icons.favorite_border,
                        color: isShortlisted ? Colors.redAccent : Colors.white,
                        size: 22,
                      ),
                      onPressed: onShortlistToggle,
                    ),
                  ),
                ),
              ],
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: Name + Call & WhatsApp Icon Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.name,
                          style: AppTypography.heading3.copyWith(fontSize: 17),
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
                          minimumSize: const Size(36, 36),
                        ),
                        onPressed: () {
                          ContactPaywallSheet.show(context, targetProfile: profile);
                        },
                        child: const Icon(Icons.phone_outlined, size: 18, color: AppColors.saffronOrange),
                      ),
                      const SizedBox(width: 6),
                      // WhatsApp icon button (green outline)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          shape: const CircleBorder(),
                          side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                          minimumSize: const Size(36, 36),
                        ),
                        onPressed: () {
                          ContactPaywallSheet.show(context, targetProfile: profile);
                        },
                        child: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF25D366)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Age, Height, Marital status
                  Text(
                    '${profile.age} yrs • ${_formatHeight(profile.heightCm)} • ${profile.maritalStatus}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Religion & Caste
                  Text(
                    '${profile.religion} • ${profile.caste.replaceAll('caste_', '').replaceAll('_', ' ')}',
                    style: AppTypography.caption(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Occupation & Education
                  Row(
                    children: [
                      const Icon(Icons.work_outline, size: 14, color: AppColors.saffronOrange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${profile.occupation} • ${profile.education}',
                          style: AppTypography.caption(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Location & Distance chip
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${profile.city}, ${profile.district}',
                          style: AppTypography.caption(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Distance Chip
                      Builder(
                        builder: (_) {
                          final distStr = LocationService.instance.getFormattedDistance(
                            profile.profileId,
                            targetDistrict: profile.district,
                            targetCity: profile.city,
                          );
                          if (distStr == null) return const SizedBox.shrink();

                          return Container(
                            margin: const EdgeInsets.only(left: 6),
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.dividerColor),
                  const SizedBox(height: 10),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      // View profile button
                      OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('View Profile'),
                      ),
                      const SizedBox(width: 10),

                      // Send Interest CTA
                      Expanded(
                        child: AppButton(
                          text: isInterestSent ? 'Interest Sent ✓' : 'Send Interest',
                          backgroundColor: isInterestSent ? AppColors.successGreen : AppColors.saffronOrange,
                          icon: isInterestSent ? Icons.check : Icons.favorite,
                          onPressed: isInterestSent
                              ? null
                              : () {
                                  if (profile.isSample) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('This is a sample profile for demonstration.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  } else {
                                    onSendInterest?.call();
                                  }
                                },
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
    );
  }

  Widget _buildCardPhoto(ProfileModel profile) {
    final photo = profile.primaryPhoto;
    if (photo == null || photo.isEmpty) {
      return _buildPlaceholderPhoto(profile);
    }
    if (photo.startsWith('assets/')) {
      return Image.asset(
        photo,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 220,
        errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(profile),
      );
    }
    return Image.network(
      photo,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 220,
      errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(profile),
    );
  }

  Widget _buildPlaceholderPhoto(ProfileModel profile) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              profile.gender.toLowerCase() == 'male' ? Icons.face : Icons.face_3,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              profile.name,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
