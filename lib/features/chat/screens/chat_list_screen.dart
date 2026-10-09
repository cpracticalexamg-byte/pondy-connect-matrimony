import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/message_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _threads = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authStateProvider);
      final myProfileId = authState.profile?.profileId ?? '';
      final chatRepo = ref.read(chatRepoProvider);
      final profileRepo = ref.read(profileRepoProvider);

      if (myProfileId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final partnerIds = await chatRepo.getChatPartnerIds(myProfileId);
      final List<Map<String, dynamic>> threads = [];

      for (final pid in partnerIds) {
        final profile = await profileRepo.getProfileById(pid);
        final threadId = (chatRepo as CsvChatRepository).getThreadId(myProfileId, pid);
        final messages = await chatRepo.getMessages(threadId);
        final lastMsg = messages.isNotEmpty ? messages.last : null;

        threads.add({
          'profile': profile,
          'partnerId': pid,
          'lastMessage': lastMsg,
        });
      }

      if (mounted) {
        setState(() {
          _threads = threads;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load chat threads', tag: 'ChatListScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : _threads.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 14),
                        Text('No active conversations yet', style: AppTypography.heading3),
                        const SizedBox(height: 6),
                        const Text(
                          'Once you or your matches accept interests, you can chat directly right here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.push('/matches'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.saffronOrange, foregroundColor: Colors.white),
                          child: const Text('Browse Compatible Matches'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _threads.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                  itemBuilder: (context, index) {
                    final item = _threads[index];
                    final ProfileModel? profile = item['profile'];
                    final String partnerId = item['partnerId'];
                    final MessageModel? lastMsg = item['lastMessage'];

                    final name = profile?.name ?? partnerId;
                    final time = lastMsg != null ? lastMsg.sentAt.split('T').first : '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: ProfileAvatar(
                        imageUrl: profile?.primaryPhoto,
                        gender: profile?.gender ?? 'Female',
                        name: name,
                        radius: 26,
                        isOnline: true,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                        ],
                      ),
                      subtitle: Text(
                        lastMsg?.text ?? 'Start conversation...',
                        style: TextStyle(
                          color: lastMsg != null ? AppColors.textSecondary : AppColors.saffronOrange,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () async {
                        await context.push('/chat/$partnerId');
                        _loadChats();
                      },
                    );
                  },
                ),
    );
  }
}
