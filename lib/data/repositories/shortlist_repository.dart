import '../../domain/models/profile_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';
import 'profile_repository.dart';

abstract class ShortlistRepository {
  Future<bool> isShortlisted(String userProfile, String targetProfile);
  Future<void> toggleShortlist(String userProfile, String targetProfile);
  Future<List<ProfileModel>> getShortlistedProfiles(String userProfile);
}

class CsvShortlistRepository implements ShortlistRepository {
  final CsvStore _store;
  final ProfileRepository _profileRepo;

  CsvShortlistRepository({CsvStore? store, ProfileRepository? profileRepo})
      : _store = store ?? CsvStore.instance,
        _profileRepo = profileRepo ?? CsvProfileRepository(store: store);

  @override
  Future<bool> isShortlisted(String userProfile, String targetProfile) async {
    final rows = await _store.query(
      CsvSchema.shortlistsTable,
      (r) => r['user_profile'] == userProfile && r['target_profile'] == targetProfile,
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> toggleShortlist(String userProfile, String targetProfile) async {
    final exists = await isShortlisted(userProfile, targetProfile);
    if (exists) {
      await _store.delete(
        CsvSchema.shortlistsTable,
        (r) => r['user_profile'] == userProfile && r['target_profile'] == targetProfile,
      );
    } else {
      await _store.insert(CsvSchema.shortlistsTable, {
        'user_profile': userProfile,
        'target_profile': targetProfile,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  @override
  Future<List<ProfileModel>> getShortlistedProfiles(String userProfile) async {
    final rows = await _store.query(
      CsvSchema.shortlistsTable,
      (r) => r['user_profile'] == userProfile,
    );
    final results = <ProfileModel>[];
    for (final r in rows) {
      final target = r['target_profile'] ?? '';
      final p = await _profileRepo.getProfileById(target);
      if (p != null) results.add(p);
    }
    return results;
  }
}
