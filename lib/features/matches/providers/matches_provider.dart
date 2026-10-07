import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/shortlist_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

enum MatchesFilterTab {
  all,
  newToday,
  nearby,
  mutual,
}

class MatchesState {
  final bool isLoading;
  final String? error;
  final List<MatchResult> allMatches;
  final Set<String> shortlistedIds;
  final Set<String> sentInterestIds;
  final MatchesFilterTab currentTab;
  final String sortOrder;

  const MatchesState({
    this.isLoading = false,
    this.error,
    this.allMatches = const [],
    this.shortlistedIds = const {},
    this.sentInterestIds = const {},
    this.currentTab = MatchesFilterTab.all,
    this.sortOrder = 'relevance',
  });

  List<MatchResult> get filteredMatches {
    switch (currentTab) {
      case MatchesFilterTab.all:
        return allMatches;
      case MatchesFilterTab.newToday:
        // Candidates with isDemo or created recently
        return allMatches.where((m) => m.profile.isDemo || m.profile.createdAt.startsWith(DateTime.now().toIso8601String().substring(0, 10))).toList();
      case MatchesFilterTab.nearby:
        return allMatches.where((m) {
          final dist = m.profile.district.toLowerCase();
          return dist == 'puducherry' || dist == 'karaikal' || dist == 'villupuram' || dist == 'cuddalore';
        }).toList();
      case MatchesFilterTab.mutual:
        return allMatches.where((m) => m.score >= 70).toList();
    }
  }

  MatchesState copyWith({
    bool? isLoading,
    String? error,
    List<MatchResult>? allMatches,
    Set<String>? shortlistedIds,
    Set<String>? sentInterestIds,
    MatchesFilterTab? currentTab,
    String? sortOrder,
  }) {
    return MatchesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allMatches: allMatches ?? this.allMatches,
      shortlistedIds: shortlistedIds ?? this.shortlistedIds,
      sentInterestIds: sentInterestIds ?? this.sentInterestIds,
      currentTab: currentTab ?? this.currentTab,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class MatchesNotifier extends StateNotifier<MatchesState> {
  final ProfileRepository _profileRepo;
  final InterestRepository _interestRepo;
  final ShortlistRepository _shortlistRepo;
  final Ref _ref;

  MatchesNotifier(this._profileRepo, this._interestRepo, this._shortlistRepo, this._ref)
      : super(const MatchesState()) {
    loadMatches();
  }

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authState = _ref.read(authStateProvider);
      ProfileModel? myProfile = authState.profile;

      // Fallback: if no logged in profile, use first profile as context
      final allProfiles = await _profileRepo.getAllProfiles(includeDemo: true);

      if (myProfile == null) {
        if (allProfiles.isNotEmpty) {
          myProfile = allProfiles.first;
        } else {
          state = state.copyWith(isLoading: false, allMatches: []);
          return;
        }
      }

      var prefs = await _profileRepo.getPartnerPrefs(myProfile.profileId);
      prefs ??= PartnerPrefModel(
        profileId: myProfile.profileId,
        ageMin: myProfile.gender == 'Male' ? 20 : 23,
        ageMax: myProfile.gender == 'Male' ? 32 : 36,
        religion: myProfile.religion,
        district: myProfile.district,
      );

      final matches = MatchingEngine.instance.findMatches(
        myProfile: myProfile,
        myPrefs: prefs,
        candidates: allProfiles,
        sortOrder: state.sortOrder,
      );

      // Load shortlists
      final shortlistedProfiles = await _shortlistRepo.getShortlistedProfiles(myProfile.profileId);
      final shortlistedSet = shortlistedProfiles.map((p) => p.profileId).toSet();

      // Load sent interests
      final sentInterests = await _interestRepo.getSentInterests(myProfile.profileId);
      final sentSet = sentInterests.map((i) => i.toProfile).toSet();

      state = state.copyWith(
        isLoading: false,
        allMatches: matches,
        shortlistedIds: shortlistedSet,
        sentInterestIds: sentSet,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilterTab(MatchesFilterTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void setSortOrder(String sort) {
    state = state.copyWith(sortOrder: sort);
    loadMatches();
  }

  Future<bool> toggleShortlist(String candidateProfileId) async {
    final authState = _ref.read(authStateProvider);
    final myProfileId = authState.profile?.profileId ?? (state.allMatches.isNotEmpty ? 'CURRENT_USER' : '');
    if (myProfileId.isEmpty) return false;

    await _shortlistRepo.toggleShortlist(myProfileId, candidateProfileId);

    final updated = Set<String>.from(state.shortlistedIds);
    final isNowShortlisted = !updated.contains(candidateProfileId);
    if (isNowShortlisted) {
      updated.add(candidateProfileId);
    } else {
      updated.remove(candidateProfileId);
    }

    state = state.copyWith(shortlistedIds: updated);
    return isNowShortlisted;
  }

  Future<bool> sendInterest(String candidateProfileId, {String message = ''}) async {
    final authState = _ref.read(authStateProvider);
    final myProfileId = authState.profile?.profileId ?? 'PC_ME';

    if (state.sentInterestIds.contains(candidateProfileId)) return true;

    await _interestRepo.sendInterest(myProfileId, candidateProfileId, message: message);

    final updated = Set<String>.from(state.sentInterestIds)..add(candidateProfileId);
    state = state.copyWith(sentInterestIds: updated);
    return true;
  }
}

final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final profileRepo = ref.watch(profileRepoProvider);
  final interestRepo = ref.watch(interestRepoProvider);
  final shortlistRepo = ref.watch(shortlistRepoProvider);
  return MatchesNotifier(profileRepo, interestRepo, shortlistRepo, ref);
});
