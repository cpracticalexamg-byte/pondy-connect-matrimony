import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/chat_repository.dart';
import 'package:pondy_connect_matrimony/data/repositories/notification_repository.dart';

void main() {
  late Directory tempDir;
  late CsvStore store;
  late ChatRepository chatRepo;
  late NotificationRepository notifRepo;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('pondy_chat_test_');
    store = CsvStore.instance;
    store.invalidateCache();
    await store.initialize(customDir: tempDir);
    chatRepo = CsvChatRepository(store: store);
    notifRepo = CsvNotificationRepository(store: store);
  });

  tearDown(() async {
    store.invalidateCache();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('ChatRepository sends message and retrieves thread', () async {
    final msg = await chatRepo.sendMessage('PC000100', 'PC000200', 'Vanakkam! Hope you are doing well.');
    expect(msg.msgId.startsWith('MSG'), isTrue);
    expect(msg.text, equals('Vanakkam! Hope you are doing well.'));

    final threadId = (chatRepo as CsvChatRepository).getThreadId('PC000100', 'PC000200');
    final messages = await chatRepo.getMessages(threadId);

    expect(messages.length, equals(1));
    expect(messages.first.text, equals('Vanakkam! Hope you are doing well.'));

    final partnerIds = await chatRepo.getChatPartnerIds('PC000100');
    expect(partnerIds.contains('PC000200'), isTrue);
  });

  test('NotificationRepository creates and marks notifications as read', () async {
    // Insert test notification via store directly
    final notifId = await store.nextId('notifications', 'notif_id', 'NOT', 6);
    await store.insert('notifications', {
      'notif_id': notifId,
      'profile_id': 'PC000100',
      'type': 'interest',
      'title': 'New Interest',
      'body': 'You have received an interest',
      'payload': '',
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 'false',
    });

    final unreadCountBefore = await notifRepo.getUnreadCount('PC000100');
    expect(unreadCountBefore, equals(1));

    await notifRepo.markAsRead(notifId);

    final unreadCountAfter = await notifRepo.getUnreadCount('PC000100');
    expect(unreadCountAfter, equals(0));
  });
}
