import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Secure token & sensitive key-value storage hardened with SHA-256 key derivation
/// and payload obfuscation/tamper protection.
class SecureStorageService {
  static final SecureStorageService instance = SecureStorageService._();
  SecureStorageService._();

  static const String _prefix = 'sec_enc_v1_';
  static const String _deviceSecret = 'pondy_connect_secret_salt_2026';

  String _deriveKey(String key) {
    return sha256.convert(utf8.encode('$_deviceSecret:$key')).toString();
  }

  String _obfuscate(String plain, String derivedKey) {
    final keyBytes = utf8.encode(derivedKey);
    final plainBytes = utf8.encode(plain);
    final masked = List<int>.generate(plainBytes.length, (i) {
      return plainBytes[i] ^ keyBytes[i % keyBytes.length];
    });

    // Append HMAC signature to detect tampering
    final hmac = Hmac(sha256, keyBytes);
    final sig = hmac.convert(masked).toString().substring(0, 16);
    final payload = base64Url.encode(masked);
    return '$sig:$payload';
  }

  String? _deobfuscate(String cipher, String derivedKey) {
    try {
      final parts = cipher.split(':');
      if (parts.length != 2) return null;
      final expectedSig = parts[0];
      final masked = base64Url.decode(parts[1]);

      final keyBytes = utf8.encode(derivedKey);
      final hmac = Hmac(sha256, keyBytes);
      final actualSig = hmac.convert(masked).toString().substring(0, 16);

      if (expectedSig != actualSig) {
        AppLogger.warning('Secure storage integrity check failed for key', tag: 'SecureStorage');
        return null;
      }

      final plainBytes = List<int>.generate(masked.length, (i) {
        return masked[i] ^ keyBytes[i % keyBytes.length];
      });
      return utf8.decode(plainBytes);
    } catch (e) {
      AppLogger.error('Failed to decrypt secure value', tag: 'SecureStorage', error: e);
      return null;
    }
  }

  Future<void> writeSecure(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final derivedKey = _deriveKey(key);
    final encrypted = _obfuscate(value, derivedKey);
    await prefs.setString('$_prefix$key', encrypted);
  }

  Future<String?> readSecure(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString('$_prefix$key');
    if (encrypted == null) return null;
    final derivedKey = _deriveKey(key);
    return _deobfuscate(encrypted, derivedKey);
  }

  Future<void> deleteSecure(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
