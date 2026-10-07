// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() async {
  print('Generating 600+ synthetic profiles for Pondy Connect Matrimony...');
  final generator = SeedGenerator();
  await generator.generateAll();
  print('Seed generation completed successfully!');
}

class SeedGenerator {
  final Random _rnd = Random(42); // deterministic seed

  final List<String> _maleFirstNames = [
    'Anand', 'Karthik', 'Vignesh', 'Saravanan', 'Senthil', 'Aravind', 'Suresh', 'Dinesh',
    'Praveen', 'Rajesh', 'Balaji', 'Manojkumar', 'Prasanna', 'Gowtham', 'Sridhar', 'Ramesh',
    'Vijay', 'Ajith', 'Suriya', 'Ashwin', 'Harish', 'Naveen', 'Sanjay', 'Deepak',
    'Mohamed', 'Irfan', 'Faisal', 'Rizwan', 'Syed', 'John', 'David', 'Antony', 'Paul',
    'Joseph', 'Daniel', 'Michael', 'Jerome', 'Franklin', 'Vasanth', 'Gunasekaran', 'Subash',
  ];

  final List<String> _femaleFirstNames = [
    'Divya', 'Priya', 'Soundarya', 'Kaviya', 'Deepika', 'Keerthana', 'Ananya', 'Pavithra',
    'Shalini', 'Sneha', 'Lavanya', 'Swetha', 'Revathi', 'Gayathri', 'Nandhini', 'Meenakshi',
    'Lakshmi', 'Archana', 'Aishwarya', 'Bhavani', 'Janani', 'Kavitha', 'Sangeetha', 'Yamuna',
    'Fathima', 'Ayesha', 'Nasreen', 'Benazir', 'Zainab', 'Mary', 'Stella', 'Roselin',
    'Jenifer', 'Mercy', 'Catherine', 'Grace', 'Anitha', 'Preethi', 'Vidhya', 'Sandhya',
  ];

  final List<String> _lastNames = [
    'Kumar', 'Raj', 'Nathan', 'Sundaram', 'Mani', 'Pandian', 'Ganesan', 'Murugan',
    'Krishnan', 'Chandran', 'Raman', 'Swamy', 'Nadarajan', 'Venkatesh', 'Babu',
    'Narayanan', 'Perumal', 'Velu', 'Thirumalai', 'Sami', 'Chettiar', 'Mudaliar',
    'Pillai', 'Reddy', 'Naidu', 'Iyer', 'Iyengar', 'Fernandez', 'D\'Souza', 'Rowther',
  ];

  final List<String> _districts = [
    'puducherry', 'puducherry', 'puducherry', 'puducherry', // puducherry weighted
    'karaikal', 'cuddalore', 'villupuram', 'chennai', 'chennai',
    'coimbatore', 'madurai', 'tiruchirappalli', 'salem', 'thanjavur',
  ];

  final List<String> _religions = [
    'hindu', 'hindu', 'hindu', 'hindu', 'hindu', 'hindu',
    'christian', 'christian', 'muslim_sunni', 'muslim_sunni',
  ];

  final List<String> _hinduCastes = [
    'mudaliar', 'vanniyar', 'pillai', 'nadar', 'chettiar', 'brahmin_iyer', 'naidu',
    'gounder', 'reddiar', 'yadava', 'viswakarma', 'adi_dravidar', 'caste_none',
  ];

  final List<String> _educations = [
    'be_btech', 'be_btech', 'mbbs', 'mba', 'msc', 'bcom', 'ca_cs_icwa', 'barch',
    'phd', 'bca_mca', 'me_mtech', 'diploma',
  ];

  final List<String> _occupations = [
    'software_engineer', 'software_engineer', 'doctor', 'bank_officer',
    'chartered_accountant', 'civil_engineer', 'professor_teacher', 'business_owner',
    'govt_officer', 'architect', 'hr_professional',
  ];

  final List<String> _incomes = [
    '3_to_5_lakhs', '5_to_7_lakhs', '7_to_10_lakhs', '10_to_15_lakhs',
    '15_to_25_lakhs', '25_to_50_lakhs',
  ];

  final List<String> _stars = [
    'ashwini', 'bharani', 'krittika', 'rohini', 'mrigashira', 'arudra', 'punarvasu',
    'pushya', 'ashlesha', 'magha', 'purva_phalguni', 'uttara_phalguni', 'hasta',
    'chitra', 'swati', 'vishakha', 'anuradha', 'jyeshtha', 'mula', 'purva_ashadha',
    'uttara_ashadha', 'shravana', 'dhanishta', 'shatabhisha', 'purva_bhadrapada',
    'uttara_bhadrapada', 'revati',
  ];

