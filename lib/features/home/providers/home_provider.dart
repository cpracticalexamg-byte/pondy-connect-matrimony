import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/shortlist_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/matching/queries/matching_queries.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../../domain/models/success_story_model.dart';
import '../../../domain/recommendations/daily_recommendations_engine.dart';
import '../../auth/providers/auth_state_provider.dart';

class HomeDashboardData {
  final int totalMatchesCount;
  final int interestsReceivedCount;
  final int shortlistCount;
  final int unreadNotificationsCount;
  final List<MatchResult> dailyRecommendations;
  final List<MatchResult> allMatches;
  final List<MatchResult> newMatches;
  final List<MatchResult> nearbyMatches;
  final List<MatchResult> viewedYou;
  final List<MatchResult> shortlistedYou;
  final List<MatchResult> mutualMatches;
  final List<MatchResult> verifiedMatches;
  final List<MatchResult> recentlyViewed;
  final List<SuccessStoryModel> successStories;
  final bool hasNewVerified;
  final bool isLoading;

  const HomeDashboardData({
    this.totalMatchesCount = 0,
    this.interestsReceivedCount = 0,
    this.shortlistCount = 0,
    this.unreadNotificationsCount = 0,
    this.dailyRecommendations = const [],
    this.allMatches = const [],
    this.newMatches = const [],
    this.nearbyMatches = const [],
    this.viewedYou = const [],
    this.shortlistedYou = const [],
    this.mutualMatches = const [],
    this.verifiedMatches = const [],
    this.recentlyViewed = const [],
    this.successStories = const [],
    this.hasNewVerified = false,
    this.isLoading = false,
  });

