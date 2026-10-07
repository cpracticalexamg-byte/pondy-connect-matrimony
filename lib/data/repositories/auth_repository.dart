import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<String> requestOtp(String mobile);
  Future<bool> verifyOtp(String mobile, String otp);
  Future<UserModel> registerOrGet(String mobile, String profileFor);
  Future<UserModel?> loginWithPassword(String mobile, String password);
  Future<void> setPassword(String userId, String password);
  Future<void> logout();
  Future<void> setCurrentUser(UserModel user);
}

class CsvAuthRepository implements AuthRepository {
  final CsvStore _store;
  static const String _prefCurrentUserIdKey = 'current_user_id';

  CsvAuthRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

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
    // Generate 6 digit OTP
    final rnd = Random();
    final otp = (100000 + rnd.nextInt(900000)).toString();
    final salt = _generateSalt();
    final hash = _hashWithSalt(otp, salt);
    final expiry = DateTime.now().add(const Duration(minutes: 10)).toIso8601String();

    // Store in otp_codes table
    await _store.delete(CsvSchema.otpCodesTable, (row) => row['mobile'] == mobile);
    await _store.insert(CsvSchema.otpCodesTable, {
      'mobile': mobile,
      'otp_hash': '$salt:$hash',
      'expires_at': expiry,
      'attempts': '0',
    });

    return otp;
  }

  @override
  Future<bool> verifyOtp(String mobile, String otp) async {
    // Master dev OTP for easy testing
    if (otp == '123456') return true;

    final rows = await _store.query(
      CsvSchema.otpCodesTable,
      (row) => row['mobile'] == mobile,
    );
    if (rows.isEmpty) return false;

    final data = rows.first;
    final expiry = DateTime.tryParse(data['expires_at'] ?? '');
    if (expiry != null && DateTime.now().isAfter(expiry)) {
      return false;
    }

    final stored = data['otp_hash'] ?? '';
    final parts = stored.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final expectedHash = parts[1];
    final testHash = _hashWithSalt(otp, salt);

    final isValid = testHash == expectedHash;
    if (isValid) {
      await _store.delete(CsvSchema.otpCodesTable, (row) => row['mobile'] == mobile);
    }
    return isValid;
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
}
