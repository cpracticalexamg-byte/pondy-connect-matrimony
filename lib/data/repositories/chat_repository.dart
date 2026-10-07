import 'dart:math';
import '../../domain/models/message_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class ChatRepository {
  Future<MessageModel> sendMessage(String fromProfile, String toProfile, String text);
  Future<List<MessageModel>> getMessages(String threadId);
  Future<List<String>> getChatPartnerIds(String myProfile);
  Future<void> markThreadRead(String threadId, String myProfile);
}

class CsvChatRepository implements ChatRepository {
  final CsvStore _store;

  CsvChatRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  String getThreadId(String p1, String p2) {
    final list = [p1, p2]..sort();
    return '${list[0]}_${list[1]}';
  }

  @override
  Future<MessageModel> sendMessage(String fromProfile, String toProfile, String text) async {
    final threadId = getThreadId(fromProfile, toProfile);
    final id = await _store.nextId(CsvSchema.messagesTable, 'msg_id', 'MSG', 6);
    final now = DateTime.now().toIso8601String();

    final msg = MessageModel(
      msgId: id,
      threadId: threadId,
      fromProfile: fromProfile,
      toProfile: toProfile,
      text: text,
      sentAt: now,
      deliveredAt: now,
      readAt: '',
    );

    await _store.insert(CsvSchema.messagesTable, msg.toMap());

    // If toProfile is a demo profile, schedule a simulated demo reply
    if (toProfile.startsWith('PC')) {
      _scheduleDemoReply(threadId, toProfile, fromProfile);
    }

    return msg;
  }

  void _scheduleDemoReply(String threadId, String demoProfile, String userProfile) {
    final cannedReplies = [
      'Hello! Thank you for connecting. I am glad to know you.',
      'Hi there, thank you for reaching out. How is your day going?',
      'Vanakkam! Happy to connect with someone from our region.',
      'Thank you for the message. I shared your details with my parents as well.',
    ];
    final delaySeconds = 2 + Random().nextInt(4);

    Future.delayed(Duration(seconds: delaySeconds), () async {
      final replyText = cannedReplies[Random().nextInt(cannedReplies.length)];
      final replyId = await _store.nextId(CsvSchema.messagesTable, 'msg_id', 'MSG', 6);
      final now = DateTime.now().toIso8601String();

      await _store.insert(CsvSchema.messagesTable, {
        'msg_id': replyId,
        'thread_id': threadId,
        'from_profile': demoProfile,
        'to_profile': userProfile,
        'text': replyText,
        'type': 'text',
        'sent_at': now,
        'delivered_at': now,
        'read_at': '',
      });
    });
  }

  @override
  Future<List<MessageModel>> getMessages(String threadId) async {
    final rows = await _store.query(
      CsvSchema.messagesTable,
      (r) => r['thread_id'] == threadId,
    );
    return rows.map((e) => MessageModel.fromMap(e)).toList();
  }

  @override
  Future<List<String>> getChatPartnerIds(String myProfile) async {
    final rows = await _store.query(
      CsvSchema.messagesTable,
      (r) => r['from_profile'] == myProfile || r['to_profile'] == myProfile,
    );

    final partners = <String>{};
    for (final r in rows) {
      final from = r['from_profile'] ?? '';
      final to = r['to_profile'] ?? '';
      if (from == myProfile && to.isNotEmpty) partners.add(to);
      if (to == myProfile && from.isNotEmpty) partners.add(from);
    }
    return partners.toList();
  }

  @override
  Future<void> markThreadRead(String threadId, String myProfile) async {
    final now = DateTime.now().toIso8601String();
    await _store.update(
      CsvSchema.messagesTable,
      {'read_at': now},
      (r) => r['thread_id'] == threadId && r['to_profile'] == myProfile && (r['read_at'] ?? '').isEmpty,
    );
  }
}
