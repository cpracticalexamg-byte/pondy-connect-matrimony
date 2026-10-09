import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../../matches/providers/matches_provider.dart';

class ShortlistScreen extends ConsumerStatefulWidget {
  const ShortlistScreen({super.key});

  @override
  ConsumerState<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends ConsumerState<ShortlistScreen> {
  bool _isLoading = true;
  List<ProfileModel> _shortlisted = [];

  @override
  void initState() {
    super.initState();
    _loadShortlist();
  }

  Future<void> _loadShortlist() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authStateProvider);
      final myProfileId = authState.profile?.profileId ?? '';
      final shortlistRepo = ref.read(shortlistRepoProvider);

      final list = myProfileId.isNotEmpty ? await shortlistRepo.getShortlistedProfiles(myProfileId) : <ProfileModel>[];
      if (mounted) {
        setState(() {
          _shortlisted = list;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load shortlisted profiles', tag: 'ShortlistScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text('Shortlisted Profiles (${_shortlisted.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : _shortlisted.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bookmark_border, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 14),
                        Text('No shortlisted profiles yet', style: AppTypography.heading3),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap the heart icon on any profile to shortlist them for quick access later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffronOrange, foregroundColor: Colors.white),
                          child: const Text('Explore Matches'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _shortlisted.length,
                  itemBuilder: (context, index) {
                    final p = _shortlisted[index];
                    final isSent = matchesState.sentInterestIds.contains(p.profileId);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        onTap: () => context.push('/profile-detail/${p.profileId}'),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ProfileAvatar(
                                imageUrl: p.primaryPhoto,
                                gender: p.gender,
                                name: p.name,
                                radius: 30,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${p.age} yrs • ${p.occupation}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                    ),
                                    Text(
                                      '${p.religion} • ${p.city}',
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                                    tooltip: 'Remove',
                                    onPressed: () async {
                                      await ref.read(matchesProvider.notifier).toggleShortlist(p.profileId);
                                      _loadShortlist();
                                    },
                                  ),
                                  TextButton(
                                    onPressed: isSent
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
                                    child: Text(
                                      isSent ? 'Sent ✓' : 'Connect',
                                      style: TextStyle(
                                        color: isSent ? AppColors.successGreen : AppColors.saffronOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
