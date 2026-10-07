import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/message_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String partnerProfileId;

  const ChatConversationScreen({super.key, required this.partnerProfileId});

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ProfileModel? _partnerProfile;
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    // Poll every 1.5s to capture simulated replies
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _pollNewMessages();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    try {
      final profileRepo = ref.read(profileRepoProvider);
      final chatRepo = ref.read(chatRepoProvider);
      final authState = ref.read(authStateProvider);

      final partner = await profileRepo.getProfileById(widget.partnerProfileId);
      final myProfileId = authState.profile?.profileId ?? '';

      List<MessageModel> msgs = [];
      if (myProfileId.isNotEmpty) {
        final threadId = (chatRepo as CsvChatRepository).getThreadId(myProfileId, widget.partnerProfileId);
        msgs = await chatRepo.getMessages(threadId);
        await chatRepo.markThreadRead(threadId, myProfileId);
      }

      setState(() {
        _partnerProfile = partner;
        _messages = msgs;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pollNewMessages() async {
    final authState = ref.read(authStateProvider);
    final myProfileId = authState.profile?.profileId ?? '';
    if (myProfileId.isEmpty) return;

    final chatRepo = ref.read(chatRepoProvider);
    final threadId = (chatRepo as CsvChatRepository).getThreadId(myProfileId, widget.partnerProfileId);
    final msgs = await chatRepo.getMessages(threadId);

    if (msgs.length != _messages.length) {
      setState(() {
        _messages = msgs;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();
    final authState = ref.read(authStateProvider);
    final myProfileId = authState.profile?.profileId ?? 'PC_USER';

    final chatRepo = ref.read(chatRepoProvider);
    final sent = await chatRepo.sendMessage(myProfileId, widget.partnerProfileId, text);

    setState(() {
      _messages.add(sent);
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final partnerName = _partnerProfile?.name ?? widget.partnerProfileId;
    final authState = ref.watch(authStateProvider);
    final myProfileId = authState.profile?.profileId ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 0,
        title: InkWell(
          onTap: () {
            context.push('/profile-detail/${widget.partnerProfileId}');
          },
          child: Row(
            children: [
              ProfileAvatar(
                imageUrl: _partnerProfile?.primaryPhoto,
                gender: _partnerProfile?.gender ?? 'Female',
                name: partnerName,
                radius: 20,
                isOnline: true,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const Text(
                    'Online • Tap to view profile',
                    style: TextStyle(fontSize: 11, color: AppColors.successGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppColors.saffronOrange),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Direct calling available for Premium members.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppColors.saffronOrange),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video calling available for Verified profiles.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Safety Tip Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Stay safe: Never share bank details or financial info with anyone.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),

          // Message Bubbles
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.chat_outlined, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text('Say Vanakkam to $partnerName!', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Start the conversation and connect meaningfully.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.fromProfile == myProfileId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe ? AppColors.saffronOrange : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(isMe ? 25 : 12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : AppColors.textPrimary,
                                      fontSize: 14,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(msg.sentAt),
                                        style: TextStyle(
                                          color: isMe ? Colors.white.withAlpha(200) : Colors.grey.shade500,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.done_all,
                                          size: 14,
                                          color: msg.readAt.isNotEmpty ? Colors.lightBlueAccent : Colors.white.withAlpha(200),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Message Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: AppColors.bgCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.saffronOrange,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
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

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    } catch (_) {
      return '';
    }
  }
}
