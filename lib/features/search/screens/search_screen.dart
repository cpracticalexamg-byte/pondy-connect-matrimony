import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_skeleton.dart';
import '../../matches/providers/matches_provider.dart';
import '../../matches/widgets/profile_card.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _idController = TextEditingController();
  bool _showFilters = true;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final matchesState = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Search Matches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (searchState.hasSearched)
            IconButton(
              icon: Icon(_showFilters ? Icons.close : Icons.tune),
              tooltip: _showFilters ? 'Hide Filters' : 'Show Filters',
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: () {
              _idController.clear();
              notifier.resetFilters();
              setState(() {
                _showFilters = true;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Search By Profile ID Bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        hintText: 'Search by Profile ID (e.g. PC000100)',
                        prefixIcon: const Icon(Icons.search, color: AppColors.saffronOrange),
                        suffixIcon: _idController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _idController.clear();
                                  notifier.updateCriteria(searchState.criteria.copyWith(searchById: ''));
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        filled: true,
                        fillColor: AppColors.bgCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) {
                        notifier.updateCriteria(searchState.criteria.copyWith(searchById: val));
                        notifier.executeSearch();
                        setState(() {
                          _showFilters = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      notifier.updateCriteria(searchState.criteria.copyWith(searchById: _idController.text));
                      notifier.executeSearch();
                      setState(() {
                        _showFilters = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffronOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const Text('Go'),
                  ),
                ],
              ),
            ),

            // 2. Filters Form (Collapsible when results are shown)
            if (_showFilters)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filter Profiles', style: AppTypography.heading3.copyWith(fontSize: 16)),
                    const SizedBox(height: 14),

                    // Age Range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Age Range', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${searchState.criteria.ageMin} - ${searchState.criteria.ageMax} yrs',
                            style: const TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(searchState.criteria.ageMin.toDouble(), searchState.criteria.ageMax.toDouble()),
                      min: 18,
                      max: 60,
                      divisions: 42,
                      activeColor: AppColors.saffronOrange,
                      onChanged: (vals) {
                        notifier.updateCriteria(searchState.criteria.copyWith(
                          ageMin: vals.start.round(),
                          ageMax: vals.end.round(),
                        ));
                      },
                    ),

                    const SizedBox(height: 12),

                    // Religion Selector
                    const Text('Religion', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'Hindu', 'Christian', 'Muslim', 'Jain'].map((rel) {
                          final isSelected = searchState.criteria.religion.toLowerCase() == rel.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(rel == 'all' ? 'All Religions' : rel),
                              selected: isSelected,
                              selectedColor: AppColors.saffronOrange.withAlpha(40),
                              checkmarkColor: AppColors.saffronOrange,
                              onSelected: (_) {
                                notifier.updateCriteria(searchState.criteria.copyWith(religion: rel));
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // District Selector
                    const Text('District / Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'Puducherry', 'Karaikal', 'Villupuram', 'Cuddalore', 'Chennai'].map((dist) {
                          final isSelected = searchState.criteria.district.toLowerCase() == dist.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(dist == 'all' ? 'All Districts' : dist),
                              selected: isSelected,
                              selectedColor: AppColors.saffronOrange.withAlpha(40),
                              checkmarkColor: AppColors.saffronOrange,
                              onSelected: (_) {
                                notifier.updateCriteria(searchState.criteria.copyWith(district: dist));
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Marital Status
                    const Text('Marital Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['all', 'Never Married', 'Divorced', 'Widowed'].map((stat) {
                          final isSelected = searchState.criteria.maritalStatus.toLowerCase() == stat.toLowerCase();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(stat == 'all' ? 'Any Status' : stat),
                              selected: isSelected,
                              selectedColor: AppColors.saffronOrange.withAlpha(40),
                              checkmarkColor: AppColors.saffronOrange,
                              onSelected: (_) {
                                notifier.updateCriteria(searchState.criteria.copyWith(maritalStatus: stat));
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Photo Only Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Profiles with Photo only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      activeColor: AppColors.saffronOrange,
                      value: searchState.criteria.photoOnly,
                      onChanged: (val) {
                        notifier.updateCriteria(searchState.criteria.copyWith(photoOnly: val));
                      },
                    ),

                    const SizedBox(height: 16),

                    // Search Button
                    AppButton(
                      text: 'Search Matches',
                      icon: Icons.search,
                      onPressed: () {
                        notifier.executeSearch();
                        setState(() {
                          _showFilters = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // 3. Search Results Section
            if (searchState.isLoading) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppSkeleton(height: 180, borderRadius: 16),
              ),
            ] else if (searchState.hasSearched) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Found ${searchState.results.length} Matches',
                      style: AppTypography.heading3.copyWith(fontSize: 16),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.tune, size: 16, color: AppColors.saffronOrange),
                      label: const Text('Edit Filter', style: TextStyle(color: AppColors.saffronOrange, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() {
                          _showFilters = true;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (searchState.results.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 56, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      Text('No profiles match these filters', style: AppTypography.heading3),
                      const SizedBox(height: 6),
                      Text(
                        'Try expanding the age range or selecting All Districts / Religions.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          notifier.resetFilters();
                          setState(() {
                            _showFilters = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronOrange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Reset All Filters'),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchState.results.length,
                  itemBuilder: (context, index) {
                    final match = searchState.results[index];
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
                        final added = await ref.read(matchesProvider.notifier).toggleShortlist(match.profile.profileId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(added ? 'Saved to shortlist' : 'Removed from shortlist'), duration: const Duration(seconds: 2)),
                          );
                        }
                      },
                      onSendInterest: () async {
                        await ref.read(matchesProvider.notifier).sendInterest(match.profile.profileId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Interest sent to ${match.profile.name}!'),
                              backgroundColor: AppColors.successGreen,
                              duration: const Duration(seconds: 2),
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
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
