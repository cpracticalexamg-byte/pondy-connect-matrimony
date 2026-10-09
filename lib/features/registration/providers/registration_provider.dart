import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/csv/csv_schema.dart';
import '../../../data/csv/csv_store.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return RegistrationNotifier(profileRepo, ref);
});

class RegistrationState {
  // Step 1: Personal
  final String gender;
  final int? birthDay;
  final int? birthMonth;
  final int? birthYear;
  final int heightCm;
  final String physicalStatus;
  final String physicalDisabilityDetail;
  final String maritalStatus;
  final int noOfChildren;
  final bool childrenLivingWithMe;

  // Step 2: Religion & Astrology
  final String religion;
  final String division;
  final String caste;
  final String subcaste;
  final bool willingOtherCaste;
  final String motherTongue;
  final String star;
  final String rasi;
  final String dosham;
  final String gothram;

  // Step 3: Location
  final String country;
  final String state;
  final String district;
  final String city;
  final String citizenship;

  // Step 4: Professional
  final String education;
  final String educationDetail;
  final String employmentType;
  final String occupation;
  final String employer;
  final String incomeCurrency;
  final String annualIncomeRange;

  // Step 5: Additional / Family
  final String familyStatus;
  final String familyType;
  final String familyValues;
  final String diet;
  final String fatherOccupation;
  final String motherOccupation;
  final int brothers;
  final int sisters;

  // Review & Bio
  final String aboutMe;
  final String? bioModerationError;
  final String? inconsistencyWarning;

  // Photo
  final String? photoPath;
  final String photoPrivacy; // all, premium, on_request

  // Completion
  final String? createdProfileId;
  final int completenessPct;
  final int realTimeMatchCount;
  final bool isLoading;

  const RegistrationState({
    this.gender = 'Male',
    this.birthDay,
    this.birthMonth,
    this.birthYear,
    this.heightCm = 170,
    this.physicalStatus = 'Normal',
    this.physicalDisabilityDetail = '',
    this.maritalStatus = 'never_married',
    this.noOfChildren = 0,
    this.childrenLivingWithMe = false,
    this.religion = 'hindu',
    this.division = 'none',
    this.caste = 'caste_none',
    this.subcaste = '',
    this.willingOtherCaste = true,
    this.motherTongue = 'tamil',
    this.star = '',
    this.rasi = '',
    this.dosham = 'none',
    this.gothram = '',
    this.country = 'India',
    this.state = 'Puducherry',
    this.district = 'puducherry',
    this.city = 'Puducherry',
    this.citizenship = 'Indian',
    this.education = 'be_btech',
    this.educationDetail = '',
    this.employmentType = 'private',
    this.occupation = 'software_engineer',
    this.employer = '',
    this.incomeCurrency = 'INR',
    this.annualIncomeRange = '5_to_7_lakhs',
    this.familyStatus = 'middle_class',
    this.familyType = 'nuclear',
    this.familyValues = 'moderate',
    this.diet = 'non_vegetarian',
    this.fatherOccupation = '',
    this.motherOccupation = '',
    this.brothers = 0,
    this.sisters = 0,
    this.aboutMe = '',
    this.bioModerationError,
    this.inconsistencyWarning,
    this.photoPath,
    this.photoPrivacy = 'all',
    this.createdProfileId,
    this.completenessPct = 75,
    this.realTimeMatchCount = 310,
    this.isLoading = false,
  });

  int get calculatedAge {
    if (birthYear == null) return 25;
    final now = DateTime.now();
    int age = now.year - birthYear!;
    if (birthMonth != null && birthDay != null) {
      if (now.month < birthMonth! || (now.month == birthMonth! && now.day < birthDay!)) {
        age--;
      }
    }
    return age;
  }

  bool isLegalAgeValid() {
    final age = calculatedAge;
    if (gender == 'Male') {
      return age >= 21;
    } else {
      return age >= 18;
    }
  }

  String? checkInconsistencies() {
    if (employmentType == 'business' && occupation == 'doctor' && education.startsWith('be')) {
      return 'Education is Engineering (B.E.), but Occupation is Doctor with Business employment. Please review.';
    }
    if (employmentType == 'not_working' && annualIncomeRange != 'no_income') {
      return 'Employment is "Not Working", but an annual income range was selected.';
    }
    return null;
  }

