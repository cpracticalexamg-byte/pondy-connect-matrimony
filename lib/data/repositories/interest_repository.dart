import '../../domain/models/interest_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class InterestRepository {
  Future<void> sendInterest(String fromProfile, String toProfile, {String message = ''});
  Future<void> acceptInterest(String interestId);
  Future<void> declineInterest(String interestId);
  Future<void> withdrawInterest(String interestId);
  Future<List<InterestModel>> getReceivedInterests(String profileId);
  Future<List<InterestModel>> getSentInterests(String profileId);
  Future<InterestModel?> getInterestBetween(String profile1, String profile2);
}

class CsvInterestRepository implements InterestRepository {
  final CsvStore _store;

  CsvInterestRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<void> sendInterest(String fromProfile, String toProfile, {String message = ''}) async {
    final existing = await getInterestBetween(fromProfile, toProfile);
    if (existing != null) return;

    final id = await _store.nextId(CsvSchema.interestsTable, 'interest_id', 'INT', 6);
    final now = DateTime.now().toIso8601String();

    await _store.insert(CsvSchema.interestsTable, {
      'interest_id': id,
      'from_profile': fromProfile,
      'to_profile': toProfile,
      'status': 'sent',
      'message': message.isNotEmpty ? message : 'Hi, I liked your profile and would love to connect!',
      'sent_at': now,
      'responded_at': '',
    });

    // Also send an in-app notification to receiver
    final notifId = await _store.nextId(CsvSchema.notificationsTable, 'notif_id', 'NOT', 6);
    await _store.insert(CsvSchema.notificationsTable, {
      'notif_id': notifId,
      'profile_id': toProfile,
      'type': 'interest',
      'title': 'New Interest Received',
      'body': '$fromProfile sent you an interest.',
      'payload': id,
      'created_at': now,
      'is_read': 'false',
    });
  }

  @override
  Future<void> acceptInterest(String interestId) async {
    final now = DateTime.now().toIso8601String();
    await _store.update(
      CsvSchema.interestsTable,
      {'status': 'accepted', 'responded_at': now},
      (r) => r['interest_id'] == interestId,
    );
  }

  @override
  Future<void> declineInterest(String interestId) async {
    final now = DateTime.now().toIso8601String();
    await _store.update(
      CsvSchema.interestsTable,
      {'status': 'declined', 'responded_at': now},
      (r) => r['interest_id'] == interestId,
    );
  }

  @override
  Future<void> withdrawInterest(String interestId) async {
    await _store.delete(
      CsvSchema.interestsTable,
      (r) => r['interest_id'] == interestId,
    );
  }

  @override
  Future<List<InterestModel>> getReceivedInterests(String profileId) async {
    final rows = await _store.query(
      CsvSchema.interestsTable,
      (r) => r['to_profile'] == profileId,
    );
    return rows.map((e) => InterestModel.fromMap(e)).toList();
  }

  @override
  Future<List<InterestModel>> getSentInterests(String profileId) async {
    final rows = await _store.query(
      CsvSchema.interestsTable,
      (r) => r['from_profile'] == profileId,
    );
    return rows.map((e) => InterestModel.fromMap(e)).toList();
  }

  @override
  Future<InterestModel?> getInterestBetween(String profile1, String profile2) async {
    final rows = await _store.query(
      CsvSchema.interestsTable,
      (r) => (r['from_profile'] == profile1 && r['to_profile'] == profile2) ||
             (r['from_profile'] == profile2 && r['to_profile'] == profile1),
    );
    if (rows.isEmpty) return null;
    return InterestModel.fromMap(rows.first);
  }
}
