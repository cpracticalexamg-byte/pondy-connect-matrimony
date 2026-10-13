// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('=== SEEDING 10 BRIDES + 10 GROOMS SAMPLE PROFILES (§9) ===');
  await seedSampleProfiles();
  print('=== SEEDING COMPLETED: 20 SAMPLE PROFILES READY (is_sample = 1) ===');
}

Future<void> seedSampleProfiles() async {
  final dataDir = Directory('db/data');
  if (!await dataDir.exists()) {
    print('Error: Directory db/data does not exist.');
    exit(1);
  }

  final now = DateTime.now().toUtc().toIso8601String();

  // 1. Clean out existing sample profiles to maintain idempotency
  await _cleanExistingSampleRows(dataDir);

  // 2. Append new sample rows into relevant tables
  await _appendUsers(dataDir, now);
  await _appendProfiles(dataDir, now);
  await _appendEducationCareer(dataDir, now);
  await _appendLocations(dataDir, now);
  await _appendHoroscopes(dataDir, now);
  await _appendPhotos(dataDir, now);
  await _appendPartnerPreferences(dataDir, now);

  print('Successfully seeded 10 Grooms and 10 Brides into database.');
}

Future<void> _cleanExistingSampleRows(Directory dataDir) async {
  final files = await dataDir.list().where((f) => f is File && f.path.endsWith('.csv')).cast<File>().toList();
  for (final file in files) {
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) continue;
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(raw.replaceAll('\r\n', '\n'));
    if (rows.length <= 1) continue;

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final sampleColIdx = headers.indexOf('is_sample');
    final profIdIdx = headers.indexOf('profile_id');
    final userIdIdx = headers.indexOf('user_id');

    final keptRows = <List<dynamic>>[rows.first];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;

      bool isSample = false;
      if (sampleColIdx != -1 && sampleColIdx < row.length) {
        final val = row[sampleColIdx].toString().trim();
        if (val == '1' || val.toLowerCase() == 'true') isSample = true;
      }
      if (profIdIdx != -1 && profIdIdx < row.length && row[profIdIdx].toString().startsWith('PRF_SMP_')) {
        isSample = true;
      }
      if (userIdIdx != -1 && userIdIdx < row.length && row[userIdIdx].toString().startsWith('USR_SMP_')) {
        isSample = true;
      }

      if (!isSample) {
        keptRows.add(row);
      }
    }

    if (keptRows.length != rows.length) {
      final newCsv = const ListToCsvConverter(eol: '\n').convert(keptRows);
      await file.writeAsString('$newCsv\n', encoding: utf8, flush: true);
    }
  }
}

