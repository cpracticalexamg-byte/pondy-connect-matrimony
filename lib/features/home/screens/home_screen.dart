import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/pondy_watermark.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entitlements/entitlements_model.dart';
import '../../../domain/location/location_service.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/profile_model.dart';
import '../../../domain/models/success_story_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';
import '../../profile/widgets/add_photo_prompt_sheet.dart';
import '../../profile/widgets/contact_paywall_sheet.dart';
import '../../profile/widgets/prime_photo_gate_sheet.dart';
import '../../recommendations/widgets/daily_recommendations_modal.dart';
import '../providers/home_provider.dart';

enum HomeMode { regular, prime }

class HomeScreen extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeMode _currentMode = HomeMode.regular;
  bool _checkedDailyModal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyRecommendationsModal();
    });
  }

  Future<void> _checkDailyRecommendationsModal() async {
    if (_checkedDailyModal || !mounted) return;
    _checkedDailyModal = true;

    try {
      final authState = ref.read(authStateProvider);
      final profile = authState.profile;
      if (profile == null) return;

      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastDate = prefs.getString('last_daily_rec_modal_date');

      if (lastDate != todayStr) {
        final homeData = ref.read(homeDashboardProvider);
        if (homeData.dailyRecommendations.isNotEmpty && mounted) {
          await prefs.setString('last_daily_rec_modal_date', todayStr);
          if (!mounted) return;
          DailyRecommendationsModal.show(
            context,
            recommendations: homeData.dailyRecommendations,
          );
        }
      }
    } catch (_) {}
  }

  void _onModeChanged(HomeMode mode) {
    if (mode == HomeMode.prime) {
      final authState = ref.read(authStateProvider);
      final p = authState.profile;
      if (p == null || p.primaryPhoto == null || p.primaryPhoto!.isEmpty) {
        PrimePhotoGateSheet.show(
          context,
          onUnlocked: () {
            setState(() => _currentMode = HomeMode.prime);
          },
        );
        return;
      }
    }
    setState(() => _currentMode = mode);
  }

  void _openHamburgerMenu(BuildContext context, ProfileModel? profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.saffronOrange),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/profile-edit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune, color: AppColors.saffronOrange),
                title: const Text('Partner Preferences'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/partner-preferences');
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined, color: AppColors.saffronOrange),
                title: const Text('Hidden Profiles'),
                onTap: () {
                  Navigator.pop(context);
                  _showHiddenProfilesSheet(context, profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: AppColors.saffronOrange),
                title: const Text('Privacy & Location'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/privacy-location');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppColors.saffronOrange),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: AppColors.saffronOrange),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/help');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.saffronOrange),
                title: const Text('About Pondy Connect'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/about');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHiddenProfilesSheet(BuildContext context, ProfileModel? profile) async {
    if (profile == null) return;
    final profileRepo = ref.read(profileRepoProvider);
    final hiddenIds = await profileRepo.getHiddenProfileIds(profile.profileId);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hidden Profiles (${hiddenIds.length})', style: AppTypography.heading3),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (hiddenIds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'You have not hidden any profiles.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: hiddenIds.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final hid = hiddenIds[i];
                        return ListTile(
                          title: Text('Profile $hid'),
                          trailing: TextButton(
                            onPressed: () async {
                              await profileRepo.unhideProfile(profile.profileId, hid);
                              hiddenIds.remove(hid);
                              setSheetState(() {});
                              ref.read(homeDashboardProvider.notifier).refreshDashboard();
                            },
                            child: const Text('Unhide'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDashboardProvider);
    final authState = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';
    final profile = authState.profile;
    final entitlements = Entitlements.of(profile);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Sticky Glassy Light-Green Gradient Header
            _buildStickyHeader(
              context: context,
              profile: profile,
              entitlements: entitlements,
              isTamil: isTamil,
              unreadCount: homeData.unreadNotificationsCount,
              hasNewVerified: homeData.hasNewVerified,
            ),

            // 2. Animated Shared-Axis Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  final offset = _currentMode == HomeMode.prime
                      ? Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
                      : Tween<Offset>(begin: const Offset(-0.2, 0), end: Offset.zero);
                  return SlideTransition(
                    position: offset.animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentMode),
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(homeDashboardProvider.notifier).refreshDashboard(),
                    color: AppColors.saffronOrange,
                    child: SingleChildScrollView(
                      key: PageStorageKey('home_${_currentMode.name}'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // Daily Recommendations Entry Card
                          _buildDailyRecommendationsEntryCard(context, homeData),

                          // Success Stories Carousel (hidden when empty)
                          if (homeData.successStories.isNotEmpty)
                            _buildSuccessStoriesSection(context, homeData.successStories),

                          if (_currentMode == HomeMode.regular) ...[
                            // All Matches Carousel
                            _buildMatchesCarousel(
                              context: context,
                              title: isTamil ? 'உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள்' : 'Matches based on your preferences',
                              subtitle: '${homeData.allMatches.length} ${isTamil ? "வரன்கள்" : "Matches"}',
                              matches: homeData.allMatches,
                              isLoading: homeData.isLoading,
                              onViewAll: () {
                                ref.read(matchesProvider.notifier).setFilterTab(MatchesFilterTab.all);
                                widget.onSwitchTab?.call(1);
                              },
                            ),

                            // Newly Joined Carousel
                            _buildMatchesCarousel(
                              context: context,
                              title: isTamil ? 'புதிதாக இணைந்தவர்கள்' : 'Newly Joined',
                              subtitle: isTamil ? 'கடந்த 30 நாட்களில் சேர்ந்தவர்கள்' : 'Joined within the last 30 days',
                              matches: homeData.newMatches,
                              isLoading: homeData.isLoading,
                              isNewlyJoined: true,
                              onViewAll: () {
                                ref.read(matchesProvider.notifier).setFilterTab(MatchesFilterTab.newlyJoined);
                                widget.onSwitchTab?.call(1);
                              },
                            ),

                            // Nearby Matches Carousel (with distance chip)
                            _buildMatchesCarousel(
                              context: context,
                              title: isTamil ? 'அருகிலுள்ள வரன்கள்' : 'Nearby Matches',
                              subtitle: isTamil ? 'உங்கள் பகுதிக்கு அருகில் உள்ளவர்கள்' : 'Matches near your location',
                              matches: homeData.nearbyMatches,
                              isLoading: homeData.isLoading,
                              showDistance: true,
                              onViewAll: () {
                                widget.onSwitchTab?.call(1);
                              },
                            ),

                            // Viewed You (Hidden when empty)
                            if (homeData.viewedYou.isNotEmpty)
                              _buildMatchesCarousel(
                                context: context,
                                title: isTamil ? 'உங்களைப் பார்த்தவர்கள்' : 'Viewed You',
                                subtitle: isTamil ? 'உங்கள் சுயவிவரத்தை பார்த்தவர்கள்' : 'Members who viewed your profile',
                                matches: homeData.viewedYou,
                                isLoading: homeData.isLoading,
                              ),

                            // Shortlisted You (Hidden when empty)
                            if (homeData.shortlistedYou.isNotEmpty)
                              _buildMatchesCarousel(
                                context: context,
                                title: isTamil ? 'உங்களை தேர்வு செய்தவர்கள்' : 'Shortlisted You',
                                subtitle: isTamil ? 'உங்களை ஷார்ட்லிஸ்ட் செய்தவர்கள்' : 'Members who shortlisted you',
                                matches: homeData.shortlistedYou,
                                isLoading: homeData.isLoading,
                              ),

                            // Mutual Matches (Hidden when empty)
                            if (homeData.mutualMatches.isNotEmpty)
                              _buildMatchesCarousel(
                                context: context,
                                title: isTamil ? 'இருவழிப் பொருத்தம்' : 'Mutual Matches',
                                subtitle: isTamil ? 'இருவரின் விருப்பங்களும் பொருந்துபவை' : 'Both profiles match preferences',
                                matches: homeData.mutualMatches,
                                isLoading: homeData.isLoading,
                              ),

                            // Premium/Verified Matches (Hidden when empty)
                            if (homeData.verifiedMatches.isNotEmpty)
                              _buildMatchesCarousel(
                                context: context,
                                title: isTamil ? 'சரிபார்க்கப்பட்ட வரன்கள்' : 'Verified Matches',
                                subtitle: isTamil ? 'அரசு அடையாள அட்டை சரிபார்க்கப்பட்டது' : '100% ID Verified profiles',
                                matches: homeData.verifiedMatches,
                                isLoading: homeData.isLoading,
                              ),

                            // Recently Viewed (Hidden when empty)
                            if (homeData.recentlyViewed.isNotEmpty)
                              _buildMatchesCarousel(
                                context: context,
                                title: isTamil ? 'சமீபத்தில் பார்த்தவை' : 'Recently Viewed',
                                subtitle: isTamil ? 'நீங்கள் பார்த்த வரன்கள்' : 'Profiles you viewed recently',
                                matches: homeData.recentlyViewed,
                                isLoading: homeData.isLoading,
                              ),
                          ] else ...[
                            // PRIME Mode Body: Only Verified Matches
                            _buildPrimeBanner(context),
                            _buildMatchesCarousel(
                              context: context,
                              title: 'PRIME Verified Profiles',
                              subtitle: '100% Government ID-verified authentic members',
                              matches: homeData.verifiedMatches,
                              isLoading: homeData.isLoading,
                              onViewAll: () {
                                widget.onSwitchTab?.call(1);
                              },
                            ),
                          ],

                          // Upgrade Banner for Free Members (hidden for paid members)
                          if (!entitlements.isPaid)
                            _buildUpgradeBanner(context),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sticky Header (§1.2) ---
  Widget _buildStickyHeader({
    required BuildContext context,
    required ProfileModel? profile,
    required Entitlements entitlements,
    required bool isTamil,
    required int unreadCount,
    required bool hasNewVerified,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9), // Light mint green
            Color(0xFFC8E6C9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Segmented Pill (Regular | PRIME), Language Toggle, Search
              Row(
                children: [
                  // Segmented pill Regular | PRIME
                  Container(
                    height: 36,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSegmentButton(
                          label: isTamil ? 'ரெகுலர்' : 'Regular',
                          isActive: _currentMode == HomeMode.regular,
                          onTap: () => _onModeChanged(HomeMode.regular),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildSegmentButton(
                              label: isTamil ? 'ப்ரைம்' : 'PRIME',
                              isActive: _currentMode == HomeMode.prime,
                              onTap: () => _onModeChanged(HomeMode.prime),
                              isGold: true,
                            ),
                            if (hasNewVerified)
                              Positioned(
                                top: 2,
                                right: 6,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Language Toggle Button (அ / A) (§7)
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.saffronOrange),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Text(
                              isTamil ? 'A' : 'அ',
                              style: const TextStyle(
                                color: AppColors.saffronOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isTamil ? 'ENG' : 'தமிழ்',
                              style: const TextStyle(
                                color: AppColors.saffronOrange,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Search Icon
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
                    onPressed: () => context.push('/search'),
                    tooltip: 'Search',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Row 2: Avatar, Name & Brand Line, Membership Label, Upgrade Chip, Notification Bell, Hamburger Menu
              Row(
                children: [
                  // Circular Avatar
                  GestureDetector(
                    onTap: () {
                      if (profile?.primaryPhoto == null || profile!.primaryPhoto!.isEmpty) {
                        AddPhotoPromptSheet.show(context);
                      } else {
                        context.push('/my-profile');
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          imageUrl: profile?.primaryPhoto,
                          gender: profile?.gender ?? 'Female',
                          name: profile?.name ?? 'Member',
                          radius: 20,
                          isVerified: profile?.isVerified ?? false,
                        ),
                        if (profile?.primaryPhoto == null || profile!.primaryPhoto!.isEmpty)
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: AppColors.saffronOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name & Membership details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name.isNotEmpty == true ? profile!.name : 'Pondy Connect Member',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              _getMembershipLabel(entitlements),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: entitlements.isPaid ? Colors.green.shade800 : AppColors.textSecondary,
                              ),
                            ),
                            if (!entitlements.isPaid) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => context.push('/upgrade'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.saffronOrange),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.workspace_premium, size: 10, color: AppColors.saffronOrange),
                                      SizedBox(width: 2),
                                      Text(
                                        'Upgrade',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.saffronOrange),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notification Bell with badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 22),
                        onPressed: () => context.push('/notifications'),
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 6),

                  // Hamburger Menu
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 24),
                    onPressed: () => _openHamburgerMenu(context, profile),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isGold = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? (isGold ? const Color(0xFF2E7D32) : AppColors.saffronOrange)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _getMembershipLabel(Entitlements e) {
    switch (e.tier) {
      case 'gold':
        return 'Gold Member';
      case 'prime_gold':
        return 'Prime Gold Member';
      case 'till_u_marry':
        return 'Prime – Till U Marry';
      default:
        return 'Free Member';
    }
  }

  // --- Daily Recommendations Entry Card (§2) ---
  Widget _buildDailyRecommendationsEntryCard(BuildContext context, HomeDashboardData homeData) {
    final count = homeData.dailyRecommendations.length;
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          DailyRecommendationsModal.show(context, recommendations: homeData.dailyRecommendations);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.saffronOrange.withAlpha(80)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.saffronOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Today\'s Recommendations ($count)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Handpicked compatible matches for you today',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.saffronOrange),
            ],
          ),
        ),
      ),
    );
  }

  // --- Success Stories (§1.3) ---
  Widget _buildSuccessStoriesSection(BuildContext context, List<SuccessStoryModel> stories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text('Success Stories', style: AppTypography.heading3.copyWith(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final s = stories[i];
                return Container(
                  width: 260,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 64,
                          height: 86,
                          color: Colors.green.shade50,
                          child: const Icon(Icons.people_alt, color: AppColors.successGreen, size: 32),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${s.groom} & ${s.bride}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (s.weddingDate.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text('Married: ${s.weddingDate}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            ],
                            if (s.location.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(s.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Horizontal Carousel of Cards ---
  Widget _buildMatchesCarousel({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<MatchResult> matches,
    required bool isLoading,
    bool isNewlyJoined = false,
    bool showDistance = false,
    VoidCallback? onViewAll,
  }) {
    if (matches.isEmpty && !isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.heading3.copyWith(fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View all', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                        Icon(Icons.chevron_right, size: 16, color: AppColors.saffronOrange),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 260,
            child: isLoading
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, __) => const AppSkeleton(width: 160, height: 260, borderRadius: 14),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final match = matches[i];
                      return _buildMiniProfileCard(
                        context: context,
                        match: match,
                        isNewlyJoined: isNewlyJoined,
                        showDistance: showDistance,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Mini Profile Card for Carousels ---
  Widget _buildMiniProfileCard({
    required BuildContext context,
    required MatchResult match,
    bool isNewlyJoined = false,
    bool showDistance = false,
  }) {
    final p = match.profile;
    final distance = LocationService.instance.getDistanceToCandidate(p.profileId, targetDistrict: p.district);

    return InkWell(
      onTap: () => context.push('/profile/${p.profileId}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 4:5 Photo area with watermark
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AspectRatio(
                    aspectRatio: 4 / 3.8,
                    child: PondyWatermark(
                      opacity: 0.18,
                      child: (p.primaryPhoto != null && p.primaryPhoto!.isNotEmpty)
                          ? Image.asset(
                              p.primaryPhoto!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.person, size: 48, color: Colors.grey),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person, size: 48, color: Colors.grey),
                            ),
                    ),
                  ),
                ),

                // Newly Joined Ribbon
                if (isNewlyJoined)
                  Positioned(
                    top: 8,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.saffronOrange,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),

                // Distance Chip
                if (showDistance && distance != null)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        LocationService.instance.formatDistance(distance) ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                // Verified Icon
                if (p.isVerified)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified, size: 14, color: AppColors.successGreen),
                    ),
                  ),
              ],
            ),

            // Card details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.age} yrs, ${_formatHeight(p.heightCm)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.occupation.isNotEmpty ? p.occupation : p.education,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Call / WhatsApp row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          ContactPaywallSheet.show(context, targetProfile: p);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.saffronOrange),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.call_outlined, size: 12, color: AppColors.saffronOrange),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          ContactPaywallSheet.show(context, targetProfile: p);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.successGreen),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.chat_outlined, size: 12, color: AppColors.successGreen),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await ref.read(matchesProvider.notifier).sendInterest(p.profileId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Interest sent to ${p.name}!')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.saffronOrange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Connect', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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

  // --- PRIME Mode Banner ---
  Widget _buildPrimeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user, color: Colors.white, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRIME Verified Matches',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'Profiles verified with government identity proof for maximum trust and authenticity.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Upgrade Banner (§1.3 & §6) ---
  Widget _buildUpgradeBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: AppColors.successGreen, size: 24),
              SizedBox(width: 8),
              Text(
                'Become a Paid Member',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Paid membership lets you connect directly:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          _buildCheckRow('View phone numbers and call / WhatsApp matches'),
          _buildCheckRow('Send personalised messages directly to matches'),
          _buildCheckRow('Unlimited horoscope views and matching reports'),
          _buildCheckRow('View verified member profiles with photos'),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Plans & Upgrade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
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
    return '$ft\'$inch"';
  }
}
