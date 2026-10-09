// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('=== SEEDING 10 AUTHENTIC MEN + 10 AUTHENTIC WOMEN (PUDUCHERRY REGION) ===');
  await seedCuratedSamples();
  print('=== SEEDING COMPLETE: 20 CURATED PROFILES FLAGGED WITH is_sample = 1 ===');
}

Future<void> seedCuratedSamples() async {
  final usersFile = File('db/data/users.csv');
  final profilesFile = File('db/data/profiles.csv');

  if (!await usersFile.exists() || !await profilesFile.exists()) {
    print('Error: Database data files do not exist at db/data/');
    exit(1);
  }

  // Load existing headers
  final usersRaw = await usersFile.readAsString();
  final usersRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(usersRaw.replaceAll('\r\n', '\n'));
  final userHeaders = usersRows.first.map((e) => e.toString().trim()).toList();

  final profilesRaw = await profilesFile.readAsString();
  final profilesRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(profilesRaw.replaceAll('\r\n', '\n'));
  final profileHeaders = profilesRows.first.map((e) => e.toString().trim()).toList();

  // Remove existing sample rows if any to prevent duplicates
  final isSampleUserIdx = userHeaders.indexOf('is_sample');
  final cleanUserRows = usersRows.where((r) => r == usersRows.first || (isSampleUserIdx != -1 && r[isSampleUserIdx].toString() != '1')).toList();

  final isSampleProfIdx = profileHeaders.indexOf('is_sample');
  final cleanProfileRows = profilesRows.where((r) => r == profilesRows.first || (isSampleProfIdx != -1 && r[isSampleProfIdx].toString() != '1')).toList();

  final now = DateTime.now().toIso8601String();

  for (final sample in _curatedProfiles) {
    // 1. Build User row
    final userMap = <String, String>{
      'user_id': sample['user_id']!,
      'mobile': sample['mobile']!,
      'email': sample['email']!,
      'password_hash': '',
      'salt': '',
      'status': 'active',
      'is_verified': '1',
      'is_sample': '1',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    final userRow = userHeaders.map((h) => userMap[h] ?? '').toList();
    cleanUserRows.add(userRow);

    // 2. Build Profile row
    final profileMap = <String, String>{
      'profile_id': sample['profile_id']!,
      'user_id': sample['user_id']!,
      'matrimony_id': 'PC${sample['profile_id']!.replaceAll(RegExp(r'[^0-9]'), '')}',
      'name': sample['name']!,
      'gender': sample['gender']!,
      'dob': sample['dob']!,
      'age': sample['age']!,
      'height_cm': sample['height_cm']!,
      'weight_kg': sample['weight_kg']!,
      'body_type_id': '1',
      'complexion_id': '1',
      'blood_group_id': '1',
      'physical_status_id': '1',
      'disability_type_id': '0',
      'marital_status_id': '1',
      'no_of_children': '0',
      'children_living_with_me': '0',
      'mother_tongue_id': '1',
      'religion_id': sample['religion_id']!,
      'division_id': '0',
      'caste_id': sample['caste_id']!,
      'sub_caste_id': sample['sub_caste_id']!,
      'gothram_id': '1',
      'willing_other_caste': '1',
      'about_me': sample['about_me']!,
      'profile_photo_privacy': 'members',
      'profile_source': 'organic',
      'is_sample': '1',
      'completeness_pct': '95',
      'created_at': now,
      'updated_at': now,
      'deleted_at': '',
      'row_version': '1',
    };
    final profileRow = profileHeaders.map((h) => profileMap[h] ?? '').toList();
    cleanProfileRows.add(profileRow);
  }

  // Save back
  final newUsersCsv = const ListToCsvConverter(eol: '\n').convert(cleanUserRows);
  await usersFile.writeAsString('$newUsersCsv\n', encoding: utf8, flush: true);

  final newProfilesCsv = const ListToCsvConverter(eol: '\n').convert(cleanProfileRows);
  await profilesFile.writeAsString('$newProfilesCsv\n', encoding: utf8, flush: true);

  print('Successfully written ${_curatedProfiles.length} curated sample profiles.');
}

final List<Map<String, String>> _curatedProfiles = [
  // ================= 10 AUTHENTIC MEN =================
  {
    'user_id': 'USR_SMP_M01',
    'profile_id': 'PRF_SMP_M01',
    'name': 'Karthikeyan Sundaram',
    'gender': 'Male',
    'dob': '1995-04-12',
    'age': '30',
    'height_cm': '176',
    'weight_kg': '72',
    'mobile': '+919840001001',
    'email': 'karthik.sundaram@sample.pondyconnect.com',
    'religion_id': '1', // Hindu
    'caste_id': '1', // Mudaliar
    'sub_caste_id': '8', // Sengunthar
    'star': 'Ashwini',
    'rasi': 'Mesham',
    'city': 'Lawspet',
    'about_me': 'Born and raised in Lawspet, Puducherry. Completed B.Tech at Pondicherry Engineering College (PEC) followed by an M.S. in Computer Science. Currently working as a Senior Software Architect with a reputed IT MNC (hybrid model from Pondy/Chennai). Deeply rooted in Tamil culture with modern progressive family values. Enjoys beachside cycling along the Promenade and Carnatic music.',
  },
  {
    'user_id': 'USR_SMP_M02',
    'profile_id': 'PRF_SMP_M02',
    'name': 'Senthil Nathan V.',
    'gender': 'Male',
    'dob': '1996-08-20',
    'age': '29',
    'height_cm': '173',
    'weight_kg': '68',
    'mobile': '+919840001002',
    'email': 'senthil.nathan@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '3', // Vanniyar
    'sub_caste_id': '16', // Padayachi
    'star': 'Rohini',
    'rasi': 'Rishabam',
    'city': 'Oulgaret',
    'about_me': 'Native of Oulgaret (Ozhukarai), Puducherry. Graduated in Civil Engineering from Puducherry Technological University (PTU). Serving as an Assistant Engineer in the Public Works Department (PWD), Government of Puducherry. Comes from a respected and traditional joint family. Believes in mutual respect, simplicity, and lifelong learning.',
  },
  {
    'user_id': 'USR_SMP_M03',
    'profile_id': 'PRF_SMP_M03',
    'name': 'Dr. Vigneshwaran R.',
    'gender': 'Male',
    'dob': '1994-11-05',
    'age': '31',
    'height_cm': '180',
    'weight_kg': '75',
    'mobile': '+919840001003',
    'email': 'dr.vignesh@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '7', // Brahmin Iyer
    'sub_caste_id': '1', // Vadama
    'star': 'Poosam',
    'rasi': 'Kadagam',
    'city': 'Muthialpet',
    'about_me': 'Born in Muthialpet, Puducherry. Completed MBBS and MD General Medicine at JIPMER Puducherry. Currently practicing as a Senior Resident Doctor at JIPMER Hospital. Grounded in traditional values while embracing progressive views on work-life harmony. Seeking an understanding life partner who values empathy, education, and family traditions.',
  },
  {
    'user_id': 'USR_SMP_M04',
    'profile_id': 'PRF_SMP_M04',
    'name': 'Anandha Krishnan G.',
    'gender': 'Male',
    'dob': '1997-02-14',
    'age': '28',
    'height_cm': '170',
    'weight_kg': '65',
    'mobile': '+919840001004',
    'email': 'anand.krishnan@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '6', // Pillai
    'sub_caste_id': '12', // Saiva Pillai
    'star': 'Hastham',
    'rasi': 'Kanni',
    'city': 'Reddiarpalayam',
    'about_me': 'Residing in Reddiarpalayam, Puducherry. Master of Design graduate from Pondicherry Central University. Works as a Lead Product Designer for a global fintech platform. Passionate about photography, heritage architecture, and coastal gastronomy. Looking for a cheerful, career-focused partner who enjoys deep conversations and weekend travel.',
  },
  {
    'user_id': 'USR_SMP_M05',
    'profile_id': 'PRF_SMP_M05',
    'name': 'Saravanan Balaji',
    'gender': 'Male',
    'dob': '1993-06-18',
    'age': '32',
    'height_cm': '175',
    'weight_kg': '70',
    'mobile': '+919840001005',
    'email': 'saravanan.balaji@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '11', // Yadava
    'sub_caste_id': '0',
    'star': 'Swathi',
    'rasi': 'Thulaam',
    'city': 'Villianur',
    'about_me': 'From a close-knit nuclear family in Villianur, Puducherry. Holds an MBA in Finance from Pondicherry University. Serving as a Branch Operations Manager at a leading nationalised bank in Puducherry. Values honesty, humility, and family togetherness. Enjoys gardening, temple architecture, and badminton.',
  },
  {
    'user_id': 'USR_SMP_M06',
    'profile_id': 'PRF_SMP_M06',
    'name': 'Jean-Luc Aravind',
    'gender': 'Male',
    'dob': '1996-03-30',
    'age': '29',
    'height_cm': '178',
    'weight_kg': '74',
    'mobile': '+919840001006',
    'email': 'aravind.jeanluc@sample.pondyconnect.com',
    'religion_id': '2', // Christian
    'caste_id': '0',
    'sub_caste_id': '0',
    'star': '',
    'rasi': '',
    'city': 'White Town',
    'about_me': 'Bilingual French-Indian heritage based in the historic French Quarter (White Town), Puducherry. Studied French Literature followed by Hospitality Management in Paris. Managing a heritage boutique hotel and French cafe in White Town. Seeking a kind, open-minded life partner who appreciates intercultural heritage, art, and quiet seaside living.',
  },
  {
    'user_id': 'USR_SMP_M07',
    'profile_id': 'PRF_SMP_M07',
    'name': 'Manikandan P.',
    'gender': 'Male',
    'dob': '1998-09-12',
    'age': '27',
    'height_cm': '172',
    'weight_kg': '67',
    'mobile': '+919840001007',
    'email': 'mani.data@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '4', // Nadar
    'sub_caste_id': '0',
    'star': 'Moolam',
    'rasi': 'Dhanusu',
    'city': 'Ariyankuppam',
    'about_me': 'Native of Ariyankuppam, Puducherry. M.Tech in Data Science from PEC. Working as a Data Scientist with a tech startup in Chennai OMR with flexible remote work from Pondy. Active runner, tech enthusiast, and weekend volunteer. Looking for a compassionate partner with a positive outlook on personal growth.',
  },
  {
    'user_id': 'USR_SMP_M08',
    'profile_id': 'PRF_SMP_M08',
    'name': 'Vijayaraghavan T.',
    'gender': 'Male',
    'dob': '1992-12-04',
    'age': '33',
    'height_cm': '174',
    'weight_kg': '71',
    'mobile': '+919840001008',
    'email': 'vijay.agri@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '10', // Chettiar
    'sub_caste_id': '23',
    'star': 'Uthiradam',
    'rasi': 'Magaram',
    'city': 'Bahour',
    'about_me': 'Based in the lush agricultural commune of Bahour, Puducherry. B.Sc Agriculture from PAJANCOA (Karaikal). Entrepreneur running an organic agro-processing unit and farm export business. Deep respect for nature, family traditions, and social responsibility. Seeking an educated, caring companion who appreciates countryside warmth.',
  },
  {
    'user_id': 'USR_SMP_M09',
    'profile_id': 'PRF_SMP_M09',
    'name': 'Dr. Sridhar Parthasarathy',
    'gender': 'Male',
    'dob': '1995-07-25',
    'age': '30',
    'height_cm': '176',
    'weight_kg': '70',
    'mobile': '+919840001009',
    'email': 'dr.sridhar@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '8', // Brahmin Iyengar
    'sub_caste_id': '6', // Vadakalai
    'star': 'Sadayam',
    'rasi': 'Kumbam',
    'city': 'Kalapet',
    'about_me': 'Residing in Kalapet, Puducherry. Ph.D. in Physics from Pondicherry Central University with post-doctoral research experience. Currently serving as an Assistant Professor at Pondicherry University. Cultured, vegetarian lifestyle with a keen interest in classical music, philosophy, and academic mentorship.',
  },
  {
    'user_id': 'USR_SMP_M10',
    'profile_id': 'PRF_SMP_M10',
    'name': 'Dinesh Kumar M.',
    'gender': 'Male',
    'dob': '1997-10-15',
    'age': '28',
    'height_cm': '177',
    'weight_kg': '73',
    'mobile': '+919840001010',
    'email': 'dinesh.karaikal@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '18', // Meenavar / Pattanavar
    'sub_caste_id': '0',
    'star': 'Revathi',
    'rasi': 'Meenam',
    'city': 'Karaikal Town',
    'about_me': 'Proud native of Karaikal region, Puducherry UT. B.E. in Marine Engineering. Working as a Marine Logistics Operations Officer with Karaikal Port Private Ltd. Honest, hardworking, and deeply respectful of family bonds. Enjoys coastal swimming, sea kayaking, and spending quiet evenings with family.',
  },

  // ================= 10 AUTHENTIC WOMEN =================
  {
    'user_id': 'USR_SMP_F01',
    'profile_id': 'PRF_SMP_F01',
    'name': 'Priyadharshini K.',
    'gender': 'Female',
    'dob': '1998-05-14',
    'age': '27',
    'height_cm': '163',
    'weight_kg': '54',
    'mobile': '+919840001011',
    'email': 'priya.k@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '1', // Mudaliar
    'sub_caste_id': '8', // Sengunthar
    'star': 'Bharani',
    'rasi': 'Mesham',
    'city': 'Lawspet',
    'about_me': 'Born and educated in Lawspet, Puducherry. Completed B.Tech (ECE) at Pondicherry Engineering College. Currently working as a Senior Cloud Solutions Consultant with an IT enterprise in Chennai (hybrid work). Broad-minded, creative, and family-oriented. Passionate about classical Bharatanatyam dance and sustainable living.',
  },
  {
    'user_id': 'USR_SMP_F02',
    'profile_id': 'PRF_SMP_F02',
    'name': 'Dr. Nivetha S.',
    'gender': 'Female',
    'dob': '1997-12-08',
    'age': '28',
    'height_cm': '165',
    'weight_kg': '56',
    'mobile': '+919840001012',
    'email': 'dr.nivetha@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '3', // Vanniyar
    'sub_caste_id': '16', // Padayachi
    'star': 'Uthiram',
    'rasi': 'Kanni',
    'city': 'Muthialpet',
    'about_me': 'Resident of Muthialpet, Puducherry. BDS and MDS in Conservative Dentistry from Indira Gandhi Medical College & Research Institute (IGMCRI Pondy). Running a successful dental clinic in Pondicherry. Gentle, affectionate, and dedicated to health advocacy. Looking for a partner who values mutual professional respect and shared laughter.',
  },
  {
    'user_id': 'USR_SMP_F03',
    'profile_id': 'PRF_SMP_F03',
    'name': 'Soundharya M.',
    'gender': 'Female',
    'dob': '1999-04-18',
    'age': '26',
    'height_cm': '160',
    'weight_kg': '52',
    'mobile': '+919840001013',
    'email': 'soundharya.lit@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '6', // Pillai
    'sub_caste_id': '12', // Saiva Pillai
    'star': 'Mrigashirsha',
    'rasi': 'Mithunam',
    'city': 'Reddiarpalayam',
    'about_me': 'From Reddiarpalayam, Puducherry. M.A. in English Literature from Pondicherry Central University with UGC-NET qualification. Working as an Assistant Professor of English at a prestigious arts college. Loves literature, theatre, sketching, and temple architecture. Looking for an open-hearted and intellectually engaging life partner.',
  },
  {
    'user_id': 'USR_SMP_F04',
    'profile_id': 'PRF_SMP_F04',
    'name': 'Kaviya Natarajan',
    'gender': 'Female',
    'dob': '2000-09-22',
    'age': '25',
    'height_cm': '164',
    'weight_kg': '55',
    'mobile': '+919840001014',
    'email': 'kaviya.design@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '4', // Nadar
    'sub_caste_id': '0',
    'star': 'Punarpoosam',
    'rasi': 'Mithunam',
    'city': 'Oulgaret',
    'about_me': 'Residing in Oulgaret (Ozhukarai), Puducherry. B.Tech in Information Technology from PTU. Working as a UI/UX Experience Lead for a SaaS design agency. Enthusiastic, warm-hearted, and loves baking, sketching, and coastal heritage walks. Values equality, companionship, and open communication.',
  },
  {
    'user_id': 'USR_SMP_F05',
    'profile_id': 'PRF_SMP_F05',
    'name': 'Malarvizhi R.',
    'gender': 'Female',
    'dob': '1998-02-10',
    'age': '27',
    'height_cm': '158',
    'weight_kg': '50',
    'mobile': '+919840001015',
    'email': 'malar.teacher@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '11', // Yadava
    'sub_caste_id': '0',
    'star': 'Magam',
    'rasi': 'Simmam',
    'city': 'Villianur',
    'about_me': 'Native of historic Villianur, Puducherry. M.Sc Chemistry and B.Ed from KMCPGS Puducherry. Appointed as a Post Graduate Science Teacher at a Government Higher Secondary School. Comes from a traditional, affectionate family. Believes in teaching values of compassion and integrity to the next generation.',
  },
  {
    'user_id': 'USR_SMP_F06',
    'profile_id': 'PRF_SMP_F06',
    'name': 'Ananya Marie D.',
    'gender': 'Female',
    'dob': '1997-07-03',
    'age': '28',
    'height_cm': '166',
    'weight_kg': '58',
    'mobile': '+919840001016',
    'email': 'ananya.marie@sample.pondyconnect.com',
    'religion_id': '2', // Christian
    'caste_id': '0',
    'sub_caste_id': '0',
    'star': '',
    'rasi': '',
    'city': 'White Town',
    'about_me': 'French-Tamil heritage resident in White Town, Puducherry. Bachelor of Architecture (B.Arch) graduate working in heritage conservation and eco-sustainable urban planning. Passionate about preserving Pondicherry\'s Franco-Tamil colonial architecture, classical piano, and organic culinary arts. Seeking a warm and cultured soulmate.',
  },
  {
    'user_id': 'USR_SMP_F07',
    'profile_id': 'PRF_SMP_F07',
    'name': 'Deepalakshmi V.',
    'gender': 'Female',
    'dob': '1999-11-28',
    'age': '26',
    'height_cm': '161',
    'weight_kg': '53',
    'mobile': '+919840001017',
    'email': 'deepa.nurse@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '15', // Adi Dravidar
    'sub_caste_id': '0',
    'star': 'Anusham',
    'rasi': 'Viruchigam',
    'city': 'Ariyankuppam',
    'about_me': 'From Ariyankuppam, Puducherry. B.Sc Nursing from the prestigious College of Nursing, JIPMER. Serving as a Senior Staff Nurse in intensive pediatric care at JIPMER Puducherry. Patient, hardworking, empathetic, and deeply dedicated to healing. Seeking a supportive life partner who values service, honesty, and family harmony.',
  },
  {
    'user_id': 'USR_SMP_F08',
    'profile_id': 'PRF_SMP_F08',
    'name': 'Swathi Krishnan',
    'gender': 'Female',
    'dob': '1996-10-12',
    'age': '29',
    'height_cm': '162',
    'weight_kg': '55',
    'mobile': '+919840001018',
    'email': 'swathi.ca@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '7', // Brahmin Iyer
    'sub_caste_id': '2', // Brahacharanam
    'star': 'Thiruvonam',
    'rasi': 'Magaram',
    'city': 'Lawspet',
    'about_me': 'Resident of Lawspet, Puducherry. Qualified Chartered Accountant (ACA). Working as a Senior Finance & Tax Manager for an industrial manufacturing corporate in Puducherry. Analytical mindset with a cheerful personal demeanor. Enjoys veena recitals, South Indian filter coffee, and weekend beach strolls.',
  },
  {
    'user_id': 'USR_SMP_F09',
    'profile_id': 'PRF_SMP_F09',
    'name': 'Janani Srinivasan',
    'gender': 'Female',
    'dob': '1998-08-05',
    'age': '27',
    'height_cm': '165',
    'weight_kg': '57',
    'mobile': '+919840001019',
    'email': 'janani.ai@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '8', // Brahmin Iyengar
    'sub_caste_id': '7', // Thenkalai
    'star': 'Uthirattathi',
    'rasi': 'Meenam',
    'city': 'Muthialpet',
    'about_me': 'Native of Muthialpet, Puducherry. M.Tech in Artificial Intelligence & Robotics from PEC. Working as an AI Research Associate with a healthcare technology laboratory. Passionate about robotics education, carnatic vocal music, and yoga. Seeking an ambitious and caring life partner who respects traditions and celebrates shared goals.',
  },
  {
    'user_id': 'USR_SMP_F10',
    'profile_id': 'PRF_SMP_F10',
    'name': 'Mathumitha B.',
    'gender': 'Female',
    'dob': '1999-01-30',
    'age': '26',
    'height_cm': '159',
    'weight_kg': '51',
    'mobile': '+919840001020',
    'email': 'mathu.revenue@sample.pondyconnect.com',
    'religion_id': '1',
    'caste_id': '10', // Chettiar
    'sub_caste_id': '23',
    'star': 'Rohini',
    'rasi': 'Rishabam',
    'city': 'Karaikal Town',
    'about_me': 'From a distinguished family in Karaikal, Puducherry UT. B.A. in Public Administration. Cleared UT civil services examination and serving as a Revenue Inspector / Deputy Tahsildar in the Karaikal Collectorate. Calm, principled, and deeply family-oriented. Looking for an educated, understanding partner with positive values.',
  },
];
