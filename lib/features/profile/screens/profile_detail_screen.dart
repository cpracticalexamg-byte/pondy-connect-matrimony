import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pondy_watermark.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entitlements/entitlements_engine.dart';
import '../../../domain/entitlements/entitlements_model.dart';
import '../../../domain/location/location_service.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';
import '../widgets/contact_paywall_sheet.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  final List<String>? candidateIds;
  final int? initialIndex;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
    this.candidateIds,
    this.initialIndex,
  });

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  late String _currentProfileId;
  ProfileModel? _profile;
  PartnerPrefModel? _prefs;
  bool _isLoading = true;
  String? _error;
  MatchResult? _matchResult;

  final ScrollController _scrollController = ScrollController();
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _currentProfileId = widget.profileId;
    _scrollController.addListener(_onScroll);
    _loadProfile(_currentProfileId);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final show = _scrollController.offset > 320;
      if (show != _showTopButton) {
        setState(() => _showTopButton = show);
      }
    }
  }

  Future<void> _loadProfile(String id) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profileRepo = ref.read(profileRepoProvider);
      final profile = await profileRepo.getProfileById(id);
      final prefs = await profileRepo.getPartnerPrefs(id);

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

      if (mounted) {
        setState(() {
          _currentProfileId = id;
          _profile = profile;
          _prefs = prefs;
          _matchResult = match;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<String> _getSiblingCandidates() {
    if (widget.candidateIds != null && widget.candidateIds!.isNotEmpty) {
      return widget.candidateIds!;
    }
    final matchesState = ref.read(matchesProvider);
    return matchesState.filteredMatches.map((m) => m.profile.profileId).toList();
  }

  void _navigateToSibling(int direction) {
    final candidates = _getSiblingCandidates();
    if (candidates.isEmpty) return;
    final currIdx = candidates.indexOf(_currentProfileId);
    final targetIdx = currIdx + direction;
    if (targetIdx >= 0 && targetIdx < candidates.length) {
      _loadProfile(candidates[targetIdx]);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saffronOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _profile!;
    final entitlementsAsync = ref.watch(entitlementsProvider);
    final entitlements = entitlementsAsync.value ?? Entitlements.free();
    final matchesState = ref.watch(matchesProvider);
    final isShortlisted = matchesState.shortlistedIds.contains(p.profileId);
    final isInterestSent = matchesState.sentInterestIds.contains(p.profileId);

    final candidates = _getSiblingCandidates();
    final currIdx = candidates.indexOf(p.profileId);
    final hasPrev = currIdx > 0;
    final hasNext = currIdx >= 0 && currIdx < candidates.length - 1;

    final displayId = p.profileId.startsWith('PC') ? p.profileId : 'PC${p.profileId.padLeft(6, '0')}';

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 1. Sliver AppBar with Hero Photo, Matrimony ID & Watermark
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: AppColors.saffronOrange,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  displayId,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                centerTitle: true,
                actions: [
                  // Shortlist button
                  IconButton(
                    icon: Icon(
                      isShortlisted ? Icons.bookmark : Icons.bookmark_border,
                      color: isShortlisted ? Colors.amberAccent : Colors.white,
                    ),
                    tooltip: 'Shortlist',
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final added = await ref.read(matchesProvider.notifier).toggleShortlist(p.profileId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(added ? 'Added to your shortlist' : 'Removed from shortlist'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  // Phone / Contact paywall icon
                  IconButton(
                    icon: const Icon(Icons.phone_outlined, color: Colors.white),
                    tooltip: 'Contact Details',
                    onPressed: () {
                      ContactPaywallSheet.show(context, targetProfile: p);
                    },
                  ),
                  // More menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (val) {
                      if (val == 'report') {
                        _showReportDialog(context, p.profileId);
                      } else if (val == 'block') {
                        _showBlockDialog(context, p.profileId);
                      } else if (val == 'share') {
                        _shareProfile(p);
                      } else if (val == 'dont_show') {
                        _hideProfile(p);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Share Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'dont_show',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_off_outlined, size: 18),
                            SizedBox(width: 10),
                            Text("Don't Show"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Report Profile', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Block Profile', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo Gallery with Watermark
                      InteractiveViewer(
                        panEnabled: false,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 2.5,
                        child: PondyWatermark(
                          text: 'Pondy Connect',
                          opacity: 0.18,
                          child: Container(
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
                                radius: 95,
                                isVerified: p.isVerified || p.completenessPct >= 80,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Gradient Bottom Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Compatibility Score & Verification Chip
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            if (_matchResult != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.saffronOrange,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                            const Spacer(),
                            if (p.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('PRIME Verified', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            if (p.isSample)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade800,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Sample Profile', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card with Name, Age, Height, Quick Actions
                      _buildHeaderCard(p),

                      // Basic Info Section
                      _buildSectionCard(
                        title: 'Basic Information',
                        children: [
                          _buildDetailRow('Age / Height', '${p.age} yrs • ${_formatHeight(p.heightCm)}'),
                          _buildLockableDetailRow(
                            label: 'Date of Birth',
                            value: p.dob.isNotEmpty ? p.dob : 'Not Specified',
                            fieldCode: 'dob',
                            entitlements: entitlements,
                            profileId: p.profileId,
                          ),
                          _buildDetailRow('Marital Status', _formatSnakeCase(p.maritalStatus)),
                          _buildDetailRow('Mother Tongue', _formatSnakeCase(p.motherTongue)),
                          _buildDetailRow('Location', '${p.city}, ${p.district}, ${p.state}'),
                          _buildDetailRow('Citizenship', p.citizenship),
                          _buildDetailRow('Physical Status', p.physicalStatus),
                        ],
                      ),

                      // Religious & Caste Information
                      _buildSectionCard(
                        title: 'Religious Background',
                        children: [
                          _buildDetailRow('Religion', _formatSnakeCase(p.religion)),
                          if (p.division.isNotEmpty && p.division != 'none')
                            _buildDetailRow('Division', _formatSnakeCase(p.division)),
                          _buildDetailRow('Caste / Community', _formatSnakeCase(p.caste)),
                          if (p.subcaste.isNotEmpty)
                            _buildDetailRow('Subcaste', _formatSnakeCase(p.subcaste)),
                          _buildDetailRow('Gothram', p.gothram.isEmpty ? 'Not specified' : p.gothram),
                          _buildLockableDetailRow(
                            label: 'Star (Nakshatram)',
                            value: p.star.isNotEmpty ? _formatSnakeCase(p.star) : 'Not specified',
                            fieldCode: 'star',
                            entitlements: entitlements,
                            profileId: p.profileId,
                          ),
                          _buildLockableDetailRow(
                            label: 'Raasi (Moon Sign)',
                            value: p.rasi.isNotEmpty ? _formatSnakeCase(p.rasi) : 'Not specified',
                            fieldCode: 'rasi',
                            entitlements: entitlements,
                            profileId: p.profileId,
                          ),
                          _buildDetailRow('Dosham', _formatSnakeCase(p.dosham)),
                        ],
                      ),

                      // Horoscope Card with Lock & 10-Porutham
                      _buildHoroscopeCard(p, entitlements),

                      // Education & Career
                      _buildSectionCard(
                        title: 'Education & Career',
                        children: [
                          _buildDetailRow('Education', p.education.toUpperCase().replaceAll('_', ' ')),
                          if (p.educationDetail.isNotEmpty)
                            _buildDetailRow('Degree Details', p.educationDetail),
                          _buildLockableDetailRow(
                            label: 'Studied At',
                            value: 'Pondicherry University', // default mock institution
                            fieldCode: 'institution',
                            entitlements: entitlements,
                            profileId: p.profileId,
                          ),
                          _buildDetailRow('Employed In', _formatSnakeCase(p.employmentType)),
                          _buildDetailRow('Occupation', _formatSnakeCase(p.occupation)),
                          _buildLockableDetailRow(
                            label: 'Works At',
                            value: p.employer.isNotEmpty ? p.employer : 'Software Tech Park',
                            fieldCode: 'employer',
                            entitlements: entitlements,
                            profileId: p.profileId,
                          ),
                          _buildDetailRow('Annual Income', _formatIncome(p.annualIncomeRange)),
                        ],
                      ),

                      // Family Information
                      _buildSectionCard(
                        title: 'Family Information',
                        children: [
                          _buildDetailRow('Family Status', _formatSnakeCase(p.familyStatus)),
                          _buildDetailRow('Family Values', _formatSnakeCase(p.familyValues)),
                          _buildDetailRow('Family Type', _formatSnakeCase(p.familyType)),
                          if (p.fatherOccupation.isNotEmpty)
                            _buildDetailRow("Father's Occupation", p.fatherOccupation),
                          if (p.motherOccupation.isNotEmpty)
                            _buildDetailRow("Mother's Occupation", p.motherOccupation),
                          _buildDetailRow('Brothers', '${p.brothers}'),
                          _buildDetailRow('Sisters', '${p.sisters}'),
                        ],
                      ),

                      // Lifestyle & Habits
                      _buildSectionCard(
                        title: 'Lifestyle & Habits',
                        children: [
                          _buildDetailRow('Diet', _formatSnakeCase(p.diet)),
                          _buildDetailRow('Smoking', p.smoking),
                          _buildDetailRow('Drinking', p.drinking),
                        ],
                      ),

                      // About Me Bio
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

                      // Partner Preferences Checklist ("You match X of Y")
                      if (_prefs != null) _buildPartnerPrefsComparison(p, _prefs!),

                      const SizedBox(height: 110), // spacing for fixed bottom action bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Left Chevron (Previous Profile)
          if (hasPrev)
            Positioned(
              left: 8,
              top: MediaQuery.of(context).size.height * 0.45,
              child: _buildFloatingNavButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous Profile',
                onPressed: () => _navigateToSibling(-1),
              ),
            ),

          // Floating Right Chevron (Next Profile)
          if (hasNext)
            Positioned(
              right: 8,
              top: MediaQuery.of(context).size.height * 0.45,
              child: _buildFloatingNavButton(
                icon: Icons.chevron_right,
                tooltip: 'Next Profile',
                onPressed: () => _navigateToSibling(1),
              ),
            ),

          // Floating "Top" Chip
          if (_showTopButton)
            Positioned(
              bottom: 90,
              right: 20,
              child: InkWell(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                    border: Border.all(color: AppColors.saffronOrange.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: AppColors.saffronOrange),
                      SizedBox(width: 4),
                      Text('Top', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // 3. Fixed Bottom Action Bar: Don't Show · Skip · Send Interest
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Don't Show Action
              OutlinedButton.icon(
                icon: const Icon(Icons.visibility_off_outlined, size: 16),
                label: const Text("Don't Show"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade400),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _hideProfile(p),
              ),
              const SizedBox(width: 8),

              // Skip Action
              OutlinedButton.icon(
                icon: const Icon(Icons.skip_next, size: 16),
                label: const Text('Skip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.saffronOrange,
                  side: const BorderSide(color: AppColors.saffronOrange),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (hasNext) {
                    _navigateToSibling(1);
                  } else {
                    context.pop();
                  }
                },
              ),
              const SizedBox(width: 8),

              // Send Interest CTA
              Expanded(
                child: AppButton(
                  text: isInterestSent ? 'Interest Sent ✓' : 'Send Interest',
                  backgroundColor: isInterestSent ? AppColors.successGreen : AppColors.saffronOrange,
                  icon: isInterestSent ? Icons.check_circle : Icons.favorite,
                  onPressed: isInterestSent
                      ? null
                      : () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(matchesProvider.notifier).sendInterest(p.profileId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.favorite, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Interest sent to ${p.name}!'),
                                  ],
                                ),
                                backgroundColor: AppColors.successGreen,
                                duration: const Duration(seconds: 3),
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

  Widget _buildFloatingNavButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 24),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHeaderCard(ProfileModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: AppTypography.heading2.copyWith(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  '${p.age} yrs • ${_formatHeight(p.heightCm)} • ${_formatSnakeCase(p.maritalStatus)}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${p.city}, ${p.district}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Builder(
                      builder: (_) {
                        final distStr = LocationService.instance.getFormattedDistance(
                          p.profileId,
                          targetDistrict: p.district,
                          targetCity: p.city,
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
              ],
            ),
          ),
          // Call & WhatsApp quick icon buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.phone_outlined, color: AppColors.saffronOrange),
                tooltip: 'Call',
                style: IconButton.styleFrom(
                  side: const BorderSide(color: AppColors.saffronOrange, width: 1.2),
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () {
                  ContactPaywallSheet.show(context, targetProfile: p);
                },
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.chat, color: Color(0xFF2E7D32)),
                tooltip: 'WhatsApp',
                style: IconButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2E7D32), width: 1.2),
                  padding: const EdgeInsets.all(8),
                ),
                onPressed: () {
                  ContactPaywallSheet.show(context, targetProfile: p);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoroscopeCard(ProfileModel p, Entitlements entitlements) {
    final canViewHoroscope = entitlements.fieldVisible('horoscope_chart');

    return _buildSectionCard(
      title: 'Horoscope & Astrology',
      trailing: TextButton.icon(
        icon: Icon(
          canViewHoroscope ? Icons.auto_awesome : Icons.lock_outline,
          size: 16,
          color: AppColors.saffronOrange,
        ),
        label: Text(
          canViewHoroscope ? '10-Porutham' : 'Unlock Horoscope',
          style: const TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          if (canViewHoroscope) {
            context.push('/horoscope?candidateId=${p.profileId}');
          } else {
            context.push('/upgrade?source=field_lock&field=horoscope_chart&profile=${p.profileId}');
          }
        },
      ),
      children: [
        if (canViewHoroscope) ...[
          _buildDetailRow('Star (Nakshatram)', _formatSnakeCase(p.star)),
          _buildDetailRow('Raasi (Moon Sign)', _formatSnakeCase(p.rasi)),
          _buildDetailRow('Dosham', _formatSnakeCase(p.dosham)),
          _buildDetailRow('Gothram', p.gothram.isEmpty ? 'Not specified' : p.gothram),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: AppColors.saffronOrange, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Full Horoscope and 10-Porutham compatibility charts are available for Paid Members.',
                    style: TextStyle(fontSize: 12, color: Colors.brown),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/upgrade?source=field_lock&field=horoscope_chart&profile=${p.profileId}');
                  },
                  child: const Text('Upgrade >', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.saffronOrange)),
                ),
              ],
            ),
          ),
        ],
      ],
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
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Widget _buildLockableDetailRow({
    required String label,
    required String value,
    required String fieldCode,
    required Entitlements entitlements,
    required String profileId,
  }) {
    final isVisible = entitlements.fieldVisible(fieldCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: isVisible
                ? Text(
                    value.isNotEmpty ? value : 'Not Specified',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                  )
                : InkWell(
                    onTap: () {
                      context.push('/upgrade?source=field_lock&field=$fieldCode&profile=$profileId');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline, size: 14, color: AppColors.saffronOrange),
                        SizedBox(width: 4),
                        Text(
                          'Upgrade to view >',
                          style: TextStyle(
                            color: AppColors.saffronOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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

    int matchCount = 0;
    if (ageMatch) matchCount++;
    if (relMatch) matchCount++;
    if (distMatch) matchCount++;
    if (dietMatch) matchCount++;

    return _buildSectionCard(
      title: "Partner Preferences",
      subtitle: "You match $matchCount of 4 preferences",
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

  String _formatSnakeCase(String raw) {
    if (raw.isEmpty) return 'Not Specified';
    return raw
        .replaceAll('caste_', '')
        .replaceAll('star_', '')
        .replaceAll('rasi_', '')
        .replaceAll('dosham_', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _formatIncome(String raw) {
    if (raw.isEmpty) return 'Not Specified';
    return raw.replaceAll('_to_', ' - ').replaceAll('_', ' ').toUpperCase();
  }

  Future<void> _hideProfile(ProfileModel p) async {
    final auth = ref.read(authStateProvider);
    final myProfileId = auth.profile?.profileId ?? '';
    final repo = ref.read(profileRepoProvider);

    await repo.hideProfile(myProfileId, p.profileId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${p.name}'s profile will no longer be shown"),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.saffronOrange,
            onPressed: () async {
              await repo.unhideProfile(myProfileId, p.profileId);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      context.pop();
    }
  }

  void _shareProfile(ProfileModel p) {
    final displayId = p.profileId.startsWith('PC') ? p.profileId : 'PC${p.profileId.padLeft(6, '0')}';
    final text = 'Check out ${p.name} ($displayId), ${p.age} yrs, ${p.city} on Pondy Connect Matrimony!';
    Share.share(text);
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
