import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import 'chat_repository.dart';
import 'interest_repository.dart';
import 'master_data_repository.dart';
import 'notification_repository.dart';
import 'plan_repository.dart';
import 'profile_repository.dart';
import 'report_repository.dart';
import 'shortlist_repository.dart';
import 'story_repository.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return CsvAuthRepository();
});

final profileRepoProvider = Provider<ProfileRepository>((ref) {
  return CsvProfileRepository();
});

final interestRepoProvider = Provider<InterestRepository>((ref) {
  return CsvInterestRepository();
});

final shortlistRepoProvider = Provider<ShortlistRepository>((ref) {
  return CsvShortlistRepository();
});

final chatRepoProvider = Provider<ChatRepository>((ref) {
  return CsvChatRepository();
});

final storyRepoProvider = Provider<StoryRepository>((ref) {
  return CsvStoryRepository();
});

final notificationRepoProvider = Provider<NotificationRepository>((ref) {
  return CsvNotificationRepository();
});

final planRepoProvider = Provider<PlanRepository>((ref) {
  return CsvPlanRepository();
});

final reportRepoProvider = Provider<ReportRepository>((ref) {
  return CsvReportRepository();
});

final masterDataRepoProvider = Provider<MasterDataRepository>((ref) {
  return MasterDataRepository.instance;
});
