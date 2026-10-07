class SuccessStoryModel {
  final String storyId;
  final String groom;
  final String bride;
  final String location;
  final String story;
  final String photo;
  final String weddingDate;
  final bool isDemo;

  const SuccessStoryModel({
    required this.storyId,
    required this.groom,
    required this.bride,
    required this.location,
    required this.story,
    this.photo = '',
    required this.weddingDate,
    this.isDemo = true,
  });

  factory SuccessStoryModel.fromMap(Map<String, String> map) {
    return SuccessStoryModel(
      storyId: map['story_id'] ?? '',
      groom: map['groom'] ?? '',
      bride: map['bride'] ?? '',
      location: map['location'] ?? '',
      story: map['story'] ?? '',
      photo: map['photo'] ?? '',
      weddingDate: map['wedding_date'] ?? '',
      isDemo: (map['is_demo'] ?? 'true').toLowerCase() == 'true',
    );
  }
}
