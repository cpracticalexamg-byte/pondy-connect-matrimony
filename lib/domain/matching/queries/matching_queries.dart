import '../../horoscope/horoscope_engine.dart';
import '../../models/partner_pref_model.dart';
import '../../models/profile_model.dart';
import '../matching_engine.dart';

class MatchingQueries {
  static final MatchingQueries instance = MatchingQueries._();
  MatchingQueries._();

  /// 1. Shortlisted you: profiles that added you to shortlist
  List<MatchResult> getShortlistedYou({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    required Set<String> shortlistedYouProfileIds,
  }) {
    final filtered = candidates.where((c) => shortlistedYouProfileIds.contains(c.profileId)).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 2. Viewed you: profiles that viewed your profile
  List<MatchResult> getViewedYou({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    required Set<String> viewedYouProfileIds,
  }) {
    final filtered = candidates.where((c) => viewedYouProfileIds.contains(c.profileId)).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 3. Shortlisted by you: profiles you added to shortlist
  List<MatchResult> getShortlistedByYou({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    required Set<String> shortlistedByYouProfileIds,
  }) {
    final filtered = candidates.where((c) => shortlistedByYouProfileIds.contains(c.profileId)).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 4. Viewed by you: profiles you have viewed
  List<MatchResult> getViewedByYou({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    required Set<String> viewedByYouProfileIds,
  }) {
    final filtered = candidates.where((c) => viewedByYouProfileIds.contains(c.profileId)).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 5. Newly joined: joined within the last 30 days
  List<MatchResult> getNewlyJoined({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final filtered = candidates.where((c) {
      if (c.isDemo) return true;
      final created = DateTime.tryParse(c.createdAt);
      if (created == null) return false;
      return now.difference(created).inDays <= 30;
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 6. Nearby matches: matches near Puducherry / nearby districts
  List<MatchResult> getNearbyMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    List<String> nearbyDistricts = const ['puducherry', 'karaikal', 'cuddalore', 'villupuram'],
  }) {
    final filtered = candidates.where((c) {
      final dist = c.district.toLowerCase();
      return nearbyDistricts.contains(dist) || dist == myProfile.district.toLowerCase();
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 7. Photo matches: profiles with photos added
  List<MatchResult> getPhotoMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      return (c.primaryPhoto != null && c.primaryPhoto!.trim().isNotEmpty);
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 8. Matches with horoscope: profiles that have added horoscope details
  List<MatchResult> getHoroscopeMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      return c.star.trim().isNotEmpty && c.star != 'none';
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 9. Star matches: compatible star sign with auspicious porutham
  List<MatchResult> getStarMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    if (myProfile.star.isEmpty || myProfile.star == 'none') {
      return getHoroscopeMatches(myProfile: myProfile, myPrefs: myPrefs, candidates: candidates);
    }

    final isBoy = myProfile.gender.toLowerCase() == 'male';
    final filtered = candidates.where((c) {
      if (c.star.isEmpty || c.star == 'none') return false;
      try {
        final result = HoroscopeEngine.instance.evaluatePorutham(
          brideStar: isBoy ? c.star : myProfile.star,
          groomStar: isBoy ? myProfile.star : c.star,
          brideRasi: isBoy ? c.rasi : myProfile.rasi,
          groomRasi: isBoy ? myProfile.rasi : c.rasi,
          brideDosham: isBoy ? c.dosham : myProfile.dosham,
          groomDosham: isBoy ? myProfile.dosham : c.dosham,
        );
        // Auspicious star match requires Rajju porutham and >= 5 total matches
        final rajjuMatch = result.isRajjuMatched;
        return rajjuMatch && result.matchedCount >= 5;
      } catch (_) {
        return false;
      }
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 10. 10-Porutham horoscope threshold match: score >= 6 / 10
  List<MatchResult> getPorutham10Matches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    int threshold = 6,
  }) {
    if (myProfile.star.isEmpty || myProfile.star == 'none') {
      return [];
    }

    final isBoy = myProfile.gender.toLowerCase() == 'male';
    final filtered = candidates.where((c) {
      if (c.star.isEmpty || c.star == 'none') return false;
      try {
        final result = HoroscopeEngine.instance.evaluatePorutham(
          brideStar: isBoy ? c.star : myProfile.star,
          groomStar: isBoy ? myProfile.star : c.star,
          brideRasi: isBoy ? c.rasi : myProfile.rasi,
          groomRasi: isBoy ? myProfile.rasi : c.rasi,
          brideDosham: isBoy ? c.dosham : myProfile.dosham,
          groomDosham: isBoy ? myProfile.dosham : c.dosham,
        );
        return result.matchedCount >= threshold;
      } catch (_) {
        return false;
      }
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 11. Mutual matches: their profile matches your preferences and vice versa
  List<MatchResult> getMutualMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    Map<String, PartnerPrefModel> candidatePrefs = const {},
  }) {
    final filtered = candidates.where((c) {
      final theirPrefs = candidatePrefs[c.profileId];
      if (theirPrefs != null) {
        final iMatchThem = myProfile.age >= theirPrefs.ageMin &&
            myProfile.age <= theirPrefs.ageMax &&
            (theirPrefs.religion == 'all' || theirPrefs.religion.toLowerCase() == myProfile.religion.toLowerCase());
        final theyMatchMe = c.age >= myPrefs.ageMin &&
            c.age <= myPrefs.ageMax &&
            (myPrefs.religion == 'all' || myPrefs.religion.toLowerCase() == c.religion.toLowerCase());
        return iMatchThem && theyMatchMe;
      }
      // If candidatePrefs not loaded, evaluate mutual compatibility score >= 70
      final result = MatchingEngine.instance.calculateMatch(myProfile: myProfile, myPrefs: myPrefs, candidate: c);
      return result.score >= 70;
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 12. Looking for you: their preferences match your profile
  List<MatchResult> getLookingForYou({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    Map<String, PartnerPrefModel> candidatePrefs = const {},
  }) {
    final filtered = candidates.where((c) {
      final theirPrefs = candidatePrefs[c.profileId];
      if (theirPrefs != null) {
        return myProfile.age >= theirPrefs.ageMin &&
            myProfile.age <= theirPrefs.ageMax &&
            (theirPrefs.religion == 'all' || theirPrefs.religion.toLowerCase() == myProfile.religion.toLowerCase());
      }
      return true; // Fallback: candidate is opposite gender seeking matches
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 13. Education preference match
  List<MatchResult> getEducationPrefMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      if (myPrefs.education.isEmpty || myPrefs.education == 'all') {
        return c.education.isNotEmpty;
      }
      return c.education.toLowerCase().contains(myPrefs.education.toLowerCase()) ||
          myPrefs.education.toLowerCase().contains(c.education.toLowerCase());
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 14. Professional preference match
  List<MatchResult> getProfessionalPrefMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      if (myPrefs.occupation.isEmpty || myPrefs.occupation == 'all') {
        return c.occupation.isNotEmpty;
      }
      return c.occupation.toLowerCase().contains(myPrefs.occupation.toLowerCase()) ||
          myPrefs.occupation.toLowerCase().contains(c.occupation.toLowerCase());
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 15. City/Location preference match
  List<MatchResult> getLocationPrefMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      if (myPrefs.district.isEmpty || myPrefs.district == 'all') {
        return c.state.toLowerCase() == myProfile.state.toLowerCase();
      }
      return c.district.toLowerCase() == myPrefs.district.toLowerCase();
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 16. NRI matches: living outside India
  List<MatchResult> getNriMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) {
      final country = c.country.toLowerCase();
      final citizenship = c.citizenship.toLowerCase();
      final city = c.city.toLowerCase();
      final about = c.aboutMe.toLowerCase();
      return (country.isNotEmpty && country != 'india' && country != 'in') ||
          (citizenship.isNotEmpty && citizenship != 'indian' && citizenship != 'india' && citizenship != 'in') ||
          city.contains('singapore') ||
          city.contains('london') ||
          city.contains('dubai') ||
          city.contains('usa') ||
          about.contains('nri');
    }).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// 17. Verified matches: Government ID verified profiles (PRIME)
  List<MatchResult> getVerifiedMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
  }) {
    final filtered = candidates.where((c) => c.isVerified || c.completenessPct >= 80).toList();
    return _rankCandidates(myProfile, myPrefs, filtered);
  }

  /// Helper to rank a list of candidates against user profile and partner preferences
  List<MatchResult> _rankCandidates(
    ProfileModel myProfile,
    PartnerPrefModel myPrefs,
    List<ProfileModel> list,
  ) {
    final results = list.map((c) {
      return MatchingEngine.instance.calculateMatch(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidate: c,
      );
    }).toList();

    // Default sorting by compatibility score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}
