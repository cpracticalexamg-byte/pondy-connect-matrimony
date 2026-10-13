class Entitlements {
  final String tier; // 'free', 'gold', 'prime_gold', 'till_u_marry'
  final String planName;
  final DateTime? expiry;
  final int contactViewsRemaining; // -1 indicates unlimited fair use
  final int dailyContactCap;
  final int dailyContactsViewedToday;
  final bool canMessage;
  final bool canViewHoroscope;
  final bool canViewVerifiedPhotos;
  final int maxInterestsPerDay;
  final Map<String, bool> fieldVisibility;

  const Entitlements({
    required this.tier,
    required this.planName,
    this.expiry,
    this.contactViewsRemaining = 0,
    this.dailyContactCap = 0,
    this.dailyContactsViewedToday = 0,
    this.canMessage = false,
    this.canViewHoroscope = false,
    this.canViewVerifiedPhotos = false,
    this.maxInterestsPerDay = 10,
    this.fieldVisibility = const {},
  });

  bool get isPaid => tier != 'free';
  bool get isPrime => tier == 'prime_gold' || tier == 'till_u_marry';
  bool get isUnlimitedContacts => contactViewsRemaining == -1;

  bool get isExpiringSoon {
    if (expiry == null) return false;
    final now = DateTime.now();
    return expiry!.isAfter(now) && expiry!.difference(now).inDays <= 3;
  }

  bool get hasExpired {
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry!);
  }

  bool fieldVisible(String fieldCode) {
    if (!fieldVisibility.containsKey(fieldCode)) {
      return true; // Default visible if not explicitly constrained
    }
    return fieldVisibility[fieldCode] == true;
  }

  static Entitlements free() {
    return const Entitlements(
      tier: 'free',
      planName: 'Free Member',
      expiry: null,
      contactViewsRemaining: 0,
      dailyContactCap: 0,
      dailyContactsViewedToday: 0,
      canMessage: false,
      canViewHoroscope: false,
      canViewVerifiedPhotos: false,
      maxInterestsPerDay: 10,
      fieldVisibility: {
        'caste': true,
        'sub_caste': true,
        'gothram': true,
        'employment_type': true,
        'annual_income': true,
        'education_level': true,
        'occupation': true,
        'family_status': true,
        'general_details': true,
        'dob': false,
        'star': false,
        'rasi': false,
        'horoscope_chart': false,
        'institution': false,
        'employer': false,
        'verified_photos': false,
        'contact_number': false,
      },
    );
  }

  static Entitlements gold({DateTime? expiry, int contactViewsRemaining = 40}) {
    return Entitlements(
      tier: 'gold',
      planName: 'Gold Member',
      expiry: expiry,
      contactViewsRemaining: contactViewsRemaining,
      dailyContactCap: 40,
      dailyContactsViewedToday: 0,
      canMessage: true,
      canViewHoroscope: true,
      canViewVerifiedPhotos: false,
      maxInterestsPerDay: 999999,
      fieldVisibility: const {
        'caste': true,
        'sub_caste': true,
        'gothram': true,
        'employment_type': true,
        'annual_income': true,
        'education_level': true,
        'occupation': true,
        'family_status': true,
        'general_details': true,
        'dob': true,
        'star': true,
        'rasi': true,
        'horoscope_chart': true,
        'institution': true,
        'employer': true,
        'verified_photos': false,
        'contact_number': true,
      },
    );
  }

  static Entitlements primeGold({DateTime? expiry, int dailyCap = 50}) {
    return Entitlements(
      tier: 'prime_gold',
      planName: 'Prime Gold Member',
      expiry: expiry,
      contactViewsRemaining: -1,
      dailyContactCap: dailyCap,
      dailyContactsViewedToday: 0,
      canMessage: true,
      canViewHoroscope: true,
      canViewVerifiedPhotos: true,
      maxInterestsPerDay: 999999,
      fieldVisibility: const {
        'caste': true,
        'sub_caste': true,
        'gothram': true,
        'employment_type': true,
        'annual_income': true,
        'education_level': true,
        'occupation': true,
        'family_status': true,
        'general_details': true,
        'dob': true,
        'star': true,
        'rasi': true,
        'horoscope_chart': true,
        'institution': true,
        'employer': true,
        'verified_photos': true,
        'contact_number': true,
      },
    );
  }

  static Entitlements primeTillMarry({DateTime? expiry, int dailyCap = 50}) {
    return Entitlements(
      tier: 'till_u_marry',
      planName: 'Prime – Till U Marry',
      expiry: expiry,
      contactViewsRemaining: -1,
      dailyContactCap: dailyCap,
      dailyContactsViewedToday: 0,
      canMessage: true,
      canViewHoroscope: true,
      canViewVerifiedPhotos: true,
      maxInterestsPerDay: 999999,
      fieldVisibility: const {
        'caste': true,
        'sub_caste': true,
        'gothram': true,
        'employment_type': true,
        'annual_income': true,
        'education_level': true,
        'occupation': true,
        'family_status': true,
        'general_details': true,
        'dob': true,
        'star': true,
        'rasi': true,
        'horoscope_chart': true,
        'institution': true,
        'employer': true,
        'verified_photos': true,
        'contact_number': true,
      },
    );
  }
}
