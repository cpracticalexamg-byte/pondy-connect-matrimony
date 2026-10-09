import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';
import '../services/otp/otp_service.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<String> requestOtp(String mobile);
  Future<bool> verifyOtp(String mobile, String otp);
  Future<UserModel> registerOrGet(String mobile, String profileFor);
  Future<UserModel?> loginWithPassword(String mobile, String password);
  Future<void> setPassword(String userId, String password);
  Future<void> logout();
  Future<void> setCurrentUser(UserModel user);
  Future<void> deleteAccount({required String userId, required String reason});
}

class CsvAuthRepository implements AuthRepository {
  final CsvStore _store;
  final OtpService _otpService;
  static const String _prefCurrentUserIdKey = 'current_user_id';

  CsvAuthRepository({CsvStore? store, OtpService? otpService})
      : _store = store ?? CsvStore.instance,
        _otpService = otpService ?? FakeOtpService(store: store ?? CsvStore.instance);

  String _generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashWithSalt(String input, String salt) {
    final bytes = utf8.encode('$salt$input$salt');
    return sha256.convert(bytes).toString();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString(_prefCurrentUserIdKey);
    if (currentId == null || currentId.isEmpty) return null;

    final users = await _store.query(
      CsvSchema.usersTable,
      (row) => row['user_id'] == currentId && row['status'] != 'deleted',
    );
    if (users.isEmpty) return null;
    return UserModel.fromMap(users.first);
  }

  @override
  Future<void> setCurrentUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCurrentUserIdKey, user.userId);
  }

  @override
  Future<String> requestOtp(String mobile) async {
    final result = await _otpService.sendOtp(mobile);
    return result.when(
      success: (data) => data.testCode ?? '123456',
      failure: (err) => throw Exception(err.message),
    );
  }

  @override
  Future<bool> verifyOtp(String mobile, String otp) async {
    final result = await _otpService.verifyOtp(mobile, otp);
    return result.when(
      success: (valid) => valid,
      failure: (_) => false,
    );
  }

  @override
  Future<UserModel> registerOrGet(String mobile, String profileFor) async {
    final existing = await _store.query(
      CsvSchema.usersTable,
      (row) => row['mobile'] == mobile,
    );

    if (existing.isNotEmpty) {
      final user = UserModel.fromMap(existing.first);
      await setCurrentUser(user);
      return user;
    }

    final userId = await _store.nextId(CsvSchema.usersTable, 'user_id', 'USR', 6);
    final now = DateTime.now().toIso8601String();
    final newUser = UserModel(
      userId: userId,
      mobile: mobile,
      profileFor: profileFor,
      createdAt: now,
      lastLogin: now,
      status: 'active',
      planId: 'free',
      isVerified: true,
      isDemo: false,
    );

    await _store.insert(CsvSchema.usersTable, newUser.toMap());
    await setCurrentUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel?> loginWithPassword(String mobile, String password) async {
    final rows = await _store.query(
      CsvSchema.usersTable,
      (row) => row['mobile'] == mobile && row['status'] != 'deleted',
    );
    if (rows.isEmpty) return null;

    final userMap = rows.first;
    final salt = userMap['salt'] ?? '';
    final storedHash = userMap['password_hash'] ?? '';

    if (storedHash.isNotEmpty && salt.isNotEmpty) {
      final testHash = _hashWithSalt(password, salt);
      if (testHash != storedHash) return null;
    }

    final user = UserModel.fromMap(userMap);
    await setCurrentUser(user);
    return user;
  }

  @override
  Future<void> setPassword(String userId, String password) async {
    final salt = _generateSalt();
    final hash = _hashWithSalt(password, salt);
    await _store.update(
      CsvSchema.usersTable,
      {'password_hash': hash, 'salt': salt},
      (row) => row['user_id'] == userId,
    );
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCurrentUserIdKey);
  }

  @override
  Future<void> deleteAccount({required String userId, required String reason}) async {
    final now = DateTime.now().toIso8601String();

    // 1. Soft-delete user record
    await _store.update(
      CsvSchema.usersTable,
      {
        'status': 'deleted',
        'deleted_at': now,
        'updated_at': now,
      },
      (row) => row['user_id'] == userId,
    );

    // 2. Soft-delete / deactivate matching profile
    await _store.update(
      CsvSchema.profilesTable,
      {
        'is_active': '0',
        'about_me': '[Account Deleted by User]',
        'updated_at': now,
      },
      (row) => row['user_id'] == userId,
    );

    // 3. Revoke consent in consents table
    try {
      final nextConsentId = await _store.nextId(CsvSchema.consentsTable, 'consent_id', 'CNS', 6);
      await _store.insert(CsvSchema.consentsTable, {
        'consent_id': nextConsentId,
        'user_id': userId,
        'terms_version': 'v2.0_dpdp2023',
        'privacy_version': 'v2.0_dpdp2023',
        'sensitive_data_consent': '0',
        'photo_visibility_consent': 'revoked',
        'accepted_at': now,
      });
    } catch (_) {}

    // 4. Record audit log
    try {
      final nextAuditId = await _store.nextId(CsvSchema.auditLogTable, 'id', 'AUD', 6);
      await _store.insert(CsvSchema.auditLogTable, {
        'id': nextAuditId,
        'table_name': CsvSchema.usersTable,
        'record_id': userId,
        'action': 'DELETE_ACCOUNT',
        'changed_by': userId,
        'changed_at': now,
        'old_value': 'status:active',
        'new_value': 'status:deleted,reason:$reason',
      });
    } catch (_) {}

    // 5. Purge local session
    await logout();
  }
}
