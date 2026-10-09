import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/errors/app_error.dart';
import 'package:pondy_connect_matrimony/core/result/result.dart';
import 'package:pondy_connect_matrimony/core/utils/app_logger.dart';

void main() {
  group('Result and AppError Tests', () {
    test('Success returns value and handles transformations correctly', () {
      const result = Success<int, AppError>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.errorOrNull, isNull);
      expect(result.getOrThrow(), 42);
      expect(result.getOrDefault(0), 42);

      final mapped = result.map((v) => 'Value: $v');
      expect(mapped.valueOrNull, 'Value: 42');

      final patternMatched = result.when(
        success: (v) => 'Success $v',
        failure: (e) => 'Failed',
      );
      expect(patternMatched, 'Success 42');
    });

    test('Failure returns typed error and handles fallback defaults', () {
      final error = AuthError.invalidOtp('Incorrect OTP');
      final result = Failure<int, AppError>(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.errorOrNull, isA<AuthError>());
      expect(result.errorOrNull?.message, 'Incorrect OTP');
      expect(result.getOrDefault(99), 99);

      expect(() => result.getOrThrow(), throwsA(isA<AuthError>()));

      final patternMatched = result.when(
        success: (v) => 'Success $v',
        failure: (e) => 'Failure: ${e.message}',
      );
      expect(patternMatched, 'Failure: Incorrect OTP');
    });

    test('Domain errors format descriptive toString messages', () {
      const valErr = ValidationError(field: 'mobile', reason: 'Must be 10 digits');
      expect(valErr.toString(), contains('Validation failed on mobile: Must be 10 digits'));

      const notFound = NotFoundError('Profile', 'PC999999');
      expect(notFound.toString(), contains('Profile with ID "PC999999" not found.'));

      const dbErr = DatabaseError('Lock timeout', table: 'users');
      expect(dbErr.toString(), contains('DatabaseError: Lock timeout'));
    });

    test('AppLogger executes without crashing across all log levels', () {
      expect(() => AppLogger.debug('Debug test', tag: 'Test'), returnsNormally);
      expect(() => AppLogger.info('Info test', tag: 'Test'), returnsNormally);
      expect(() => AppLogger.warning('Warn test', tag: 'Test'), returnsNormally);
      expect(() => AppLogger.error('Error test', tag: 'Test'), returnsNormally);
    });
  });
}
