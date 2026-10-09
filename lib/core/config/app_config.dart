class AppConfig {
  static const String appName = 'Pondy Connect Matrimony';
  static const String appTagline = 'Find your life partner, the Pondy way.';
  static const String supportPhoneNumber = '+91 98400 12345';
  static const String supportEmail = 'support@pondyconnectmatrimony.com';

  /// When true, OTP is printed to debug banner / snackbar instead of SMS gateway
  static const bool devOtp = true;

  /// Isolated OTP Service mode: true = FakeOtpService (dev/test), false = SmsOtpService (production SMS gateway)
  static const bool useFakeOtp = true;

  /// Shows 'Test Mode: Use code 123456' hint under OTP inputs
  static const bool showOtpTestHint = true;

  /// Fixed test code for FakeOtpService
  static const String testOtpCode = '123456';

  /// OTP Resend countdown in seconds
  static const int otpResendSeconds = 30;

  /// Maximum failed OTP verification attempts before lockout
  static const int maxOtpAttempts = 5;

  /// Lockout duration on exceeded attempts in minutes
  static const int otpLockoutMinutes = 10;

  /// OTP validity expiration in minutes
  static const int otpExpiryMinutes = 10;

  /// Maximum OTP send requests per 10 minutes (rate limiting)
  static const int maxOtpRequestsPerWindow = 3;

  /// Default currency
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';

  /// Legal age constraints
  static const int minMaleAge = 21;
  static const int minFemaleAge = 18;

  /// Maximum photo upload size in bytes (800 KB)
  static const int maxPhotoSizeBytes = 800 * 1024;
}
