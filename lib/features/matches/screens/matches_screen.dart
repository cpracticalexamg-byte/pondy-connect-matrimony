import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../providers/matches_provider.dart';
import '../widgets/profile_card.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesProvider);
    final notifier = ref.read(matchesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Matches for You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // Sort Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: AppColors.textPrimary),
            tooltip: 'Sort by',
            onSelected: (value) => notifier.setSortOrder(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'relevance', child: Text('Best Match / Relevance')),
              const PopupMenuItem(value: 'newest', child: Text('Newest First')),
              const PopupMenuItem(value: 'age', child: Text('Age: Low to High')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
            tooltip: 'Filters',
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip(
                    context,
                    label: 'All (${matchesState.allMatches.length})',
                    isSelected: matchesState.currentTab == MatchesFilterTab.all,
                    onTap: () => notifier.setFilterTab(MatchesFilterTab.all),
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context,
                    label: 'New Today',
                    isSelected: matchesState.currentTab == MatchesFilterTab.newToday,
                    onTap: () => notifier.setFilterTab(MatchesFilterTab.newToday),
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context,
                    label: 'Nearby Pondy',
                    isSelected: matchesState.currentTab == MatchesFilterTab.nearby,
                    onTap: () => notifier.setFilterTab(MatchesFilterTab.nearby),
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context,
                    label: 'Mutual 70%+',
                    isSelected: matchesState.currentTab == MatchesFilterTab.mutual,
                    onTap: () => notifier.setFilterTab(MatchesFilterTab.mutual),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: matchesState.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AppSkeleton(
                  height: 180,
                  borderRadius: 16,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => notifier.loadMatches(),
              color: AppColors.saffronOrange,
              child: matchesState.filteredMatches.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No matches found in this tab',
                              style: AppTypography.heading3,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try switching to All Matches or broadening your partner preferences.',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.saffronOrange,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => notifier.setFilterTab(MatchesFilterTab.all),
                              child: const Text('View All Matches'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: matchesState.filteredMatches.length,
                      itemBuilder: (context, index) {
                        final match = matchesState.filteredMatches[index];
                        final isShortlisted = matchesState.shortlistedIds.contains(match.profile.profileId);
                        final isInterestSent = matchesState.sentInterestIds.contains(match.profile.profileId);

                        return ProfileCard(
                          match: match,
                          isShortlisted: isShortlisted,
                          isInterestSent: isInterestSent,
                          onTap: () {
                            context.push('/profile-detail/${match.profile.profileId}');
                          },
                          onShortlistToggle: () async {
                            final added = await notifier.toggleShortlist(match.profile.profileId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(added ? 'Saved to shortlist' : 'Removed from shortlist'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          onSendInterest: () async {
                            await notifier.sendInterest(match.profile.profileId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Interest sent to ${match.profile.name}!'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: AppColors.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          onChat: () {
                            context.push('/chat/${match.profile.profileId}');
                          },
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildTabChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronOrange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.saffronOrange : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
