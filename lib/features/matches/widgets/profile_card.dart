import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../domain/matching/matching_engine.dart';

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

  @override
  Widget build(BuildContext context) {
    final profile = match.profile;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2.0,
      shadowColor: Colors.black.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.cardBorder.withAlpha(120),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar + Details + Match Score & Shortlist
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo with verification
                  ProfileAvatar(
                    imageUrl: profile.primaryPhoto,
                    gender: profile.gender,
                    name: profile.name,
                    radius: 36,
                    isVerified: profile.completenessPct >= 80,
                  ),
                  const SizedBox(width: 14),
                  // Core Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            // Shortlist Bookmark Button
                            IconButton(
                              icon: Icon(
                                isShortlisted ? Icons.favorite : Icons.favorite_border,
                                color: isShortlisted ? Colors.redAccent : AppColors.textSecondary,
                                size: 22,
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: onShortlistToggle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.age} yrs • ${_formatHeight(profile.heightCm)} • ${profile.maritalStatus}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${profile.religion} • ${profile.caste.replaceAll('caste_', '').replaceAll('_', ' ')}',
                          style: AppTypography.caption(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.saffronOrange),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${profile.city}, ${profile.district}',
                                style: AppTypography.caption(color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Profession & Education pill strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgCream.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work_outline, size: 14, color: AppColors.saffronOrange),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${profile.occupation} (${profile.education})',
                        style: AppTypography.caption(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Match score tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _scoreColor(match.score).withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _scoreColor(match.score).withAlpha(100)),
                      ),
                      child: Text(
                        '${match.score}% Match',
                        style: TextStyle(
                          color: _scoreColor(match.score),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // "Why this match" reason chips
              if (match.matchReasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: match.matchReasons.map((reason) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 11, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            reason,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.dividerColor),
              const SizedBox(height: 10),

              // Bottom Action Buttons
              Row(
                children: [
                  // Chat button
                  OutlinedButton.icon(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.saffronOrange,
                      side: const BorderSide(color: AppColors.saffronOrange),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send Interest CTA
                  Expanded(
                    child: AppButton(
                      text: isInterestSent ? 'Interest Sent ✓' : 'Send Interest',
                      backgroundColor: isInterestSent ? AppColors.successGreen : AppColors.saffronOrange,
                      icon: isInterestSent ? Icons.check : Icons.favorite,
                      height: 40,
                      onPressed: isInterestSent ? null : onSendInterest,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