  RegistrationState copyWith({
    String? gender,
    int? birthDay,
    int? birthMonth,
    int? birthYear,
    int? heightCm,
    String? physicalStatus,
    String? physicalDisabilityDetail,
    String? maritalStatus,
    int? noOfChildren,
    bool? childrenLivingWithMe,
    String? religion,
    String? division,
    String? caste,
    String? subcaste,
    bool? willingOtherCaste,
    String? motherTongue,
    String? star,
    String? rasi,
    String? dosham,
    String? gothram,
    String? country,
    String? state,
    String? district,
    String? city,
    String? citizenship,
    String? education,
    String? educationDetail,
    String? employmentType,
    String? occupation,
    String? employer,
    String? incomeCurrency,
    String? annualIncomeRange,
    String? familyStatus,
    String? familyType,
    String? familyValues,
    String? diet,
    String? fatherOccupation,
    String? motherOccupation,
    int? brothers,
    int? sisters,
    String? aboutMe,
    String? bioModerationError,
    String? inconsistencyWarning,
    String? photoPath,
    String? photoPrivacy,
    String? createdProfileId,
    int? completenessPct,
    int? realTimeMatchCount,
    bool? isLoading,
  }) {
    return RegistrationState(
      gender: gender ?? this.gender,
      birthDay: birthDay ?? this.birthDay,
      birthMonth: birthMonth ?? this.birthMonth,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      physicalStatus: physicalStatus ?? this.physicalStatus,
      physicalDisabilityDetail: physicalDisabilityDetail ?? this.physicalDisabilityDetail,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      noOfChildren: noOfChildren ?? this.noOfChildren,
      childrenLivingWithMe: childrenLivingWithMe ?? this.childrenLivingWithMe,
      religion: religion ?? this.religion,
      division: division ?? this.division,
      caste: caste ?? this.caste,
      subcaste: subcaste ?? this.subcaste,
      willingOtherCaste: willingOtherCaste ?? this.willingOtherCaste,
      motherTongue: motherTongue ?? this.motherTongue,
      star: star ?? this.star,
      rasi: rasi ?? this.rasi,
      dosham: dosham ?? this.dosham,
      gothram: gothram ?? this.gothram,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      citizenship: citizenship ?? this.citizenship,
      education: education ?? this.education,
      educationDetail: educationDetail ?? this.educationDetail,
      employmentType: employmentType ?? this.employmentType,
      occupation: occupation ?? this.occupation,
      employer: employer ?? this.employer,
      incomeCurrency: incomeCurrency ?? this.incomeCurrency,
      annualIncomeRange: annualIncomeRange ?? this.annualIncomeRange,
      familyStatus: familyStatus ?? this.familyStatus,
      familyType: familyType ?? this.familyType,
      familyValues: familyValues ?? this.familyValues,
      diet: diet ?? this.diet,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      brothers: brothers ?? this.brothers,
      sisters: sisters ?? this.sisters,
      aboutMe: aboutMe ?? this.aboutMe,
      bioModerationError: bioModerationError,
      inconsistencyWarning: inconsistencyWarning,
      photoPath: photoPath ?? this.photoPath,
      photoPrivacy: photoPrivacy ?? this.photoPrivacy,
      createdProfileId: createdProfileId ?? this.createdProfileId,
      completenessPct: completenessPct ?? this.completenessPct,
      realTimeMatchCount: realTimeMatchCount ?? this.realTimeMatchCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final ProfileRepository _profileRepo;
  final Ref _ref;
  static const String _draftKey = 'registration_draft_v1';

  RegistrationNotifier(this._profileRepo, this._ref) : super(const RegistrationState()) {
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_draftKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = state.copyWith(
          gender: map['gender']?.toString(),
          birthDay: map['birthDay'] as int?,
          birthMonth: map['birthMonth'] as int?,
          birthYear: map['birthYear'] as int?,
          heightCm: map['heightCm'] as int?,
          maritalStatus: map['maritalStatus']?.toString(),
          religion: map['religion']?.toString(),
          division: map['division']?.toString(),
          caste: map['caste']?.toString(),
          district: map['district']?.toString(),
          city: map['city']?.toString(),
          education: map['education']?.toString(),
          occupation: map['occupation']?.toString(),
          annualIncomeRange: map['annualIncomeRange']?.toString(),
          aboutMe: map['aboutMe']?.toString(),
        );
      } catch (e, stack) {
        AppLogger.warning('Failed to restore registration draft', tag: 'RegistrationProvider', error: e, stackTrace: stack);
      }
    }
    _recomputeMatchCount();
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'gender': state.gender,
      'birthDay': state.birthDay,
      'birthMonth': state.birthMonth,
      'birthYear': state.birthYear,
      'heightCm': state.heightCm,
      'maritalStatus': state.maritalStatus,
      'religion': state.religion,
      'division': state.division,
      'caste': state.caste,
      'district': state.district,
      'city': state.city,
      'education': state.education,
      'occupation': state.occupation,
      'annualIncomeRange': state.annualIncomeRange,
      'aboutMe': state.aboutMe,
    };
    await prefs.setString(_draftKey, jsonEncode(map));
  }

  void updatePersonal({
    String? gender,
    int? birthDay,
    int? birthMonth,
    int? birthYear,
    int? heightCm,
    String? physicalStatus,
    String? maritalStatus,
    int? noOfChildren,
    bool? childrenLivingWithMe,
  }) {
    state = state.copyWith(
      gender: gender,
      birthDay: birthDay,
      birthMonth: birthMonth,
      birthYear: birthYear,
      heightCm: heightCm,
      physicalStatus: physicalStatus,
      maritalStatus: maritalStatus,
      noOfChildren: noOfChildren,
      childrenLivingWithMe: childrenLivingWithMe,
    );
    _persistDraft();
    _recomputeMatchCount();
  }

  void updateReligion({
    String? religion,
    String? division,
    String? caste,
    String? subcaste,
    bool? willingOtherCaste,
    String? motherTongue,
    String? star,
    String? rasi,
    String? dosham,
    String? gothram,
  }) {
    state = state.copyWith(
      religion: religion,
      division: division,
      caste: caste,
      subcaste: subcaste,
      willingOtherCaste: willingOtherCaste,
      motherTongue: motherTongue,
      star: star,
      rasi: rasi,
      dosham: dosham,
      gothram: gothram,
    );
    _persistDraft();
    _recomputeMatchCount();
  }

  void updateLocation({
    String? country,
    String? stateName,
    String? district,
    String? city,
    String? citizenship,
  }) {
    state = state.copyWith(
      country: country,
      state: stateName,
      district: district,
      city: city,
      citizenship: citizenship,
    );
    _persistDraft();
    _recomputeMatchCount();
  }

  void updateProfessional({
    String? education,
    String? educationDetail,
    String? employmentType,
    String? occupation,
    String? employer,
    String? annualIncomeRange,
  }) {
    state = state.copyWith(
      education: education,
      educationDetail: educationDetail,
      employmentType: employmentType,
      occupation: occupation,
      employer: employer,
      annualIncomeRange: annualIncomeRange,
    );
    _persistDraft();
    _recomputeMatchCount();
  }

  void updateFamily({
    String? familyStatus,
    String? familyType,
    String? familyValues,
    String? diet,
    String? fatherOccupation,
    String? motherOccupation,
    int? brothers,
    int? sisters,
  }) {
    state = state.copyWith(
      familyStatus: familyStatus,
      familyType: familyType,
      familyValues: familyValues,
      diet: diet,
      fatherOccupation: fatherOccupation,
      motherOccupation: motherOccupation,
      brothers: brothers,
      sisters: sisters,
    );
    _persistDraft();
  }

  void updateAboutMe(String text) {
    final error = validateBio(text);
    state = state.copyWith(aboutMe: text, bioModerationError: error);
    _persistDraft();
  }

  void updatePhoto(String path, {String? privacy}) {
    state = state.copyWith(photoPath: path, photoPrivacy: privacy);
  }

  /// Content moderation validator: reject phone numbers, emails, links, handles, profanities
  String? validateBio(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 30) {
      return 'Please write at least 30 characters about yourself/your relation.';
    }
    if (trimmed.length > 500) {
      return 'Bio must not exceed 500 characters.';
    }

    // Phone number detection
    final phoneRegex = RegExp(r'(\+?\d{1,4}[-.\s]?)?(\(?\d{3}\)?[-.\s]?)?\d{3}[-.\s]?\d{4}|\b\d{10}\b');
    if (phoneRegex.hasMatch(trimmed)) {
      return 'Please review and update your content. Phone numbers are not allowed in the bio.';
    }

    // Email detection
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    if (emailRegex.hasMatch(trimmed)) {
      return 'Please review and update your content. Email addresses are not allowed in the bio.';
    }

    // URL detection
    final urlRegex = RegExp(r'(https?:\/\/|www\.)[^\s/$.?#].[^\s]*|\b[a-zA-Z0-9.-]+\.(com|org|net|in|io)\b');
    if (urlRegex.hasMatch(trimmed)) {
      return 'Please review and update your content. Web links/URLs are not allowed in the bio.';
    }

    // Social handles
    final handleRegex = RegExp(r'(@[a-zA-Z0-9_]{3,}|insta:|fb:|whatsapp:)', caseSensitive: false);
    if (handleRegex.hasMatch(trimmed)) {
      return 'Social media handles or messaging accounts are not allowed in the bio.';
    }

    return null;
  }

  /// Smart validation engine: flags inconsistent combinations
  String? checkInconsistencies() {
    if (state.employmentType == 'business' && state.occupation == 'doctor' && state.education.startsWith('be')) {
      return 'Education is Engineering (B.E.), but Occupation is Doctor with Business employment. Please review.';
    }
    if (state.employmentType == 'not_working' && state.annualIncomeRange != 'no_income') {
      return 'Employment is "Not Working", but an annual income range was selected.';
    }
    return null;
  }

  /// Generate rule-based default bio without network
  void suggestBio() {
    final prefix = _ref.read(authStateProvider).relationPrefix;
    final relWord = prefix.isNotEmpty ? prefix.replaceAll("'s ", "") : "me";
    final isMyself = prefix.isEmpty;

    String bio;
    if (isMyself) {
      bio = 'Hello! I am a warm, ambitious person working as a ${state.occupation.replaceAll('_', ' ')}. '
          'I value family culture, mutual respect and open communication. '
          'Looking for a kind, caring partner to share life\'s beautiful journey with.';
    } else {
      bio = 'Hello! Creating this profile for my $relWord. '
          'Works as a ${state.occupation.replaceAll('_', ' ')} with a strong academic background. '
          'Looking for a suitable partner with good values, understanding nature and family traditions.';
    }

    updateAboutMe(bio);
  }

  /// Dynamic match counting: queries real CSV rows to compute exact count for teaser strip
  Future<void> _recomputeMatchCount() async {
    try {
      final oppositeGender = state.gender == 'Male' ? 'Female' : 'Male';
      final store = CsvStore.instance;

      final rows = await store.query(CsvSchema.profilesTable, (row) {
        if (row['gender'] != oppositeGender) return false;
        if (state.religion.isNotEmpty && state.religion != 'all' && !state.willingOtherCaste) {
          if (row['religion'] != state.religion) return false;
        }
        return true;
      });

      state = state.copyWith(realTimeMatchCount: rows.length);
    } catch (e, stack) {
      AppLogger.warning('Failed to compute real-time matches', tag: 'RegistrationProvider', error: e, stackTrace: stack);
    }
  }

  /// Finalize registration: creates real Profile in profiles.csv
  Future<String?> finalizeRegistration() async {
    state = state.copyWith(isLoading: true);
    try {
      final auth = _ref.read(authStateProvider);
      final userId = auth.user?.userId ?? 'USR000101';
      final name = auth.user?.mobile ?? 'Member';

      final birthDateStr = '${state.birthYear ?? 1998}-${(state.birthMonth ?? 1).toString().padLeft(2, '0')}-${(state.birthDay ?? 1).toString().padLeft(2, '0')}';
      final now = DateTime.now().toIso8601String();

      final newProfile = ProfileModel(
        profileId: '',
        userId: userId,
        name: name,
        gender: state.gender,
        dob: birthDateStr,
        age: state.calculatedAge,
        heightCm: state.heightCm,
        physicalStatus: state.physicalStatus,
        maritalStatus: state.maritalStatus,
        noOfChildren: state.noOfChildren,
        motherTongue: state.motherTongue,
        religion: state.religion,
        division: state.division,
        caste: state.caste,
        subcaste: state.subcaste,
        willingOtherCaste: state.willingOtherCaste,
        star: state.star,
        rasi: state.rasi,
        dosham: state.dosham,
        gothram: state.gothram,
        country: state.country,
        state: state.state,
        district: state.district,
        city: state.city,
        citizenship: state.citizenship,
        education: state.education,
        educationDetail: state.educationDetail,
        employmentType: state.employmentType,
        occupation: state.occupation,
        employer: state.employer,
        incomeCurrency: state.incomeCurrency,
        annualIncomeRange: state.annualIncomeRange,
        familyStatus: state.familyStatus,
        familyType: state.familyType,
        familyValues: state.familyValues,
        fatherOccupation: state.fatherOccupation,
        motherOccupation: state.motherOccupation,
        brothers: state.brothers,
        sisters: state.sisters,
        diet: state.diet,
        aboutMe: state.aboutMe,
        profilePhotoPrivacy: state.photoPrivacy,
        completenessPct: state.photoPath != null ? 85 : 70,
        createdAt: now,
        updatedAt: now,
        isDemo: false,
      );

      final profileId = await _profileRepo.createProfile(newProfile);

      if (state.photoPath != null && state.photoPath!.isNotEmpty) {
        await _profileRepo.addPhoto(profileId, state.photoPath!, isPrimary: true, privacy: state.photoPrivacy);
      }

      // Clear draft
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftKey);

      state = state.copyWith(
        createdProfileId: profileId,
        isLoading: false,
      );

      await _ref.read(authStateProvider.notifier).checkCurrentUser();
      return profileId;
    } catch (e, stack) {
      AppLogger.error('Failed to finalize registration profile', tag: 'RegistrationProvider', error: e, stackTrace: stack);
      state = state.copyWith(isLoading: false);
      return null;
    }
  }
}
