class ProfileModel {
  final String profileId;
  final String userId;
  final String name;
  final String gender;
  final String dob;
  final int age;
  final int heightCm;
  final String physicalStatus;
  final String maritalStatus;
  final int noOfChildren;
  final String motherTongue;
  final String religion;
  final String division;
  final String caste;
  final String subcaste;
  final bool willingOtherCaste;
  final String star;
  final String rasi;
  final String dosham;
  final String gothram;
  final String country;
  final String state;
  final String district;
  final String city;
  final String citizenship;
  final String education;
  final String educationDetail;
  final String employmentType;
  final String occupation;
  final String employer;
  final String incomeCurrency;
  final String annualIncomeRange;
  final String familyStatus;
  final String familyType;
  final String familyValues;
  final String fatherOccupation;
  final String motherOccupation;
  final int brothers;
  final int sisters;
  final String diet;
  final String smoking;
  final String drinking;
  final String aboutMe;
  final String profilePhotoPrivacy; // all, premium, on_request
  final int completenessPct;
  final String createdAt;
  final String updatedAt;
  final bool isDemo;
  final bool isSample;
  final bool isVerified;
  final String profileSource;
  final String? phone;
  final String? primaryPhotoUrl;
  String? get primaryPhoto => primaryPhotoUrl;

  const ProfileModel({
    required this.profileId,
    required this.userId,
    required this.name,
    required this.gender,
    required this.dob,
    required this.age,
    required this.heightCm,
    this.physicalStatus = 'Normal',
    this.maritalStatus = 'never_married',
    this.noOfChildren = 0,
    this.motherTongue = 'tamil',
    this.religion = 'hindu',
    this.division = 'none',
    this.caste = 'caste_none',
    this.subcaste = '',
    this.willingOtherCaste = true,
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
    this.fatherOccupation = '',
    this.motherOccupation = '',
    this.brothers = 0,
    this.sisters = 0,
    this.diet = 'non_vegetarian',
    this.smoking = 'No',
    this.drinking = 'No',
    this.aboutMe = '',
    this.profilePhotoPrivacy = 'all',
    this.completenessPct = 70,
    required this.createdAt,
    required this.updatedAt,
    this.isDemo = false,
    this.isSample = false,
    this.isVerified = false,
    this.profileSource = 'user',
    this.phone,
    this.primaryPhotoUrl,
  });

