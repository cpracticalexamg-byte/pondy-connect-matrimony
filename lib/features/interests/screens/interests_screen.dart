import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/interest_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class InterestsScreen extends ConsumerStatefulWidget {
  const InterestsScreen({super.key});

  @override
  ConsumerState<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends ConsumerState<InterestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<InterestModel> _received = [];
  List<InterestModel> _sent = [];
  final Map<String, ProfileModel> _profileCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInterests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authStateProvider);
      final myProfileId = authState.profile?.profileId ?? '';

      final interestRepo = ref.read(interestRepoProvider);
      final profileRepo = ref.read(profileRepoProvider);

      final received = myProfileId.isNotEmpty ? await interestRepo.getReceivedInterests(myProfileId) : <InterestModel>[];
      final sent = myProfileId.isNotEmpty ? await interestRepo.getSentInterests(myProfileId) : <InterestModel>[];

      // Fetch related profiles
      final neededIds = {...received.map((i) => i.fromProfile), ...sent.map((i) => i.toProfile)};
      for (final id in neededIds) {
        if (!_profileCache.containsKey(id)) {
          final p = await profileRepo.getProfileById(id);
          if (p != null) _profileCache[id] = p;
        }
      }

      if (mounted) {
        setState(() {
          _received = received;
          _sent = sent;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load interests', tag: 'InterestsScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingReceived = _received.where((i) => i.status == 'sent').toList();
    final acceptedReceived = _received.where((i) => i.status == 'accepted').toList();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Interests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.saffronOrange,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.saffronOrange,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Received (${pendingReceived.length})'),
            Tab(text: 'Accepted (${acceptedReceived.length})'),
            Tab(text: 'Sent (${_sent.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Pending Received
                _buildInterestList(
                  items: pendingReceived,
                  isReceived: true,
                  emptyMessage: 'No pending interests received yet',
                ),
                // 2. Accepted
                _buildInterestList(
                  items: acceptedReceived,
                  isReceived: true,
                  isAcceptedTab: true,
                  emptyMessage: 'No accepted connections yet',
                ),
                // 3. Sent
                _buildInterestList(
                  items: _sent,
                  isReceived: false,
                  emptyMessage: 'You haven\'t sent any interests yet',
                ),
              ],
            ),
    );
  }

  Widget _buildInterestList({
    required List<InterestModel> items,
    required bool isReceived,
    bool isAcceptedTab = false,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline, size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text(emptyMessage, style: AppTypography.heading3.copyWith(fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Send interests to compatible profiles from the Matches tab.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final targetProfileId = isReceived ? item.fromProfile : item.toProfile;
        final profile = _profileCache[targetProfileId];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProfileAvatar(
                      imageUrl: profile?.primaryPhoto,
                      gender: profile?.gender ?? 'Female',
                      name: profile?.name ?? targetProfileId,
                      radius: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? targetProfileId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (profile != null)
                            Text(
                              '${profile.age} yrs • ${profile.occupation} • ${profile.city}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          Text(
                            'Sent: ${item.sentAt.split('T').first}',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (!isReceived)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == 'accepted'
                              ? Colors.green.shade50
                              : (item.status == 'declined' ? Colors.red.shade50 : Colors.orange.shade50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: item.status == 'accepted'
                                ? Colors.green.shade800
                                : (item.status == 'declined' ? Colors.red.shade800 : Colors.orange.shade800),
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.message.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${item.message}"',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.push('/profile-detail/$targetProfileId');
                      },
                      child: const Text('View Profile'),
                    ),
                    if (isReceived && item.status == 'sent') ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () async {
                          await ref.read(interestRepoProvider).declineInterest(item.interestId);
                          _loadInterests();
                        },
                        child: const Text('Decline'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await ref.read(interestRepoProvider).acceptInterest(item.interestId);
                          _loadInterests();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Interest accepted! You can now chat directly.'),
                                backgroundColor: AppColors.successGreen,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ] else if (isAcceptedTab || item.status == 'accepted') ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Chat Now'),
                        onPressed: () {
                          context.push('/chat/$targetProfileId');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.saffronOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
