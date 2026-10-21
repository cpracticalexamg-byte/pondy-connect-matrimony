import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/widgets/pondy_watermark.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entitlements/entitlements_engine.dart';
import '../../../domain/entitlements/entitlements_model.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';
import '../widgets/contact_paywall_sheet.dart';

/// Olive Green palette constants derived from reference (#808000)
class _OliveTokens {
  static const Color primary = Color(0xFF808000); // Base Olive Green
  static const Color headerBgStart = Color(0xFFF3F5EB); // Soft olive gradient start
  static const Color headerBgEnd = Color(0xFFFFFFFF); // Soft olive gradient end
  static const Color border = Color(0xFFD6DEC0);
  static const Color iconCircleBg = Color(0xFFE9EED8);
  static const Color titleColor = Color(0xFF2E331A);
}

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String profileId;
  final List<String>? candidateIds;
  final int? initialIndex;
  final String? sourceTitle;

  const ProfileDetailScreen({
    super.key,
    required this.profileId,
    this.candidateIds,
    this.initialIndex,
    this.sourceTitle,
  });

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  late PageController _pageController;
  late List<String> _candidateIds;
  late int _currentIndex;
  String _sourceTitle = 'Matches';
  bool _showFirstTimeHint = false;

  // Track active scroll controllers per page index for "Top" button
  final Map<int, ScrollController> _scrollControllers = {};
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _sourceTitle = widget.sourceTitle ?? 'All matches';

    // Resolve candidates list
    if (widget.candidateIds != null && widget.candidateIds!.isNotEmpty) {
      _candidateIds = List<String>.from(widget.candidateIds!);
    } else {
      final matchesState = ref.read(matchesProvider);
      final list = matchesState.filteredMatches.map((m) => m.profile.profileId).toList();
      _candidateIds = list.isNotEmpty ? list : [widget.profileId];
    }

    if (!_candidateIds.contains(widget.profileId)) {
      _candidateIds.insert(0, widget.profileId);
    }

    final initialIdx = widget.initialIndex ?? _candidateIds.indexOf(widget.profileId);
    _currentIndex = (initialIdx >= 0 && initialIdx < _candidateIds.length) ? initialIdx : 0;
    _pageController = PageController(initialPage: _currentIndex);

    _checkFirstTimeHint();
  }

  Future<void> _checkFirstTimeHint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('has_seen_swipe_hint') ?? false;
      if (!seen && mounted) {
        setState(() => _showFirstTimeHint = true);
      }
    } catch (_) {}
  }

  Future<void> _dismissFirstTimeHint() async {
    if (!_showFirstTimeHint) return;
    setState(() => _showFirstTimeHint = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_swipe_hint', true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  ScrollController _getScrollController(int index) {
    if (!_scrollControllers.containsKey(index)) {
      final controller = ScrollController();
      controller.addListener(() {
        if (index == _currentIndex) {
          final show = controller.hasClients && controller.offset > 320;
          if (show != _showTopButton) {
            setState(() => _showTopButton = show);
          }
        }
      });
      _scrollControllers[index] = controller;
    }
    return _scrollControllers[index]!;
  }

  void _scrollToTop() {
    final controller = _scrollControllers[_currentIndex];
    if (controller != null && controller.hasClients) {
      controller.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToPrevious() {
    _dismissFirstTimeHint();
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _goToNext() {
    _dismissFirstTimeHint();
    if (_currentIndex < _candidateIds.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleDontShow(String profileId, String profileName) async {
    final auth = ref.read(authStateProvider);
    final myProfileId = auth.profile?.profileId ?? '';
    final repo = ref.read(profileRepoProvider);

    await repo.hideProfile(myProfileId, profileId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$profileName's profile will no longer be shown"),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.saffronOrange,
            onPressed: () async {
              await repo.unhideProfile(myProfileId, profileId);
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );

      setState(() {
        _candidateIds.remove(profileId);
      });

      if (_candidateIds.isEmpty) {
        context.pop();
      } else if (_currentIndex >= _candidateIds.length) {
        _pageController.jumpToPage(_candidateIds.length - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_candidateIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_sourceTitle)),
        body: _buildEmptyState(),
      );
    }

    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < _candidateIds.length - 1;
    final currentId = _candidateIds[_currentIndex.clamp(0, _candidateIds.length - 1)];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '$_sourceTitle ${_currentIndex + 1}/${_candidateIds.length}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: const [
          LanguageToggleButton(),
        ],
      ),
      body: Stack(
        children: [
          // Horizontal PageView over current session
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _candidateIds.length,
            onPageChanged: (idx) {
              _dismissFirstTimeHint();
              setState(() {
                _currentIndex = idx;
                _showTopButton = false;
              });
            },
            itemBuilder: (context, index) {
              return _ProfileDetailPageView(
                key: ValueKey(_candidateIds[index]),
                profileId: _candidateIds[index],
                scrollController: _getScrollController(index),
                isFirstProfile: index == 0,
                showFirstTimeHint: _showFirstTimeHint && index == 0,
                onDismissHint: _dismissFirstTimeHint,
                onSelectSibling: (targetId) {
                  final targetIdx = _candidateIds.indexOf(targetId);
                  if (targetIdx >= 0) {
                    _pageController.jumpToPage(targetIdx);
                  } else {
                    context.push('/profile/$targetId');
                  }
                },
              );
            },
          ),

          // Floating Left Chevron (<) - hide on first
          if (hasPrev)
            Positioned(
              left: 10,
              top: MediaQuery.of(context).size.height * 0.42,
              child: _buildEdgeChevron(
                icon: Icons.chevron_left,
                tooltip: 'Previous Profile',
                onPressed: _goToPrevious,
              ),
            ),

          // Floating Right Chevron (>) - hide on last
          if (hasNext)
            Positioned(
              right: 10,
              top: MediaQuery.of(context).size.height * 0.42,
              child: _buildEdgeChevron(
                icon: Icons.chevron_right,
                tooltip: 'Next Profile',
                onPressed: _goToNext,
              ),
            ),

          // Floating "Top" Pill (appears when scrolled down)
          if (_showTopButton)
            Positioned(
              bottom: 120,
              right: 20,
              child: InkWell(
                onTap: _scrollToTop,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: AppColors.saffronOrange.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_up, size: 18, color: AppColors.saffronOrange),
                      SizedBox(width: 4),
                      Text(
                        'Top',
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
            ),
        ],
      ),

      // Sticky Bottom Action Bar
      bottomNavigationBar: _StickyProfileActionBar(
        profileId: currentId,
        onSkip: hasNext ? _goToNext : () => context.pop(),
        onDontShow: (p) => _handleDontShow(p.profileId, p.name),
        onInterestSentAutoAdvance: () {
          if (hasNext) {
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) _goToNext();
            });
          }
        },
      ),
    );
  }

  Widget _buildEdgeChevron({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              "You've seen all matches",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try changing your search filters or explore nearby matches.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Back to Matches'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single profile detail page inside the PageView
class _ProfileDetailPageView extends ConsumerStatefulWidget {
  final String profileId;
  final ScrollController scrollController;
  final bool isFirstProfile;
  final bool showFirstTimeHint;
  final VoidCallback onDismissHint;
  final ValueChanged<String> onSelectSibling;

  const _ProfileDetailPageView({
    super.key,
    required this.profileId,
    required this.scrollController,
    this.isFirstProfile = false,
    this.showFirstTimeHint = false,
    required this.onDismissHint,
    required this.onSelectSibling,
  });

  @override
  ConsumerState<_ProfileDetailPageView> createState() => _ProfileDetailPageViewState();
}

class _ProfileDetailPageViewState extends ConsumerState<_ProfileDetailPageView> {
  ProfileModel? _profile;
  PartnerPrefModel? _prefs;
  bool _isLoading = true;
  String? _error;
  Timer? _viewTimer;

  // Photo gallery index
  final int _activePhotoIndex = 0;

  // Expansion states for partner preferences
  bool _expandedEducation = false;
  bool _expandedOccupation = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profileRepo = ref.read(profileRepoProvider);
      final profile = await profileRepo.getProfileById(widget.profileId);
      final prefs = await profileRepo.getPartnerPrefs(widget.profileId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _prefs = prefs;
          _isLoading = false;
        });

        // Record profile view after 1 second of visibility
        _viewTimer = Timer(const Duration(seconds: 1), () {
          final myId = ref.read(authStateProvider).profile?.profileId;
          if (myId != null && profile != null) {
            profileRepo.recordView(myId, profile.profileId);
          }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.saffronOrange),
      );
    }

    if (_profile == null || _error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 54, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(_error ?? 'Profile not found', style: AppTypography.heading3),
          ],
        ),
      );
    }

    final p = _profile!;
    final entitlementsAsync = ref.watch(entitlementsProvider);
    final entitlements = entitlementsAsync.value ?? Entitlements.free();
    final authState = ref.watch(authStateProvider);
    final myProfile = authState.profile;

    final displayId = p.profileId.startsWith('M')
        ? p.profileId
        : (p.profileId.startsWith('PC') ? 'M${p.profileId.substring(2)}' : 'M${p.profileId.padLeft(8, '0')}');

    return SingleChildScrollView(
      controller: widget.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Photo Hero Section with Shortlist, 3-dot menu, photo arrows, hint scrim
          _buildHeroPhotoSection(context, p, displayId),

          // 2. Verified Badge Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
            child: Row(
              children: [
                if (p.isVerified || p.completenessPct >= 80)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FD),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFF1E88E5), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Verified Profile',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Text(
                  'Last seen few hours ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 3. Name, Profile ID & Contact Quick Actions (Call & WhatsApp)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayId,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Call (Orange outline circle)
                InkWell(
                  onTap: () => ContactPaywallSheet.show(context, targetProfile: p),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.saffronOrange, width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.call_outlined, color: AppColors.saffronOrange, size: 22),
                  ),
                ),
                const SizedBox(width: 10),

                // WhatsApp (Green outline circle)
                InkWell(
                  onTap: () => ContactPaywallSheet.show(context, targetProfile: p),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF2E7D32), size: 22),
                  ),
                ),
              ],
            ),
          ),

          // 4. Dot-separated Summary Line with Locality + City
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Text(
              _buildSummaryLine(p),
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),

          // 5. Sections with Olive Green Header Pills (#808000)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // a. Personal Information
                _buildOliveSectionHeader(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                ),
                _buildInfoRow('Age', '${p.age} Yrs'),
                _buildInfoRow('Height', _formatHeight(p.heightCm)),
                _buildInfoRow('Weight', '62 Kg'),
                _buildInfoRow('Body Type', 'Average'),
                _buildInfoRow('Mother Tongue', _formatTitle(p.motherTongue)),
                _buildInfoRow('Spoken Languages', 'Tamil, English'),
                _buildInfoRow('Profile created by', _formatTitle(p.profileSource.isNotEmpty ? p.profileSource : 'Self')),
                _buildInfoRow('Marital Status', _formatTitle(p.maritalStatus)),
                _buildInfoRow('Lives In', '${p.locality.isNotEmpty ? p.locality : "Mudaliarpet"}, ${p.city.isNotEmpty ? p.city : "Puducherry"}'),
                _buildInfoRow('Eating Habits', _formatTitle(p.diet)),
                _buildInfoRow('Smoking', p.smoking.isNotEmpty ? p.smoking : 'No'),
                _buildInfoRow('Drinking', p.drinking.isNotEmpty ? p.drinking : 'No'),
                _buildInfoRow('Physical Status', p.physicalStatus.isNotEmpty ? p.physicalStatus : 'Normal'),

                const SizedBox(height: 24),

                // About Myself & Lifestyle
                if (p.aboutMe.isNotEmpty) ...[
                  _buildOliveSectionHeader(
                    icon: Icons.info_outline,
                    title: 'About Myself',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      p.aboutMe,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // b. Religious / Horoscope
                _buildOliveSectionHeader(
                  icon: Icons.brightness_auto,
                  title: 'Religious / Horoscope',
                  trailing: TextButton.icon(
                    onPressed: () {
                      if (entitlements.fieldVisible('horoscope_chart')) {
                        context.push('/horoscope?candidateId=${p.profileId}');
                      } else {
                        context.push('/upgrade?source=field_lock&field=horoscope_chart&profile=${p.profileId}');
                      }
                    },
                    icon: Icon(
                      entitlements.fieldVisible('horoscope_chart') ? Icons.auto_awesome : Icons.lock_outline,
                      size: 14,
                      color: AppColors.saffronOrange,
                    ),
                    label: Text(
                      entitlements.fieldVisible('horoscope_chart') ? '10-Porutham' : 'Unlock Horoscope',
                      style: const TextStyle(
                        color: AppColors.saffronOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                _buildInfoRow('Religion', _formatTitle(p.religion)),
                _buildInfoRow('Caste', _formatTitle(p.caste)),
                _buildInfoRow('Subcaste', p.subcaste.isNotEmpty ? _formatTitle(p.subcaste) : 'Not specified'),
                _buildLockableInfoRow(
                  label: 'Star',
                  value: p.star.isNotEmpty ? _formatTitle(p.star) : 'Anusham',
                  fieldCode: 'star',
                  entitlements: entitlements,
                  profileId: p.profileId,
                ),
                _buildLockableInfoRow(
                  label: 'Raasi',
                  value: p.rasi.isNotEmpty ? _formatTitle(p.rasi) : 'Viruchigam',
                  fieldCode: 'rasi',
                  entitlements: entitlements,
                  profileId: p.profileId,
                ),
                _buildLockableInfoRow(
                  label: 'Horoscope',
                  value: 'Complete Jathagam available',
                  fieldCode: 'horoscope_chart',
                  entitlements: entitlements,
                  profileId: p.profileId,
                ),

                const SizedBox(height: 24),

                // c. Professional Information
                _buildOliveSectionHeader(
                  icon: Icons.work_outline,
                  title: 'Professional',
                ),
                _buildInfoRow('Employment', _formatTitle(p.employmentType)),
                _buildInfoRow('Income', _formatIncome(p.annualIncomeRange)),
                _buildInfoRow('Education', p.education.toUpperCase().replaceAll('_', ' ')),
                if (p.educationDetail.isNotEmpty)
                  _buildInfoRow('Education Detail', p.educationDetail),
                _buildInfoRow('Occupation', _formatTitle(p.occupation)),
                _buildLockableInfoRow(
                  label: 'Works at',
                  value: p.employer.isNotEmpty ? p.employer : 'Software Tech Park',
                  fieldCode: 'employer',
                  entitlements: entitlements,
                  profileId: p.profileId,
                ),

                const SizedBox(height: 24),

                // d. Family Information
                _buildOliveSectionHeader(
                  icon: Icons.group_outlined,
                  title: 'Family Information',
                ),
                _buildInfoRow('Family Status', _formatTitle(p.familyStatus)),
                _buildInfoRow('Parents', p.fatherOccupation.isNotEmpty ? "Father: ${p.fatherOccupation}" : 'Father: Government Service'),
                _buildInfoRow('Brothers', '${p.brothers} (Married: 0)'),
                _buildInfoRow('Sisters', '${p.sisters} (Married: 0)'),
                _buildInfoRow('Ancestral Origin', '${p.district.isNotEmpty ? p.district : "Puducherry"}, India'),

                const SizedBox(height: 28),

                // e. Partner Preferences
                _buildPartnerPreferencesSection(p, myProfile),

                const SizedBox(height: 28),

                // f. "Profiles you may like" Carousel
                _buildProfilesYouMayLike(context),

                const SizedBox(height: 24),

                // g. Assisted Service / Upsell Banner
                _buildAssistedServiceBanner(context),

                const SizedBox(height: 100), // Spacing for sticky bottom action bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPhotoSection(BuildContext context, ProfileModel p, String displayId) {
    final matchesState = ref.watch(matchesProvider);
    final isShortlisted = matchesState.shortlistedIds.contains(p.profileId);

    // Photos list
    final photos = [
      if (p.primaryPhoto != null && p.primaryPhoto!.isNotEmpty) p.primaryPhoto!,
    ];

    return SizedBox(
      height: 380,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo Gallery with Watermark
          GestureDetector(
            onTap: () {
              widget.onDismissHint();
            },
            child: PondyWatermark(
              text: 'Pondy Connect',
              opacity: 0.16,
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
                    imageUrl: photos.isNotEmpty ? photos[_activePhotoIndex.clamp(0, photos.length - 1)] : null,
                    gender: p.gender,
                    name: p.name,
                    radius: 110,
                    isVerified: p.isVerified,
                  ),
                ),
              ),
            ),
          ),

          // Shortlist chip (top-left of photo)
          Positioned(
            top: 14,
            left: 14,
            child: InkWell(
              onTap: () async {
                HapticFeedback.lightImpact();
                final added = await ref.read(matchesProvider.notifier).toggleShortlist(p.profileId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(added ? 'Added to Shortlist' : 'Removed from Shortlist'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isShortlisted ? Icons.bookmark : Icons.bookmark_border,
                      size: 16,
                      color: isShortlisted ? const Color(0xFFFFD700) : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isShortlisted ? 'Shortlisted' : 'Shortlist',
                      style: TextStyle(
                        color: isShortlisted ? const Color(0xFFFFD700) : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3-dot menu (top-right of photo)
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (val) {
                  if (val == 'share') {
                    final text = 'Check out ${p.name} ($displayId), ${p.age} yrs, ${p.locality}, ${p.city} on Pondy Connect Matrimony!';
                    Share.share(text);
                  } else if (val == 'dont_show') {
                    ref.read(profileRepoProvider).hideProfile(
                          ref.read(authStateProvider).profile?.profileId ?? '',
                          p.profileId,
                        );
                    context.pop();
                  } else if (val == 'report') {
                    _showReportDialog(context, p.profileId);
                  } else if (val == 'block') {
                    _showBlockDialog(context, p.profileId);
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
            ),
          ),

          // First-time Swipe Hint scrim overlay
          if (widget.showFirstTimeHint)
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onDismissHint,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.72),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Text(
                          'Tap here or swipe to move to the next profile',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.black87,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Section Header Pill styled with the First Olive Green (#808000)
  Widget _buildOliveSectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_OliveTokens.headerBgStart, _OliveTokens.headerBgEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _OliveTokens.border, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _OliveTokens.iconCircleBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _OliveTokens.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _OliveTokens.titleColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not Specified',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockableInfoRow({
    required String label,
    required String value,
    required String fieldCode,
    required Entitlements entitlements,
    required String profileId,
  }) {
    final isVisible = entitlements.fieldVisible(fieldCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: isVisible
                ? Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : InkWell(
                    onTap: () {
                      context.push('/upgrade?source=field_lock&field=$fieldCode&profile=$profileId');
                    },
                    borderRadius: BorderRadius.circular(4),
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
                            fontSize: 13,
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

  /// Partner Preferences Section
  Widget _buildPartnerPreferencesSection(ProfileModel p, ProfileModel? my) {
    final prefs = _prefs ?? PartnerPrefModel(profileId: p.profileId);

    // Compute live match rows
    final ageMatch = my != null ? (my.age >= prefs.ageMin && my.age <= prefs.ageMax) : true;
    final heightMatch = my != null ? (my.heightCm >= prefs.heightMin && my.heightCm <= prefs.heightMax) : true;
    final maritalMatch = my != null ? (prefs.maritalStatus == 'all' || prefs.maritalStatus.toLowerCase() == my.maritalStatus.toLowerCase()) : true;
    final tongueMatch = my != null ? (prefs.motherTongue == 'all' || prefs.motherTongue.toLowerCase() == my.motherTongue.toLowerCase()) : true;
    final relMatch = my != null ? (prefs.religion == 'all' || prefs.religion.toLowerCase() == my.religion.toLowerCase()) : true;
    final casteMatch = my != null ? (prefs.caste == 'all' || prefs.caste.toLowerCase() == my.caste.toLowerCase() || p.willingOtherCaste) : true;
    final eduMatch = my != null ? (prefs.education == 'all' || my.education.toLowerCase().contains(prefs.education.toLowerCase())) : true;
    final occMatch = my != null ? (prefs.occupation == 'all' || my.occupation.toLowerCase().contains(prefs.occupation.toLowerCase())) : true;
    final distMatch = my != null ? (prefs.district == 'all' || prefs.district.toLowerCase() == my.district.toLowerCase() || prefs.district.toLowerCase() == my.city.toLowerCase()) : true;
    final dietMatch = my != null ? (prefs.diet == 'all' || prefs.diet.toLowerCase() == my.diet.toLowerCase()) : true;

    final matchChecks = [
      ageMatch,
      heightMatch,
      maritalMatch,
      tongueMatch,
      relMatch,
      casteMatch,
      eduMatch,
      occMatch,
      distMatch,
      dietMatch,
    ];
    final matchScore = matchChecks.where((c) => c).length;
    final totalPrefs = matchChecks.length;

    final genderLabel = p.gender == 'Male' ? 'His' : 'Her';
    final pronounLabel = p.gender == 'Male' ? 'his' : 'her';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with sparkles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 18),
            const SizedBox(width: 8),
            Text(
              "$genderLabel Partner Preferences",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 18),
          ],
        ),
        const SizedBox(height: 14),

        // Header Comparison Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFE0B2)),
          ),
          child: Row(
            children: [
              // Candidate avatar
              ProfileAvatar(
                imageUrl: p.primaryPhoto,
                gender: p.gender,
                name: p.name,
                radius: 28,
              ),
              const SizedBox(width: 14),
              // Match text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You match $matchScore/$totalPrefs of $pronounLabel preferences',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on your profile details and preferences',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // User avatar placeholder
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  my?.gender == 'Female' ? Icons.face_3 : Icons.face,
                  color: Colors.grey.shade600,
                  size: 32,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sub-sections with checks
        _buildPrefSubHeader('Basic Preferences'),
        _buildPrefRow('Age', '${prefs.ageMin} to ${prefs.ageMax} Yrs', ageMatch),
        _buildPrefRow('Height', '${_formatHeight(prefs.heightMin)} to ${_formatHeight(prefs.heightMax)}', heightMatch),
        _buildPrefRow('Marital Status', prefs.maritalStatus == 'all' ? 'Any' : _formatTitle(prefs.maritalStatus), maritalMatch),
        _buildPrefRow('Mother Tongue', prefs.motherTongue == 'all' ? 'Any' : _formatTitle(prefs.motherTongue), tongueMatch),
        _buildPrefRow('Diet / Eating Habits', prefs.diet == 'all' ? 'Any' : _formatTitle(prefs.diet), dietMatch),

        const SizedBox(height: 12),
        _buildPrefSubHeader('Religious Preferences'),
        _buildPrefRow('Religion', prefs.religion == 'all' ? 'Any' : _formatTitle(prefs.religion), relMatch),
        _buildPrefRow('Caste', prefs.caste == 'all' ? 'Any' : _formatTitle(prefs.caste), casteMatch),

        const SizedBox(height: 12),
        _buildPrefSubHeader('Professional Preferences'),
        _buildPrefRowWithExpander(
          label: 'Education',
          value: prefs.education == 'all' ? 'Any Degree' : prefs.education.toUpperCase(),
          isMatch: eduMatch,
          isExpanded: _expandedEducation,
          onToggle: () => setState(() => _expandedEducation = !_expandedEducation),
        ),
        _buildPrefRowWithExpander(
          label: 'Occupation',
          value: prefs.occupation == 'all' ? 'Any Profession' : _formatTitle(prefs.occupation),
          isMatch: occMatch,
          isExpanded: _expandedOccupation,
          onToggle: () => setState(() => _expandedOccupation = !_expandedOccupation),
        ),

        const SizedBox(height: 12),
        _buildPrefSubHeader('Location Preferences'),
        _buildPrefRow('Citizenship', 'India', true),
        _buildPrefRow('Location', prefs.district == 'all' ? 'Puducherry & Tamil Nadu' : _formatTitle(prefs.district), distMatch),
      ],
    );
  }

  Widget _buildPrefSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          const Text(
            'You match',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefRow(String label, String value, bool isMatch) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            isMatch ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: isMatch ? const Color(0xFF2E7D32) : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildPrefRowWithExpander({
    required String label,
    required String value,
    required bool isMatch,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: isExpanded ? 6 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (value.length > 25)
                  GestureDetector(
                    onTap: onToggle,
                    child: Text(
                      isExpanded ? 'Less' : 'More',
                      style: const TextStyle(
                        color: AppColors.saffronOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            isMatch ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: isMatch ? const Color(0xFF2E7D32) : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  /// Horizontal "Profiles you may like" carousel
  Widget _buildProfilesYouMayLike(BuildContext context) {
    final allMatches = ref.watch(matchesProvider).filteredMatches;
    final otherProfiles = allMatches.where((m) => m.profile.profileId != widget.profileId).take(6).toList();

    if (otherProfiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profiles you may like',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.pop(),
              child: const Text(
                'See all >',
                style: TextStyle(
                  color: AppColors.saffronOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: otherProfiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final item = otherProfiles[idx].profile;
              return InkWell(
                onTap: () => widget.onSelectSibling(item.profileId),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      ProfileAvatar(
                        imageUrl: item.primaryPhoto,
                        gender: item.gender,
                        name: item.name,
                        radius: 38,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.age} Yrs, ${_formatHeightShort(item.heightCm)}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.locality.isNotEmpty ? item.locality : item.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Assisted Service / Membership Upsell Banner (Dark green + gold gradient card)
  Widget _buildAssistedServiceBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3B24), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 24),
              SizedBox(width: 8),
              Text(
                'Pondy Connect Assisted Service',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Get a dedicated relationship manager to handpick verified Pondicherry matches for you.',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: const Color(0xFF0F3B24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Explore Assisted Plans',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummaryLine(ProfileModel p) {
    final parts = [
      _formatTitle(p.maritalStatus),
      'Created by ${_formatTitle(p.profileSource.isNotEmpty ? p.profileSource : "Self")}',
      '${p.age} yrs',
      _formatHeight(p.heightCm),
      '${_formatTitle(p.religion)} (${_formatTitle(p.caste)})',
      p.education.toUpperCase().replaceAll('_', ' '),
      _formatTitle(p.occupation),
      _formatIncome(p.annualIncomeRange),
      '${p.locality.isNotEmpty ? p.locality : "Mudaliarpet"}, ${p.city.isNotEmpty ? p.city : "Puducherry"}',
    ];
    return parts.where((s) => s.isNotEmpty).join(' • ');
  }

  String _formatHeight(int cm) {
    if (cm <= 0) return '5\'4" (162 cm)';
    final inches = (cm / 2.54).round();
    final ft = inches ~/ 12;
    final inch = inches % 12;
    return '$ft\'$inch" ($cm cm)';
  }

  String _formatHeightShort(int cm) {
    if (cm <= 0) return '5\'4"';
    final inches = (cm / 2.54).round();
    final ft = inches ~/ 12;
    final inch = inches % 12;
    return '$ft\'$inch"';
  }

  String _formatTitle(String raw) {
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

/// Sticky Bottom Action Bar with Don't Show, Skip, Send Interest
class _StickyProfileActionBar extends ConsumerWidget {
  final String profileId;
  final VoidCallback onSkip;
  final ValueChanged<ProfileModel> onDontShow;
  final VoidCallback onInterestSentAutoAdvance;

  const _StickyProfileActionBar({
    required this.profileId,
    required this.onSkip,
    required this.onDontShow,
    required this.onInterestSentAutoAdvance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesProvider);
    final isInterestSent = matchesState.sentInterestIds.contains(profileId);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Don't Show & Skip
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Don't Show"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: () async {
                      final profile = await ref.read(profileRepoProvider).getProfileById(profileId);
                      if (profile != null) {
                        onDontShow(profile);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.keyboard_double_arrow_right, size: 18),
                    label: const Text('Skip'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.saffronOrange,
                      side: const BorderSide(color: AppColors.saffronOrange, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: onSkip,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Row 2: Full-width Send Interest CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  isInterestSent ? Icons.check_circle : Icons.favorite,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  isInterestSent ? 'Interest Sent ✓' : 'Send Interest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInterestSent ? const Color(0xFF2E7D32) : AppColors.saffronOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                onPressed: isInterestSent
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        await ref.read(matchesProvider.notifier).sendInterest(profileId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Interest sent successfully!'),
                              backgroundColor: Color(0xFF2E7D32),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        onInterestSentAutoAdvance();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
