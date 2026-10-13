import '../models/partner_pref_model.dart';
import '../models/profile_model.dart';

class MatchResult {
  final ProfileModel profile;
  final int score; // 0 to 100
  final List<String> matchReasons;

  const MatchResult({
    required this.profile,
    required this.score,
    required this.matchReasons,
  });
}

class MatchingEngine {
  static final MatchingEngine instance = MatchingEngine._();
  MatchingEngine._();

  int calculateCompatibility({
    required ProfileModel myProfile,
    required ProfileModel candidate,
    required PartnerPrefModel myPrefs,
  }) {
    return calculateMatch(
      myProfile: myProfile,
      myPrefs: myPrefs,
      candidate: candidate,
    ).score;
  }

  MatchResult calculateMatch({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required ProfileModel candidate,
  }) {
    int score = 0;
    final reasons = <String>[];

    // 1. Age compatibility (up to 20 points)
    final age = candidate.age;
    if (age >= myPrefs.ageMin && age <= myPrefs.ageMax) {
      score += 20;
      reasons.add('Age Match (${candidate.age} yrs)');
    } else if ((age - myPrefs.ageMin).abs() <= 2 || (age - myPrefs.ageMax).abs() <= 2) {
      score += 10;
    }

    // 2. Height compatibility (up to 15 points)
    final height = candidate.heightCm;
    if (height >= myPrefs.heightMin && height <= myPrefs.heightMax) {
      score += 15;
      reasons.add('Height Match');
    } else if ((height - myPrefs.heightMin).abs() <= 5 || (height - myPrefs.heightMax).abs() <= 5) {
      score += 8;
    }

    // 3. Location / District compatibility (up to 15 points)
    final isSameDistrict = myProfile.district.toLowerCase() == candidate.district.toLowerCase();
    final isSameState = myProfile.state.toLowerCase() == candidate.state.toLowerCase();
    if (isSameDistrict) {
      score += 15;
      reasons.add('Same District (${candidate.city})');
    } else if (isSameState) {
      score += 10;
      reasons.add('Same State (${candidate.state})');
    } else if (myPrefs.district == 'all' || myPrefs.state == 'all') {
      score += 8;
    }

    // 4. Religion & Caste compatibility (up to 20 points)
    final isSameReligion = myProfile.religion.toLowerCase() == candidate.religion.toLowerCase();
    if (isSameReligion) {
      score += 12;
      reasons.add('Same Religion');
      final isSameCaste = myProfile.caste.toLowerCase() == candidate.caste.toLowerCase();
      if (isSameCaste && myProfile.caste != 'caste_none') {
        score += 8;
        reasons.add('Same Community');
      } else if (myProfile.willingOtherCaste || candidate.willingOtherCaste) {
        score += 8;
        reasons.add('Caste No Bar');
      }
    } else if (myProfile.willingOtherCaste) {
      score += 8;
    }

    // 5. Mother Tongue (up to 10 points)
    if (myProfile.motherTongue.toLowerCase() == candidate.motherTongue.toLowerCase()) {
      score += 10;
      reasons.add('Both ${candidate.motherTongue[0].toUpperCase()}${candidate.motherTongue.substring(1)}');
    }

    // 6. Education & Profession (up to 10 points)
    final isHighEdu = candidate.education.startsWith('be') ||
        candidate.education.startsWith('mbbs') ||
        candidate.education.startsWith('mba') ||
        candidate.education.startsWith('ca');
    if (isHighEdu) {
      score += 5;
      reasons.add('Professional Degree');
    }
    if (candidate.employmentType == 'private' || candidate.employmentType == 'government' || candidate.employmentType == 'business') {
      score += 5;
      reasons.add('Employed');
    }

    // 7. Marital status & Diet (up to 10 points)
    if (myPrefs.maritalStatus == 'all' || candidate.maritalStatus == myPrefs.maritalStatus) {
      score += 5;
    }
    if (myPrefs.diet == 'all' || candidate.diet == myPrefs.diet) {
      score += 5;
      reasons.add('Matching Diet');
    }

    final finalScore = score.clamp(35, 98);
    return MatchResult(
      profile: candidate,
      score: finalScore,
      matchReasons: reasons.take(4).toList(),
    );
  }

  List<MatchResult> findMatches({
    required ProfileModel myProfile,
    required PartnerPrefModel myPrefs,
    required List<ProfileModel> candidates,
    List<String> blockedIds = const [],
    String sortOrder = 'relevance',
  }) {
    final oppositeGender = myProfile.gender == 'Male' ? 'Female' : 'Male';

    final eligible = candidates.where((c) {
      if (c.profileId == myProfile.profileId) return false;
      if (c.gender != oppositeGender) return false;
      if (blockedIds.contains(c.profileId)) return false;
      return true;
    }).toList();

    final results = eligible.map((c) => calculateMatch(
      myProfile: myProfile,
      myPrefs: myPrefs,
      candidate: c,
    )).toList();

    if (sortOrder == 'relevance') {
      results.sort((a, b) => b.score.compareTo(a.score));
    } else if (sortOrder == 'newest') {
      results.sort((a, b) => b.profile.createdAt.compareTo(a.profile.createdAt));
    } else if (sortOrder == 'age') {
      results.sort((a, b) => a.profile.age.compareTo(b.profile.age));
    }

    return results;
  }
}
