import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../data/csv/csv_schema.dart';
import '../../data/csv/csv_store.dart';
import '../../data/repositories/profile_repository.dart';
import '../location/location_service.dart';
import '../matching/matching_engine.dart';
import '../models/partner_pref_model.dart';
import '../models/profile_model.dart';

class DailyRecommendationsEngine {
  static final DailyRecommendationsEngine instance = DailyRecommendationsEngine._();
  DailyRecommendationsEngine._();

  /// Computes up to 8 daily recommendations deterministically per (user, calendarDate).
  /// Hard filters:
  /// - Opposite gender
  /// - Not blocked
  /// - Not hidden ("Don't Show")
  /// - Not already interested / declined
  /// - Not previously recommended in the last 14 days
  /// - Within partner preference hard limits (age/marital/religion if set)
  /// - Max 3 from the same city for diversity
  Future<List<MatchResult>> getDailyRecommendations({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> allCandidates,
    required ProfileRepository profileRepo,
    DateTime? calendarDate,
  }) async {
    final date = calendarDate ?? DateTime.now();
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // 1. Check if recommendations for today are already persisted in daily_recommendations table
    final store = CsvStore.instance;
    final existingTodayRows = await store.query(
      CsvSchema.dailyRecommendationsTable,
      (r) => r['user_profile_id'] == myProfile.profileId && r['rec_date'] == dateStr,
    );

    if (existingTodayRows.isNotEmpty) {
      // Sort by position
      final sortedRows = List<Map<String, String>>.from(existingTodayRows)
        ..sort((a, b) => (int.tryParse(a['position'] ?? '0') ?? 0)
            .compareTo(int.tryParse(b['position'] ?? '0') ?? 0));

      final candidateMap = {for (var c in allCandidates) c.profileId: c};
      final List<MatchResult> cachedResults = [];

      for (final r in sortedRows) {
        final pid = r['profile_id'] ?? '';
        final profile = candidateMap[pid];
        if (profile != null) {
          cachedResults.add(MatchResult(
            profile: profile,
            score: MatchingEngine.instance.calculateCompatibility(
              myProfile: myProfile,
              candidate: profile,
              myPrefs: myPrefs,
            ),
            matchReasons: ['Daily Pick', if (profile.isVerified) 'ID Verified'],
          ));
        }
      }

      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }
    }

    // 2. Fetch hidden profiles
    final hiddenIds = (await profileRepo.getHiddenProfileIds(myProfile.profileId)).toSet();

    // 3. Fetch past 14 days recommended profile IDs
    final cutoff14Days = date.subtract(const Duration(days: 14));
    final pastRecRows = await store.query(
      CsvSchema.dailyRecommendationsTable,
      (r) {
        if (r['user_profile_id'] != myProfile.profileId) return false;
        final rDate = DateTime.tryParse(r['rec_date'] ?? '');
        if (rDate == null) return false;
        return rDate.isAfter(cutoff14Days);
      },
    );
    final past14DaysProfileIds = pastRecRows.map((r) => r['profile_id'] ?? '').toSet();

    // 4. Hard Filter Opposite gender & active
    final oppositeGender = myProfile.gender.toLowerCase() == 'male' ? 'Female' : 'Male';
    var pool = allCandidates.where((c) {
      if (c.profileId == myProfile.profileId) return false;
      if (c.gender.toLowerCase() != oppositeGender.toLowerCase()) return false;
      if (hiddenIds.contains(c.profileId)) return false;
      if (past14DaysProfileIds.contains(c.profileId)) return false;

      // Partner preference hard limits
      if (myPrefs.ageMin > 0 && c.age < myPrefs.ageMin) return false;
      if (myPrefs.ageMax > 0 && c.age > myPrefs.ageMax) return false;
      if (myPrefs.religion != 'all' && myPrefs.religion.isNotEmpty) {
        if (c.religion.toLowerCase() != myPrefs.religion.toLowerCase()) return false;
      }
      if (myPrefs.maritalStatus != 'all' && myPrefs.maritalStatus.isNotEmpty) {
        if (c.maritalStatus.toLowerCase() != myPrefs.maritalStatus.toLowerCase()) return false;
      }

      return true;
    }).toList();

    // 5. Score candidates
    final scoredList = pool.map((c) {
      var score = MatchingEngine.instance.calculateCompatibility(
        myProfile: myProfile,
        candidate: c,
        myPrefs: myPrefs,
      );

      // Bonuses:
      if (c.primaryPhoto != null && c.primaryPhoto!.isNotEmpty) score += 5;
      if (c.isVerified) score += 10;

      final dist = LocationService.instance.getDistanceToCandidate(c.profileId, targetDistrict: c.district);
      if (dist != null && dist <= 25.0) score += 5;

      return MatchResult(
        profile: c,
        score: score.clamp(0, 100),
        matchReasons: [
          'High Compatibility',
          if (c.isVerified) 'Verified Profile',
          if (dist != null && dist <= 10.0) 'Nearby You',
        ],
      );
    }).toList();

    // 6. Deterministic Sort per (user_id + dateStr)
    final seed = '${myProfile.userId}_$dateStr';
    final seedHash = md5.convert(utf8.encode(seed)).bytes;

    scoredList.sort((a, b) {
      // Primary: Score descending
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;

      // Secondary: Deterministic hash tie-breaker
      final hashA = md5.convert(utf8.encode('$seedHash${a.profile.profileId}')).toString();
      final hashB = md5.convert(utf8.encode('$seedHash${b.profile.profileId}')).toString();
      return hashA.compareTo(hashB);
    });

    // 7. Ensure diversity: no more than 3 from the same city
    final Map<String, int> cityCounts = {};
    final List<MatchResult> chosen = [];

    for (final match in scoredList) {
      final cityKey = match.profile.city.toLowerCase().trim();
      final count = cityCounts[cityKey] ?? 0;
      if (count < 3) {
        chosen.add(match);
        cityCounts[cityKey] = count + 1;
        if (chosen.length >= 8) break;
      }
    }

    // 8. Persist to daily_recommendations table
    for (int i = 0; i < chosen.length; i++) {
      final m = chosen[i];
      final row = {
        'rec_id': 'REC_${myProfile.profileId}_${dateStr}_${m.profile.profileId}',
        'user_profile_id': myProfile.profileId,
        'profile_id': m.profile.profileId,
        'rec_date': dateStr,
        'position': '${i + 1}',
        'status': 'shown',
        'acted_at': DateTime.now().toUtc().toIso8601String(),
      };
      try {
        await store.insert(CsvSchema.dailyRecommendationsTable, row);
      } catch (_) {}
    }

    return chosen;
  }

  /// Record user action on recommendation
  Future<void> recordRecommendationAction({
    required String userProfileId,
    required String targetProfileId,
    required String action, // 'skipped', 'interest_sent', 'dont_show', 'shortlisted'
  }) async {
    final nowStr = DateTime.now().toUtc().toIso8601String();
    try {
      final store = CsvStore.instance;
      await store.update(
        CsvSchema.dailyRecommendationsTable,
        {
          'status': action,
          'acted_at': nowStr,
        },
        (r) => r['user_profile_id'] == userProfileId && r['profile_id'] == targetProfileId,
      );
    } catch (_) {}
  }
}
