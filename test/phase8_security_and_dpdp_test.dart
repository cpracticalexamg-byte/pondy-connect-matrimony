import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/security/secure_storage_service.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/auth_repository.dart';
import 'package:pondy_connect_matrimony/data/services/consent/consent_service.dart';
import 'package:pondy_connect_matrimony/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late CsvStore store;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pondy_phase8_test_');
    SharedPreferences.setMockInitialValues({});
    store = CsvStore.instance;
    await store.initialize(customDir: tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Phase 8: DPDP Act 2023 ConsentService Tests', () {
    test('ConsentService records consent and validates presence', () async {
      final service = ConsentService(store: store);

      final hasBefore = await service.hasValidConsent('USR000101');
      expect(hasBefore, isFalse);

      final record = await service.recordConsent(
        userId: 'USR000101',
        sensitiveDataConsent: true,
        photoVisibilityConsent: 'members',
      );

      expect(record.consentId, startsWith('CNS'));
      expect(record.userId, 'USR000101');
      expect(record.sensitiveDataConsent, isTrue);
      expect(record.photoVisibilityConsent, 'members');

      final hasAfter = await service.hasValidConsent('USR000101');
      expect(hasAfter, isTrue);

      // Verify stored row in consents table
      final rows = await store.readAll(CsvSchema.consentsTable);
      expect(rows.length, 1);
      expect(rows.first['photo_visibility_consent'], 'members');
    });

    test('ConsentService revokes consent cleanly on request', () async {
      final service = ConsentService(store: store);

      await service.recordConsent(
        userId: 'USR000102',
        sensitiveDataConsent: true,
        photoVisibilityConsent: 'all',
      );
      expect(await service.hasValidConsent('USR000102'), isTrue);

      await service.revokeConsent('USR000102', reason: 'Account deletion');
      expect(await service.hasValidConsent('USR000102'), isFalse);
    });
  });

  group('Phase 8: Cascading Account Deletion Tests', () {
    test('deleteAccount soft-deletes user, profile, revokes consent and records audit', () async {
      final authRepo = CsvAuthRepository(store: store);
      const userId = 'USR000201';

      // Seed user and profile
      await store.insert(CsvSchema.usersTable, {
        'user_id': userId,
        'mobile': '+919876543210',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });

      await store.insert(CsvSchema.profilesTable, {
        'profile_id': 'PRF000201',
        'user_id': userId,
        'first_name': 'Karthik',
        'is_active': '1',
        'about_me': 'Software Engineer in Puducherry',
      });

      await authRepo.setCurrentUser(UserModel(
        userId: userId,
        mobile: '+919876543210',
        profileFor: 'Myself',
        createdAt: DateTime.now().toIso8601String(),
        lastLogin: DateTime.now().toIso8601String(),
      ));

      // Execute account deletion
      await authRepo.deleteAccount(userId: userId, reason: 'Found my match on Pondy Connect');

      // 1. User status should be deleted
      final users = await store.query(CsvSchema.usersTable, (r) => r['user_id'] == userId);
      expect(users.first['status'], 'deleted');
      expect(users.first['deleted_at'], isNotEmpty);

      // 2. Profile should be deactivated and sanitized
      final profiles = await store.query(CsvSchema.profilesTable, (r) => r['user_id'] == userId);
      expect(profiles.first['is_active'], '0');
      expect(profiles.first['about_me'], contains('Deleted'));

      // 3. Consent should be recorded as revoked
      final consents = await store.query(CsvSchema.consentsTable, (r) => r['user_id'] == userId);
      expect(consents, isNotEmpty);
      expect(consents.last['photo_visibility_consent'], 'revoked');
      expect(consents.last['sensitive_data_consent'], '0');

      // 4. Session should be cleared
      final currentUser = await authRepo.getCurrentUser();
      expect(currentUser, isNull);
    });
  });

  group('Phase 8: SecureStorageService Hardened Encryption Tests', () {
    final sec = SecureStorageService.instance;

    test('SecureStorageService encrypts and decodes secrets accurately', () async {
      await sec.writeSecure('jwt_token', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      final retrieved = await sec.readSecure('jwt_token');
      expect(retrieved, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');

      // Verify raw stored string in SharedPreferences is NOT plain text
      final prefs = await SharedPreferences.getInstance();
      final rawStored = prefs.getString('sec_enc_v1_jwt_token');
      expect(rawStored, isNotNull);
      expect(rawStored, isNot(contains('eyJhbGci')));
      expect(rawStored, contains(':')); // Signature:Payload
    });

    test('SecureStorageService detects tampering and returns null', () async {
      await sec.writeSecure('api_key', 'super_secret_key_123');

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('sec_enc_v1_api_key')!;
      // Tamper with payload
      final tampered = '0000000000000000:${raw.split(':')[1]}';
      await prefs.setString('sec_enc_v1_api_key', tampered);

      final result = await sec.readSecure('api_key');
      expect(result, isNull);
    });
  });
}
