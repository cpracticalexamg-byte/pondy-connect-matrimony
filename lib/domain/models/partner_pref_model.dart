class PartnerPrefModel {
  final String profileId;
  final int ageMin;
  final int ageMax;
  final int heightMin;
  final int heightMax;
  final String maritalStatus;
  final String religion;
  final String division;
  final String caste;
  final String motherTongue;
  final String education;
  final String occupation;
  final String incomeMin;
  final String country;
  final String state;
  final String district;
  final String diet;
  final bool starMatchRequired;
  final String doshamPref;

  const PartnerPrefModel({
    required this.profileId,
    this.ageMin = 21,
    this.ageMax = 35,
    this.heightMin = 150,
    this.heightMax = 190,
    this.maritalStatus = 'all',
    this.religion = 'all',
    this.division = 'all',
    this.caste = 'all',
    this.motherTongue = 'tamil',
    this.education = 'all',
    this.occupation = 'all',
    this.incomeMin = 'all',
    this.country = 'India',
    this.state = 'all',
    this.district = 'all',
    this.diet = 'all',
    this.starMatchRequired = false,
    this.doshamPref = 'all',
  });

  factory PartnerPrefModel.fromMap(Map<String, String> map) {
    return PartnerPrefModel(
      profileId: map['profile_id'] ?? '',
      ageMin: int.tryParse(map['age_min'] ?? '21') ?? 21,
      ageMax: int.tryParse(map['age_max'] ?? '35') ?? 35,
      heightMin: int.tryParse(map['height_min'] ?? '150') ?? 150,
      heightMax: int.tryParse(map['height_max'] ?? '190') ?? 190,
      maritalStatus: map['marital_status'] ?? 'all',
      religion: map['religion'] ?? 'all',
      division: map['division'] ?? 'all',
      caste: map['caste'] ?? 'all',
      motherTongue: map['mother_tongue'] ?? 'tamil',
      education: map['education'] ?? 'all',
      occupation: map['occupation'] ?? 'all',
      incomeMin: map['income_min'] ?? 'all',
      country: map['country'] ?? 'India',
      state: map['state'] ?? 'all',
      district: map['district'] ?? 'all',
      diet: map['diet'] ?? 'all',
      starMatchRequired: (map['star_match_required'] ?? 'false').toLowerCase() == 'true',
      doshamPref: map['dosham_pref'] ?? 'all',
    );
  }

  Map<String, String> toMap() {
    return {
      'profile_id': profileId,
      'age_min': ageMin.toString(),
      'age_max': ageMax.toString(),
      'height_min': heightMin.toString(),
      'height_max': heightMax.toString(),
      'marital_status': maritalStatus,
      'religion': religion,
      'division': division,
      'caste': caste,
      'mother_tongue': motherTongue,
      'education': education,
      'occupation': occupation,
      'income_min': incomeMin,
      'country': country,
      'state': state,
      'district': district,
      'diet': diet,
      'star_match_required': starMatchRequired.toString(),
      'dosham_pref': doshamPref,
    };
  }
}
