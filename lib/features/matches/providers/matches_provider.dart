import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/csv/csv_schema.dart';
import '../../../data/csv/csv_store.dart';
import '../../../data/repositories/interest_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/shortlist_repository.dart';
import '../../../domain/location/location_service.dart';
import '../../../domain/matching/matching_engine.dart';
import '../../../domain/matching/queries/matching_queries.dart';
import '../../../domain/models/partner_pref_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

enum MatchesFilterTab {
  all,
  newlyJoined,
  more,
  newToday,
  nearby,
  mutual,
}

class MatchesFilterCriteria {
  final int? ageMin;
  final int? ageMax;
  final int? heightMinCm;
  final int? heightMaxCm;
  final String? maritalStatus;
  final String? religion;
  final String? caste;
  final String? motherTongue;
  final String? education;
  final String? employmentType;
  final String? annualIncome;
  final String? district;
  final String? state;
  final int? distanceRadiusKm;
  final String? diet;
  final bool? hasHoroscope;
  final List<String> localities;
  final List<String> cities;

  const MatchesFilterCriteria({
    this.ageMin,
    this.ageMax,
    this.heightMinCm,
    this.heightMaxCm,
    this.maritalStatus,
    this.religion,
    this.caste,
    this.motherTongue,
    this.education,
    this.employmentType,
    this.annualIncome,
    this.district,
    this.state,
    this.distanceRadiusKm,
    this.diet,
    this.hasHoroscope,
    this.localities = const [],
    this.cities = const [],
  });

  bool get isEmpty =>
      ageMin == null &&
      ageMax == null &&
      heightMinCm == null &&
      heightMaxCm == null &&
      maritalStatus == null &&
      religion == null &&
      caste == null &&
      motherTongue == null &&
      education == null &&
      employmentType == null &&
      annualIncome == null &&
      district == null &&
      state == null &&
      distanceRadiusKm == null &&
      diet == null &&
      hasHoroscope == null &&
      localities.isEmpty &&
      cities.isEmpty;

  int get activeCount {
    int c = 0;
    if (ageMin != null || ageMax != null) c++;
    if (heightMinCm != null || heightMaxCm != null) c++;
    if (maritalStatus != null && maritalStatus != 'all') c++;
    if (religion != null && religion != 'all') c++;
    if (caste != null && caste != 'all') c++;
    if (motherTongue != null && motherTongue != 'all') c++;
    if (education != null && education != 'all') c++;
    if (employmentType != null && employmentType != 'all') c++;
    if (annualIncome != null && annualIncome != 'all') c++;
    if (district != null && district != 'all') c++;
    if (state != null && state != 'all') c++;
    if (distanceRadiusKm != null) c++;
    if (diet != null && diet != 'all') c++;
    if (hasHoroscope == true) c++;
    if (localities.isNotEmpty) c += localities.length;
    if (cities.isNotEmpty) c += cities.length;
    return c;
  }

  Map<String, dynamic> toJson() => {
        'ageMin': ageMin,
        'ageMax': ageMax,
        'heightMinCm': heightMinCm,
        'heightMaxCm': heightMaxCm,
        'maritalStatus': maritalStatus,
        'religion': religion,
        'caste': caste,
        'motherTongue': motherTongue,
        'education': education,
        'employmentType': employmentType,
        'annualIncome': annualIncome,
        'district': district,
        'state': state,
        'distanceRadiusKm': distanceRadiusKm,
        'diet': diet,
        'hasHoroscope': hasHoroscope,
        'localities': localities,
        'cities': cities,
      };

