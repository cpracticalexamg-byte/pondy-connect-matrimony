import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/core/theme/app_theme.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_lock.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/profile_repository.dart';
import 'package:pondy_connect_matrimony/data/repositories/repository_providers.dart';
import 'package:pondy_connect_matrimony/domain/entitlements/entitlements_engine.dart';
import 'package:pondy_connect_matrimony/domain/entitlements/entitlements_model.dart';
import 'package:pondy_connect_matrimony/domain/models/partner_pref_model.dart';
import 'package:pondy_connect_matrimony/domain/models/profile_model.dart';
import 'package:pondy_connect_matrimony/data/repositories/interest_repository.dart';
import 'package:pondy_connect_matrimony/data/repositories/shortlist_repository.dart';
import 'package:pondy_connect_matrimony/features/matches/providers/matches_provider.dart';
import 'package:pondy_connect_matrimony/features/profile/screens/profile_detail_screen.dart';
import 'package:pondy_connect_matrimony/features/profile/widgets/contact_paywall_sheet.dart';

class FakeMatchesNotifier extends MatchesNotifier {
  FakeMatchesNotifier(super.profileRepo, super.interestRepo, super.shortlistRepo, super.ref);

  @override
  Future<void> loadMatches() async {
    state = const MatchesState(isLoading: false);
  }
}

class FakeProfileRepository implements ProfileRepository {
  final Map<String, ProfileModel> profiles = {};
  final Map<String, PartnerPrefModel> prefs = {};
  final Set<String> viewedContacts = {};
  final Set<String> hiddenProfiles = {};

  @override
  Future<ProfileModel?> getProfileById(String profileId) async => profiles[profileId];

  @override
  Future<ProfileModel?> getProfileByUserId(String userId) async {
    return profiles.values.cast<ProfileModel?>().firstWhere((p) => p?.userId == userId, orElse: () => null);
  }

  @override
  Future<String> createProfile(ProfileModel profile) async {
    profiles[profile.profileId] = profile;
    return profile.profileId;
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    profiles[profile.profileId] = profile;
  }

  @override
  Future<List<ProfileModel>> getAllProfiles({bool includeDemo = true}) async => profiles.values.toList();

  @override
  Future<PartnerPrefModel?> getPartnerPrefs(String profileId) async => prefs[profileId];

  @override
  Future<void> savePartnerPrefs(PartnerPrefModel p) async {
    prefs[p.profileId] = p;
  }

  @override
  Future<void> addPhoto(String profileId, String pathOrAsset, {bool isPrimary = false, String privacy = 'all'}) async {}

  @override
  Future<List<Map<String, String>>> getPhotos(String profileId) async => [];

  @override
  Future<void> recordView(String viewerProfile, String viewedProfile) async {}

  @override
  Future<List<ProfileModel>> getProfilesWhoViewedMe(String myProfile) async => [];

  @override
  Future<List<ProfileModel>> getRecentlyViewedByMe(String myProfile) async => [];

  @override
  Future<bool> hasViewedContact(String viewerProfileId, String viewedProfileId) async {
    return viewedContacts.contains('${viewerProfileId}_$viewedProfileId');
  }

  @override
  Future<void> recordContactView(String viewerProfileId, String viewedProfileId, {String quotaWindowId = ''}) async {
    viewedContacts.add('${viewerProfileId}_$viewedProfileId');
  }

  @override
  Future<void> hideProfile(String hiderProfileId, String hiddenProfileId) async {
    hiddenProfiles.add('${hiderProfileId}_$hiddenProfileId');
  }

  @override
  Future<void> unhideProfile(String hiderProfileId, String hiddenProfileId) async {
    hiddenProfiles.remove('${hiderProfileId}_$hiddenProfileId');
  }

