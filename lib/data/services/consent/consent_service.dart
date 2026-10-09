import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_logger.dart';
import '../../csv/csv_schema.dart';
import '../../csv/csv_store.dart';

class ConsentRecord {
  final String consentId;
  final String userId;
  final String termsVersion;
  final String privacyVersion;
  final bool sensitiveDataConsent;
  final String photoVisibilityConsent;
  final String acceptedAt;

  const ConsentRecord({
    required this.consentId,
    required this.userId,
    required this.termsVersion,
    required this.privacyVersion,
    required this.sensitiveDataConsent,
    required this.photoVisibilityConsent,
    required this.acceptedAt,
  });

  Map<String, String> toMap() => {
    'consent_id': consentId,
    'user_id': userId,
    'terms_version': termsVersion,
    'privacy_version': privacyVersion,
    'sensitive_data_consent': sensitiveDataConsent ? '1' : '0',
    'photo_visibility_consent': photoVisibilityConsent,
    'accepted_at': acceptedAt,
  };

  factory ConsentRecord.fromMap(Map<String, String> map) => ConsentRecord(
    consentId: map['consent_id'] ?? '',
    userId: map['user_id'] ?? '',
    termsVersion: map['terms_version'] ?? '',
    privacyVersion: map['privacy_version'] ?? '',
    sensitiveDataConsent: (map['sensitive_data_consent'] ?? '0') == '1',
    photoVisibilityConsent: map['photo_visibility_consent'] ?? 'all',
    acceptedAt: map['accepted_at'] ?? '',
  );
}

class ConsentService {
  final CsvStore _store;
  static const String currentVersion = 'v2.0_dpdp2023';

  ConsentService({CsvStore? store}) : _store = store ?? CsvStore.instance;

  Future<ConsentRecord?> getConsent(String userId) async {
    try {
      final rows = await _store.query(
        CsvSchema.consentsTable,
        (r) => r['user_id'] == userId,
      );
      if (rows.isEmpty) return null;
      return ConsentRecord.fromMap(rows.last);
    } catch (e, stack) {
      AppLogger.error('Failed to get consent for user $userId', tag: 'ConsentService', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<bool> hasValidConsent(String userId) async {
    final consent = await getConsent(userId);
    return consent != null && consent.sensitiveDataConsent;
  }

  Future<ConsentRecord> recordConsent({
    required String userId,
    required bool sensitiveDataConsent,
    required String photoVisibilityConsent,
    String termsVersion = currentVersion,
    String privacyVersion = currentVersion,
  }) async {
    final nextId = await _store.nextId(CsvSchema.consentsTable, 'consent_id', 'CNS', 6);
    final record = ConsentRecord(
      consentId: nextId,
      userId: userId,
      termsVersion: termsVersion,
      privacyVersion: privacyVersion,
      sensitiveDataConsent: sensitiveDataConsent,
      photoVisibilityConsent: photoVisibilityConsent,
      acceptedAt: DateTime.now().toIso8601String(),
    );

    await _store.insert(CsvSchema.consentsTable, record.toMap());
    AppLogger.info('DPDP Act 2023 consent recorded for $userId (ID: $nextId)', tag: 'ConsentService');
    return record;
  }

  Future<void> revokeConsent(String userId, {String reason = 'User requested account deletion'}) async {
    final record = ConsentRecord(
      consentId: await _store.nextId(CsvSchema.consentsTable, 'consent_id', 'CNS', 6),
      userId: userId,
      termsVersion: currentVersion,
      privacyVersion: currentVersion,
      sensitiveDataConsent: false,
      photoVisibilityConsent: 'revoked',
      acceptedAt: DateTime.now().toIso8601String(),
    );
    await _store.insert(CsvSchema.consentsTable, record.toMap());
    AppLogger.warning('Consent revoked for user $userId: $reason', tag: 'ConsentService');
  }
}

final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});
