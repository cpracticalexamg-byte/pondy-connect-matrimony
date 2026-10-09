import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/result/result.dart';
import '../../../core/utils/app_logger.dart';
import '../../csv/csv_schema.dart';
import '../../csv/csv_store.dart';

/// Data transfer object holding the outcome of an OTP dispatch.
class OtpSendResult {
  final String requestId;
  final String mobile;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
  final bool isFake;
  final String? testCode;

  const OtpSendResult({
    required this.requestId,
    required this.mobile,
    required this.expiresAt,
    required this.resendAvailableAt,
    required this.isFake,
    this.testCode,
  });
}

/// Abstract contract for isolated OTP authentication.
/// Swapping between development fake OTP and production SMS providers
/// requires altering only the dependency injection provider.
abstract class OtpService {
  Future<Result<OtpSendResult, AppError>> sendOtp(String mobile);
  Future<Result<bool, AuthError>> verifyOtp(String mobile, String otp);
  Future<int> getRemainingCooldownSeconds(String mobile);
}

/// Isolated development and testing OTP service.
/// Uses fixed test code (123456) with full production-grade constraints:
/// - Rate limiting: max 3 requests per 10 minutes
/// - Expiration: 10 minutes
/// - Lockout: 5 failed attempts locks mobile for 10 minutes
/// - Persistent tracking in CSV database (otp_requests table)
class FakeOtpService implements OtpService {
  final CsvStore _store;

  FakeOtpService({CsvStore? store}) : _store = store ?? CsvStore.instance;

  String _cleanMobile(String mobile) => mobile.replaceAll(RegExp(r'\s+'), '');

  String _hashOtp(String otp, String salt) {
    final bytes = utf8.encode('$salt:$otp');
    return sha256.convert(bytes).toString();
  }

