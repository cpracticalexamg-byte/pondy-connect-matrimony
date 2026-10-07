import '../../domain/models/partner_pref_model.dart';
import '../../domain/models/profile_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class ProfileRepository {
  Future<ProfileModel?> getProfileById(String profileId);
  Future<ProfileModel?> getProfileByUserId(String userId);
  Future<String> createProfile(ProfileModel profile);
  Future<void> updateProfile(ProfileModel profile);
  Future<List<ProfileModel>> getAllProfiles({bool includeDemo = true});
  Future<PartnerPrefModel?> getPartnerPrefs(String profileId);
  Future<void> savePartnerPrefs(PartnerPrefModel prefs);
  Future<void> addPhoto(String profileId, String pathOrAsset, {bool isPrimary = false, String privacy = 'all'});
  Future<List<Map<String, String>>> getPhotos(String profileId);
  Future<void> recordView(String viewerProfile, String viewedProfile);
  Future<List<ProfileModel>> getProfilesWhoViewedMe(String myProfile);
  Future<List<ProfileModel>> getRecentlyViewedByMe(String myProfile);
}

class CsvProfileRepository implements ProfileRepository {
  final CsvStore _store;

  CsvProfileRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<ProfileModel?> getProfileById(String profileId) async {
    final rows = await _store.query(
      CsvSchema.profilesTable,
      (r) => r['profile_id'] == profileId,
    );
    if (rows.isEmpty) return null;

    final photoRows = await _store.query(
      CsvSchema.photosTable,
      (p) => p['profile_id'] == profileId && p['is_primary'] == 'true',
    );
    final primaryPhoto = photoRows.isNotEmpty ? photoRows.first['path_or_asset'] : null;

    return ProfileModel.fromMap(rows.first, primaryPhoto);
  }

  @override
  Future<ProfileModel?> getProfileByUserId(String userId) async {
    final rows = await _store.query(
      CsvSchema.profilesTable,
      (r) => r['user_id'] == userId,
    );
    if (rows.isEmpty) return null;

    final profileId = rows.first['profile_id'] ?? '';
    final photoRows = await _store.query(
      CsvSchema.photosTable,
      (p) => p['profile_id'] == profileId && p['is_primary'] == 'true',
    );
    final primaryPhoto = photoRows.isNotEmpty ? photoRows.first['path_or_asset'] : null;

    return ProfileModel.fromMap(rows.first, primaryPhoto);
  }

  @override
  Future<String> createProfile(ProfileModel profile) async {
    final profileId = await _store.nextId(CsvSchema.profilesTable, 'profile_id', 'PC', 6);
    final now = DateTime.now().toIso8601String();

    final newProfile = ProfileModel(
      profileId: profileId,
      userId: profile.userId,
      name: profile.name,
      gender: profile.gender,
      dob: profile.dob,
      age: profile.age,
      heightCm: profile.heightCm,
      physicalStatus: profile.physicalStatus,
      maritalStatus: profile.maritalStatus,
      noOfChildren: profile.noOfChildren,
      motherTongue: profile.motherTongue,
      religion: profile.religion,
      division: profile.division,
      caste: profile.caste,
      subcaste: profile.subcaste,
      willingOtherCaste: profile.willingOtherCaste,
      star: profile.star,
      rasi: profile.rasi,
      dosham: profile.dosham,
      gothram: profile.gothram,
      country: profile.country,
      state: profile.state,
      district: profile.district,
      city: profile.city,
      citizenship: profile.citizenship,
      education: profile.education,
      educationDetail: profile.educationDetail,
      employmentType: profile.employmentType,
      occupation: profile.occupation,
      employer: profile.employer,
      incomeCurrency: profile.incomeCurrency,
      annualIncomeRange: profile.annualIncomeRange,
      familyStatus: profile.familyStatus,
      familyType: profile.familyType,
      familyValues: profile.familyValues,
      fatherOccupation: profile.fatherOccupation,
      motherOccupation: profile.motherOccupation,
      brothers: profile.brothers,
      sisters: profile.sisters,
      diet: profile.diet,
      smoking: profile.smoking,
      drinking: profile.drinking,
      aboutMe: profile.aboutMe,
      profilePhotoPrivacy: profile.profilePhotoPrivacy,
      completenessPct: profile.completenessPct,
      createdAt: now,
      updatedAt: now,
      isDemo: false,
    );

    await _store.insert(CsvSchema.profilesTable, newProfile.toMap());

    // Create default partner preferences for this profile
    final defaultPrefs = PartnerPrefModel(
      profileId: profileId,
      ageMin: profile.gender == 'Male' ? (profile.age - 5).clamp(18, 50) : (profile.age - 1).clamp(21, 55),
      ageMax: profile.gender == 'Male' ? (profile.age + 1).clamp(18, 50) : (profile.age + 7).clamp(21, 55),
      heightMin: (profile.heightCm - 15).clamp(140, 200),
      heightMax: (profile.heightCm + 15).clamp(150, 210),
      religion: profile.religion,
      motherTongue: profile.motherTongue,
      state: profile.state,
      district: profile.district,
    );
    await savePartnerPrefs(defaultPrefs);

    return profileId;
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final now = DateTime.now().toIso8601String();
    final map = profile.toMap();
    map['updated_at'] = now;

    await _store.update(
      CsvSchema.profilesTable,
      map,
      (r) => r['profile_id'] == profile.profileId,
    );
  }