Future<void> _appendUsers(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/users.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final map = <String, String>{
      'user_id': p['user_id']!,
      'mobile': '', // Null as per Rule 3
      'email': '',  // Null as per Rule 3
      'password_hash': '',
      'salt': '',
      'status': 'active',
      'is_verified': p['is_verified']!,
      'is_sample': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendProfiles(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/profiles.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final map = <String, String>{
      'profile_id': p['profile_id']!,
      'user_id': p['user_id']!,
      'matrimony_id': p['matrimony_id']!,
      'name': p['name']!,
      'gender': p['gender']!,
      'dob': p['dob']!,
      'age': p['age']!,
      'height_cm': p['height_cm']!,
      'weight_kg': p['weight_kg']!,
      'body_type_id': '1',
      'complexion_id': '1',
      'blood_group_id': '1',
      'physical_status_id': '1',
      'disability_type_id': '0',
      'marital_status_id': '1',
      'no_of_children': '0',
      'children_living_with_me': '0',
      'mother_tongue_id': '1',
      'religion_id': p['religion_id']!,
      'division_id': p['division_id'] ?? '0',
      'caste_id': p['caste_id']!,
      'sub_caste_id': p['sub_caste_id'] ?? '0',
      'gothram_id': '1',
      'willing_other_caste': '1',
      'about_me': p['about_me']!,
      'profile_photo_privacy': 'members',
      'profile_source': 'sample', // Rule 1
      'is_sample': '1',          // Rule 1
      'completeness_pct': '95',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendEducationCareer(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/profile_education_career.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final map = <String, String>{
      'edu_career_id': 'EDC_${p['profile_id']}',
      'profile_id': p['profile_id']!,
      'education_level_id': '3',
      'education_degree_id': '1',
      'degree_detail': p['education']!,
      'institution': p['institution']!, // Locked field
      'employment_type_id': '1',
      'occupation_category_id': p['occupation_category_id']!,
      'occupation_id': p['occupation_id']!,
      'employer': p['employer']!,       // Locked field
      'job_location': p['area']!,
      'currency_id': '1',
      'annual_income_range_id': '4',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendLocations(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/profile_locations.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final map = <String, String>{
      'profile_id': p['profile_id']!,
      'lat_coarse': p['lat_coarse']!,
      'lng_coarse': p['lng_coarse']!,
      'geohash5': p['geohash5']!,
      'share_mode': 'precise',
      'source': 'centroid',
      'updated_at': now,
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendHoroscopes(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/profile_horoscopes.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    // Only add horoscope if nakshatra is specified
    if ((p['star'] ?? '').isEmpty) continue;

    final map = <String, String>{
      'horoscope_id': 'HOR_${p['profile_id']}',
      'profile_id': p['profile_id']!,
      'nakshatra_id': p['nakshatra_id'] ?? '1',
      'padam': '2',
      'rasi_id': p['rasi_id'] ?? '1',
      'lagnam_id': '1',
      'dosham_id': '1',
      'dasa_id': '1',
      'dasa_balance_years': '4',
      'dasa_balance_months': '2',
      'dasa_balance_days': '15',
      'time_of_birth': '06:30:00',
      'place_of_birth': p['area']!,
      'chart_raasi_json': '{"1":"Sun","4":"Moon","7":"Jupiter"}',
      'chart_amsam_json': '{"2":"Venus","9":"Mars"}',
      'horoscope_match_required': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendPhotos(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/photos.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final prefix = p['gender'] == 'Male' ? 'g' : 'b';
    final numStr = p['code']!.substring(1);

    // Photo 1: Primary
    final p1 = <String, String>{
      'photo_id': 'PHO_${p['profile_id']}_1',
      'profile_id': p['profile_id']!,
      'blob_path': 'assets/avatars/$prefix${numStr}_primary.jpg',
      'is_primary': '1',
      'privacy': 'members',
      'sort_order': '1',
      'is_sample': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => p1[h] ?? '').toList());

    // Photo 2: Gallery
    final p2 = <String, String>{
      'photo_id': 'PHO_${p['profile_id']}_2',
      'profile_id': p['profile_id']!,
      'blob_path': 'assets/avatars/$prefix${numStr}_primary.jpg',
      'is_primary': '0',
      'privacy': 'members',
      'sort_order': '2',
      'is_sample': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => p2[h] ?? '').toList());

    // Photo 3: On Request
    final p3 = <String, String>{
      'photo_id': 'PHO_${p['profile_id']}_3',
      'profile_id': p['profile_id']!,
      'blob_path': 'assets/avatars/$prefix${numStr}_request.jpg',
      'is_primary': '0',
      'privacy': 'on_request',
      'sort_order': '3',
      'is_sample': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => p3[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

Future<void> _appendPartnerPreferences(Directory dataDir, String now) async {
  final file = File('${dataDir.path}/partner_preferences.csv');
  final raw = await file.readAsString();
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(raw.replaceAll('\r\n', '\n'));
  final headers = rows.first.map((e) => e.toString().trim()).toList();

  for (final p in _sampleData) {
    final isMale = p['gender'] == 'Male';
    final map = <String, String>{
      'pref_id': 'PRF_PREF_${p['profile_id']}',
      'profile_id': p['profile_id']!,
      'age_min': isMale ? '21' : '25',
      'age_max': isMale ? '30' : '36',
      'height_min_cm': isMale ? '150' : '165',
      'height_max_cm': isMale ? '175' : '190',
      'income_min_id': '3',
      'diet_id': '1',
      'smoking_id': '1',
      'drinking_id': '1',
      'star_match_required': '0',
      'dosham_pref_id': '1',
      'photo_only': '0',
      'verified_only': '0',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    rows.add(headers.map((h) => map[h] ?? '').toList());
  }

  await file.writeAsString('${const ListToCsvConverter(eol: '\n').convert(rows)}\n', encoding: utf8, flush: true);
}

// -------------------------------------------------------------
// The 20 Curated Profiles Specified in Section 9
// -------------------------------------------------------------
final List<Map<String, String>> _sampleData = [
  // ================= 10 GROOMS (G1 - G10) =================
  {
    'code': 'G01',
    'user_id': 'USR_SMP_G01',
    'profile_id': 'PRF_SMP_G01',
    'matrimony_id': 'PC000101',
    'name': 'Karthikeyan Sundaram',
    'gender': 'Male',
    'dob': '1997-04-12',
    'age': '29',
    'height_cm': '175',
    'weight_kg': '72',
    'religion_id': '1', // Hindu
    'division_id': '1', // Mudaliar
    'caste_id': '1',
    'education': 'B.E.',
    'institution': 'Pondicherry Engineering College',
    'occupation_category_id': '2', // IT & Software
    'occupation_id': '201', // Software Engineer (Techie)
    'employer': 'ZoHo Corporation',
    'area': 'Lawspet, Puducherry',
    'lat_coarse': '11.9610',
    'lng_coarse': '79.8210',
    'geohash5': 'tf0c4',
    'star': 'Ashwini',
    'nakshatra_id': '1',
    'rasi_id': '1',
    'is_verified': '0',
    'about_me': 'Born and raised in Lawspet, Puducherry. Completed B.E. at Pondicherry Engineering College. Currently working as a Senior Software Engineer with ZoHo. Deeply rooted in Tamil culture with progressive family values. Enjoys cycling along the Promenade and Carnatic music.',
  },
  {
    'code': 'G02',
    'user_id': 'USR_SMP_G02',
    'profile_id': 'PRF_SMP_G02',
    'matrimony_id': 'PC000102',
    'name': 'Dr. Ashwin Bharathi',
    'gender': 'Male',
    'dob': '1995-08-20',
    'age': '31',
    'height_cm': '180',
    'weight_kg': '75',
    'religion_id': '2', // Christian
    'division_id': '2', // Roman Catholic
    'caste_id': '2', // Paravar-Bharathar
    'education': 'MBBS, MD',
    'institution': 'JIPMER Puducherry',
    'occupation_category_id': '1', // Medical
    'occupation_id': '101', // Doctor (Doctor)
    'employer': 'JIPMER Super Specialty Hospital',
    'area': 'Muthialpet, Puducherry',
    'lat_coarse': '11.9510',
    'lng_coarse': '79.8320',
    'geohash5': 'tf0c6',
    'star': 'Rohini',
    'nakshatra_id': '4',
    'rasi_id': '2',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Resident of Muthialpet, Puducherry. Completed MBBS and MD General Medicine at JIPMER. Practicing physician passionate about community healthcare and medical research. Values family togetherness, honesty, and mutual respect.',
  },
  {
    'code': 'G03',
    'user_id': 'USR_SMP_G03',
    'profile_id': 'PRF_SMP_G03',
    'matrimony_id': 'PC000103',
    'name': 'Saravana Kumar V.',
    'gender': 'Male',
    'dob': '1998-11-05',
    'age': '28',
    'height_cm': '173',
    'weight_kg': '68',
    'religion_id': '1', // Hindu
    'division_id': '3', // Vanniyar
    'caste_id': '3', // Padayachi
    'education': 'B.L., LLB',
    'institution': 'Dr. Ambedkar Govt Law College, Puducherry',
    'occupation_category_id': '3', // Legal
    'occupation_id': '301', // Advocate (Advocate)
    'employer': 'Puducherry High Court Bar / Independent Practice',
    'area': 'Villianur, Puducherry',
    'lat_coarse': '11.9160',
    'lng_coarse': '79.7580',
    'geohash5': 'tf0bf',
    'star': 'Poosam',
    'nakshatra_id': '8',
    'rasi_id': '4',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Practicing advocate at Puducherry Integrated Court Complex and Madras High Court bench. Residing in Villianur with traditional family values. Passionate about social justice, heritage farming, and coastal community welfare.',
  },
  {
    'code': 'G04',
    'user_id': 'USR_SMP_G04',
    'profile_id': 'PRF_SMP_G04',
    'matrimony_id': 'PC000104',
    'name': 'Rizwan Ahmed',
    'gender': 'Male',
    'dob': '1993-02-14',
    'age': '33',
    'height_cm': '178',
    'weight_kg': '74',
    'religion_id': '3', // Muslim
    'division_id': '1', // Sunni
    'caste_id': '4', // Rowther
    'education': 'B.Tech',
    'institution': 'B.S. Abdur Rahman Crescent Institute',
    'occupation_category_id': '4', // Business
    'occupation_id': '401', // Business Owner
    'employer': 'Al-Noor Trade & Logistics',
    'area': 'Chennai',
    'lat_coarse': '13.0827',
    'lng_coarse': '80.2707',
    'geohash5': 'tf34h',
    'star': 'Hastham',
    'nakshatra_id': '13',
    'rasi_id': '6',
    'is_verified': '0',
    'about_me': 'Entrepreneur operating international freight logistics between Chennai harbor and Puducherry port. Believes in integrity, ethical commerce, and philanthropic causes. Looking for a cultured and understanding life partner.',
  },
  {
    'code': 'G05',
    'user_id': 'USR_SMP_G05',
    'profile_id': 'PRF_SMP_G05',
    'matrimony_id': 'PC000105',
    'name': 'Muthukrishnan N.',
    'gender': 'Male',
    'dob': '1996-06-18',
    'age': '30',
    'height_cm': '183',
    'weight_kg': '76',
    'religion_id': '1', // Hindu
    'division_id': '4', // Nadar
    'caste_id': '5', // Gramani
    'education': 'M.E.',
    'institution': 'Anna University',
    'occupation_category_id': '5', // Education
    'occupation_id': '501', // Assistant Professor
    'employer': 'Govt Engineering College',
    'area': 'Tirunelveli',
    'lat_coarse': '8.7139',
    'lng_coarse': '77.7567',
    'geohash5': 't9y3q',
    'star': 'Swathi',
    'nakshatra_id': '15',
    'rasi_id': '7',
    'is_verified': '0',
    'about_me': 'Academician and researcher dedicated to mechanical engineering and renewable energy. Raised with traditional values in Tirunelveli. Enjoys Tamil classical literature, badminton, and organic terrace farming.',
  },
  {
    'code': 'G06',
    'user_id': 'USR_SMP_G06',
    'profile_id': 'PRF_SMP_G06',
    'matrimony_id': 'PC000106',
    'name': 'David Immanuel',
    'gender': 'Male',
    'dob': '1999-03-30',
    'age': '27',
    'height_cm': '170',
    'weight_kg': '65',
    'religion_id': '2', // Christian
    'division_id': '3', // CSI
    'caste_id': '6', // Nadar
    'education': 'B.Sc, B.Ed',
    'institution': "St. Joseph's College, Cuddalore",
    'occupation_category_id': '5', // Education
    'occupation_id': '502', // School Teacher
    'employer': 'St. Patrick Higher Secondary School',
    'area': 'Cuddalore',
    'lat_coarse': '11.7480',
    'lng_coarse': '79.7714',
    'geohash5': 'tf09m',
    'star': '', // No horoscope (Christian)
    'nakshatra_id': '',
    'rasi_id': '',
    'is_verified': '0',
    'about_me': 'Science educator teaching at a reputed higher secondary school in Cuddalore, commuting easily to Pondicherry. Active in church choir and youth mentorship. Believes in kindness, simplicity, and joyous family life.',
  },
  {
    'code': 'G07',
    'user_id': 'USR_SMP_G07',
    'profile_id': 'PRF_SMP_G07',
    'matrimony_id': 'PC000107',
    'name': 'Vijayakumar Gounder',
    'gender': 'Male',
    'dob': '1992-09-12',
    'age': '34',
    'height_cm': '175',
    'weight_kg': '73',
    'religion_id': '1', // Hindu
    'division_id': '5', // Gounder
    'caste_id': '7', // Kongu Vellalar
    'education': 'MBA',
    'institution': 'PSG Institute of Management',
    'occupation_category_id': '4', // Business
    'occupation_id': '402', // Entrepreneur
    'employer': 'Kongu Eco Textiles & Agro',
    'area': 'Coimbatore',
    'lat_coarse': '11.0168',
    'lng_coarse': '76.9558',
    'geohash5': 't9yu1',
    'star': 'Moolam',
    'nakshatra_id': '19',
    'rasi_id': '9',
    'is_verified': '0',
    'about_me': 'Managing family textile export house in Coimbatore with business ties across South India. Values traditional family traditions, agriculture, and progressive business thinking. Seeking a caring and educated homemaker/partner.',
  },
  {
    'code': 'G08',
    'user_id': 'USR_SMP_G08',
    'profile_id': 'PRF_SMP_G08',
    'matrimony_id': 'PC000108',
    'name': 'Venkataraman Iyer',
    'gender': 'Male',
    'dob': '2000-12-04',
    'age': '26',
    'height_cm': '178',
    'weight_kg': '70',
    'religion_id': '1', // Hindu
    'division_id': '6', // Iyer
    'caste_id': '8', // Vadama
    'education': 'CA',
    'institution': 'ICAI Chennai',
    'occupation_category_id': '6', // Finance
    'occupation_id': '601', // Chartered Accountant
    'employer': 'Ernst & Young / Private Advisory',
    'area': 'White Town, Puducherry',
    'lat_coarse': '11.9338',
    'lng_coarse': '79.8330',
    'geohash5': 'tf0c3',
    'star': 'Uthirattathi',
    'nakshatra_id': '26',
    'rasi_id': '12',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Chartered Accountant residing in White Town, Puducherry. Handles audit and international taxation. Trained in mridangam and deeply appreciative of Tamil temple heritage. Seeks an educated partner with fine cultural grounding.',
  },
  {
    'code': 'G09',
    'user_id': 'USR_SMP_G09',
    'profile_id': 'PRF_SMP_G09',
    'matrimony_id': 'PC000109',
    'name': 'Prabakaran M.',
    'gender': 'Male',
    'dob': '1994-07-25',
    'age': '32',
    'height_cm': '173',
    'weight_kg': '67',
    'religion_id': '1', // Hindu
    'division_id': '7', // Adi Dravidar
    'caste_id': '9', // Paraiyar
    'education': 'M.Sc',
    'institution': 'Madras Christian College',
    'occupation_category_id': '7', // Govt
    'occupation_id': '701', // Scientist (Govt)
    'employer': 'National Institute of Ocean Technology',
    'area': 'Chennai',
    'lat_coarse': '13.0827',
    'lng_coarse': '80.2707',
    'geohash5': 'tf34h',
    'star': 'Revathi',
    'nakshatra_id': '27',
    'rasi_id': '12',
    'is_verified': '0',
    'about_me': 'Research scientist working on marine conservation and coastal mapping. Native roots in Villupuram/Puducherry belt. Enjoys scuba diving, long distance running, and Tamil social reform literature.',
  },
  {
    'code': 'G10',
    'user_id': 'USR_SMP_G10',
    'profile_id': 'PRF_SMP_G10',
    'matrimony_id': 'PC000110',
    'name': 'Siddharthan Pillai',
    'gender': 'Male',
    'dob': '1996-01-19',
    'age': '30',
    'height_cm': '180',
    'weight_kg': '74',
    'religion_id': '1', // Hindu
    'division_id': '8', // Pillai
    'caste_id': '10', // Saiva Pillai
    'education': 'B.E., M.S.',
    'institution': 'National University of Singapore',
    'occupation_category_id': '2', // IT & Software
    'occupation_id': '202', // Data Scientist (Techie, NRI)
    'employer': 'Grab Technologies Singapore',
    'area': 'Singapore',
    'lat_coarse': '1.3521',
    'lng_coarse': '103.8198',
    'geohash5': 'w21zf',
    'star': 'Krithigai',
    'nakshatra_id': '3',
    'rasi_id': '2',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Data Science lead based in Singapore, born in Pondicherry. Regularly visits parents in Pondicherry twice a year. Enjoys international cuisine, hiking, and acoustic guitar. Looking for a progressive partner willing to relocate or explore global opportunities.',
  },

  // ================= 10 BRIDES (B1 - B10) =================
  {
    'code': 'B01',
    'user_id': 'USR_SMP_B01',
    'profile_id': 'PRF_SMP_B01',
    'matrimony_id': 'PC000111',
    'name': 'Soundarya Mudaliar',
    'gender': 'Female',
    'dob': '2000-05-14',
    'age': '26',
    'height_cm': '160',
    'weight_kg': '54',
    'religion_id': '1', // Hindu
    'division_id': '1', // Mudaliar
    'caste_id': '1',
    'education': 'B.Tech',
    'institution': 'Pondicherry Engineering College',
    'occupation_category_id': '2', // IT & Software
    'occupation_id': '201', // Software Engineer (Techie)
    'employer': 'Tata Consultancy Services',
    'area': 'Reddiarpalayam, Puducherry',
    'lat_coarse': '11.9420',
    'lng_coarse': '79.8050',
    'geohash5': 'tf0c1',
    'star': 'Anusham',
    'nakshatra_id': '17',
    'rasi_id': '8',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Working as a full-stack engineer in TCS Puducherry/Chennai delivery center. Raised in a loving family in Reddiarpalayam. Enjoys Bharatanatyam, baking, and quiet seaside evening strolls. Seeking an understanding and supportive life partner.',
  },
  {
    'code': 'B02',
    'user_id': 'USR_SMP_B02',
    'profile_id': 'PRF_SMP_B02',
    'matrimony_id': 'PC000112',
    'name': 'Mary Jennifer',
    'gender': 'Female',
    'dob': '1998-10-08',
    'age': '28',
    'height_cm': '165',
    'weight_kg': '58',
    'religion_id': '2', // Christian
    'division_id': '2', // Roman Catholic
    'caste_id': '11', // Latin Catholic
    'education': 'B.Sc Nursing',
    'institution': 'Mother Theresa Post Graduate Institute',
    'occupation_category_id': '1', // Medical
    'occupation_id': '102', // Nurse (Govt)
    'employer': 'Indira Gandhi Govt General Hospital',
    'area': 'Puducherry',
    'lat_coarse': '11.9350',
    'lng_coarse': '79.8200',
    'geohash5': 'tf0c2',
    'star': '', // No horoscope (Christian)
    'nakshatra_id': '',
    'rasi_id': '',
    'is_verified': '0',
    'about_me': 'Registered staff nurse serving in government health services in Puducherry. Devout, cheerful, and family-oriented. Believes in service with empathy, joy in small things, and mutual support in marriage.',
  },
  {
    'code': 'B03',
    'user_id': 'USR_SMP_B03',
    'profile_id': 'PRF_SMP_B03',
    'matrimony_id': 'PC000113',
    'name': 'Dr. Kanimozhi Vanniyar',
    'gender': 'Female',
    'dob': '2001-08-16',
    'age': '25',
    'height_cm': '157',
    'weight_kg': '50',
    'religion_id': '1', // Hindu
    'division_id': '3', // Vanniyar
    'caste_id': '3', // Padayachi
    'education': 'MBBS',
    'institution': 'JIPMER Puducherry',
    'occupation_category_id': '1', // Medical
    'occupation_id': '101', // Doctor (Doctor)
    'employer': 'Apollo Hospitals / Resident Doctor',
    'area': 'Ariyankuppam, Puducherry',
    'lat_coarse': '11.8980',
    'lng_coarse': '79.8070',
    'geohash5': 'tf0b8',
    'star': 'Mirugasirisham',
    'nakshatra_id': '5',
    'rasi_id': '2',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Young doctor with a passion for pediatric care and public health. Residing with family in Ariyankuppam. Enjoys carnatic violin, reading historical Tamil novels, and community medical camps.',
  },
  {
    'code': 'B04',
    'user_id': 'USR_SMP_B04',
    'profile_id': 'PRF_SMP_B04',
    'matrimony_id': 'PC000114',
    'name': 'Ayesha Fathima',
    'gender': 'Female',
    'dob': '1997-12-22',
    'age': '29',
    'height_cm': '163',
    'weight_kg': '56',
    'religion_id': '3', // Muslim
    'division_id': '1', // Sunni
    'caste_id': '12', // Labbai
    'education': 'LLB',
    'institution': 'Central Law College',
    'occupation_category_id': '3', // Legal
    'occupation_id': '301', // Advocate (Advocate)
    'employer': 'Legal Aid & Chamber Practice',
    'area': 'Karaikal',
    'lat_coarse': '10.9254',
    'lng_coarse': '79.8380',
    'geohash5': 'tf00s',
    'star': 'Punarpoosam',
    'nakshatra_id': '7',
    'rasi_id': '3',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Legal practitioner specializing in family arbitration and corporate documentation in Karaikal. Combines religious values with progressive professional ambition. Seeking a kind, well-educated, and honest gentleman.',
  },
  {
    'code': 'B05',
    'user_id': 'USR_SMP_B05',
    'profile_id': 'PRF_SMP_B05',
    'matrimony_id': 'PC000115',
    'name': 'Meenakshi Thevar',
    'gender': 'Female',
    'dob': '1999-02-11',
    'age': '27',
    'height_cm': '168',
    'weight_kg': '59',
    'religion_id': '1', // Hindu
    'division_id': '9', // Thevar
    'caste_id': '13', // Maravar
    'education': 'MBA',
    'institution': 'Thiagarajar School of Management',
    'occupation_category_id': '8', // Corporate HR
    'occupation_id': '801', // HR Manager
    'employer': 'HCL Technologies',
    'area': 'Madurai',
    'lat_coarse': '9.9252',
    'lng_coarse': '78.1198',
    'geohash5': 't9xf3',
    'star': 'Magam',
    'nakshatra_id': '10',
    'rasi_id': '5',
    'is_verified': '0',
    'about_me': 'Human resources professional working with an IT enterprise in Madurai. Rooted in traditional South Tamil Nadu customs with modern outlook. Passionate about culinary arts, temple festivals, and family gatherings.',
  },
  {
    'code': 'B06',
    'user_id': 'USR_SMP_B06',
    'profile_id': 'PRF_SMP_B06',
    'matrimony_id': 'PC000116',
    'name': 'Kavitha Nadar',
    'gender': 'Female',
    'dob': '2002-09-03',
    'age': '24',
    'height_cm': '160',
    'weight_kg': '52',
    'religion_id': '1', // Hindu
    'division_id': '4', // Nadar
    'caste_id': '5', // Nadar
    'education': 'B.A., B.Ed',
    'institution': 'V.O.C. College, Tuticorin',
    'occupation_category_id': '5', // Education
    'occupation_id': '502', // Teacher
    'employer': 'Spic Nagar Matriculation School',
    'area': 'Thoothukudi',
    'lat_coarse': '8.7642',
    'lng_coarse': '78.1348',
    'geohash5': 't9y9q',
    'star': 'Pooram',
    'nakshatra_id': '11',
    'rasi_id': '5',
    'is_verified': '0',
    'about_me': 'High school English teacher from Thoothukudi. Simple, affectionate, and family-first nature. Enjoys handicrafts, veena music, and gardening. Seeking a groom with good character and positive family values.',
  },
  {
    'code': 'B07',
    'user_id': 'USR_SMP_B07',
    'profile_id': 'PRF_SMP_B07',
    'matrimony_id': 'PC000117',
    'name': 'Rachel Priya',
    'gender': 'Female',
    'dob': '1996-04-17',
    'age': '30',
    'height_cm': '165',
    'weight_kg': '57',
    'religion_id': '2', // Christian
    'division_id': '3', // CSI
    'caste_id': '9', // Adi Dravidar
    'education': 'M.Sc',
    'institution': 'Loyola College Chennai',
    'occupation_category_id': '5', // Education
    'occupation_id': '503', // Lecturer
    'employer': 'WCC Chennai / Assistant Professor',
    'area': 'Chennai',
    'lat_coarse': '13.0827',
    'lng_coarse': '80.2707',
    'geohash5': 'tf34h',
    'star': '', // No horoscope
    'nakshatra_id': '',
    'rasi_id': '',
    'is_verified': '0',
    'about_me': 'College lecturer in biochemistry at Chennai. Deep Christian faith, balanced lifestyle, and independent character. Enjoys choral music, nature photography, and youth tutoring.',
  },
  {
    'code': 'B08',
    'user_id': 'USR_SMP_B08',
    'profile_id': 'PRF_SMP_B08',
    'matrimony_id': 'PC000118',
    'name': 'Janani Iyengar',
    'gender': 'Female',
    'dob': '1998-06-28',
    'age': '28',
    'height_cm': '163',
    'weight_kg': '55',
    'religion_id': '1', // Hindu
    'division_id': '10', // Iyengar
    'caste_id': '14', // Thenkalai
    'education': 'B.Arch',
    'institution': 'School of Planning & Architecture',
    'occupation_category_id': '9', // Architecture
    'occupation_id': '901', // Architect
    'employer': 'Urban Design Collective',
    'area': 'Bengaluru',
    'lat_coarse': '12.9716',
    'lng_coarse': '77.5946',
    'geohash5': 'tdr1v',
    'star': 'Chithirai',
    'nakshatra_id': '14',
    'rasi_id': '6',
    'is_verified': '0',
    'about_me': 'Conservation architect working on sustainable housing and heritage restoration in Bengaluru. Born in a cultured Tamil family with Puducherry connections. Fond of Carnatic vocal, sketching, and heritage walks.',
  },
  {
    'code': 'B09',
    'user_id': 'USR_SMP_B09',
    'profile_id': 'PRF_SMP_B09',
    'matrimony_id': 'PC000119',
    'name': 'Deepika Gounder',
    'gender': 'Female',
    'dob': '2000-01-31',
    'age': '26',
    'height_cm': '157',
    'weight_kg': '51',
    'religion_id': '1', // Hindu
    'division_id': '5', // Gounder
    'caste_id': '7', // Kongu Vellalar
    'education': 'B.Pharm, M.Pharm',
    'institution': 'Vinayaka Missions University',
    'occupation_category_id': '1', // Medical
    'occupation_id': '103', // Pharmacist
    'employer': 'Fortis Healthcare / Clinical Research',
    'area': 'Salem',
    'lat_coarse': '11.6643',
    'lng_coarse': '78.1460',
    'geohash5': 'tf000',
    'star': 'Visagam',
    'nakshatra_id': '16',
    'rasi_id': '7',
    'is_verified': '0',
    'about_me': 'Clinical pharmacist in healthcare services at Salem. Well mannered, warm, and values-driven. Enjoys culinary experiments, traditional kolam art, and family weekend trips.',
  },
  {
    'code': 'B10',
    'user_id': 'USR_SMP_B10',
    'profile_id': 'PRF_SMP_B10',
    'matrimony_id': 'PC000120',
    'name': 'Nandhini Chettiar',
    'gender': 'Female',
    'dob': '1995-11-18',
    'age': '31',
    'height_cm': '165',
    'weight_kg': '58',
    'religion_id': '1', // Hindu
    'division_id': '11', // Chettiar
    'caste_id': '15', // Nattukottai
    'education': 'MS (UK)',
    'institution': 'London School of Economics',
    'occupation_category_id': '6', // Finance
    'occupation_id': '602', // Research Analyst (NRI - London)
    'employer': 'Barclays Capital London',
    'area': 'London',
    'lat_coarse': '51.5074',
    'lng_coarse': '-0.1278',
    'geohash5': 'gcpvj',
    'star': 'Uthiradam',
    'nakshatra_id': '21',
    'rasi_id': '9',
    'is_verified': '1', // PRIME ID-verified
    'about_me': 'Financial market researcher in London with deep familial roots in Karaikudi and Puducherry. Passionate about world history, museum visits, and Chettinad culinary culture. Seeking a well-settled and open-minded life partner.',
  },
];
