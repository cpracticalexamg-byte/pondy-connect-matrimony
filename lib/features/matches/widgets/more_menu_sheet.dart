import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class MoreMenuItem {
  final String code;
  final String title;
  final String subtitle;
  final IconData icon;

  const MoreMenuItem({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class MoreMenuGroup {
  final String title;
  final List<MoreMenuItem> items;

  const MoreMenuGroup({
    required this.title,
    required this.items,
  });
}

class MoreMenuSheet extends ConsumerWidget {
  final void Function(String queryCode, String titleEn) onSelectQuery;

  const MoreMenuSheet({
    super.key,
    required this.onSelectQuery,
  });

  static Future<void> show(
    BuildContext context, {
    required void Function(String queryCode, String titleEn) onSelectQuery,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MoreMenuSheet(onSelectQuery: onSelectQuery),
    );
  }

  static const List<MoreMenuGroup> groups = [
    MoreMenuGroup(
      title: 'Based on activity',
      items: [
        MoreMenuItem(
          code: 'shortlisted_you',
          title: 'Shortlisted you',
          subtitle: 'Profiles that added you to shortlist',
          icon: Icons.bookmark_added_outlined,
        ),
        MoreMenuItem(
          code: 'viewed_you',
          title: 'Viewed you',
          subtitle: 'Profiles that viewed your profile',
          icon: Icons.visibility_outlined,
        ),
        MoreMenuItem(
          code: 'shortlisted_by_you',
          title: 'Shortlisted by you',
          subtitle: 'Profiles you added to shortlist',
          icon: Icons.bookmark_border_outlined,
        ),
        MoreMenuItem(
          code: 'viewed_by_you',
          title: 'Viewed by you',
          subtitle: 'Profiles you have viewed',
          icon: Icons.remove_red_eye_outlined,
        ),
      ],
    ),
    MoreMenuGroup(
      title: 'Recently joined & nearby matches',
      items: [
        MoreMenuItem(
          code: 'newly_joined',
          title: 'Newly joined',
          subtitle: 'Joined within the last 30 days',
          icon: Icons.fiber_new_outlined,
        ),
        MoreMenuItem(
          code: 'nearby_matches',
          title: 'Nearby matches',
          subtitle: 'Matches near your location',
          icon: Icons.near_me_outlined,
        ),
      ],
    ),
    MoreMenuGroup(
      title: 'Based on profile details',
      items: [
        MoreMenuItem(
          code: 'photo_matches',
          title: 'Photo matches',
          subtitle: 'Profiles with photos added',
          icon: Icons.photo_camera_outlined,
        ),
        MoreMenuItem(
          code: 'horoscope_matches',
          title: 'Matches with horoscope',
          subtitle: 'Profiles that have added horoscope',
          icon: Icons.auto_awesome_outlined,
        ),
        MoreMenuItem(
          code: 'verified_matches',
          title: 'Verified matches',
          subtitle: 'Government ID verified profiles',
          icon: Icons.verified_user_outlined,
        ),
      ],
    ),
    MoreMenuGroup(
      title: 'Based on astrological compatibility',
      items: [
        MoreMenuItem(
          code: 'star_matches',
          title: 'Star matches',
          subtitle: 'Compatible star sign',
          icon: Icons.stars_outlined,
        ),
        MoreMenuItem(
          code: 'porutham_10_matches',
          title: 'Horoscope matches',
          subtitle: 'Horoscope matching yours — 10-porutham threshold',
          icon: Icons.brightness_7_outlined,
        ),
      ],
    ),
    MoreMenuGroup(
      title: 'Members who are looking for someone like you',
      items: [
        MoreMenuItem(
          code: 'mutual_matches',
          title: 'Mutual matches',
          subtitle: 'Their profile matches your preferences and vice versa',
          icon: Icons.swap_horiz_outlined,
        ),
        MoreMenuItem(
          code: 'looking_for_you',
          title: 'Looking for you',
          subtitle: 'Their preferences match your profile',
          icon: Icons.person_search_outlined,
        ),
      ],
    ),
    MoreMenuGroup(
      title: 'Matches based on preferences',
      items: [
        MoreMenuItem(
          code: 'education_pref',
          title: 'Education preference',
          subtitle: 'Matches based on your education preferences',
          icon: Icons.school_outlined,
        ),
        MoreMenuItem(
          code: 'professional_pref',
          title: 'Professional preference',
          subtitle: 'Matches based on your occupation preferences',
          icon: Icons.work_outline,
        ),
        MoreMenuItem(
          code: 'location_pref',
          title: 'City/location preference',
          subtitle: 'Matches in your preferred locations',
          icon: Icons.location_city_outlined,
        ),
        MoreMenuItem(
          code: 'nri_matches',
          title: 'NRI matches',
          subtitle: 'Matches living outside India',
          icon: Icons.flight_takeoff_outlined,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height * 0.90;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.explore_outlined, color: AppColors.saffronOrange, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Explore More Matches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable list of sections
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: groups.length,
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Text(
                        group.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: group.items.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;
                          final isLast = idx == group.items.length - 1;

                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Icon(item.icon, color: AppColors.saffronOrange, size: 20),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  item.subtitle,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  onSelectQuery(item.code, item.title);
                                },
                              ),
                              if (!isLast)
                                Divider(
                                  height: 1,
                                  indent: 64,
                                  endIndent: 16,
                                  color: Colors.grey.shade200,
                                ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom dismiss scrim & ✕ button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
