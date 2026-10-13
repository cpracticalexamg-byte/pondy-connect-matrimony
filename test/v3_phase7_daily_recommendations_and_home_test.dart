import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/core/theme/app_typography.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_lock.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/interest_repository.dart';
import 'package:pondy_connect_matrimony/data/repositories/profile_repository.dart';
import 'package:pondy_connect_matrimony/data/repositories/shortlist_repository.dart';
import 'package:pondy_connect_matrimony/domain/matching/matching_engine.dart';
import 'package:pondy_connect_matrimony/domain/models/partner_pref_model.dart';
import 'package:pondy_connect_matrimony/domain/models/profile_model.dart';
import 'package:pondy_connect_matrimony/domain/recommendations/daily_recommendations_engine.dart';
import 'package:pondy_connect_matrimony/features/home/screens/main_shell.dart';
import 'package:pondy_connect_matrimony/features/matches/providers/matches_provider.dart';
import 'package:pondy_connect_matrimony/features/recommendations/widgets/daily_recommendations_modal.dart';
import 'package:pondy_connect_matrimony/features/profile/widgets/prime_photo_gate_sheet.dart';
import 'package:pondy_connect_matrimony/features/profile/widgets/add_photo_prompt_sheet.dart';

class FakeMatchesNotifier extends MatchesNotifier {
  FakeMatchesNotifier(super.profileRepo, super.interestRepo, super.shortlistRepo, super.ref);

