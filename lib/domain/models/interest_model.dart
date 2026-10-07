class InterestModel {
  final String interestId;
  final String fromProfile;
  final String toProfile;
  final String status; // sent, accepted, declined, withdrawn
  final String message;
  final String sentAt;
  final String respondedAt;

  const InterestModel({
    required this.interestId,
    required this.fromProfile,
    required this.toProfile,
    this.status = 'sent',
    this.message = 'Hi, I liked your profile and would love to connect!',
    required this.sentAt,
    this.respondedAt = '',
  });

  factory InterestModel.fromMap(Map<String, String> map) {
    return InterestModel(
      interestId: map['interest_id'] ?? '',
      fromProfile: map['from_profile'] ?? '',
      toProfile: map['to_profile'] ?? '',
      status: map['status'] ?? 'sent',
      message: map['message'] ?? '',
      sentAt: map['sent_at'] ?? '',
      respondedAt: map['responded_at'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'interest_id': interestId,
      'from_profile': fromProfile,
      'to_profile': toProfile,
      'status': status,
      'message': message,
      'sent_at': sentAt,
      'responded_at': respondedAt,
    };
  }
}
