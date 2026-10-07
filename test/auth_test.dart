import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late CsvStore store;
  late CsvAuthRepository authRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('pondy_auth_test_db');
    store = CsvStore.instance;
    store.invalidateCache();
    await store.initialize(customDir: tempDir);
    authRepo = CsvAuthRepository(store: store);
  });

  tearDown(() async {
    store.invalidateCache();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('AuthRepository requests and verifies OTP correctly', () async {
    const mobile = '+91 98400 99999';
    final otp = await authRepo.requestOtp(mobile);
    expect(otp.length, 6);

    // Master dev OTP
    final masterValid = await authRepo.verifyOtp(mobile, '123456');
    expect(masterValid, isTrue);

    // Re-request OTP for real hash test
    final newOtp = await authRepo.requestOtp(mobile);
    final isRealValid = await authRepo.verifyOtp(mobile, newOtp);
    expect(isRealValid, isTrue);

    // Bad OTP fails
    final isBadValid = await authRepo.verifyOtp(mobile, '000000');
    expect(isBadValid, isFalse);
  });

  test('AuthRepository registers user and checks password authentication', () async {
    const mobile = '+91 94432 11111';
    final user = await authRepo.registerOrGet(mobile, 'Myself');
    expect(user.mobile, mobile);
    expect(user.userId.startsWith('USR'), isTrue);

    // Set password
    await authRepo.setPassword(user.userId, 'Secret@123');

    // Login with correct password
    final loginUser = await authRepo.loginWithPassword(mobile, 'Secret@123');
    expect(loginUser, isNotNull);
    expect(loginUser!.userId, user.userId);

    // Login with wrong password
    final wrongLogin = await authRepo.loginWithPassword(mobile, 'WrongPass');
    expect(wrongLogin, isNull);
  });
}