  @override
  Future<List<String>> getHiddenProfileIds(String hiderProfileId) async {
    return hiddenProfiles
        .where((k) => k.startsWith('${hiderProfileId}_'))
        .map((k) => k.replaceFirst('${hiderProfileId}_', ''))
        .toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late CsvStore testStore;
  late ProfileRepository profileRepo;

  setUp(() async {
    CsvLock.reset();
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('v3_phase4_test_');
    testStore = CsvStore.instance;
    testStore.clearCache();
    await testStore.initialize(customDir: tempDir);

    // Clean tables for test isolation
    await testStore.delete(CsvSchema.profilesTable, (r) => true);
    await testStore.delete(CsvSchema.subscriptionsTable, (r) => true);
    await testStore.delete(CsvSchema.contactViewsTable, (r) => true);
    await testStore.delete(CsvSchema.hiddenProfilesTable, (r) => true);
    await testStore.delete(CsvSchema.fieldVisibilityTable, (r) => true);

    // Seed field visibility rules
    final rules = [
      {'field_code': 'dob', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'star', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'rasi', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'horoscope_chart', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'institution', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'employer', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'contact_number', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
    ];
    for (final r in rules) {
      await testStore.insert(CsvSchema.fieldVisibilityTable, r);
    }

    profileRepo = CsvProfileRepository(store: testStore);
  });

  ProfileModel createTestProfile({
    required String id,
    String name = 'Test Candidate',
    String gender = 'Female',
    bool isSample = false,
  }) {
    return ProfileModel(
      profileId: id,
      userId: 'USER_$id',
      name: name,
      gender: gender,
      dob: '1996-05-15',
      age: 28,
      heightCm: 165,
      star: 'star_rohini',
      rasi: 'rasi_rishabham',
      dosham: 'none',
      gothram: 'Kashyapa',
      education: 'be_btech',
      educationDetail: 'Computer Science',
      employmentType: 'private',
      occupation: 'software_engineer',
      employer: 'TechCorp Puducherry',
      annualIncomeRange: '7_to_10_lakhs',
      city: 'Puducherry',
      district: 'puducherry',
      state: 'Puducherry',
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: '2026-01-01T00:00:00Z',
      phone: '9840012345',
      isSample: isSample,
    );
  }

  test('Hide and Unhide profile repository methods work correctly', () async {
    const myId = 'MY_PROFILE_1';
    const targetId = 'TARGET_PROFILE_2';

    final beforeHiding = await profileRepo.getHiddenProfileIds(myId);
    expect(beforeHiding.contains(targetId), isFalse);

    await profileRepo.hideProfile(myId, targetId);
    final afterHiding = await profileRepo.getHiddenProfileIds(myId);
    expect(afterHiding.contains(targetId), isTrue);

    await profileRepo.unhideProfile(myId, targetId);
    final afterUnhiding = await profileRepo.getHiddenProfileIds(myId);
    expect(afterUnhiding.contains(targetId), isFalse);
  });

  test('Contact view quota tracking: new profile consumes quota, re-view is free', () async {
    const myId = 'MY_PAID_USER';
    const target1 = 'TARGET_1';

    // 1. Initially no contacts viewed
    expect(await profileRepo.hasViewedContact(myId, target1), isFalse);

    // 2. View target 1
    await profileRepo.recordContactView(myId, target1, quotaWindowId: 'gold_3m');
    expect(await profileRepo.hasViewedContact(myId, target1), isTrue);

    // 3. Re-view target 1
    await profileRepo.recordContactView(myId, target1, quotaWindowId: 'gold_3m');
    expect(await profileRepo.hasViewedContact(myId, target1), isTrue);

    // 4. Check contact views count for user in store
    final views = await testStore.query(
      CsvSchema.contactViewsTable,
      (r) => r['viewer_profile_id'] == myId,
    );
    // Unique target profiles viewed is 1
    final uniqueTargets = views.map((r) => r['viewed_profile_id']).toSet();
    expect(uniqueTargets.length, 1);
  });

  testWidgets('Free member sees Upgrade to view for locked fields in ProfileDetailScreen', (tester) async {
    final candidate = createTestProfile(id: 'CAN_101', name: 'Priya Mudaliar');
    final fakeRepo = FakeProfileRepository();
    fakeRepo.profiles[candidate.profileId] = candidate;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepoProvider.overrideWithValue(fakeRepo),
          matchesProvider.overrideWith((ref) => FakeMatchesNotifier(
                fakeRepo,
                CsvInterestRepository(store: testStore),
                CsvShortlistRepository(store: testStore),
                ref,
              )),
          entitlementsProvider.overrideWith((ref) => Future.value(Entitlements.free())),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProfileDetailScreen(profileId: candidate.profileId),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    // Verify candidate basic info is displayed
    expect(find.text('Priya Mudaliar'), findsOneWidget);

    // Verify "Upgrade to view >" text appears for locked fields
    expect(find.text('Upgrade to view >'), findsWidgets);
    expect(find.text('Unlock Horoscope'), findsOneWidget);
    expect(find.text("Don't Show"), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Send Interest'), findsOneWidget);
  });

  testWidgets('Paid member sees unlocked horoscope & fields in ProfileDetailScreen', (tester) async {
    final candidate = createTestProfile(id: 'CAN_102', name: 'Lakshmi Narayanan');
    final fakeRepo = FakeProfileRepository();
    fakeRepo.profiles[candidate.profileId] = candidate;

    const paidEntitlements = Entitlements(
      tier: 'gold',
      planName: 'Gold 3 Months',
      contactViewsRemaining: 40,
      fieldVisibility: {
        'dob': true,
        'star': true,
        'rasi': true,
        'horoscope_chart': true,
        'institution': true,
        'employer': true,
        'contact_number': true,
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepoProvider.overrideWithValue(fakeRepo),
          matchesProvider.overrideWith((ref) => FakeMatchesNotifier(
                fakeRepo,
                CsvInterestRepository(store: testStore),
                CsvShortlistRepository(store: testStore),
                ref,
              )),
          entitlementsProvider.overrideWith((ref) => Future.value(paidEntitlements)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProfileDetailScreen(profileId: candidate.profileId),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Lakshmi Narayanan'), findsOneWidget);
    // Unlocked 10-Porutham button
    expect(find.text('10-Porutham'), findsOneWidget);
    // "Upgrade to view >" should not exist
    expect(find.text('Upgrade to view >'), findsNothing);
  });

  testWidgets('Free member opens ContactPaywallSheet showing masked phone and upgrade benefits', (tester) async {
    final candidate = createTestProfile(id: 'CAN_103', name: 'Ananya Ramesh');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          entitlementsProvider.overrideWith((ref) => Future.value(Entitlements.free())),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ContactPaywallSheet.show(ctx, targetProfile: candidate),
                child: const Text('Open Contact'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap button to open sheet
    await tester.tap(find.text('Open Contact'));
    await tester.pumpAndSettle();

    // Verify Free Member Paywall content
    expect(find.text('Upgrade to Paid Membership'), findsOneWidget);
    expect(find.textContaining('98XXXXXXXX'), findsOneWidget);
    expect(find.text('Paid membership lets you:'), findsOneWidget);
    expect(find.text('Continue to Upgrade'), findsOneWidget);
  });

  testWidgets('Paid member opens ContactPaywallSheet with confirmation and reveal', (tester) async {
    final candidate = createTestProfile(id: 'CAN_104', name: 'Divya Bharathi');
    final fakeRepo = FakeProfileRepository();
    fakeRepo.profiles[candidate.profileId] = candidate;

    const paidEntitlements = Entitlements(
      tier: 'gold',
      planName: 'Gold 3 Months',
      contactViewsRemaining: 39,
      fieldVisibility: {'contact_number': true},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepoProvider.overrideWithValue(fakeRepo),
          entitlementsProvider.overrideWith((ref) => Future.value(paidEntitlements)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => ContactPaywallSheet.show(ctx, targetProfile: candidate),
                child: const Text('Open Contact'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Contact'));
    await tester.pumpAndSettle();

    // Verify Paid Member confirmation flow
    expect(find.text('View Contact Number'), findsOneWidget);
    expect(find.textContaining('39 of 40 contact views left'), findsOneWidget);
    expect(find.text('Reveal Contact Number'), findsOneWidget);

    // Tap Reveal Contact Number
    await tester.tap(find.text('Reveal Contact Number'));
    await tester.pumpAndSettle();

    // Verify revealed phone and Call & WhatsApp action buttons
    expect(find.text('Contact Details'), findsOneWidget);
    expect(find.text('Call Now'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });
}