  @override
  Future<List<ProfileModel>> getAllProfiles({bool includeDemo = true}) async {
    final rows = await _store.readAll(CsvSchema.profilesTable);
    final results = <ProfileModel>[];

    for (final r in rows) {
      final isDemo = (r['is_demo'] ?? 'false').toLowerCase() == 'true';
      if (!includeDemo && isDemo) continue;
      results.add(ProfileModel.fromMap(r));
    }

    return results;
  }

  @override
  Future<PartnerPrefModel?> getPartnerPrefs(String profileId) async {
    final rows = await _store.query(
      CsvSchema.partnerPrefsTable,
      (r) => r['profile_id'] == profileId,
    );
    if (rows.isEmpty) return null;
    return PartnerPrefModel.fromMap(rows.first);
  }

  @override
  Future<void> savePartnerPrefs(PartnerPrefModel prefs) async {
    final existing = await _store.query(
      CsvSchema.partnerPrefsTable,
      (r) => r['profile_id'] == prefs.profileId,
    );

    if (existing.isEmpty) {
      await _store.insert(CsvSchema.partnerPrefsTable, prefs.toMap());
    } else {
      await _store.update(
        CsvSchema.partnerPrefsTable,
        prefs.toMap(),
        (r) => r['profile_id'] == prefs.profileId,
      );
    }
  }

  @override
  Future<void> addPhoto(
    String profileId,
    String pathOrAsset, {
    bool isPrimary = false,
    String privacy = 'all',
  }) async {
    final photoId = await _store.nextId(CsvSchema.photosTable, 'photo_id', 'PHT', 6);
    if (isPrimary) {
      // Unset previous primary
      await _store.update(
        CsvSchema.photosTable,
        {'is_primary': 'false'},
        (p) => p['profile_id'] == profileId,
      );
    }

    await _store.insert(CsvSchema.photosTable, {
      'photo_id': photoId,
      'profile_id': profileId,
      'path_or_asset': pathOrAsset,
      'is_primary': isPrimary.toString(),
      'privacy': privacy,
      'order': '1',
      'uploaded_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, String>>> getPhotos(String profileId) async {
    return await _store.query(
      CsvSchema.photosTable,
      (p) => p['profile_id'] == profileId,
    );
  }

  @override
  Future<void> recordView(String viewerProfile, String viewedProfile) async {
    if (viewerProfile == viewedProfile) return;
    await _store.insert(CsvSchema.viewsTable, {
      'viewer_profile': viewerProfile,
      'viewed_profile': viewedProfile,
      'viewed_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<ProfileModel>> getProfilesWhoViewedMe(String myProfile) async {
    final rows = await _store.query(
      CsvSchema.viewsTable,
      (v) => v['viewed_profile'] == myProfile,
    );
    final profileIds = rows.map((r) => r['viewer_profile'] ?? '').toSet();
    final results = <ProfileModel>[];
    for (final id in profileIds) {
      final p = await getProfileById(id);
      if (p != null) results.add(p);
    }
    return results;
  }

  @override
  Future<List<ProfileModel>> getRecentlyViewedByMe(String myProfile) async {
    final rows = await _store.query(
      CsvSchema.viewsTable,
      (v) => v['viewer_profile'] == myProfile,
    );
    final profileIds = rows.map((r) => r['viewed_profile'] ?? '').toSet();
    final results = <ProfileModel>[];
    for (final id in profileIds) {
      final p = await getProfileById(id);
      if (p != null) results.add(p);
    }
    return results;
  }
}
