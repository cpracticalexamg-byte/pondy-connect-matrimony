import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../../core/widgets/pondy_logo.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/success_story_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(int tabIndex)? onSwitchTab;

  const HomeScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDashboardProvider);
    final authState = ref.watch(authStateProvider);
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';
    final profile = authState.profile;

    final userName = profile?.name.isNotEmpty == true
        ? profile!.name.split(' ').first
        : (authState.user?.mobile.isNotEmpty == true ? 'Member' : 'Guest');

    final completeness = profile?.completenessPct ?? 70;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 16,
        title: Row(
          children: [
            const PondyLogo(size: 32, showText: false),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pondy Connect',
                  style: AppTypography.heading3.copyWith(fontSize: 16, color: AppColors.saffronOrange),
                ),
                Text(
                  profile?.profileId.isNotEmpty == true ? profile!.profileId : 'Matrimony',
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switch
          TextButton(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.saffronOrange),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isTamil ? 'EN' : 'தமிழ்',
                style: const TextStyle(
                  color: AppColors.saffronOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Notification Bell
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  context.push('/notifications');
                },
              ),
              if (homeData.unreadNotificationsCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${homeData.unreadNotificationsCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeDashboardProvider.notifier).refreshDashboard(),
        color: AppColors.saffronOrange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Welcome Greeting & Profile Completeness
              _buildGreetingCard(context, userName, completeness, profile?.primaryPhoto),

              // 2. Quick Activity Stats Strip
              _buildStatsStrip(context, homeData),

              // 3. Premium Upgrade Callout Card
              _buildUpgradeCard(context),

              // 4. Daily Recommendations Carousel
              _buildCarouselSection(
                context: context,
                title: 'Daily Recommendations',
                subtitle: 'Hand-picked compatible profiles for you',
                matches: homeData.dailyRecommendations,
                isLoading: homeData.isLoading,
                onSeeAll: () {
                  ref.read(matchesProvider.notifier).setFilterTab(MatchesFilterTab.all);
                  onSwitchTab?.call(1);
                },
              ),

              // 5. New Matches Today Carousel
              _buildCarouselSection(
                context: context,
                title: 'New Matches',
                subtitle: 'Recently registered profiles',
                matches: homeData.newMatches,
                isLoading: homeData.isLoading,
                onSeeAll: () {
                  ref.read(matchesProvider.notifier).setFilterTab(MatchesFilterTab.newToday);
                  onSwitchTab?.call(1);
                },
              ),

              // 6. Nearby in Puducherry Carousel
              _buildCarouselSection(
                context: context,
                title: 'Nearby Puducherry & Surrounds',
                subtitle: 'Profiles located in Puducherry, Karaikal & TN border',
                matches: homeData.nearbyMatches,
                isLoading: homeData.isLoading,
                onSeeAll: () {
                  ref.read(matchesProvider.notifier).setFilterTab(MatchesFilterTab.nearby);
                  onSwitchTab?.call(1);
                },
              ),

              // 7. Success Stories Section
              _buildSuccessStoriesSection(context, homeData.successStories),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(
    BuildContext context,
    String name,
    int completeness,
    String? photoUrl,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfileAvatar(
                imageUrl: photoUrl,
                radius: 28,
                name: name,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vanakkam, $name! 🙏',
                      style: AppTypography.heading3.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find your life partner in Pondy Connect',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (completeness < 100) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.saffronOrange.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.saffronOrange.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: completeness / 100,
                          strokeWidth: 4,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.saffronOrange),
                        ),
                      ),
                      Text(
                        '$completeness%',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.saffronOrange),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile Completeness',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Add horoscope & photos for 3x more interests!',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push('/profile-edit');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Complete', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsStrip(BuildContext context, HomeDashboardData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Matches', '${data.totalMatchesCount}', Icons.favorite_border, AppColors.saffronOrange, () {
            onSwitchTab?.call(1);
          }),
          _buildDivider(),
          _buildStatItem('Interests', '${data.interestsReceivedCount}', Icons.mail_outline, Colors.purple, () {
            context.push('/interests');
          }),
          _buildDivider(),
          _buildStatItem('Shortlisted', '${data.shortlistCount}', Icons.bookmark_border, Colors.blue, () {
            context.push('/shortlist');
          }),
          _buildDivider(),
          _buildStatItem('Porutham', '10', Icons.stars_outlined, Colors.teal, () {
            context.push('/horoscope');
          }),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 28, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2670A), Color(0xFFC75404)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronOrange.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(
                  'View phone numbers & chat directly',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.push('/membership');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.saffronOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: const Text('View Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<MatchResult> matches,
    required bool isLoading,
    required VoidCallback onSeeAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.heading3.copyWith(fontSize: 17)),
                  Text(subtitle, style: AppTypography.caption(color: AppColors.textSecondary)),
                ],
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: isLoading
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: 4,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: AppSkeleton(width: 140, height: 210, borderRadius: 14),
                  ),
                )
              : matches.isEmpty
                  ? Center(child: Text('No profiles in this category', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final m = matches[index];
                        final p = m.profile;

                        return Container(
                          width: 146,
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder.withAlpha(90)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              context.push('/profile-detail/${p.profileId}');
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      ProfileAvatar(
                                        imageUrl: p.primaryPhoto,
                                        gender: p.gender,
                                        name: p.name,
                                        radius: 36,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.saffronOrange,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${m.score}%',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${p.age} yrs • ${p.city}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.occupation,
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.saffronOrange.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'View Profile',
                                      style: TextStyle(color: AppColors.saffronOrange, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSuccessStoriesSection(BuildContext context, List<SuccessStoryModel> stories) {
    if (stories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pondy Connect Success Stories ❤️', style: AppTypography.heading3.copyWith(fontSize: 17)),
              const Text('Couples who found each other through our platform', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade50.withAlpha(120),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          radius: 18,
                          child: const Icon(Icons.favorite, color: Colors.pink, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${story.groom.split('(').first.trim()} & ${story.bride.split('(').first.trim()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${story.location} • Married ${story.weddingDate}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        '"${story.story}"',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontStyle: FontStyle.italic),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
