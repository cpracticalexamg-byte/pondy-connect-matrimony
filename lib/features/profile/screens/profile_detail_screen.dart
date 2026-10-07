import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;

  const ProfileDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  ProfileModel? _profile;
  PartnerPrefModel? _prefs;
  bool _isLoading = true;
  String? _error;
  MatchResult? _matchResult;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profileRepo = ref.read(profileRepoProvider);
      final profile = await profileRepo.getProfileById(widget.profileId);
      final prefs = await profileRepo.getPartnerPrefs(widget.profileId);

      final authState = ref.read(authStateProvider);
      final myProfile = authState.profile;

      MatchResult? match;
      if (myProfile != null && profile != null) {
        final myPrefs = await profileRepo.getPartnerPrefs(myProfile.profileId) ??
            PartnerPrefModel(profileId: myProfile.profileId);
        match = MatchingEngine.instance.calculateMatch(
          myProfile: myProfile,
          myPrefs: myPrefs,
          candidate: profile,
        );

        // Record profile view
        await profileRepo.recordView(myProfile.profileId, profile.profileId);
      }

      setState(() {
        _profile = profile;
        _prefs = prefs;
        _matchResult = match;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.saffronOrange)),
      );
    }

    if (_profile == null || _error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 54, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(_error ?? 'Profile not found', style: AppTypography.heading3),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffronOrange, foregroundColor: Colors.white),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _profile!;
    final matchesState = ref.watch(matchesProvider);
    final isShortlisted = matchesState.shortlistedIds.contains(p.profileId);
    final isInterestSent = matchesState.sentInterestIds.contains(p.profileId);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          // 1. Sliver AppBar with Hero Photo & Action Badges
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.saffronOrange,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Photo / Fallback Avatar
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          p.gender == 'Male' ? const Color(0xFF1E3C72) : const Color(0xFFE2670A),
                          p.gender == 'Male' ? const Color(0xFF2A5298) : const Color(0xFFD6336C),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: ProfileAvatar(
                        imageUrl: p.primaryPhoto,
                        gender: p.gender,
                        name: p.name,
                        radius: 80,
                        isVerified: p.completenessPct >= 80,
                      ),
                    ),
                  ),
                  // Gradient Overlay at bottom of hero
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withAlpha(160)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // Score Tag on hero
                  if (_matchResult != null)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.saffronOrange,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${_matchResult!.score}% Compatibility',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isShortlisted ? Icons.favorite : Icons.favorite_border,
                  color: isShortlisted ? Colors.redAccent : Colors.white,
                ),
                onPressed: () async {
                  final added = await ref.read(matchesProvider.notifier).toggleShortlist(p.profileId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(added ? 'Saved to shortlist' : 'Removed from shortlist')),
                    );
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (val) {
                  if (val == 'report') {
                    _showReportDialog(context, p.profileId);
                  } else if (val == 'block') {
                    _showBlockDialog(context, p.profileId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'report', child: Text('Report Profile')),
                  const PopupMenuItem(value: 'block', child: Text('Block Profile')),
                ],
              ),
            ],
          ),

          // 2. Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  _buildSectionCard(
                    title: '${p.name} (${p.profileId})',
                    subtitle: '${p.age} yrs • ${_formatHeight(p.heightCm)} • ${p.maritalStatus}',
                    children: [
                      _buildDetailRow('Location', '${p.city}, ${p.district}, ${p.state}'),
                      _buildDetailRow('Mother Tongue', p.motherTongue),
                      _buildDetailRow('Citizenship', p.citizenship),
                      _buildDetailRow('Physical Status', p.physicalStatus),
                    ],
                  ),

                  // Horoscope & Astrology Card
                  _buildSectionCard(
                    title: 'Horoscope Details',
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.saffronOrange),
                      label: const Text('10-Porutham', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        context.push('/horoscope?candidateId=${p.profileId}');
                      },
                    ),
                    children: [
                      _buildDetailRow('Religion', p.religion),
                      _buildDetailRow('Community / Caste', p.caste.replaceAll('caste_', '').replaceAll('_', ' ')),
                      if (p.division.isNotEmpty) _buildDetailRow('Division', p.division),
                      _buildDetailRow('Star (Nakshatram)', p.star.replaceAll('star_', '').replaceAll('_', ' ')),
                      _buildDetailRow('Rasi (Moon Sign)', p.rasi.replaceAll('rasi_', '').replaceAll('_', ' ')),
                      _buildDetailRow('Gothram', p.gothram.isEmpty ? 'Not specified' : p.gothram),
                      _buildDetailRow('Dosham', p.dosham.replaceAll('dosham_', '').replaceAll('_', ' ')),
                    ],
                  ),

                  // Education & Profession Card
                  _buildSectionCard(
                    title: 'Education & Career',
                    children: [
                      _buildDetailRow('Education', p.education.toUpperCase()),
                      if (p.educationDetail.isNotEmpty) _buildDetailRow('Degree Details', p.educationDetail),
                      _buildDetailRow('Employed In', p.employmentType),
                      _buildDetailRow('Occupation', p.occupation),
                      if (p.employer.isNotEmpty) _buildDetailRow('Employer', p.employer),
                      _buildDetailRow('Annual Income', p.annualIncomeRange),
                    ],
                  ),

                  // Family Details Card
                  _buildSectionCard(
                    title: 'Family Background',
                    children: [
                      _buildDetailRow('Family Status', p.familyStatus),
                      _buildDetailRow('Family Values', p.familyValues),
                      _buildDetailRow('Family Type', p.familyType),
                      if (p.fatherOccupation.isNotEmpty) _buildDetailRow("Father's Occupation", p.fatherOccupation),
                      if (p.motherOccupation.isNotEmpty) _buildDetailRow("Mother's Occupation", p.motherOccupation),
                      _buildDetailRow('Brothers', '${p.brothers}'),
                      _buildDetailRow('Sisters', '${p.sisters}'),
                    ],
                  ),

                  // Lifestyle Card
                  _buildSectionCard(
                    title: 'Lifestyle & Habits',
                    children: [
                      _buildDetailRow('Diet', p.diet),
                      _buildDetailRow('Smoking', p.smoking),
                      _buildDetailRow('Drinking', p.drinking),
                    ],
                  ),

                  // About Bio
                  if (p.aboutMe.isNotEmpty)
                    _buildSectionCard(
                      title: 'About Me',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            p.aboutMe,
                            style: AppTypography.bodySmall.copyWith(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),

                  // Partner Preferences Checklist
                  if (_prefs != null) _buildPartnerPrefsComparison(p, _prefs!),

                  const SizedBox(height: 100), // spacing for floating bar
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Floating Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Chat
              OutlinedButton(
                onPressed: () {
                  context.push('/chat/${p.profileId}');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.saffronOrange,
                  side: const BorderSide(color: AppColors.saffronOrange),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 18),
                    SizedBox(width: 6),
                    Text('Chat'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Send Interest CTA
              Expanded(
                child: AppButton(
                  text: isInterestSent ? 'Interest Sent ✓' : 'Send Interest',
                  backgroundColor: isInterestSent ? AppColors.successGreen : AppColors.saffronOrange,
                  icon: isInterestSent ? Icons.check : Icons.favorite,
                  onPressed: isInterestSent
                      ? null
                      : () async {
                          await ref.read(matchesProvider.notifier).sendInterest(p.profileId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Interest sent to ${p.name}!'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading3.copyWith(fontSize: 16)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.caption(color: AppColors.textSecondary)),
                  ],
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.dividerColor),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not Specified',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerPrefsComparison(ProfileModel candidate, PartnerPrefModel prefs) {
    final authState = ref.read(authStateProvider);
    final my = authState.profile;

    final ageMatch = my != null ? (my.age >= prefs.ageMin && my.age <= prefs.ageMax) : true;
    final relMatch = my != null ? (prefs.religion == 'all' || prefs.religion.toLowerCase() == my.religion.toLowerCase()) : true;
    final distMatch = my != null ? (prefs.district == 'all' || prefs.district.toLowerCase() == my.district.toLowerCase()) : true;
    final dietMatch = my != null ? (prefs.diet == 'all' || prefs.diet.toLowerCase() == my.diet.toLowerCase()) : true;

    return _buildSectionCard(
      title: "Partner Preferences",
      subtitle: "See how well you match their criteria",
      children: [
        _buildPrefRow('Age Range', '${prefs.ageMin} - ${prefs.ageMax} yrs', ageMatch),
        _buildPrefRow('Religion', prefs.religion == 'all' ? 'Any' : prefs.religion, relMatch),
        _buildPrefRow('District', prefs.district == 'all' ? 'Any' : prefs.district, distMatch),
        _buildPrefRow('Diet', prefs.diet == 'all' ? 'Any' : prefs.diet, dietMatch),
      ],
    );
  }

  Widget _buildPrefRow(String label, String expected, bool isMatch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMatch ? Icons.check_circle : Icons.remove_circle_outline,
            size: 16,
            color: isMatch ? AppColors.successGreen : Colors.grey,
          ),
          const SizedBox(width: 8),
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Expanded(
            child: Text(expected, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatHeight(int cm) {
    if (cm <= 0) return '5\'4"';
    final inches = (cm / 2.54).round();
    final ft = inches ~/ 12;
    final inch = inches % 12;
    return '$ft\'$inch" ($cm cm)';
  }

  void _showReportDialog(BuildContext context, String profileId) {
    final reportController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Report Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the reason for reporting this profile:'),
            const SizedBox(height: 10),
            TextField(
              controller: reportController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Fake photo, inappropriate messages, etc.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final myProfileId = ref.read(authStateProvider).profile?.profileId ?? 'PC_USER';
              await ref.read(reportRepoProvider).reportProfile(
                    myProfileId,
                    profileId,
                    'inappropriate',
                    reportController.text,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted. We will investigate promptly.')),
                );
              }
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context, String profileId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block Profile'),
        content: const Text('Are you sure you want to block this profile? They will no longer be able to message you or view your profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final myProfileId = ref.read(authStateProvider).profile?.profileId ?? 'PC_USER';
              await ref.read(reportRepoProvider).blockUser(myProfileId, profileId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile blocked successfully.')));
                context.pop();
              }
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