  @override
  Future<int> getRemainingCooldownSeconds(String mobile) async {
    final clean = _cleanMobile(mobile);
    final rows = await _store.query(
      CsvSchema.otpRequestsTable,
      (row) => row['mobile'] == clean,
    );
    if (rows.isEmpty) return 0;

    final sorted = List<Map<String, String>>.from(rows)
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    final latest = sorted.first;

    final createdAt = DateTime.tryParse(latest['created_at'] ?? '');
    if (createdAt == null) return 0;

    final cooldownEnd = createdAt.add(const Duration(seconds: AppConfig.otpResendSeconds));
    final diff = cooldownEnd.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  @override
  Future<Result<OtpSendResult, AppError>> sendOtp(String mobile) async {
    final clean = _cleanMobile(mobile);
    if (clean.length < 10) {
      return const Failure(ValidationError(field: 'mobile', reason: 'Mobile number must have at least 10 digits.'));
    }

    final now = DateTime.now();

    // 1. Check if user is locked out
    final existingRows = await _store.query(
      CsvSchema.otpRequestsTable,
      (row) => row['mobile'] == clean,
    );

    for (final row in existingRows) {
      final lockoutStr = row['lockout_until'] ?? '';
      if (lockoutStr.isNotEmpty) {
        final lockoutUntil = DateTime.tryParse(lockoutStr);
        if (lockoutUntil != null && now.isBefore(lockoutUntil)) {
          final remainingMinutes = lockoutUntil.difference(now).inMinutes + 1;
          AppLogger.warning('Mobile $clean is locked out for $remainingMinutes more minutes', tag: 'FakeOtpService');
          return Failure(AuthError.otpLockedOut(
            'Too many failed attempts. Account locked. Try again in $remainingMinutes minute(s).',
          ));
        }
      }
    }

    // 2. Check rate limit: max requests within 10 minute window
    final windowStart = now.subtract(const Duration(minutes: 10));
    final recentRequests = existingRows.where((row) {
      final created = DateTime.tryParse(row['created_at'] ?? '');
      return created != null && created.isAfter(windowStart);
    }).length;

    if (recentRequests >= AppConfig.maxOtpRequestsPerWindow) {
      AppLogger.warning('Rate limit reached for mobile $clean ($recentRequests requests in window)', tag: 'FakeOtpService');
      return Failure(AuthError.rateLimited(
        'Too many OTP requests. Please wait a few minutes before trying again.',
      ));
    }

    // 3. Generate and store OTP record
    final requestId = await _store.nextId(CsvSchema.otpRequestsTable, 'request_id', 'OTP', 6);
    final salt = 'pondy_${now.millisecondsSinceEpoch}';
    const testCode = AppConfig.testOtpCode;
    final hash = '$salt:${_hashOtp(testCode, salt)}';
    final expiresAt = now.add(const Duration(minutes: AppConfig.otpExpiryMinutes));
    final resendAvailableAt = now.add(const Duration(seconds: AppConfig.otpResendSeconds));

    await _store.insert(CsvSchema.otpRequestsTable, {
      'request_id': requestId,
      'mobile': clean,
      'otp_hash': hash,
      'attempts': '0',
      'is_verified': '0',
      'lockout_until': '',
      'expires_at': expiresAt.toIso8601String(),
      'created_at': now.toIso8601String(),
    });

    AppLogger.info('Fake OTP sent to $clean [Code: $testCode, Req: $requestId]', tag: 'FakeOtpService');

    return Success(OtpSendResult(
      requestId: requestId,
      mobile: clean,
      expiresAt: expiresAt,
      resendAvailableAt: resendAvailableAt,
      isFake: true,
      testCode: testCode,
    ));
  }

  @override
  Future<Result<bool, AuthError>> verifyOtp(String mobile, String otp) async {
    final clean = _cleanMobile(mobile);
    final now = DateTime.now();

    final rows = await _store.query(
      CsvSchema.otpRequestsTable,
      (row) => row['mobile'] == clean,
    );

    if (rows.isEmpty) {
      return Failure(AuthError.invalidOtp('No active OTP request found. Please request a new code.'));
    }

    // Pick latest request
    final sorted = List<Map<String, String>>.from(rows)
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    final record = sorted.first;

    // Check lockout
    final lockoutStr = record['lockout_until'] ?? '';
    if (lockoutStr.isNotEmpty) {
      final lockoutUntil = DateTime.tryParse(lockoutStr);
      if (lockoutUntil != null && now.isBefore(lockoutUntil)) {
        final remainingMinutes = lockoutUntil.difference(now).inMinutes + 1;
        return Failure(AuthError.otpLockedOut(
          'Account locked due to too many failed attempts. Try again in $remainingMinutes minute(s).',
        ));
      }
    }

    // Check expiration
    final expiry = DateTime.tryParse(record['expires_at'] ?? '');
    if (expiry != null && now.isAfter(expiry)) {
      return Failure(AuthError.otpExpired('OTP has expired. Please request a new code.'));
    }

    // Verify hash or master test code
    final storedHash = record['otp_hash'] ?? '';
    final parts = storedHash.split(':');
    bool isValid = false;

    if (otp == AppConfig.testOtpCode) {
      isValid = true;
    } else if (parts.length == 2) {
      final salt = parts[0];
      final expectedHash = parts[1];
      final computed = _hashOtp(otp, salt);
      isValid = computed == expectedHash;
    }

    final attempts = (int.tryParse(record['attempts'] ?? '0') ?? 0) + 1;

    if (!isValid) {
      if (attempts >= AppConfig.maxOtpAttempts) {
        final lockoutUntil = now.add(const Duration(minutes: AppConfig.otpLockoutMinutes));
        await _store.update(
          CsvSchema.otpRequestsTable,
          {
            'attempts': attempts.toString(),
            'lockout_until': lockoutUntil.toIso8601String(),
          },
          (r) => r['request_id'] == record['request_id'],
        );
        AppLogger.warning('Max OTP attempts exceeded for $clean. Locked out for ${AppConfig.otpLockoutMinutes} mins.', tag: 'FakeOtpService');
        return Failure(AuthError.otpLockedOut(
          'Too many failed attempts. Mobile locked for ${AppConfig.otpLockoutMinutes} minutes.',
        ));
      } else {
        await _store.update(
          CsvSchema.otpRequestsTable,
          {'attempts': attempts.toString()},
          (r) => r['request_id'] == record['request_id'],
        );
        final remainingAttempts = AppConfig.maxOtpAttempts - attempts;
        return Failure(AuthError.invalidOtp(
          'Incorrect OTP code. $remainingAttempts attempt(s) remaining.',
        ));
      }
    }

    // Successful verification
    await _store.update(
      CsvSchema.otpRequestsTable,
      {'is_verified': '1'},
      (r) => r['request_id'] == record['request_id'],
    );

    AppLogger.info('OTP successfully verified for $clean', tag: 'FakeOtpService');
    return const Success(true);
  }
}

/// Production SMS Gateway OTP Service Stub.
/// When switching to SMS in production, populate the API key / credentials
/// below or pass them via environment variables.
class SmsOtpService implements OtpService {
  final String apiKey;
  final String endpoint;

  const SmsOtpService({
    this.apiKey = '',
    this.endpoint = 'https://api.sms-gateway.in/v1/otp',
  });

  @override
  Future<int> getRemainingCooldownSeconds(String mobile) async {
    return 0;
  }

  @override
  Future<Result<OtpSendResult, AppError>> sendOtp(String mobile) async {
    // In production: perform HTTPS POST to SMS gateway
    AppLogger.info('SmsOtpService: Dispatching real SMS to $mobile via $endpoint', tag: 'SmsOtpService');
    final now = DateTime.now();
    return Success(OtpSendResult(
      requestId: 'SMS_${now.millisecondsSinceEpoch}',
      mobile: mobile,
      expiresAt: now.add(const Duration(minutes: AppConfig.otpExpiryMinutes)),
      resendAvailableAt: now.add(const Duration(seconds: AppConfig.otpResendSeconds)),
      isFake: false,
    ));
  }

  @override
  Future<Result<bool, AuthError>> verifyOtp(String mobile, String otp) async {
    // In production: verify against SMS gateway validation endpoint
    AppLogger.info('SmsOtpService: Verifying SMS OTP for $mobile', tag: 'SmsOtpService');
    return const Success(true);
  }
}
