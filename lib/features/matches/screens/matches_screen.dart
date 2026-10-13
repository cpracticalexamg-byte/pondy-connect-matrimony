import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../providers/matches_provider.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/more_menu_sheet.dart';
import '../widgets/occupation_chips_strip.dart';
import '../widgets/profile_card.dart';
import '../widgets/sort_sheet.dart';

class MatchesScreen extends ConsumerWidget {
  const MatchesScreen({super.key});

  String _getSortDisplayName(String code) {
    switch (code) {
      case 'date_created':
        return 'Date created';
      case 'distance':
        return 'Distance';
      case 'latest_photos':
        return 'Latest photos';
      case 'best_match':
        return 'Best match';
      case 'last_active':
      default:
        return 'Last active';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesState = ref.watch(matchesProvider);
    final notifier = ref.read(matchesProvider.notifier);
    final displayedList = matchesState.filteredMatches;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Matches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          // Filter button in AppBar
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.textPrimary),
                tooltip: 'Filters',
                onPressed: () => _openFilterSheet(context, ref),
              ),
              if (matchesState.totalActiveFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.saffronOrange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${matchesState.totalActiveFilterCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            tooltip: 'Options',
            onSelected: (value) {
              if (value == 'clear') {
                notifier.clearAllFilters();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filters cleared'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'save') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search criteria saved'), duration: Duration(seconds: 1)),
                );
              } else if (value == 'share') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share search link copied'), duration: Duration(seconds: 1)),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'save', child: Text('Save this search')),
              const PopupMenuItem(value: 'clear', child: Text('Clear filters')),
              const PopupMenuItem(value: 'share', child: Text('Share search')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                // All Matches Tab
                _buildTopTab(
                  label: 'All matches',
                  isSelected: matchesState.currentTab == MatchesFilterTab.all && matchesState.activeMoreQueryCode == null,
                  onTap: () {
                    notifier.clearMoreQuery();
                    notifier.setFilterTab(MatchesFilterTab.all);
                  },
                ),
                const SizedBox(width: 10),
                // Newly Joined Tab
                _buildTopTab(
                  label: 'Newly joined',
                  isSelected: matchesState.currentTab == MatchesFilterTab.newlyJoined && matchesState.activeMoreQueryCode == null,
                  onTap: () {
                    notifier.clearMoreQuery();
                    notifier.setFilterTab(MatchesFilterTab.newlyJoined);
                  },
                ),
                const SizedBox(width: 10),
                // More ▾ Tab
                _buildTopTab(
                  label: matchesState.activeMoreQueryTitle ?? 'More ▾',
                  isSelected: matchesState.activeMoreQueryCode != null,
                  icon: matchesState.activeMoreQueryCode != null ? Icons.check : Icons.arrow_drop_down,
                  onTap: () {
                    MoreMenuSheet.show(
                      context,
                      onSelectQuery: (code, title) {
                        notifier.selectMoreQuery(code, title);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Subheader: Live count + active query / filter status
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    matchesState.activeMoreQueryTitle != null
                        ? '${displayedList.length} ${matchesState.activeMoreQueryTitle}'
                        : '${displayedList.length} Matches based on your preferences',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (matchesState.hasActiveFilters)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.close, size: 14, color: AppColors.saffronOrange),
                    label: const Text(
                      'Show all',
                      style: TextStyle(fontSize: 12, color: AppColors.saffronOrange, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => notifier.clearAllFilters(),
                  ),
              ],
            ),
          ),

          // Scrollable Chip Row (§3.1)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // Filter trigger chip
                  ActionChip(
                    avatar: const Icon(Icons.tune, size: 15, color: AppColors.textPrimary),
                    label: Text(
                      matchesState.totalActiveFilterCount > 0 ? 'Filter (${matchesState.totalActiveFilterCount})' : 'Filter',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: matchesState.totalActiveFilterCount > 0 ? AppColors.saffronOrange.withAlpha(30) : Colors.grey.shade100,
                    side: BorderSide(
                      color: matchesState.totalActiveFilterCount > 0 ? AppColors.saffronOrange : Colors.grey.shade300,
                    ),
                    onPressed: () => _openFilterSheet(context, ref),
                  ),
                  const SizedBox(width: 8),

                  // Sort by ▾ trigger chip
                  ActionChip(
                    avatar: const Icon(Icons.sort, size: 15, color: AppColors.textPrimary),
                    label: Text(
                      'Sort: ${_getSortDisplayName(matchesState.sortOrder)} ▾',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade300),
                    onPressed: () {
                      SortSheet.show(
                        context,
                        currentSort: matchesState.sortOrder,
                        onApply: (sort) => notifier.setSortOrder(sort),
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Active Occupation Chips (Removable e.g. "Occupation: Doctor ✕")
                  ...matchesState.selectedOccupations.map((code) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InputChip(
                        label: Text('Occupation: ${_capitalize(code)}'),
                        labelStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        backgroundColor: AppColors.saffronOrange,
                        deleteIconColor: Colors.white,
                        onDeleted: () => notifier.toggleOccupationFilter(code),
                      ),
                    );
                  }),

                  // Quick toggle chips
                  FilterChip(
                    label: const Text('Profiles with photo'),
                    selected: matchesState.filterPhotoOnly,
                    selectedColor: AppColors.saffronOrange.withAlpha(40),
                    checkmarkColor: AppColors.saffronOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: matchesState.filterPhotoOnly ? AppColors.saffronOrange : AppColors.textPrimary,
                    ),
                    onSelected: (_) => notifier.togglePhotoFilter(),
                  ),
                  const SizedBox(width: 8),

                  FilterChip(
                    label: const Text('Verified'),
                    selected: matchesState.filterVerifiedOnly,
                    selectedColor: AppColors.saffronOrange.withAlpha(40),
                    checkmarkColor: AppColors.saffronOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: matchesState.filterVerifiedOnly ? AppColors.saffronOrange : AppColors.textPrimary,
                    ),
                    onSelected: (_) => notifier.toggleVerifiedFilter(),
                  ),
                  const SizedBox(width: 8),

                  FilterChip(
                    label: const Text('Nearby'),
                    selected: matchesState.filterNearbyOnly,
                    selectedColor: AppColors.saffronOrange.withAlpha(40),
                    checkmarkColor: AppColors.saffronOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: matchesState.filterNearbyOnly ? AppColors.saffronOrange : AppColors.textPrimary,
                    ),
                    onSelected: (_) => notifier.toggleNearbyFilter(),
                  ),
                  const SizedBox(width: 8),

                  FilterChip(
                    label: const Text('Not seen'),
                    selected: matchesState.filterNotSeenOnly,
                    selectedColor: AppColors.saffronOrange.withAlpha(40),
                    checkmarkColor: AppColors.saffronOrange,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: matchesState.filterNotSeenOnly ? AppColors.saffronOrange : AppColors.textPrimary,
                    ),
                    onSelected: (_) => notifier.toggleNotSeenFilter(),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal Occupation Quick Filter Strip (§3.5)
          OccupationChipsStrip(
            selectedOccupations: matchesState.selectedOccupations,
            onToggleOccupation: (code) => notifier.toggleOccupationFilter(code),
            onSameProfession: () => notifier.selectSameProfessionAsMe(),
            onMore: () => _openFilterSheet(context, ref),
          ),

          // Main List of Profiles
          Expanded(
            child: matchesState.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: 4,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: AppSkeleton(
                        height: 320,
                        borderRadius: 16,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => notifier.loadMatches(),
                    color: AppColors.saffronOrange,
                    child: displayedList.isEmpty
                        ? ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No matches found',
                                      style: AppTypography.heading3,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters or switching to All Matches.',
                                      style: AppTypography.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.saffronOrange,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => notifier.clearAllFilters(),
                                      child: const Text('Show All Matches'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: displayedList.length,
                            itemBuilder: (context, index) {
                              final match = displayedList[index];
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
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(matchesProvider);
    final notifier = ref.read(matchesProvider.notifier);

    FilterSheet.show(
      context,
      initialCriteria: state.filterCriteria,
      initialOccupations: state.selectedOccupations,
      initialPhotoOnly: state.filterPhotoOnly,
      initialVerifiedOnly: state.filterVerifiedOnly,
      initialNotSeenOnly: state.filterNotSeenOnly,
      initialNearbyOnly: state.filterNearbyOnly,
      onApply: ({
        required criteria,
        required occupations,
        required photoOnly,
        required verifiedOnly,
        required notSeenOnly,
        required nearbyOnly,
      }) {
        notifier.applyFilterCriteria(criteria);
        // Sync toggles and occupations
        for (final occ in occupations) {
          if (!state.selectedOccupations.contains(occ)) notifier.toggleOccupationFilter(occ);
        }
        for (final occ in state.selectedOccupations) {
          if (!occupations.contains(occ)) notifier.toggleOccupationFilter(occ);
        }
        if (photoOnly != state.filterPhotoOnly) notifier.togglePhotoFilter();
        if (verifiedOnly != state.filterVerifiedOnly) notifier.toggleVerifiedFilter();
        if (notSeenOnly != state.filterNotSeenOnly) notifier.toggleNotSeenFilter();
        if (nearbyOnly != state.filterNearbyOnly) notifier.toggleNearbyFilter();
      },
    );
  }

  Widget _buildTopTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffronOrange : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.saffronOrange : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textPrimary),
            ],
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