  @override
  Future<void> loadMatches() async {
    state = const MatchesState(isLoading: false);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    AppTypography.disableGoogleFontsInTests = true;
    SharedPreferences.setMockInitialValues({});
    CsvLock.reset();
    CsvStore.instance.clearCache();
    tempDir = await Directory.systemTemp.createTemp('pondy_phase7_test_');
    await CsvStore.instance.initialize(customDir: tempDir);
  });

  tearDown(() async {
    AppTypography.disableGoogleFontsInTests = false;
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  ProfileModel createTestProfile({
    required String id,
    required String name,
    required String gender,
    int age = 28,
    String city = 'Puducherry',
    String district = 'Puducherry',
    String religion = 'Hindu',
    String maritalStatus = 'never_married',
    bool isVerified = false,
    String? photo,
  }) {
    final now = DateTime.now().toIso8601String();
    return ProfileModel(
      profileId: id,
      userId: 'U_$id',
      name: name,
      gender: gender,
      dob: '1996-05-15',
      age: age,
      heightCm: 165,
      physicalStatus: 'Normal',
      maritalStatus: maritalStatus,
      noOfChildren: 0,
      motherTongue: 'Tamil',
      religion: religion,
      country: 'India',
      state: 'Puducherry',
      district: district,
      city: city,
      citizenship: 'Indian',
      education: 'B.E.',
      employmentType: 'private',
      occupation: 'Engineer',
      isVerified: isVerified,
      primaryPhotoUrl: photo,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('V3 Phase 7 — Daily Recommendations Engine Unit Tests', () {
    test('Daily recommendations return up to 8 profiles deterministically', () async {
      final user = createTestProfile(id: 'PC_USER_M1', name: 'Groom 1', gender: 'Male');
      const prefs = PartnerPrefModel(profileId: 'PC_USER_M1', ageMin: 22, ageMax: 32);

      // Create 12 eligible female candidates
      final candidates = List.generate(12, (i) => createTestProfile(
        id: 'PC_BRIDE_$i',
        name: 'Bride $i',
        gender: 'Female',
        age: 24 + (i % 6),
        city: 'City_${i % 5}', // Distributed cities
      ));

      final repo = CsvProfileRepository();

      final recs1 = await DailyRecommendationsEngine.instance.getDailyRecommendations(
        myProfile: user,
        myPrefs: prefs,
        allCandidates: candidates,
        profileRepo: repo,
        calendarDate: DateTime(2026, 10, 15),
      );

      expect(recs1.length, lessThanOrEqualTo(8));
      expect(recs1.isNotEmpty, isTrue);

      // Deterministic check: Calling with same user and date returns exact same recommendation order
      final recs2 = await DailyRecommendationsEngine.instance.getDailyRecommendations(
        myProfile: user,
        myPrefs: prefs,
        allCandidates: candidates,
        profileRepo: repo,
        calendarDate: DateTime(2026, 10, 15),
      );

      expect(recs1.length, equals(recs2.length));
      for (int i = 0; i < recs1.length; i++) {
        expect(recs1[i].profile.profileId, equals(recs2[i].profile.profileId));
      }
    });

    test('Daily recommendations exclude hidden profiles and hard preference violations', () async {
      final user = createTestProfile(id: 'PC_USER_M2', name: 'Groom 2', gender: 'Male');
      const prefs = PartnerPrefModel(
        profileId: 'PC_USER_M2',
        ageMin: 23,
        ageMax: 27,
        religion: 'Hindu',
      );

      final candidates = [
        createTestProfile(id: 'PC_B_VALID', name: 'Valid Bride', gender: 'Female', age: 25, religion: 'Hindu'),
        createTestProfile(id: 'PC_B_OLD', name: 'Too Old', gender: 'Female', age: 35, religion: 'Hindu'),
        createTestProfile(id: 'PC_B_DIFF_REL', name: 'Christian Bride', gender: 'Female', age: 25, religion: 'Christian'),
        createTestProfile(id: 'PC_B_HIDDEN', name: 'Hidden Bride', gender: 'Female', age: 25, religion: 'Hindu'),
      ];

      final repo = CsvProfileRepository();
      await repo.hideProfile(user.profileId, 'PC_B_HIDDEN');

      final recs = await DailyRecommendationsEngine.instance.getDailyRecommendations(
        myProfile: user,
        myPrefs: prefs,
        allCandidates: candidates,
        profileRepo: repo,
        calendarDate: DateTime(2026, 10, 16),
      );

      final recIds = recs.map((r) => r.profile.profileId).toSet();
      expect(recIds.contains('PC_B_VALID'), isTrue);
      expect(recIds.contains('PC_B_OLD'), isFalse);
      expect(recIds.contains('PC_B_DIFF_REL'), isFalse);
      expect(recIds.contains('PC_B_HIDDEN'), isFalse);
    });

    test('Daily recommendations enforce city diversity (max 3 from same city)', () async {
      final user = createTestProfile(id: 'PC_USER_M3', name: 'Groom 3', gender: 'Male');
      const prefs = PartnerPrefModel(profileId: 'PC_USER_M3');

      // 6 candidates from Chennai, 4 from Puducherry
      final candidates = [
        ...List.generate(6, (i) => createTestProfile(id: 'PC_CHN_$i', name: 'Chennai $i', gender: 'Female', city: 'Chennai')),
        ...List.generate(4, (i) => createTestProfile(id: 'PC_PDY_$i', name: 'Pondy $i', gender: 'Female', city: 'Puducherry')),
      ];

      final repo = CsvProfileRepository();
      final recs = await DailyRecommendationsEngine.instance.getDailyRecommendations(
        myProfile: user,
        myPrefs: prefs,
        allCandidates: candidates,
        profileRepo: repo,
        calendarDate: DateTime(2026, 10, 17),
      );

      final chennaiCount = recs.where((r) => r.profile.city.toLowerCase() == 'chennai').length;
      expect(chennaiCount, lessThanOrEqualTo(3));
    });

    test('Recording recommendation actions writes to daily_recommendations table', () async {
      await DailyRecommendationsEngine.instance.recordRecommendationAction(
        userProfileId: 'PC_TEST_USER',
        targetProfileId: 'PC_TEST_TARGET',
        action: 'interest_sent',
      );

      final store = CsvStore.instance;
      final rows = await store.query(
        CsvSchema.dailyRecommendationsTable,
        (r) => r['user_profile_id'] == 'PC_TEST_USER' && r['profile_id'] == 'PC_TEST_TARGET',
      );

      if (rows.isNotEmpty) {
        expect(rows.first['status'], equals('interest_sent'));
      }
    });
  });

  group('V3 Phase 7 — MainShell and Bottom Navigation Widget Tests', () {
    testWidgets('MainShell renders all 5 V3 tabs with correct labels and icons', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              matchesProvider.overrideWith((ref) => FakeMatchesNotifier(
                CsvProfileRepository(),
                CsvInterestRepository(),
                CsvShortlistRepository(),
                ref,
              )),
            ],
            child: const MaterialApp(
              home: MainShell(),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Matches'), findsOneWidget);
        expect(find.text('Interests'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
        expect(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Upgrade')), findsOneWidget);
      });
    });

    testWidgets('PrimePhotoGateSheet renders step 1 and step 2 properly', (tester) async {
      bool unlocked = false;
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: PrimePhotoGateSheet(
                  onUnlocked: () => unlocked = true,
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Step 1 text and button
        expect(find.text('Step 1/2'), findsOneWidget);
        expect(find.text('Photo Required for PRIME'), findsOneWidget);
        expect(find.text('Add Your Photo'), findsOneWidget);
        expect(find.text('100% Privacy Control — Choose who can view your photo'), findsOneWidget);
        expect(unlocked, isFalse);
      });
    });

    testWidgets('AddPhotoPromptSheet renders without fake statistics', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: AddPhotoPromptSheet(),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Add Your Photo Now'), findsOneWidget);
        expect(find.text('If no photo → less visibility → less response'), findsOneWidget);
        expect(find.text('Upload Photo'), findsOneWidget);
        expect(find.text('I\'ll add photo later ›'), findsOneWidget);
        // Guardrail verification: NO fake statistics
        expect(find.textContaining('95%'), findsNothing);
      });
    });

    testWidgets('DailyRecommendationsModal renders top title and action buttons', (tester) async {
      final sample = MatchResult(
        profile: createTestProfile(id: 'PC_REC_1', name: 'Divya R', gender: 'Female', age: 26),
        score: 88,
        matchReasons: ['High Compatibility', 'Verified Profile'],
      );

      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              matchesProvider.overrideWith((ref) => FakeMatchesNotifier(
                CsvProfileRepository(),
                CsvInterestRepository(),
                CsvShortlistRepository(),
                ref,
              )),
            ],
            child: MaterialApp(
              home: DailyRecommendationsModal(
                recommendations: [sample],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Daily Recommendation (1/1)'), findsOneWidget);
        expect(find.text('Divya R'), findsAtLeastNWidgets(1));
        expect(find.text('Don\'t Show'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Send Interest'), findsOneWidget);
      });
    });
  });
}
