class MessageModel {
  final String msgId;
  final String threadId;
  final String fromProfile;
  final String toProfile;
  final String text;
  final String type; // text, template, image
  final String sentAt;
  final String deliveredAt;
  final String readAt;

  const MessageModel({
    required this.msgId,
    required this.threadId,
    required this.fromProfile,
    required this.toProfile,
    required this.text,
    this.type = 'text',
    required this.sentAt,
    this.deliveredAt = '',
    this.readAt = '',
  });

  factory MessageModel.fromMap(Map<String, String> map) {
    return MessageModel(
      msgId: map['msg_id'] ?? '',
      threadId: map['thread_id'] ?? '',
      fromProfile: map['from_profile'] ?? '',
      toProfile: map['to_profile'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      sentAt: map['sent_at'] ?? '',
      deliveredAt: map['delivered_at'] ?? '',
      readAt: map['read_at'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'msg_id': msgId,
      'thread_id': threadId,
      'from_profile': fromProfile,
      'to_profile': toProfile,
      'text': text,
      'type': type,
      'sent_at': sentAt,
      'delivered_at': deliveredAt,
      'read_at': readAt,
    };
  }
}