  final List<String> _rasis = [
    'mesha', 'vrishabha', 'mithuna', 'karka', 'simha', 'kanya', 'tula', 'vrischika',
    'dhanu', 'makara', 'kumbha', 'meena',
  ];

  Future<void> generateAll() async {
    final seedDir = Directory('assets/csv/seed');
    if (!await seedDir.exists()) {
      await seedDir.create(recursive: true);
    }

    final usersRows = <List<String>>[];
    final profilesRows = <List<String>>[];
    final prefsRows = <List<String>>[];
    final photosRows = <List<String>>[];
    final storiesRows = <List<String>>[];

    // Headers
    usersRows.add([
      'user_id', 'mobile', 'email', 'password_hash', 'salt', 'profile_for',
      'created_at', 'last_login', 'status', 'plan_id', 'plan_expiry', 'is_verified', 'is_demo',
    ]);

    profilesRows.add([
      'profile_id', 'user_id', 'name', 'gender', 'dob', 'age', 'height_cm',
      'physical_status', 'marital_status', 'no_of_children', 'mother_tongue',
      'religion', 'division', 'caste', 'subcaste', 'willing_other_caste',
      'star', 'rasi', 'dosham', 'gothram', 'country', 'state', 'district', 'city',
      'citizenship', 'education', 'education_detail', 'employment_type', 'occupation',
      'employer', 'income_currency', 'annual_income_range', 'family_status',
      'family_type', 'family_values', 'father_occupation', 'mother_occupation',
      'brothers', 'sisters', 'diet', 'smoking', 'drinking', 'about_me',
      'profile_photo_privacy', 'completeness_pct', 'created_at', 'updated_at', 'is_demo',
    ]);

    prefsRows.add([
      'profile_id', 'age_min', 'age_max', 'height_min', 'height_max', 'marital_status',
      'religion', 'division', 'caste', 'mother_tongue', 'education', 'occupation',
      'income_min', 'country', 'state', 'district', 'diet', 'star_match_required', 'dosham_pref',
    ]);

    photosRows.add([
      'photo_id', 'profile_id', 'path_or_asset', 'is_primary', 'privacy', 'order', 'uploaded_at',
    ]);

    storiesRows.add([
      'story_id', 'groom', 'bride', 'location', 'story', 'photo', 'wedding_date', 'is_demo',
    ]);

    // Generate 620 profiles (310 Male, 310 Female)
    for (int i = 1; i <= 620; i++) {
      final isMale = i % 2 == 1;
      final profileId = 'PC${i.toString().padLeft(6, '0')}';
      final userId = 'USR${i.toString().padLeft(6, '0')}';
      final gender = isMale ? 'Male' : 'Female';

      final firstName = isMale
          ? _maleFirstNames[_rnd.nextInt(_maleFirstNames.length)]
          : _femaleFirstNames[_rnd.nextInt(_femaleFirstNames.length)];
      final lastName = _lastNames[_rnd.nextInt(_lastNames.length)];
      final fullName = '$firstName $lastName';

      final age = isMale ? (24 + _rnd.nextInt(16)) : (21 + _rnd.nextInt(15));
      final birthYear = DateTime.now().year - age;
      final birthMonth = 1 + _rnd.nextInt(12);
      final birthDay = 1 + _rnd.nextInt(28);
      final dob = '$birthYear-${birthMonth.toString().padLeft(2, '0')}-${birthDay.toString().padLeft(2, '0')}';

      final heightCm = isMale ? (165 + _rnd.nextInt(22)) : (150 + _rnd.nextInt(20));
      final religion = _religions[_rnd.nextInt(_religions.length)];
      String division = 'none';
      String caste = 'caste_none';

      if (religion == 'christian') {
        division = _rnd.nextBool() ? 'rc' : 'csi';
        caste = _rnd.nextBool() ? 'christian_nadar' : 'caste_none';
      } else if (religion.startsWith('muslim')) {
        division = 'sunni_hanafi';
        caste = 'muslim_lebbai';
      } else {
        division = 'hindu_saivite';
        caste = _hinduCastes[_rnd.nextInt(_hinduCastes.length)];
      }

      final district = _districts[_rnd.nextInt(_districts.length)];
      final isPondy = district == 'puducherry' || district == 'karaikal';
      final state = isPondy ? 'Puducherry' : 'Tamil Nadu';
      final city = isPondy
          ? (district == 'puducherry' ? 'Puducherry' : 'Karaikal')
          : (district[0].toUpperCase() + district.substring(1));

      final education = _educations[_rnd.nextInt(_educations.length)];
      final occupation = _occupations[_rnd.nextInt(_occupations.length)];
      final income = _incomes[_rnd.nextInt(_incomes.length)];
      final star = _stars[_rnd.nextInt(_stars.length)];
      final rasi = _rasis[_rnd.nextInt(_rasis.length)];
      final dosham = _rnd.nextInt(5) == 0 ? 'sevvai' : 'none';
      final plan = i % 7 == 0 ? 'gold' : (i % 15 == 0 ? 'diamond' : 'free');
      final isVerified = i % 3 != 0;

      final mobile = '+91 9${_rnd.nextInt(900000000) + 100000000}';
      final email = '${firstName.toLowerCase()}.${lastName.toLowerCase()}$i@example.com';
      final createdAt = DateTime.now().subtract(Duration(days: _rnd.nextInt(180))).toIso8601String();

      // User row
      usersRows.add([
        userId, mobile, email, 'demo_hash_$i', 'salt_$i', 'Myself',
        createdAt, DateTime.now().toIso8601String(), 'active', plan, '', isVerified.toString(), 'true',
      ]);

      // Profile row
      final bio = 'Hi, I am $firstName. I completed my education in $education and work as a $occupation in $city. Looking for an understanding and caring life partner with good family values.';
      profilesRows.add([
        profileId, userId, fullName, gender, dob, age.toString(), heightCm.toString(),
        'Normal', 'never_married', '0', 'tamil',
        religion, division, caste, '', (_rnd.nextBool()).toString(),
        star, rasi, dosham, 'Shiva', 'India', state, district, city,
        'Indian', education, '', 'private', occupation,
        'Reputed Organization', 'INR', income, 'middle_class',
        'nuclear', 'moderate', 'Retired Employee', 'Homemaker',
        '1', '0', 'non_vegetarian', 'No', 'No', bio,
        'all', '90', createdAt, createdAt, 'true',
      ]);

      // Partner prefs row
      final prefAgeMin = isMale ? (age - 5).clamp(18, 50) : (age - 1).clamp(21, 55);
      final prefAgeMax = isMale ? (age + 1).clamp(18, 50) : (age + 7).clamp(21, 55);
      final prefHeightMin = (heightCm - 15).clamp(140, 200);
      final prefHeightMax = (heightCm + 15).clamp(150, 210);

      prefsRows.add([
        profileId, prefAgeMin.toString(), prefAgeMax.toString(),
        prefHeightMin.toString(), prefHeightMax.toString(), 'never_married',
        religion, 'all', 'all', 'tamil', 'all', 'all',
        '3_to_5_lakhs', 'India', state, district, 'all', 'false', 'none',
      ]);

      // Photo row
      photosRows.add([
        'PHT$i', profileId, 'avatar_${gender.toLowerCase()}_${(i % 10) + 1}',
        'true', 'all', '1', createdAt,
      ]);
    }

    // Success stories
    storiesRows.add([
      'STORY1', 'Senthil Nathan (PC000102)', 'Divya Priya (PC000145)', 'Puducherry',
      'We found each other through Pondy Connect Matrimony. Both our families in Pondy connected within a week and our wedding was solemnized beautifully at Heritage Town!',
      'story_1.png', '2026-02-14', 'true',
    ]);
    storiesRows.add([
      'STORY2', 'Karthik Raja (PC000215)', 'Keerthana (PC000340)', 'Karaikal',
      'Matching by Puducherry native roots and 10-Porutham made it very seamless for our parents. Truly grateful to the platform.',
      'story_2.png', '2026-05-20', 'true',
    ]);
    storiesRows.add([
      'STORY3', 'Dr. Vignesh (PC000088)', 'Dr. Meenakshi (PC000099)', 'Villupuram',
      'Both of us being doctors from neighbouring districts, Pondy Connect gave us the exact cultural and career alignment we were searching for.',
      'story_3.png', '2026-08-10', 'true',
    ]);

    // Write all seed CSVs
    await _writeCsv('assets/csv/seed/users.csv', usersRows);
    await _writeCsv('assets/csv/seed/profiles.csv', profilesRows);
    await _writeCsv('assets/csv/seed/partner_prefs.csv', prefsRows);
    await _writeCsv('assets/csv/seed/photos.csv', photosRows);
    await _writeCsv('assets/csv/seed/success_stories.csv', storiesRows);

    print('Wrote 620 profiles and related tables to assets/csv/seed/');
  }

  Future<void> _writeCsv(String path, List<List<String>> rows) async {
    final buffer = StringBuffer();
    for (final row in rows) {
      final line = row.map((field) {
        if (field.contains(',') || field.contains('"') || field.contains('\n')) {
          return '"${field.replaceAll('"', '""')}"';
        }
        return field;
      }).join(',');
      buffer.write('$line\r\n');
    }
    await File(path).writeAsString(buffer.toString(), encoding: utf8);
  }
}