  factory MatchesFilterCriteria.fromJson(Map<String, dynamic> json) => MatchesFilterCriteria(
        ageMin: json['ageMin'] as int?,
        ageMax: json['ageMax'] as int?,
        heightMinCm: json['heightMinCm'] as int?,
        heightMaxCm: json['heightMaxCm'] as int?,
        maritalStatus: json['maritalStatus'] as String?,
        religion: json['religion'] as String?,
        caste: json['caste'] as String?,
        motherTongue: json['motherTongue'] as String?,
        education: json['education'] as String?,
        employmentType: json['employmentType'] as String?,
        annualIncome: json['annualIncome'] as String?,
        district: json['district'] as String?,
        state: json['state'] as String?,
        distanceRadiusKm: json['distanceRadiusKm'] as int?,
        diet: json['diet'] as String?,
        hasHoroscope: json['hasHoroscope'] as bool?,
        localities: (json['localities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
        cities: (json['cities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      );

  MatchesFilterCriteria copyWith({
    int? ageMin,
    int? ageMax,
    int? heightMinCm,
    int? heightMaxCm,
    String? maritalStatus,
    String? religion,
    String? caste,
    String? motherTongue,
    String? education,
    String? employmentType,
    String? annualIncome,
    String? district,
    String? state,
    int? distanceRadiusKm,
    String? diet,
    bool? hasHoroscope,
    List<String>? localities,
    List<String>? cities,
  }) {
    return MatchesFilterCriteria(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      heightMinCm: heightMinCm ?? this.heightMinCm,
      heightMaxCm: heightMaxCm ?? this.heightMaxCm,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      motherTongue: motherTongue ?? this.motherTongue,
      education: education ?? this.education,
      employmentType: employmentType ?? this.employmentType,
      annualIncome: annualIncome ?? this.annualIncome,
      district: district ?? this.district,
      state: state ?? this.state,
      distanceRadiusKm: distanceRadiusKm ?? this.distanceRadiusKm,
      diet: diet ?? this.diet,
      hasHoroscope: hasHoroscope ?? this.hasHoroscope,
      localities: localities ?? this.localities,
      cities: cities ?? this.cities,
    );
  }
}

class MatchesState {
  final bool isLoading;
  final String? error;
  final List<MatchResult> allMatches;
  final Set<String> shortlistedIds;
  final Set<String> sentInterestIds;
  final Set<String> viewedProfileIds;
  final Set<String> hiddenProfileIds;
  final MatchesFilterTab currentTab;
  final String? activeMoreQueryCode;
  final String? activeMoreQueryTitle;
  final String sortOrder; // last_active, date_created, distance, latest_photos, best_match
  final Set<String> selectedOccupations;
  final bool filterPhotoOnly;
  final bool filterVerifiedOnly;
  final bool filterNotSeenOnly;
  final bool filterNearbyOnly;
  final MatchesFilterCriteria filterCriteria;

  const MatchesState({
    this.isLoading = false,
    this.error,
    this.allMatches = const [],
    this.shortlistedIds = const {},
    this.sentInterestIds = const {},
    this.viewedProfileIds = const {},
    this.hiddenProfileIds = const {},
    this.currentTab = MatchesFilterTab.all,
    this.activeMoreQueryCode,
    this.activeMoreQueryTitle,
    this.sortOrder = 'last_active',
    this.selectedOccupations = const {},
    this.filterPhotoOnly = false,
    this.filterVerifiedOnly = false,
    this.filterNotSeenOnly = false,
    this.filterNearbyOnly = false,
    this.filterCriteria = const MatchesFilterCriteria(),
  });

  int get totalActiveFilterCount {
    int count = filterCriteria.activeCount;
    if (selectedOccupations.isNotEmpty) count += selectedOccupations.length;
    if (filterPhotoOnly) count++;
    if (filterVerifiedOnly) count++;
    if (filterNotSeenOnly) count++;
    if (filterNearbyOnly) count++;
    return count;
  }

  bool get hasActiveFilters => totalActiveFilterCount > 0 || activeMoreQueryCode != null;

  List<MatchResult> get filteredMatches {
    // 1. Exclude hidden profiles everywhere
    var list = allMatches.where((m) => !hiddenProfileIds.contains(m.profile.profileId)).toList();

    // 2. Tab or More Query filter
    if (activeMoreQueryCode != null) {
      // Applied in load/run query
    } else if (currentTab == MatchesFilterTab.newlyJoined) {
      final now = DateTime.now();
      list = list.where((m) {
        if (m.profile.isDemo) return true;
        final created = DateTime.tryParse(m.profile.createdAt);
        if (created == null) return false;
        return now.difference(created).inDays <= 30;
      }).toList();
    }

    // 3. Quick Chips filters
    if (filterPhotoOnly) {
      list = list.where((m) => m.profile.primaryPhoto != null && m.profile.primaryPhoto!.trim().isNotEmpty).toList();
    }
    if (filterVerifiedOnly) {
      list = list.where((m) => m.profile.isVerified || m.profile.completenessPct >= 80).toList();
    }
    if (filterNotSeenOnly) {
      list = list.where((m) => !viewedProfileIds.contains(m.profile.profileId)).toList();
    }
    if (filterNearbyOnly) {
      const nearby = ['puducherry', 'karaikal', 'cuddalore', 'villupuram'];
      list = list.where((m) => nearby.contains(m.profile.district.toLowerCase())).toList();
    }

    // 4. Occupation Filter
    if (selectedOccupations.isNotEmpty) {
      list = list.where((m) {
        final occ = m.profile.occupation.toLowerCase();
        final edu = m.profile.education.toLowerCase();
        final emp = m.profile.employmentType.toLowerCase();

        return selectedOccupations.any((chip) {
          switch (chip.toLowerCase()) {
            case 'doctor':
              return occ.contains('doctor') || occ.contains('physician') || occ.contains('dentist') || edu.contains('mbbs') || edu.contains('bds');
            case 'techie':
              return occ.contains('software') || occ.contains('tech') || occ.contains('developer') || occ.contains('data') || occ.contains('qa') || occ.contains('it');
            case 'advocate':
              return occ.contains('advocate') || occ.contains('law') || occ.contains('legal') || edu.contains('llb') || edu.contains('b.l');
            case 'engineer':
              return occ.contains('engineer') || occ.contains('civil') || occ.contains('mechanical') || occ.contains('electrical') || occ.contains('architect');
            case 'professor':
            case 'teacher':
              return occ.contains('teacher') || occ.contains('professor') || occ.contains('lecturer');
            case 'ca':
              return occ.contains('ca') || occ.contains('accountant') || occ.contains('auditor');
            case 'business':
              return occ.contains('business') || occ.contains('entrepreneur') || emp.contains('business');
            case 'government':
              return occ.contains('govt') || occ.contains('government') || occ.contains('civil_servant') || emp.contains('government');
            case 'defence':
              return occ.contains('defence') || occ.contains('army') || occ.contains('navy') || occ.contains('air_force');
            default:
              return occ.contains(chip.toLowerCase());
          }
        });
      }).toList();
    }

    // 5. Custom filter criteria
    if (!filterCriteria.isEmpty) {
      list = list.where((m) {
        final p = m.profile;
        if (filterCriteria.ageMin != null && p.age < filterCriteria.ageMin!) return false;
        if (filterCriteria.ageMax != null && p.age > filterCriteria.ageMax!) return false;
        if (filterCriteria.heightMinCm != null && p.heightCm < filterCriteria.heightMinCm!) return false;
        if (filterCriteria.heightMaxCm != null && p.heightCm > filterCriteria.heightMaxCm!) return false;
        if (filterCriteria.maritalStatus != null && filterCriteria.maritalStatus != 'all' && p.maritalStatus.toLowerCase() != filterCriteria.maritalStatus!.toLowerCase()) return false;
        if (filterCriteria.religion != null && filterCriteria.religion != 'all' && p.religion.toLowerCase() != filterCriteria.religion!.toLowerCase()) return false;
        if (filterCriteria.caste != null && filterCriteria.caste != 'all' && !p.caste.toLowerCase().contains(filterCriteria.caste!.toLowerCase())) return false;
        if (filterCriteria.motherTongue != null && filterCriteria.motherTongue != 'all' && p.motherTongue.toLowerCase() != filterCriteria.motherTongue!.toLowerCase()) return false;
        if (filterCriteria.diet != null && filterCriteria.diet != 'all' && p.diet.toLowerCase() != filterCriteria.diet!.toLowerCase()) return false;
        if (filterCriteria.district != null && filterCriteria.district != 'all' && p.district.toLowerCase() != filterCriteria.district!.toLowerCase()) return false;
        if (filterCriteria.distanceRadiusKm != null) {
          final dist = LocationService.instance.getDistanceToCandidate(
            p.profileId,
            targetDistrict: p.district,
          );
          if (dist != null && dist > filterCriteria.distanceRadiusKm!) return false;
        }
        if (filterCriteria.hasHoroscope == true && (p.star.isEmpty || p.star == 'none')) return false;
        if (filterCriteria.localities.isNotEmpty) {
          if (!filterCriteria.localities.any((loc) => p.locality.toLowerCase() == loc.toLowerCase())) {
            return false;
          }
        }
        if (filterCriteria.cities.isNotEmpty) {
          if (!filterCriteria.cities.any((c) => p.city.toLowerCase() == c.toLowerCase())) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    // 6. Sort
    final sorted = List<MatchResult>.from(list);
    switch (sortOrder) {
      case 'date_created':
        sorted.sort((a, b) => b.profile.createdAt.compareTo(a.profile.createdAt));
        break;
      case 'latest_photos':
        sorted.sort((a, b) {
          final aHas = a.profile.primaryPhoto != null && a.profile.primaryPhoto!.isNotEmpty;
          final bHas = b.profile.primaryPhoto != null && b.profile.primaryPhoto!.isNotEmpty;
          if (aHas && !bHas) return -1;
          if (!aHas && bHas) return 1;
          return b.score.compareTo(a.score);
        });
        break;
      case 'distance':
        // Nearer locations first using real Haversine distance
        sorted.sort((a, b) {
          final distA = LocationService.instance.getDistanceToCandidate(
                a.profile.profileId,
                targetDistrict: a.profile.district,
              ) ??
              99999.0;
          final distB = LocationService.instance.getDistanceToCandidate(
                b.profile.profileId,
                targetDistrict: b.profile.district,
              ) ??
              99999.0;
          return distA.compareTo(distB);
        });
        break;
      case 'best_match':
        sorted.sort((a, b) => b.score.compareTo(a.score));
        break;
      case 'last_active':
      default:
        sorted.sort((a, b) {
          if (a.profile.isVerified && !b.profile.isVerified) return -1;
          if (!a.profile.isVerified && b.profile.isVerified) return 1;
          return b.score.compareTo(a.score);
        });
        break;
    }

    return sorted;
  }

  MatchesState copyWith({
    bool? isLoading,
    String? error,
    List<MatchResult>? allMatches,
    Set<String>? shortlistedIds,
    Set<String>? sentInterestIds,
    Set<String>? viewedProfileIds,
    Set<String>? hiddenProfileIds,
    MatchesFilterTab? currentTab,
    String? activeMoreQueryCode,
    String? activeMoreQueryTitle,
    String? sortOrder,
    Set<String>? selectedOccupations,
    bool? filterPhotoOnly,
    bool? filterVerifiedOnly,
    bool? filterNotSeenOnly,
    bool? filterNearbyOnly,
    MatchesFilterCriteria? filterCriteria,
  }) {
    return MatchesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allMatches: allMatches ?? this.allMatches,
      shortlistedIds: shortlistedIds ?? this.shortlistedIds,
      sentInterestIds: sentInterestIds ?? this.sentInterestIds,
      viewedProfileIds: viewedProfileIds ?? this.viewedProfileIds,
      hiddenProfileIds: hiddenProfileIds ?? this.hiddenProfileIds,
      currentTab: currentTab ?? this.currentTab,
      activeMoreQueryCode: activeMoreQueryCode ?? this.activeMoreQueryCode,
      activeMoreQueryTitle: activeMoreQueryTitle ?? this.activeMoreQueryTitle,
      sortOrder: sortOrder ?? this.sortOrder,
      selectedOccupations: selectedOccupations ?? this.selectedOccupations,
      filterPhotoOnly: filterPhotoOnly ?? this.filterPhotoOnly,
      filterVerifiedOnly: filterVerifiedOnly ?? this.filterVerifiedOnly,
      filterNotSeenOnly: filterNotSeenOnly ?? this.filterNotSeenOnly,
      filterNearbyOnly: filterNearbyOnly ?? this.filterNearbyOnly,
      filterCriteria: filterCriteria ?? this.filterCriteria,
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

      // Filter opposite gender
      final oppositeGender = myProfile.gender.toLowerCase() == 'male' ? 'Female' : 'Male';
      final candidates = allProfiles.where((p) => p.profileId != myProfile!.profileId && p.gender.toLowerCase() == oppositeGender.toLowerCase()).toList();

      final matches = MatchingEngine.instance.findMatches(
        myProfile: myProfile,
        myPrefs: prefs,
        candidates: candidates,
        sortOrder: state.sortOrder,
      );

      // Load shortlists
      final shortlistedProfiles = await _shortlistRepo.getShortlistedProfiles(myProfile.profileId);
      final shortlistedSet = shortlistedProfiles.map((p) => p.profileId).toSet();

      // Load sent interests
      final sentInterests = await _interestRepo.getSentInterests(myProfile.profileId);
      final sentSet = sentInterests.map((i) => i.toProfile).toSet();

      // Load views
      final viewedProfiles = await _profileRepo.getRecentlyViewedByMe(myProfile.profileId);
      final viewedSet = viewedProfiles.map((p) => p.profileId).toSet();

      // Load hidden profiles
      final hiddenIds = await _profileRepo.getHiddenProfileIds(myProfile.profileId);

      state = state.copyWith(
        isLoading: false,
        allMatches: matches,
        shortlistedIds: shortlistedSet,
        sentInterestIds: sentSet,
        viewedProfileIds: viewedSet,
        hiddenProfileIds: hiddenIds.toSet(),
      );

      // Restore persisted filter state
      await _loadPersistedFilterState(myProfile.userId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilterTab(MatchesFilterTab tab) {
    if (tab == MatchesFilterTab.more) return;
    if (tab == MatchesFilterTab.newToday) {
      state = state.copyWith(
        currentTab: MatchesFilterTab.newlyJoined,
        activeMoreQueryCode: null,
        activeMoreQueryTitle: null,
      );
      return;
    }
    if (tab == MatchesFilterTab.nearby) {
      selectMoreQuery('nearby_matches', 'Nearby matches');
      return;
    }
    if (tab == MatchesFilterTab.mutual) {
      selectMoreQuery('mutual_matches', 'Mutual matches');
      return;
    }
    state = state.copyWith(
      currentTab: tab,
      activeMoreQueryCode: null,
      activeMoreQueryTitle: null,
    );
  }

  Future<void> selectMoreQuery(String queryCode, String titleEn) async {
    state = state.copyWith(isLoading: true);
    try {
      final authState = _ref.read(authStateProvider);
      final myProfile = authState.profile ?? state.allMatches.first.profile;
      final myPrefs = await _profileRepo.getPartnerPrefs(myProfile.profileId) ??
          PartnerPrefModel(profileId: myProfile.profileId);

      final oppositeGender = myProfile.gender.toLowerCase() == 'male' ? 'Female' : 'Male';
      final allProfiles = await _profileRepo.getAllProfiles(includeDemo: true);
      final candidates = allProfiles.where((p) => p.profileId != myProfile.profileId && p.gender.toLowerCase() == oppositeGender.toLowerCase()).toList();

      List<MatchResult> results = [];
      final queries = MatchingQueries.instance;

      switch (queryCode) {
        case 'shortlisted_you':
          final whoShortlisted = await _shortlistRepo.getShortlistedProfiles(myProfile.profileId);
          results = queries.getShortlistedYou(
            myProfile: myProfile,
            myPrefs: myPrefs,
            candidates: candidates,
            shortlistedYouProfileIds: whoShortlisted.map((p) => p.profileId).toSet(),
          );
          break;
        case 'viewed_you':
          final whoViewed = await _profileRepo.getProfilesWhoViewedMe(myProfile.profileId);
          results = queries.getViewedYou(
            myProfile: myProfile,
            myPrefs: myPrefs,
            candidates: candidates,
            viewedYouProfileIds: whoViewed.map((p) => p.profileId).toSet(),
          );
          break;
        case 'shortlisted_by_you':
          results = queries.getShortlistedByYou(
            myProfile: myProfile,
            myPrefs: myPrefs,
            candidates: candidates,
            shortlistedByYouProfileIds: state.shortlistedIds,
          );
          break;
        case 'viewed_by_you':
          results = queries.getViewedByYou(
            myProfile: myProfile,
            myPrefs: myPrefs,
            candidates: candidates,
            viewedByYouProfileIds: state.viewedProfileIds,
          );
          break;
        case 'newly_joined':
          results = queries.getNewlyJoined(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'nearby_matches':
          results = queries.getNearbyMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'photo_matches':
          results = queries.getPhotoMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'horoscope_matches':
          results = queries.getHoroscopeMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'star_matches':
          results = queries.getStarMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'porutham_10_matches':
          results = queries.getPorutham10Matches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'mutual_matches':
          results = queries.getMutualMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'looking_for_you':
          results = queries.getLookingForYou(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'education_pref':
          results = queries.getEducationPrefMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'professional_pref':
          results = queries.getProfessionalPrefMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'location_pref':
          results = queries.getLocationPrefMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'nri_matches':
          results = queries.getNriMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        case 'verified_matches':
          results = queries.getVerifiedMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
          break;
        default:
          results = state.allMatches;
          break;
      }

      state = state.copyWith(
        isLoading: false,
        allMatches: results,
        activeMoreQueryCode: queryCode,
        activeMoreQueryTitle: titleEn,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearMoreQuery() {
    state = state.copyWith(
      activeMoreQueryCode: null,
      activeMoreQueryTitle: null,
    );
    loadMatches();
  }

  void setSortOrder(String sort) {
    state = state.copyWith(sortOrder: sort);
    _persistFilterState();
  }

  void toggleOccupationFilter(String occupationChipCode) {
    final updated = Set<String>.from(state.selectedOccupations);
    if (updated.contains(occupationChipCode)) {
      updated.remove(occupationChipCode);
    } else {
      updated.add(occupationChipCode);
    }
    state = state.copyWith(selectedOccupations: updated);
    _persistFilterState();
  }

  void selectSameProfessionAsMe() {
    final authState = _ref.read(authStateProvider);
    final myProfile = authState.profile;
    if (myProfile == null) return;

    final occ = myProfile.occupation.toLowerCase();
    String chipCode = 'techie';
    if (occ.contains('doctor') || occ.contains('physician') || occ.contains('dentist')) {
      chipCode = 'doctor';
    } else if (occ.contains('software') || occ.contains('tech') || occ.contains('data') || occ.contains('it')) {
      chipCode = 'techie';
    } else if (occ.contains('law') || occ.contains('advocate') || occ.contains('legal')) {
      chipCode = 'advocate';
    } else if (occ.contains('engineer') || occ.contains('civil') || occ.contains('mech')) {
      chipCode = 'engineer';
    } else if (occ.contains('teach') || occ.contains('professor') || occ.contains('lecturer')) {
      chipCode = 'professor';
    } else if (occ.contains('ca') || occ.contains('accountant')) {
      chipCode = 'ca';
    } else if (occ.contains('business') || occ.contains('entrepreneur')) {
      chipCode = 'business';
    } else if (occ.contains('govt') || occ.contains('government') || myProfile.employmentType == 'government') {
      chipCode = 'government';
    } else if (occ.contains('defence') || occ.contains('army')) {
      chipCode = 'defence';
    }

    state = state.copyWith(selectedOccupations: {chipCode});
    _persistFilterState();
  }

  void togglePhotoFilter() {
    state = state.copyWith(filterPhotoOnly: !state.filterPhotoOnly);
    _persistFilterState();
  }

  void toggleVerifiedFilter() {
    state = state.copyWith(filterVerifiedOnly: !state.filterVerifiedOnly);
    _persistFilterState();
  }

  void toggleNotSeenFilter() {
    state = state.copyWith(filterNotSeenOnly: !state.filterNotSeenOnly);
    _persistFilterState();
  }

  void toggleNearbyFilter() {
    state = state.copyWith(filterNearbyOnly: !state.filterNearbyOnly);
    _persistFilterState();
  }

  void applyFilterCriteria(MatchesFilterCriteria criteria) {
    state = state.copyWith(filterCriteria: criteria);
    _persistFilterState();
  }

  void toggleLocality(String locality) {
    final current = List<String>.from(state.filterCriteria.localities);
    if (current.any((l) => l.toLowerCase() == locality.toLowerCase())) {
      current.removeWhere((l) => l.toLowerCase() == locality.toLowerCase());
    } else {
      current.add(locality);
    }
    state = state.copyWith(
      filterCriteria: state.filterCriteria.copyWith(localities: current),
    );
    _persistFilterState();
  }

  void setLocality(String? locality) {
    final current = locality != null && locality.isNotEmpty ? [locality] : <String>[];
    state = state.copyWith(
      filterCriteria: state.filterCriteria.copyWith(localities: current),
    );
    _persistFilterState();
  }

  void clearLocalities() {
    state = state.copyWith(
      filterCriteria: state.filterCriteria.copyWith(localities: []),
    );
    _persistFilterState();
  }

  Map<String, int> getLocalityCounts() {
    final counts = <String, int>{};
    for (final m in state.allMatches) {
      final loc = m.profile.locality.trim();
      if (loc.isNotEmpty) {
        counts[loc] = (counts[loc] ?? 0) + 1;
      }
    }
    return counts;
  }

  void clearAllFilters() {
    state = state.copyWith(
      selectedOccupations: {},
      filterPhotoOnly: false,
      filterVerifiedOnly: false,
      filterNotSeenOnly: false,
      filterNearbyOnly: false,
      filterCriteria: const MatchesFilterCriteria(),
      activeMoreQueryCode: null,
      activeMoreQueryTitle: null,
      sortOrder: 'last_active',
    );
    _persistFilterState();
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

  Future<void> _persistFilterState() async {
    try {
      final auth = _ref.read(authStateProvider);
      final userId = auth.user?.userId ?? 'guest';
      final store = CsvStore.instance;

      final row = {
        'user_id': userId,
        'scope': 'matches',
        'filters_json_normalised': jsonEncode(state.filterCriteria.toJson()),
        'sort_code': state.sortOrder,
        'occupation_codes': state.selectedOccupations.join(';'),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final existing = await store.query(
        CsvSchema.userFilterStateTable,
        (r) => r['user_id'] == userId && r['scope'] == 'matches',
      );

      if (existing.isEmpty) {
        await store.insert(CsvSchema.userFilterStateTable, row);
      } else {
        await store.update(
          CsvSchema.userFilterStateTable,
          row,
          (r) => r['user_id'] == userId && r['scope'] == 'matches',
        );
      }
    } catch (_) {}
  }

  Future<void> _loadPersistedFilterState(String userId) async {
    try {
      final store = CsvStore.instance;
      final rows = await store.query(
        CsvSchema.userFilterStateTable,
        (r) => r['user_id'] == userId && r['scope'] == 'matches',
      );
      if (rows.isNotEmpty) {
        final r = rows.first;
        final sort = r['sort_code'] ?? 'last_active';
        final occs = (r['occupation_codes'] ?? '').split(';').where((s) => s.isNotEmpty).toSet();
        MatchesFilterCriteria criteria = const MatchesFilterCriteria();
        if (r['filters_json_normalised'] != null && r['filters_json_normalised']!.isNotEmpty) {
          try {
            criteria = MatchesFilterCriteria.fromJson(jsonDecode(r['filters_json_normalised']!));
          } catch (_) {}
        }
        state = state.copyWith(
          sortOrder: sort,
          selectedOccupations: occs,
          filterCriteria: criteria,
        );
      }
    } catch (_) {}
  }
}

final matchesProvider = StateNotifierProvider<MatchesNotifier, MatchesState>((ref) {
  final profileRepo = ref.watch(profileRepoProvider);
  final interestRepo = ref.watch(interestRepoProvider);
  final shortlistRepo = ref.watch(shortlistRepoProvider);
  return MatchesNotifier(profileRepo, interestRepo, shortlistRepo, ref);
});
