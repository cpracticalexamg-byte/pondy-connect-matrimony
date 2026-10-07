import '../../domain/models/notification_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications(String profileId);
  Future<void> markAsRead(String notifId);
  Future<void> markAllAsRead(String profileId);
  Future<void> deleteNotification(String notifId);
  Future<int> getUnreadCount(String profileId);
}

class CsvNotificationRepository implements NotificationRepository {
  final CsvStore _store;

  CsvNotificationRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<List<NotificationModel>> getNotifications(String profileId) async {
    final rows = await _store.query(
      CsvSchema.notificationsTable,
      (r) => r['profile_id'] == profileId,
    );
    final list = rows.map((e) => NotificationModel.fromMap(e)).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<void> markAsRead(String notifId) async {
    await _store.update(
      CsvSchema.notificationsTable,
      {'is_read': 'true'},
      (r) => r['notif_id'] == notifId,
    );
  }

  @override
  Future<void> markAllAsRead(String profileId) async {
    await _store.update(
      CsvSchema.notificationsTable,
      {'is_read': 'true'},
      (r) => r['profile_id'] == profileId,
    );
  }

  @override
  Future<void> deleteNotification(String notifId) async {
    await _store.delete(
      CsvSchema.notificationsTable,
      (r) => r['notif_id'] == notifId,
    );
  }

  @override
  Future<int> getUnreadCount(String profileId) async {
    final list = await getNotifications(profileId);
    return list.where((n) => !n.isRead).length;
  }
}
