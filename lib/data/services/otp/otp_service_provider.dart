import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../csv/csv_store.dart';
import 'otp_service.dart';

/// Provides either FakeOtpService or SmsOtpService based on AppConfig.useFakeOtp
final otpServiceProvider = Provider<OtpService>((ref) {
  if (AppConfig.useFakeOtp) {
    return FakeOtpService(store: CsvStore.instance);
  } else {
    return const SmsOtpService();
  }
});
