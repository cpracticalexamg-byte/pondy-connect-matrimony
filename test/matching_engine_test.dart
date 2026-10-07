import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/domain/matching/matching_engine.dart';
import 'package:pondy_connect_matrimony/domain/models/partner_pref_model.dart';
import 'package:pondy_connect_matrimony/domain/models/profile_model.dart';

void main() {
  group('MatchingEngine Tests', () {
    const myProfile = ProfileModel(
      profileId: 'PC000001',
      userId: 'USR001',
      name: 'Vignesh',
      gender: 'Male',
      dob: '1998-05-15',
      age: 28,
      heightCm: 175,
      maritalStatus: 'Never Married',
      motherTongue: 'Tamil',
      religion: 'Hindu',
      division: '',
      caste: 'caste_mudaliar',
      subcaste: '',
      star: 'star_hastha',
      rasi: 'rasi_kanni',
      dosham: 'dosham_none',
      country: 'India',
      state: 'Puducherry',
      district: 'Puducherry',
      city: 'White Town',
      citizenship: 'Indian',
      education: 'be_btech',
      educationDetail: 'Computer Science',
      employmentType: 'private',
      occupation: 'Software Engineer',
      employer: 'Tech Corp',
      incomeCurrency: 'INR',
      annualIncomeRange: '10-15 Lakhs',
      familyStatus: 'Middle Class',
      familyType: 'Nuclear',
      familyValues: 'Traditional',
      fatherOccupation: 'Business',
      motherOccupation: 'Homemaker',
      diet: 'Vegetarian',
      smoking: 'No',
      drinking: 'No',
      aboutMe: 'Simple and caring person',
      profilePhotoPrivacy: 'all',
      completenessPct: 90,
      createdAt: '2026-01-01T00:00:00',
      updatedAt: '2026-01-01T00:00:00',
    );

    const prefs = PartnerPrefModel(
      profileId: 'PC000001',
      ageMin: 23,
      ageMax: 27,
      heightMin: 155,
      heightMax: 170,
      religion: 'Hindu',
      caste: 'caste_mudaliar',
      district: 'Puducherry',
      maritalStatus: 'Never Married',
      diet: 'Vegetarian',
    );

    test('Candidate matching full criteria receives high score (80+)', () {
      const highlyCompatibleCandidate = ProfileModel(
        profileId: 'PC000002',
        userId: 'USR002',
        name: 'Lavanya',
        gender: 'Female',
        dob: '2001-08-20',
        age: 25,
        heightCm: 162,
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        division: '',
        caste: 'caste_mudaliar',
        subcaste: '',
        star: 'star_rohini',
        rasi: 'rasi_rishabam',
        dosham: 'dosham_none',
        country: 'India',
        state: 'Puducherry',
        district: 'Puducherry',
        city: 'Lawspet',
        citizenship: 'Indian',
        education: 'be_btech',
        educationDetail: 'Information Technology',
        employmentType: 'private',
        occupation: 'Data Analyst',
        employer: 'Global Systems',
        incomeCurrency: 'INR',
        annualIncomeRange: '7-10 Lakhs',
        familyStatus: 'Middle Class',
        familyType: 'Nuclear',
        familyValues: 'Traditional',
        fatherOccupation: 'Teacher',
        motherOccupation: 'Homemaker',
        diet: 'Vegetarian',
        smoking: 'No',
        drinking: 'No',
        aboutMe: 'Looking for a compatible partner',
        profilePhotoPrivacy: 'all',
        completenessPct: 85,
        createdAt: '2026-01-02T00:00:00',
        updatedAt: '2026-01-02T00:00:00',
      );

      final result = MatchingEngine.instance.calculateMatch(
        myProfile: myProfile,
        myPrefs: prefs,
        candidate: highlyCompatibleCandidate,
      );

      expect(result.score, greaterThanOrEqualTo(80));
      expect(result.matchReasons.isNotEmpty, isTrue);
      expect(result.matchReasons.any((r) => r.contains('Age Match')), isTrue);
      expect(result.matchReasons.any((r) => r.contains('Same Religion') || r.contains('Same Community')), isTrue);
    });

    test('Filters out same-gender profiles from candidate list', () {
      const maleCandidate = ProfileModel(
        profileId: 'PC000003',
        userId: 'USR003',
        name: 'Suresh',
        gender: 'Male',
        dob: '1999-01-01',
        age: 27,
        heightCm: 172,
        maritalStatus: 'Never Married',
        motherTongue: 'Tamil',
        religion: 'Hindu',
        division: '',
        caste: 'caste_mudaliar',
        subcaste: '',
        star: 'star_swati',
        rasi: 'rasi_thulam',
        dosham: 'dosham_none',
        country: 'India',
        state: 'Puducherry',
        district: 'Puducherry',
        city: 'Puducherry',
        citizenship: 'Indian',
        education: 'be_btech',
        employmentType: 'private',
        occupation: 'Engineer',
        annualIncomeRange: '10-15 Lakhs',
        diet: 'Vegetarian',
        smoking: 'No',
        drinking: 'No',
        aboutMe: 'Bio',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      );

      final results = MatchingEngine.instance.findMatches(
        myProfile: myProfile,
        myPrefs: prefs,
        candidates: [maleCandidate],
      );

      expect(results, isEmpty);
    });
  });
}
