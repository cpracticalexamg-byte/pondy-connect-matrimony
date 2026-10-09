import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/notification_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authStateProvider);
      final profileId = authState.profile?.profileId ?? '';
      final notifRepo = ref.read(notificationRepoProvider);

      final list = profileId.isNotEmpty ? await notifRepo.getNotifications(profileId) : <NotificationModel>[];
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load notifications', tag: 'NotificationsScreen', error: e, stackTrace: stack);
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
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                final authState = ref.read(authStateProvider);
                final profileId = authState.profile?.profileId ?? '';
                if (profileId.isNotEmpty) {
                  await ref.read(notificationRepoProvider).markAllAsRead(profileId);
                  _loadNotifications();
                }
              },
              child: const Text('Mark all read', style: TextStyle(color: AppColors.saffronOrange, fontSize: 12)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : _notifications.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_none, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text('No notifications yet', style: AppTypography.heading3),
                        const SizedBox(height: 6),
                        const Text(
                          'You will be notified when members send you interests, view your profile, or message you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    final isRead = item.isRead;

                    return Dismissible(
                      key: Key(item.notifId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        ref.read(notificationRepoProvider).deleteNotification(item.notifId);
                      },
                      child: Container(
                        color: isRead ? Colors.transparent : Colors.orange.shade50.withAlpha(80),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getNotifColor(item.type).withAlpha(30),
                            child: Icon(_getNotifIcon(item.type), color: _getNotifColor(item.type), size: 20),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(item.body, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                item.createdAt.split('T').first,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          trailing: !isRead
                              ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.saffronOrange, shape: BoxShape.circle))
                              : null,
                          onTap: () async {
                            if (!isRead) {
                              await ref.read(notificationRepoProvider).markAsRead(item.notifId);
                              _loadNotifications();
                            }
                            if (item.type == 'interest') {
                              if (context.mounted) context.push('/interests');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getNotifIcon(String type) {
    switch (type) {
      case 'interest':
        return Icons.favorite;
      case 'view':
        return Icons.remove_red_eye;
      case 'chat':
        return Icons.chat_bubble;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotifColor(String type) {
    switch (type) {
      case 'interest':
        return AppColors.saffronOrange;
      case 'view':
        return Colors.blue;
      case 'chat':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}
