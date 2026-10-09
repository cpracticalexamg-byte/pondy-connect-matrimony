import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/config/app_config.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/services/otp/otp_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late CsvStore store;
  late FakeOtpService otpService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('pondy_otp_test');
    store = CsvStore.instance;
    store.invalidateCache();
    await store.initialize(customDir: tempDir);
    otpService = FakeOtpService(store: store);
  });

  tearDown(() async {
    store.invalidateCache();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FakeOtpService Tests', () {
    const mobile = '+919840012345';

    test('sendOtp returns success with test code and expiry', () async {
      final res = await otpService.sendOtp(mobile);
      expect(res.isSuccess, isTrue);

      final data = res.valueOrNull!;
      expect(data.isFake, isTrue);
      expect(data.testCode, AppConfig.testOtpCode);
      expect(data.mobile, mobile.replaceAll(' ', ''));
      expect(data.expiresAt.isAfter(DateTime.now()), isTrue);
    });

    test('verifyOtp succeeds with correct test code 123456', () async {
      final sendRes = await otpService.sendOtp(mobile);
      expect(sendRes.isSuccess, isTrue);

      final verifyRes = await otpService.verifyOtp(mobile, AppConfig.testOtpCode);
      expect(verifyRes.isSuccess, isTrue);
      expect(verifyRes.valueOrNull, isTrue);
    });

    test('verifyOtp fails with incorrect code and tracks remaining attempts', () async {
      await otpService.sendOtp(mobile);

      final wrongRes1 = await otpService.verifyOtp(mobile, '000000');
      expect(wrongRes1.isFailure, isTrue);
      expect(wrongRes1.errorOrNull?.message, contains('4 attempt(s) remaining'));

      final wrongRes2 = await otpService.verifyOtp(mobile, '111111');
      expect(wrongRes2.isFailure, isTrue);
      expect(wrongRes2.errorOrNull?.message, contains('3 attempt(s) remaining'));
    });

    test('5 consecutive failed attempts locks out the mobile for 10 minutes', () async {
      await otpService.sendOtp(mobile);

      for (int i = 0; i < 4; i++) {
        final r = await otpService.verifyOtp(mobile, '99999$i');
        expect(r.isFailure, isTrue);
      }

      // 5th attempt triggers lockout
      final lockoutRes = await otpService.verifyOtp(mobile, '000000');
      expect(lockoutRes.isFailure, isTrue);
      expect(lockoutRes.errorOrNull?.message, contains('Mobile locked'));

      // Subsequent attempt is blocked by lockout
      final blockedSend = await otpService.sendOtp(mobile);
      expect(blockedSend.isFailure, isTrue);
      expect(blockedSend.errorOrNull?.message, contains('Account locked'));
    });

    test('Rate limit enforces maximum 3 OTP requests in window', () async {
      const uniqueMobile = '+919876543210';

      final r1 = await otpService.sendOtp(uniqueMobile);
      expect(r1.isSuccess, isTrue);

      final r2 = await otpService.sendOtp(uniqueMobile);
      expect(r2.isSuccess, isTrue);

      final r3 = await otpService.sendOtp(uniqueMobile);
      expect(r3.isSuccess, isTrue);

      // 4th request must be rate limited
      final r4 = await otpService.sendOtp(uniqueMobile);
      expect(r4.isFailure, isTrue);
      expect(r4.errorOrNull?.message, contains('Too many OTP requests'));
    });
  });

  group('SmsOtpService Stub Tests', () {
    test('SmsOtpService sends and verifies cleanly', () async {
      const smsService = SmsOtpService();
      final send = await smsService.sendOtp('+919840012345');
      expect(send.isSuccess, isTrue);
      expect(send.valueOrNull!.isFake, isFalse);

      final verify = await smsService.verifyOtp('+919840012345', '123456');
      expect(verify.isSuccess, isTrue);
    });
  });
}