  factory ProfileModel.fromMap(Map<String, String> map, [String? photoUrl]) {
    final isSampleFlag = (map['is_sample'] == '1' ||
        map['is_sample'] == 'true' ||
        map['profile_source'] == 'sample' ||
        map['is_demo'] == 'true' ||
        (map['profile_id']?.startsWith('PC_SAMPLE') ?? false) ||
        (map['profile_id']?.startsWith('SAMPLE') ?? false));

    return ProfileModel(
      profileId: map['profile_id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
      gender: map['gender'] ?? 'Male',
      dob: map['dob'] ?? '',
      age: int.tryParse(map['age'] ?? '25') ?? 25,
      heightCm: int.tryParse(map['height_cm'] ?? '165') ?? 165,
      physicalStatus: map['physical_status'] ?? map['physical_status_id'] ?? 'Normal',
      maritalStatus: map['marital_status'] ?? map['marital_status_id'] ?? 'never_married',
      noOfChildren: int.tryParse(map['no_of_children'] ?? '0') ?? 0,
      motherTongue: map['mother_tongue'] ?? map['mother_tongue_id'] ?? 'tamil',
      religion: map['religion'] ?? map['religion_id'] ?? 'hindu',
      division: map['division'] ?? map['division_id'] ?? 'none',
      caste: map['caste'] ?? map['caste_id'] ?? 'caste_none',
      subcaste: map['subcaste'] ?? map['sub_caste_id'] ?? '',
      willingOtherCaste: (map['willing_other_caste'] ?? 'true').toLowerCase() == 'true',
      star: map['star'] ?? '',
      rasi: map['rasi'] ?? '',
      dosham: map['dosham'] ?? 'none',
      gothram: map['gothram'] ?? map['gothram_id'] ?? '',
      country: map['country'] ?? 'India',
      state: map['state'] ?? 'Puducherry',
      district: map['district'] ?? 'puducherry',
      city: map['city'] ?? 'Puducherry',
      citizenship: map['citizenship'] ?? 'Indian',
      education: map['education'] ?? 'be_btech',
      educationDetail: map['education_detail'] ?? '',
      employmentType: map['employment_type'] ?? 'private',
      occupation: map['occupation'] ?? 'software_engineer',
      employer: map['employer'] ?? '',
      incomeCurrency: map['income_currency'] ?? 'INR',
      annualIncomeRange: map['annual_income_range'] ?? '5_to_7_lakhs',
      familyStatus: map['family_status'] ?? 'middle_class',
      familyType: map['family_type'] ?? 'nuclear',
      familyValues: map['family_values'] ?? 'moderate',
      fatherOccupation: map['father_occupation'] ?? '',
      motherOccupation: map['mother_occupation'] ?? '',
      brothers: int.tryParse(map['brothers'] ?? '0') ?? 0,
      sisters: int.tryParse(map['sisters'] ?? '0') ?? 0,
      diet: map['diet'] ?? 'non_vegetarian',
      smoking: map['smoking'] ?? 'No',
      drinking: map['drinking'] ?? 'No',
      aboutMe: map['about_me'] ?? '',
      profilePhotoPrivacy: map['profile_photo_privacy'] ?? 'all',
      completenessPct: int.tryParse(map['completeness_pct'] ?? '70') ?? 70,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      isDemo: (map['is_demo'] ?? 'false').toLowerCase() == 'true',
      isSample: isSampleFlag,
      isVerified: (map['is_verified'] == '1' || map['is_verified'] == 'true'),
      profileSource: map['profile_source'] ?? (isSampleFlag ? 'sample' : 'user'),
      phone: map['phone'] ?? map['mobile'] ?? map['contact_number'],
      primaryPhotoUrl: photoUrl,
    );
  }

  Map<String, String> toMap() {
    return {
      'profile_id': profileId,
      'user_id': userId,
      'name': name,
      'gender': gender,
      'dob': dob,
      'age': age.toString(),
      'height_cm': heightCm.toString(),
      'physical_status': physicalStatus,
      'physical_status_id': physicalStatus,
      'marital_status': maritalStatus,
      'marital_status_id': maritalStatus,
      'no_of_children': noOfChildren.toString(),
      'mother_tongue': motherTongue,
      'mother_tongue_id': motherTongue,
      'religion': religion,
      'religion_id': religion,
      'division': division,
      'division_id': division,
      'caste': caste,
      'caste_id': caste,
      'subcaste': subcaste,
      'sub_caste_id': subcaste,
      'willing_other_caste': willingOtherCaste.toString(),
      'star': star,
      'rasi': rasi,
      'dosham': dosham,
      'gothram': gothram,
      'gothram_id': gothram,
      'country': country,
      'state': state,
      'district': district,
      'city': city,
      'citizenship': citizenship,
      'education': education,
      'education_detail': educationDetail,
      'employment_type': employmentType,
      'occupation': occupation,
      'employer': employer,
      'income_currency': incomeCurrency,
      'annual_income_range': annualIncomeRange,
      'family_status': familyStatus,
      'family_type': familyType,
      'family_values': familyValues,
      'father_occupation': fatherOccupation,
      'mother_occupation': motherOccupation,
      'brothers': brothers.toString(),
      'sisters': sisters.toString(),
      'diet': diet,
      'smoking': smoking,
      'drinking': drinking,
      'about_me': aboutMe,
      'profile_photo_privacy': profilePhotoPrivacy,
      'completeness_pct': completenessPct.toString(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_demo': isDemo.toString(),
    };
  }

  ProfileModel copyWith({
    String? profileId,
    String? userId,
    String? name,
    String? gender,
    String? dob,
    int? age,
    int? heightCm,
    String? physicalStatus,
    String? maritalStatus,
    int? noOfChildren,
    String? motherTongue,
    String? religion,
    String? division,
    String? caste,
    String? subcaste,
    bool? willingOtherCaste,
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
    String? fatherOccupation,
    String? motherOccupation,
    int? brothers,
    int? sisters,
    String? diet,
    String? smoking,
    String? drinking,
    String? aboutMe,
    String? profilePhotoPrivacy,
    int? completenessPct,
    String? createdAt,
    String? updatedAt,
    bool? isDemo,
    bool? isSample,
    bool? isVerified,
    String? profileSource,
    String? phone,
    String? primaryPhotoUrl,
  }) {
    return ProfileModel(
      profileId: profileId ?? this.profileId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      physicalStatus: physicalStatus ?? this.physicalStatus,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      noOfChildren: noOfChildren ?? this.noOfChildren,
      motherTongue: motherTongue ?? this.motherTongue,
      religion: religion ?? this.religion,
      division: division ?? this.division,
      caste: caste ?? this.caste,
      subcaste: subcaste ?? this.subcaste,
      willingOtherCaste: willingOtherCaste ?? this.willingOtherCaste,
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
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      motherOccupation: motherOccupation ?? this.motherOccupation,
      brothers: brothers ?? this.brothers,
      sisters: sisters ?? this.sisters,
      diet: diet ?? this.diet,
      smoking: smoking ?? this.smoking,
      drinking: drinking ?? this.drinking,
      aboutMe: aboutMe ?? this.aboutMe,
      profilePhotoPrivacy: profilePhotoPrivacy ?? this.profilePhotoPrivacy,
      completenessPct: completenessPct ?? this.completenessPct,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDemo: isDemo ?? this.isDemo,
      isSample: isSample ?? this.isSample,
      isVerified: isVerified ?? this.isVerified,
      profileSource: profileSource ?? this.profileSource,
      phone: phone ?? this.phone,
      primaryPhotoUrl: primaryPhotoUrl ?? this.primaryPhotoUrl,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return 'PC';
  }
}
