class AppConfig {
  static const String appName = 'Pondy Connect Matrimony';
  static const String appTagline = 'Find your life partner, the Pondy way.';
  static const String supportPhoneNumber = '+91 98400 12345';
  static const String supportEmail = 'support@pondyconnectmatrimony.com';

  /// When true, OTP is printed to debug banner / snackbar instead of SMS gateway
  static const bool devOtp = true;

  /// Default currency
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';

  /// Legal age constraints
  static const int minMaleAge = 21;
  static const int minFemaleAge = 18;

  /// Maximum photo upload size in bytes (800 KB)
  static const int maxPhotoSizeBytes = 800 * 1024;
}
