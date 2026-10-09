import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class SearchCriteria {
  final int ageMin;
  final int ageMax;
  final int heightMinCm;
  final int heightMaxCm;
  final String religion;
  final String caste;
  final String district;
  final String maritalStatus;
  final String education;
  final String employmentType;
  final bool photoOnly;
  final String searchById;

  const SearchCriteria({
    this.ageMin = 21,
    this.ageMax = 35,
    this.heightMinCm = 150,
    this.heightMaxCm = 190,
    this.religion = 'all',
    this.caste = 'all',
    this.district = 'all',
    this.maritalStatus = 'all',
    this.education = 'all',
    this.employmentType = 'all',
    this.photoOnly = false,
    this.searchById = '',
  });

  SearchCriteria copyWith({
    int? ageMin,
    int? ageMax,
    int? heightMinCm,
    int? heightMaxCm,
    String? religion,
    String? caste,
    String? district,
    String? maritalStatus,
    String? education,
    String? employmentType,
    bool? photoOnly,
    String? searchById,
  }) {
    return SearchCriteria(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      heightMinCm: heightMinCm ?? this.heightMinCm,
      heightMaxCm: heightMaxCm ?? this.heightMaxCm,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      district: district ?? this.district,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
      employmentType: employmentType ?? this.employmentType,
      photoOnly: photoOnly ?? this.photoOnly,
      searchById: searchById ?? this.searchById,
    );
  }
}

class SearchState {
  final SearchCriteria criteria;
  final List<MatchResult> results;
  final bool hasSearched;
  final bool isLoading;

  const SearchState({
    this.criteria = const SearchCriteria(),
    this.results = const [],
    this.hasSearched = false,
    this.isLoading = false,
  });

  SearchState copyWith({
    SearchCriteria? criteria,
    List<MatchResult>? results,
    bool? hasSearched,
    bool? isLoading,
  }) {
    return SearchState(
      criteria: criteria ?? this.criteria,
      results: results ?? this.results,
      hasSearched: hasSearched ?? this.hasSearched,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final ProfileRepository _profileRepo;
  final Ref _ref;

  SearchNotifier(this._profileRepo, this._ref) : super(const SearchState());

  void updateCriteria(SearchCriteria criteria) {
    state = state.copyWith(criteria: criteria);
  }

  Future<void> executeSearch() async {
    state = state.copyWith(isLoading: true, hasSearched: true);

    try {
      final allProfiles = await _profileRepo.getAllProfiles(includeDemo: true);
      final authState = _ref.read(authStateProvider);
      ProfileModel? myProfile = authState.profile;
      if (myProfile == null && allProfiles.isNotEmpty) {
        myProfile = allProfiles.first;
      }

      final c = state.criteria;

      // Filter
      final filtered = allProfiles.where((p) {
        if (myProfile != null && p.profileId == myProfile.profileId) return false;

        // Search by ID exact match
        if (c.searchById.trim().isNotEmpty) {
          return p.profileId.toLowerCase().contains(c.searchById.trim().toLowerCase());
        }

        // Opposite gender
        if (myProfile != null && p.gender == myProfile.gender) return false;

        // Age
        if (p.age < c.ageMin || p.age > c.ageMax) return false;

        // Height
        if (p.heightCm < c.heightMinCm || p.heightCm > c.heightMaxCm) return false;

        // Religion
        if (c.religion != 'all' && p.religion.toLowerCase() != c.religion.toLowerCase()) return false;

        // Caste
        if (c.caste != 'all' && p.caste.toLowerCase() != c.caste.toLowerCase()) return false;

        // District
        if (c.district != 'all' && p.district.toLowerCase() != c.district.toLowerCase()) return false;

        // Marital Status
        if (c.maritalStatus != 'all' && p.maritalStatus.toLowerCase() != c.maritalStatus.toLowerCase()) return false;

        // Education
        if (c.education != 'all' && !p.education.toLowerCase().contains(c.education.toLowerCase())) return false;

        // Employment
        if (c.employmentType != 'all' && p.employmentType.toLowerCase() != c.employmentType.toLowerCase()) return false;

        // Photo Only
        if (c.photoOnly && (p.primaryPhoto == null || p.primaryPhoto!.isEmpty)) return false;

        return true;
      }).toList();

      // Convert to MatchResults
      final prefs = PartnerPrefModel(
        profileId: myProfile?.profileId ?? '',
        ageMin: c.ageMin,
        ageMax: c.ageMax,
        religion: c.religion,
        district: c.district,
      );

      final matches = filtered.map((candidate) {
        if (myProfile != null) {
          return MatchingEngine.instance.calculateMatch(
            myProfile: myProfile,
            myPrefs: prefs,
            candidate: candidate,
          );
        }
        return MatchResult(profile: candidate, score: 75, matchReasons: ['Compatible Profile']);
      }).toList();

      matches.sort((a, b) => b.score.compareTo(a.score));

      state = state.copyWith(results: matches, isLoading: false);
    } catch (e, stack) {
      AppLogger.error('Search filtering failed', tag: 'SearchNotifier', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false);
    }
  }

  void resetFilters() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final profileRepo = ref.watch(profileRepoProvider);
  return SearchNotifier(profileRepo, ref);
});
