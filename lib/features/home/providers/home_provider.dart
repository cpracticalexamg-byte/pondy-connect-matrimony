import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/shortlist_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../../domain/models/success_story_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class HomeDashboardData {
  final int totalMatchesCount;
  final int interestsReceivedCount;
  final int shortlistCount;
  final int unreadNotificationsCount;
  final List<MatchResult> dailyRecommendations;
  final List<MatchResult> newMatches;
  final List<MatchResult> nearbyMatches;
  final List<SuccessStoryModel> successStories;
  final bool isLoading;

  const HomeDashboardData({
    this.totalMatchesCount = 0,
    this.interestsReceivedCount = 0,
    this.shortlistCount = 0,
    this.unreadNotificationsCount = 0,
    this.dailyRecommendations = const [],
    this.newMatches = const [],
    this.nearbyMatches = const [],
    this.successStories = const [],
    this.isLoading = false,
  });

  HomeDashboardData copyWith({
    int? totalMatchesCount,
    int? interestsReceivedCount,
    int? shortlistCount,
    int? unreadNotificationsCount,
    List<MatchResult>? dailyRecommendations,
    List<MatchResult>? newMatches,
    List<MatchResult>? nearbyMatches,
    List<SuccessStoryModel>? successStories,
    bool? isLoading,
  }) {
    return HomeDashboardData(
      totalMatchesCount: totalMatchesCount ?? this.totalMatchesCount,
      interestsReceivedCount: interestsReceivedCount ?? this.interestsReceivedCount,
      shortlistCount: shortlistCount ?? this.shortlistCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      dailyRecommendations: dailyRecommendations ?? this.dailyRecommendations,
      newMatches: newMatches ?? this.newMatches,
      nearbyMatches: nearbyMatches ?? this.nearbyMatches,
      successStories: successStories ?? this.successStories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeDashboardData> {
  final ProfileRepository _profileRepo;
  final InterestRepository _interestRepo;
  final ShortlistRepository _shortlistRepo;
  final StoryRepository _storyRepo;
  final NotificationRepository _notifRepo;
  final Ref _ref;

  HomeNotifier(
    this._profileRepo,
    this._interestRepo,
    this._shortlistRepo,
    this._storyRepo,
    this._notifRepo,
    this._ref,
  ) : super(const HomeDashboardData()) {
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = _ref.read(authStateProvider);
      ProfileModel? myProfile = authState.profile;
      final allProfiles = await _profileRepo.getAllProfiles(includeDemo: false);

      final profileId = myProfile?.profileId ?? '';

      // Load partner prefs
      PartnerPrefModel? prefs;
      if (profileId.isNotEmpty) {
        prefs = await _profileRepo.getPartnerPrefs(profileId);
      }
      if (prefs == null && myProfile != null) {
        prefs = PartnerPrefModel(
          profileId: profileId,
          religion: myProfile.religion.isNotEmpty ? myProfile.religion : 'hindu',
          district: myProfile.district.isNotEmpty ? myProfile.district : 'puducherry',
        );
      }

      // Compute matches
      List<MatchResult> matches = [];
      if (myProfile != null && prefs != null) {
        matches = MatchingEngine.instance.findMatches(
          myProfile: myProfile,
          myPrefs: prefs,
          candidates: allProfiles,
        );
      }

      // Daily recommendations (top 10 by score)
      final daily = matches.take(10).toList();

      // New today (last 10)
      final newMatches = List<MatchResult>.from(matches)
        ..sort((a, b) => b.profile.createdAt.compareTo(a.profile.createdAt));
      final newToday = newMatches.take(10).toList();

      // Nearby (Puducherry, Karaikal, Villupuram, Cuddalore)
      final nearby = matches.where((m) {
        final d = m.profile.district.toLowerCase();
        return d == 'puducherry' || d == 'karaikal' || d == 'villupuram' || d == 'cuddalore';
      }).take(10).toList();

      // Counts
      final interests = profileId.isNotEmpty ? await _interestRepo.getReceivedInterests(profileId) : [];
      final shortlists = profileId.isNotEmpty ? await _shortlistRepo.getShortlistedProfiles(profileId) : [];
      final unreadNotifs = profileId.isNotEmpty ? await _notifRepo.getUnreadCount(profileId) : 0;
      final stories = await _storyRepo.getSuccessStories();

      state = state.copyWith(
        isLoading: false,
        totalMatchesCount: matches.length,
        interestsReceivedCount: interests.length,
        shortlistCount: shortlists.length,
        unreadNotificationsCount: unreadNotifs,
        dailyRecommendations: daily,
        newMatches: newToday,
        nearbyMatches: nearby,
        successStories: stories,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to refresh dashboard', tag: 'HomeNotifier', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false);
    }
  }
}

final homeDashboardProvider = StateNotifierProvider<HomeNotifier, HomeDashboardData>((ref) {
  final profileRepo = ref.watch(profileRepoProvider);
  final interestRepo = ref.watch(interestRepoProvider);
  final shortlistRepo = ref.watch(shortlistRepoProvider);
  final storyRepo = ref.watch(storyRepoProvider);
  final notifRepo = ref.watch(notificationRepoProvider);
  return HomeNotifier(profileRepo, interestRepo, shortlistRepo, storyRepo, notifRepo, ref);
});