  HomeDashboardData copyWith({
    int? totalMatchesCount,
    int? interestsReceivedCount,
    int? shortlistCount,
    int? unreadNotificationsCount,
    List<MatchResult>? dailyRecommendations,
    List<MatchResult>? allMatches,
    List<MatchResult>? newMatches,
    List<MatchResult>? nearbyMatches,
    List<MatchResult>? viewedYou,
    List<MatchResult>? shortlistedYou,
    List<MatchResult>? mutualMatches,
    List<MatchResult>? verifiedMatches,
    List<MatchResult>? recentlyViewed,
    List<SuccessStoryModel>? successStories,
    bool? hasNewVerified,
    bool? isLoading,
  }) {
    return HomeDashboardData(
      totalMatchesCount: totalMatchesCount ?? this.totalMatchesCount,
      interestsReceivedCount: interestsReceivedCount ?? this.interestsReceivedCount,
      shortlistCount: shortlistCount ?? this.shortlistCount,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      dailyRecommendations: dailyRecommendations ?? this.dailyRecommendations,
      allMatches: allMatches ?? this.allMatches,
      newMatches: newMatches ?? this.newMatches,
      nearbyMatches: nearbyMatches ?? this.nearbyMatches,
      viewedYou: viewedYou ?? this.viewedYou,
      shortlistedYou: shortlistedYou ?? this.shortlistedYou,
      mutualMatches: mutualMatches ?? this.mutualMatches,
      verifiedMatches: verifiedMatches ?? this.verifiedMatches,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      successStories: successStories ?? this.successStories,
      hasNewVerified: hasNewVerified ?? this.hasNewVerified,
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

  static ProfileModel _createGuestProfile(String id) {
    final now = DateTime.now().toIso8601String();
    return ProfileModel(
      profileId: id,
      userId: 'GUEST',
      name: 'Guest',
      gender: 'Male',
      dob: '1995-01-01',
      age: 29,
      heightCm: 175,
      physicalStatus: 'Normal',
      maritalStatus: 'Never Married',
      noOfChildren: 0,
      motherTongue: 'Tamil',
      religion: 'Hindu',
      country: 'India',
      state: 'Puducherry',
      district: 'Puducherry',
      city: 'Puducherry',
      citizenship: 'Indian',
      education: 'Engineering',
      employmentType: 'Private',
      occupation: 'Software Engineer',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = _ref.read(authStateProvider);
      ProfileModel? myProfile = authState.profile;
      final allProfiles = await _profileRepo.getAllProfiles(includeDemo: true);

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
      } else if (allProfiles.isNotEmpty) {
        final dummyProfile = _createGuestProfile('TEMP_GUEST');
        const dummyPrefs = PartnerPrefModel(profileId: 'TEMP_GUEST');
        matches = MatchingEngine.instance.findMatches(
          myProfile: dummyProfile,
          myPrefs: dummyPrefs,
          candidates: allProfiles,
        );
      }

      // Compute Daily Recommendations via DailyRecommendationsEngine
      List<MatchResult> dailyRecs = [];
      if (myProfile != null && prefs != null) {
        dailyRecs = await DailyRecommendationsEngine.instance.getDailyRecommendations(
          myProfile: myProfile,
          myPrefs: prefs,
          allCandidates: allProfiles,
          profileRepo: _profileRepo,
        );
      } else {
        dailyRecs = matches.take(8).toList();
      }

      // Newly joined (last 30 days)
      final newMatches = MatchingQueries.instance.getNewlyJoined(
        myProfile: myProfile ?? _createGuestProfile('PC_GUEST'),
        myPrefs: prefs ?? PartnerPrefModel(profileId: profileId),
        candidates: allProfiles,
      );

      // Nearby matches
      final nearby = MatchingQueries.instance.getNearbyMatches(
        myProfile: myProfile ?? _createGuestProfile('PC_GUEST'),
        myPrefs: prefs ?? PartnerPrefModel(profileId: profileId),
        candidates: allProfiles,
      );

      // Viewed you
      final viewedYouProfiles = profileId.isNotEmpty ? await _profileRepo.getProfilesWhoViewedMe(profileId) : <ProfileModel>[];
      final viewedYou = viewedYouProfiles.map((p) => MatchResult(
        profile: p,
        score: myProfile != null && prefs != null ? MatchingEngine.instance.calculateCompatibility(
          myProfile: myProfile,
          candidate: p,
          myPrefs: prefs,
        ) : 75,
        matchReasons: ['Viewed Your Profile'],
      )).toList();

      // Shortlisted you
      final shortlistedYouProfiles = profileId.isNotEmpty ? await _shortlistRepo.getProfilesWhoShortlistedMe(profileId) : <ProfileModel>[];
      final shortlistedYou = shortlistedYouProfiles.map((p) => MatchResult(
        profile: p,
        score: myProfile != null && prefs != null ? MatchingEngine.instance.calculateCompatibility(
          myProfile: myProfile,
          candidate: p,
          myPrefs: prefs,
        ) : 80,
        matchReasons: ['Shortlisted You'],
      )).toList();

      // Mutual matches
      final mutual = (myProfile != null && prefs != null)
          ? MatchingQueries.instance.getMutualMatches(
              myProfile: myProfile,
              myPrefs: prefs,
              candidates: allProfiles,
            )
          : <MatchResult>[];

      // Verified / PRIME matches
      final verified = MatchingQueries.instance.getVerifiedMatches(
        myProfile: myProfile ?? _createGuestProfile('PC_GUEST'),
        myPrefs: prefs ?? PartnerPrefModel(profileId: profileId),
        candidates: allProfiles,
      );

      // Recently viewed by me
      final recentlyViewedProfiles = profileId.isNotEmpty ? await _profileRepo.getRecentlyViewedByMe(profileId) : <ProfileModel>[];
      final recentlyViewed = recentlyViewedProfiles.map((p) => MatchResult(
        profile: p,
        score: myProfile != null && prefs != null ? MatchingEngine.instance.calculateCompatibility(
          myProfile: myProfile,
          candidate: p,
          myPrefs: prefs,
        ) : 70,
        matchReasons: ['Recently Viewed'],
      )).toList();

      // Counts & Stories (only approved stories)
      final interests = profileId.isNotEmpty ? await _interestRepo.getReceivedInterests(profileId) : [];
      final shortlists = profileId.isNotEmpty ? await _shortlistRepo.getShortlistedProfiles(profileId) : [];
      final unreadNotifs = profileId.isNotEmpty ? await _notifRepo.getUnreadCount(profileId) : 0;
      final rawStories = await _storyRepo.getSuccessStories();
      final approvedStories = rawStories.where((s) => !s.isDemo || s.groom.isNotEmpty).toList();

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        totalMatchesCount: matches.length,
        interestsReceivedCount: interests.length,
        shortlistCount: shortlists.length,
        unreadNotificationsCount: unreadNotifs,
        dailyRecommendations: dailyRecs,
        allMatches: matches,
        newMatches: newMatches,
        nearbyMatches: nearby,
        viewedYou: viewedYou,
        shortlistedYou: shortlistedYou,
        mutualMatches: mutual,
        verifiedMatches: verified,
        recentlyViewed: recentlyViewed,
        successStories: approvedStories,
        hasNewVerified: verified.isNotEmpty,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to refresh dashboard', tag: 'HomeNotifier', error: e, stackTrace: stack);
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
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
