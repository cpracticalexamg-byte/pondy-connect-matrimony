import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/domain/matching/matching_engine.dart';
import 'package:pondy_connect_matrimony/domain/matching/queries/matching_queries.dart';
import 'package:pondy_connect_matrimony/domain/models/partner_pref_model.dart';
import 'package:pondy_connect_matrimony/domain/models/profile_model.dart';
import 'package:pondy_connect_matrimony/features/matches/providers/matches_provider.dart';
import 'package:pondy_connect_matrimony/features/matches/widgets/filter_sheet.dart';
import 'package:pondy_connect_matrimony/features/matches/widgets/more_menu_sheet.dart';
import 'package:pondy_connect_matrimony/features/matches/widgets/occupation_chips_strip.dart';
import 'package:pondy_connect_matrimony/features/matches/widgets/sort_sheet.dart';

ProfileModel _createSampleProfile({
  required String id,
  required String name,
  required String gender,
  required int age,
  required String occupation,
  required String education,
  required String district,
  String city = 'Puducherry',
  String country = 'India',
  String citizenship = 'India',
  String? photo,
  bool isVerified = false,
  String star = 'ashwini',
  String rasi = 'mesham',
  String dosham = 'none',
  DateTime? createdAt,
}) {
  return ProfileModel(
    profileId: id,
    userId: 'u_$id',
    name: name,
    gender: gender,
    dob: '1995-01-01',
    age: age,
    heightCm: 165,
    maritalStatus: 'never_married',
    religion: 'hindu',
    caste: 'mudaliar',
    motherTongue: 'tamil',
    education: education,
    occupation: occupation,
    annualIncomeRange: '5_to_7_lakhs',
    country: country,
    state: 'puducherry',
    district: district,
    city: city,
    diet: 'vegetarian',
    star: star,
    rasi: rasi,
    dosham: dosham,
    primaryPhotoUrl: photo,
    isVerified: isVerified,
    createdAt: (createdAt ?? DateTime.now()).toIso8601String(),
    updatedAt: (createdAt ?? DateTime.now()).toIso8601String(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final myProfile = _createSampleProfile(
    id: 'MY_P01',
    name: 'Groom User',
    gender: 'Male',
    age: 28,
    occupation: 'Software Engineer',
    education: 'B.Tech',
    district: 'puducherry',
    star: 'ashwini',
    rasi: 'mesham',
  );

  final myPrefs = PartnerPrefModel(
    profileId: myProfile.profileId,
    ageMin: 22,
    ageMax: 30,
    religion: 'hindu',
    education: 'b.tech',
    occupation: 'doctor',
    district: 'puducherry',
  );

  final candidates = [
    // 0: Doctor in Puducherry, has photo, star rohini
    _createSampleProfile(
      id: 'C_DOC',
      name: 'Dr. Ananya',
      gender: 'Female',
      age: 26,
      occupation: 'Doctor (MBBS)',
      education: 'MBBS',
      district: 'puducherry',
      photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      isVerified: true,
      star: 'rohini',
      rasi: 'rishabham',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // 1: Techie in Puducherry, no photo, star krittika
    _createSampleProfile(
      id: 'C_TECH',
      name: 'Kavitha',
      gender: 'Female',
      age: 27,
      occupation: 'IT Software Engineer',
      education: 'B.Tech',
      district: 'puducherry',
      isVerified: false,
      star: 'krittika',
      rasi: 'mesham',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    // 2: Advocate in Cuddalore (nearby), has photo
    _createSampleProfile(
      id: 'C_ADV',
      name: 'Priya Advocate',
      gender: 'Female',
      age: 29,
      occupation: 'Advocate Legal',
      education: 'B.L., LLB',
      district: 'cuddalore',
      city: 'Cuddalore',
      photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      isVerified: true,
      star: 'rohini',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    // 3: NRI in Singapore
    _createSampleProfile(
      id: 'C_NRI',
      name: 'Divya NRI',
      gender: 'Female',
      age: 28,
      occupation: 'Data Scientist',
      education: 'M.S.',
      district: 'singapore',
      country: 'Singapore',
      city: 'Singapore',
      isVerified: true,
      star: 'hastha',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    // 4: Profile with no horoscope / empty star
    _createSampleProfile(
      id: 'C_NOHORO',
      name: 'Meena',
      gender: 'Female',
      age: 25,
      occupation: 'School Teacher',
      education: 'B.Sc, B.Ed',
      district: 'karaikal',
      city: 'Karaikal',
      star: 'none',
      isVerified: false,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
    ),
  ];

  group('MatchingQueries V3 - 17 Query Systems', () {
    final queries = MatchingQueries.instance;

    test('1. Shortlisted you returns profiles that shortlisted me', () {
      final results = queries.getShortlistedYou(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        shortlistedYouProfileIds: {'C_DOC', 'C_ADV'},
      );
      expect(results.length, 2);
      expect(results.map((r) => r.profile.profileId).toSet(), containsAll(['C_DOC', 'C_ADV']));
    });

    test('2. Viewed you returns profiles that viewed me', () {
      final results = queries.getViewedYou(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        viewedYouProfileIds: {'C_TECH'},
      );
      expect(results.length, 1);
      expect(results.first.profile.profileId, 'C_TECH');
    });

    test('3. Shortlisted by you returns profiles I shortlisted', () {
      final results = queries.getShortlistedByYou(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        shortlistedByYouProfileIds: {'C_DOC'},
      );
      expect(results.length, 1);
      expect(results.first.profile.profileId, 'C_DOC');
    });

    test('4. Viewed by you returns profiles I viewed', () {
      final results = queries.getViewedByYou(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        viewedByYouProfileIds: {'C_ADV', 'C_NRI'},
      );
      expect(results.length, 2);
    });

    test('5. Newly joined filters candidates within 30 days', () {
      final results = queries.getNewlyJoined(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        referenceDate: DateTime.now(),
      );
      // C_DOC (5d), C_ADV (10d), C_NRI (2d) are <= 30 days
      expect(results.length, 3);
      final ids = results.map((r) => r.profile.profileId).toSet();
      expect(ids.contains('C_DOC'), isTrue);
      expect(ids.contains('C_ADV'), isTrue);
      expect(ids.contains('C_NRI'), isTrue);
      expect(ids.contains('C_TECH'), isFalse); // 45d
      expect(ids.contains('C_NOHORO'), isFalse); // 80d
    });

    test('6. Nearby matches filters candidates in puducherry / nearby districts', () {
      final results = queries.getNearbyMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      // C_DOC (puducherry), C_TECH (puducherry), C_ADV (cuddalore), C_NOHORO (karaikal)
      expect(results.length, 4);
      final ids = results.map((r) => r.profile.profileId).toSet();
      expect(ids.contains('C_NRI'), isFalse);
    });

    test('7. Photo matches returns candidates with valid photo', () {
      final results = queries.getPhotoMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(results.length, 2);
      expect(results.map((r) => r.profile.profileId).toSet(), containsAll(['C_DOC', 'C_ADV']));
    });

    test('8. Matches with horoscope excludes star none/empty', () {
      final results = queries.getHoroscopeMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(results.length, 4);
      expect(results.any((r) => r.profile.profileId == 'C_NOHORO'), isFalse);
    });

    test('9 & 10. Astrological compatibility star & horoscope matches', () {
      final starMatches = queries.getStarMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(starMatches, isNotNull);

      final poruthamMatches = queries.getPorutham10Matches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
        threshold: 5,
      );
      expect(poruthamMatches, isNotNull);
    });

    test('11 & 12. Mutual matches and looking for you', () {
      final mutual = queries.getMutualMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(mutual, isNotNull);

      final looking = queries.getLookingForYou(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(looking, isNotNull);
    });

    test('13. Education preference returns matching education', () {
      final results = queries.getEducationPrefMatches(
        myProfile: myProfile,
        myPrefs: myPrefs, // education: b.tech
        candidates: candidates,
      );
      expect(results.length, 1);
      expect(results.first.profile.profileId, 'C_TECH');
    });

    test('14. Professional preference returns matching occupation', () {
      final results = queries.getProfessionalPrefMatches(
        myProfile: myProfile,
        myPrefs: myPrefs, // occupation: doctor
        candidates: candidates,
      );
      expect(results.length, 1);
      expect(results.first.profile.profileId, 'C_DOC');
    });

    test('15. Location preference returns matching district', () {
      final results = queries.getLocationPrefMatches(
        myProfile: myProfile,
        myPrefs: myPrefs, // district: puducherry
        candidates: candidates,
      );
      expect(results.length, 2);
      expect(results.map((r) => r.profile.profileId).toSet(), containsAll(['C_DOC', 'C_TECH']));
    });

    test('16. NRI matches returns profiles outside India', () {
      final results = queries.getNriMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(results.length, 1);
      expect(results.first.profile.profileId, 'C_NRI');
    });

    test('17. Verified matches returns only ID-verified profiles', () {
      final results = queries.getVerifiedMatches(
        myProfile: myProfile,
        myPrefs: myPrefs,
        candidates: candidates,
      );
      expect(results.length, 3);
      expect(results.map((r) => r.profile.profileId).toSet(), containsAll(['C_DOC', 'C_ADV', 'C_NRI']));
    });
  });

  group('MatchesState Filtering & Occupation Quick Chips', () {
    final matchResults = candidates.map((c) => MatchResult(
      profile: c,
      score: c.isVerified ? 85 : 70,
      matchReasons: ['Age suitable', 'Same religion'],
    )).toList();

    test('Filtering by occupation "doctor" returns only doctor profile', () {
      final state = MatchesState(
        allMatches: matchResults,
        selectedOccupations: {'doctor'},
      );
      final filtered = state.filteredMatches;
      expect(filtered.length, 1);
      expect(filtered.first.profile.profileId, 'C_DOC');
    });

    test('Filtering by multi-select "doctor" and "techie" returns both', () {
      final state = MatchesState(
        allMatches: matchResults,
        selectedOccupations: {'doctor', 'techie'},
      );
      final filtered = state.filteredMatches;
      expect(filtered.length, 3); // C_DOC, C_TECH, C_NRI (Data Scientist/tech)
      expect(filtered.map((m) => m.profile.profileId).toSet(), containsAll(['C_DOC', 'C_TECH', 'C_NRI']));
    });

    test('Removing occupation chip instantly restores full list', () {
      final state = MatchesState(
        allMatches: matchResults,
        selectedOccupations: {},
      );
      final filtered = state.filteredMatches;
      expect(filtered.length, candidates.length);
    });

    test('Quick toggle filterPhotoOnly returns only profiles with photos', () {
      final state = MatchesState(
        allMatches: matchResults,
        filterPhotoOnly: true,
      );
      final filtered = state.filteredMatches;
      expect(filtered.length, 2);
      expect(filtered.every((m) => m.profile.primaryPhoto != null), isTrue);
    });

    test('Quick toggle filterVerifiedOnly returns only verified profiles', () {
      final state = MatchesState(
        allMatches: matchResults,
        filterVerifiedOnly: true,
      );
      final filtered = state.filteredMatches;
      expect(filtered.length, 3);
      expect(filtered.every((m) => m.profile.isVerified), isTrue);
    });

    test('Sorting by date_created orders recently created profiles first', () {
      final state = MatchesState(
        allMatches: matchResults,
        sortOrder: 'date_created',
      );
      final sorted = state.filteredMatches;
      expect(sorted.first.profile.profileId, 'C_NRI'); // created 2 days ago
      expect(sorted.last.profile.profileId, 'C_NOHORO'); // created 80 days ago
    });
  });

  group('Matches Tab UI Widgets', () {
    testWidgets('SortSheet renders all 5 sort options and triggers callback on apply', (tester) async {
      String appliedSort = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortSheet(
              currentSort: 'last_active',
              onApply: (sort) => appliedSort = sort,
            ),
          ),
        ),
      );

      expect(find.text('Sort matches by:'), findsOneWidget);
      expect(find.text('Last active'), findsOneWidget);
      expect(find.text('Date created'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('Latest photos'), findsOneWidget);
      expect(find.text('Best match %'), findsOneWidget);

      // Tap Date created
      await tester.tap(find.text('Date created'));
      await tester.pump();

      // Tap Apply Sort
      await tester.tap(find.text('Apply Sort'));
      await tester.pump();

      expect(appliedSort, 'date_created');
    });

    testWidgets('OccupationChipsStrip renders quick chips and triggers callbacks', (tester) async {
      tester.view.physicalSize = const Size(1600, 900);
      addTearDown(tester.view.resetPhysicalSize);

      String toggledCode = '';
      bool sameProfTriggered = false;
      bool moreTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OccupationChipsStrip(
              selectedOccupations: const {'doctor'},
              onToggleOccupation: (code) => toggledCode = code,
              onSameProfession: () => sameProfTriggered = true,
              onMore: () => moreTriggered = true,
            ),
          ),
        ),
      );

      expect(find.text('Same profession as me'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);

      // Tap "Same profession as me"
      await tester.tap(find.text('Same profession as me'));
      await tester.pump();
      expect(sameProfTriggered, isTrue);

      // Tap "Doctor"
      await tester.tap(find.text('Doctor'));
      await tester.pump();
      expect(toggledCode, 'doctor');
    });

    testWidgets('FilterSheet renders and allows setting and resetting filters', (tester) async {
      bool applied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterSheet(
              initialCriteria: const MatchesFilterCriteria(),
              initialOccupations: const {},
              initialPhotoOnly: false,
              initialVerifiedOnly: false,
              initialNotSeenOnly: false,
              initialNearbyOnly: false,
              onApply: ({
                required criteria,
                required occupations,
                required photoOnly,
                required verifiedOnly,
                required notSeenOnly,
                required nearbyOnly,
              }) {
                applied = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Quick Occupation Filter'), findsOneWidget);
      expect(find.text('Profile Requirements'), findsOneWidget);

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();
      expect(applied, isTrue);
    });

    testWidgets('MoreMenuSheet renders grouped sections and 17 categories', (tester) async {
      String selectedCode = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoreMenuSheet(
              onSelectQuery: (code, title) => selectedCode = code,
            ),
          ),
        ),
      );

      expect(find.text('Explore More Matches'), findsOneWidget);
      expect(find.text('Based on activity'), findsOneWidget);
      expect(find.text('Shortlisted you'), findsOneWidget);
      expect(find.text('Viewed you'), findsOneWidget);
      expect(find.text('Shortlisted by you'), findsOneWidget);

      await tester.tap(find.text('Shortlisted you'));
      await tester.pump();
      expect(selectedCode, 'shortlisted_you');
    });
  });
}
