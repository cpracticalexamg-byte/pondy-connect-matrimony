import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class ReportRepository {
  Future<void> blockUser(String blockerProfile, String blockedProfile);
  Future<void> unblockUser(String blockerProfile, String blockedProfile);
  Future<bool> isBlocked(String p1, String p2);
  Future<List<String>> getBlockedProfiles(String myProfile);
  Future<void> reportProfile(String reporter, String reported, String reason, String details);
  Future<void> createHelpTicket(String userId, String subject, String message);
}

class CsvReportRepository implements ReportRepository {
  final CsvStore _store;

  CsvReportRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<void> blockUser(String blockerProfile, String blockedProfile) async {
    final already = await isBlocked(blockerProfile, blockedProfile);
    if (already) return;

    await _store.insert(CsvSchema.blocksTable, {
      'blocker': blockerProfile,
      'blocked': blockedProfile,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> unblockUser(String blockerProfile, String blockedProfile) async {
    await _store.delete(
      CsvSchema.blocksTable,
      (r) => r['blocker'] == blockerProfile && r['blocked'] == blockedProfile,
    );
  }

  @override
  Future<bool> isBlocked(String p1, String p2) async {
    final rows = await _store.query(
      CsvSchema.blocksTable,
      (r) => (r['blocker'] == p1 && r['blocked'] == p2) ||
             (r['blocker'] == p2 && r['blocked'] == p1),
    );
    return rows.isNotEmpty;
  }

  @override
  Future<List<String>> getBlockedProfiles(String myProfile) async {
    final rows = await _store.query(
      CsvSchema.blocksTable,
      (r) => r['blocker'] == myProfile,
    );
    return rows.map((r) => r['blocked'] ?? '').toList();
  }

  @override
  Future<void> reportProfile(String reporter, String reported, String reason, String details) async {
    final id = await _store.nextId(CsvSchema.reportsTable, 'report_id', 'REP', 6);
    await _store.insert(CsvSchema.reportsTable, {
      'report_id': id,
      'reporter': reporter,
      'reported': reported,
      'reason': reason,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });
  }

  @override
  Future<void> createHelpTicket(String userId, String subject, String message) async {
    final id = await _store.nextId(CsvSchema.helpTicketsTable, 'ticket_id', 'TCK', 6);
    await _store.insert(CsvSchema.helpTicketsTable, {
      'ticket_id': id,
      'user_id': userId,
      'subject': subject,
      'message': message,
      'status': 'open',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
