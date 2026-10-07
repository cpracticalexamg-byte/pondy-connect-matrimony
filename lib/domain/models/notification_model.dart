class NotificationModel {
  final String notifId;
  final String profileId;
  final String type; // interest, match, message, view, shortlist, system
  final String title;
  final String body;
  final String payload;
  final String createdAt;
  final bool isRead;

  const NotificationModel({
    required this.notifId,
    required this.profileId,
    required this.type,
    required this.title,
    required this.body,
    this.payload = '',
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, String> map) {
    return NotificationModel(
      notifId: map['notif_id'] ?? '',
      profileId: map['profile_id'] ?? '',
      type: map['type'] ?? 'system',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      payload: map['payload'] ?? '',
      createdAt: map['created_at'] ?? '',
      isRead: (map['is_read'] ?? 'false').toLowerCase() == 'true',
    );
  }

  Map<String, String> toMap() {
    return {
      'notif_id': notifId,
      'profile_id': profileId,
      'type': type,
      'title': title,
      'body': body,
      'payload': payload,
      'created_at': createdAt,
      'is_read': isRead.toString(),
    };
  }
}
