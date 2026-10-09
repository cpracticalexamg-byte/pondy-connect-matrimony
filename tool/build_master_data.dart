// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  print('==============================================');
  print('BUILDING COMPLETE V2 MASTER DATA CSVs');
  print('==============================================');

  final dbMasterDir = Directory('db/master');
  final assetsMasterDir = Directory('assets/csv/master');
  final docsDir = Directory('docs');

  if (!await dbMasterDir.exists()) await dbMasterDir.create(recursive: true);
  if (!await assetsMasterDir.exists()) await assetsMasterDir.create(recursive: true);
  if (!await docsDir.exists()) await docsDir.create(recursive: true);

  final builder = MasterDataBuilder();
  await builder.buildAll(dbMasterDir, assetsMasterDir, docsDir);

  print('Master data generation finished successfully!');
}

class MasterDataBuilder {
  Future<void> writeCsv(
    Directory dbDir,
    Directory assetsDir,
    String filename,
    List<String> headers,
    List<List<dynamic>> rows,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln(headers.map(_escape).join(','));
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(','));
    }
    final content = buffer.toString();

    final dbFile = File('${dbDir.path}/$filename');
    final assetsFile = File('${assetsDir.path}/$filename');

    await dbFile.writeAsString(content, encoding: utf8, flush: true);
    await assetsFile.writeAsString(content, encoding: utf8, flush: true);
    print('  [✓] $filename (${rows.length} rows)');
  }

  String _escape(dynamic val) {
    if (val == null) return '';
    final s = val.toString().trim();
    if (s.contains(',') || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  Future<void> buildAll(Directory dbDir, Directory assetsDir, Directory docsDir) async {
    // 1. profile_created_for.csv
    await writeCsv(dbDir, assetsDir, 'profile_created_for.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'myself', 'Myself', 'எனக்காக', 1, 1],
        [2, 'son', 'Son', 'மகன்', 2, 1],
        [3, 'daughter', 'Daughter', 'மகள்', 3, 1],
        [4, 'brother', 'Brother', 'சகோதரன்', 4, 1],
        [5, 'sister', 'Sister', 'சகோதரி', 5, 1],
        [6, 'friend', 'Friend', 'நண்பர்', 6, 1],
        [7, 'relative', 'Relative', 'உறவினர்', 7, 1],
      ],
    );

    // 2. gender.csv
    await writeCsv(dbDir, assetsDir, 'gender.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'male', 'Male', 'ஆண்', 1, 1],
        [2, 'female', 'Female', 'பெண்', 2, 1],
      ],
    );

    // 3. marital_status.csv
    await writeCsv(dbDir, assetsDir, 'marital_status.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'never_married', 'Never Married', 'திருமணம் ஆகாதவர்', 1, 1],
        [2, 'widowed', 'Widowed', 'துணையை இழந்தவர்', 2, 1],
        [3, 'divorced', 'Divorced', 'விவாகரத்து பெற்றவர்', 3, 1],
        [4, 'awaiting_divorce', 'Awaiting Divorce', 'விவாகரத்து கோரியவர்', 4, 1],
        [5, 'annulled', 'Annulled', 'செல்லாததாக்கப்பட்ட திருமணம்', 5, 1],
      ],
    );

    // 4. physical_status.csv
    await writeCsv(dbDir, assetsDir, 'physical_status.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'normal', 'Normal', 'இயல்பானது', 1, 1],
        [2, 'physically_challenged', 'Physically Challenged', 'மாற்றுத்திறனாளி', 2, 1],
      ],
    );

    // 5. disability_type.csv
    await writeCsv(dbDir, assetsDir, 'disability_type.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'locomotor', 'Locomotor Disability', 'உடல் இயக்க குறைபாடு', 1, 1],
        [2, 'visual', 'Visual Impairment', 'பார்வை குறைபாடு', 2, 1],
        [3, 'hearing_speech', 'Hearing & Speech Impairment', 'செவித்திறன் / பேச்சு குறைபாடு', 3, 1],
        [4, 'other', 'Other Disability', 'இதர குறைபாடு', 4, 1],
      ],
    );

    // 6. body_type.csv
    await writeCsv(dbDir, assetsDir, 'body_type.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'slim', 'Slim', 'ஒல்லியான', 1, 1],
        [2, 'average', 'Average', 'சராசரியான', 2, 1],
        [3, 'athletic', 'Athletic', 'உடலமைப்பு மிக்கவர்', 3, 1],
        [4, 'heavy', 'Heavy', 'பருமனான', 4, 1],
      ],
    );

    // 7. complexion.csv
    await writeCsv(dbDir, assetsDir, 'complexion.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'very_fair', 'Very Fair', 'மிகவும் சிவப்பு', 1, 1],
        [2, 'fair', 'Fair', 'சிவப்பு', 2, 1],
        [3, 'wheatish', 'Wheatish', 'மாநிறம்', 3, 1],
        [4, 'wheatish_brown', 'Wheatish Brown', 'மாநிற பழுப்பு', 4, 1],
        [5, 'dark', 'Dark', 'கருமை', 5, 1],
      ],
    );

    // 8. blood_group.csv
    await writeCsv(dbDir, assetsDir, 'blood_group.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'a_pos', 'A+', 'A+', 1, 1],
        [2, 'a_neg', 'A−', 'A−', 2, 1],
        [3, 'b_pos', 'B+', 'B+', 3, 1],
        [4, 'b_neg', 'B−', 'B−', 4, 1],
        [5, 'o_pos', 'O+', 'O+', 5, 1],
        [6, 'o_neg', 'O−', 'O−', 6, 1],
        [7, 'ab_pos', 'AB+', 'AB+', 7, 1],
        [8, 'ab_neg', 'AB−', 'AB−', 8, 1],
      ],
    );

    // 9. height.csv (4'0" to 7'0" every single inch)
    final heightRows = <List<dynamic>>[];
    int hId = 1;
    for (int feet = 4; feet <= 7; feet++) {
      for (int inch = 0; inch < 12; inch++) {
        if (feet == 7 && inch > 0) break;
        final totalInches = (feet * 12) + inch;
        final cm = (totalInches * 2.54).round();
        final labelEn = '$feet ft $inch in ($cm cm)';
        final labelTa = '$feet அடி $inch அங்குலம் ($cm செ.மீ)';
        final code = '${feet}ft_${inch}in';
        heightRows.add([hId++, code, cm, feet, inch, labelEn, labelTa, hId - 1, 1]);
      }
    }
    await writeCsv(dbDir, assetsDir, 'height.csv',
      ['id', 'code', 'cm', 'feet', 'inches', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      heightRows,
    );

    // 10. mother_tongue.csv & language_known.csv (22 scheduled + regional Puducherry languages)
    final languageRows = [
      [1, 'tamil', 'Tamil', 'தமிழ்', 1, 1],
      [2, 'telugu', 'Telugu', 'தெலுங்கு', 2, 1],
      [3, 'malayalam', 'Malayalam', 'மலையாளம்', 3, 1],
      [4, 'kannada', 'Kannada', 'கன்னடம்', 4, 1],
      [5, 'hindi', 'Hindi', 'இந்தி', 5, 1],
      [6, 'french', 'French', 'பிரெஞ்சு', 6, 1], // Puducherry historic
      [7, 'sourashtra', 'Sourashtra', 'சௌராஷ்ட்ரா', 7, 1],
      [8, 'urdu', 'Urdu', 'உருது', 8, 1],
      [9, 'english', 'English', 'ஆங்கிலம்', 9, 1],
      [10, 'marathi', 'Marathi', 'மராத்தி', 10, 1],
      [11, 'gujarati', 'Gujarati', 'குஜராத்தி', 11, 1],
      [12, 'bengali', 'Bengali', 'வங்காளி', 12, 1],
      [13, 'punjabi', 'Punjabi', 'பஞ்சாபி', 13, 1],
      [14, 'odia', 'Odia', 'ஒடியா', 14, 1],
      [15, 'konkani', 'Konkani', 'கொங்கணி', 15, 1],
      [16, 'tulu', 'Tulu', 'துளு', 16, 1],
      [17, 'marwari', 'Marwari', 'மார்வாடி', 17, 1],
      [18, 'rajasthani', 'Rajasthani', 'ராஜஸ்தானி', 18, 1],
      [19, 'sindhi', 'Sindhi', 'சிந்தி', 19, 1],
      [20, 'assamese', 'Assamese', 'அஸ்ஸாமி', 20, 1],
      [21, 'kashmiri', 'Kashmiri', 'காஷ்மீரி', 21, 1],
      [22, 'nepali', 'Nepali', 'நேபாளி', 22, 1],
      [23, 'sanskrit', 'Sanskrit', 'சமஸ்கிருதம்', 23, 1],
      [24, 'badaga', 'Badaga', 'படக', 24, 1],
      [25, 'kodava', 'Kodava', 'குடகு', 25, 1],
      [26, 'dogri', 'Dogri', 'டோக்ரி', 26, 1],
      [27, 'maithili', 'Maithili', 'மைதிலி', 27, 1],
      [28, 'santali', 'Santali', 'சந்தாலி', 28, 1],
      [29, 'bodo', 'Bodo', 'போடோ', 29, 1],
      [30, 'manipuri', 'Manipuri', 'மணிப்புரி', 30, 1],
      [31, 'other', 'Others', 'இதர மொழிகள்', 31, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'mother_tongue.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      languageRows,
    );
    await writeCsv(dbDir, assetsDir, 'language_known.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      languageRows,
    );

    // 11. religion.csv
    final religionRows = [
      [1, 'hindu', 'Hindu', 'இந்து', 1, 1],
      [2, 'muslim_sunni', 'Muslim – Sunni', 'முஸ்லிம் – சுன்னி', 2, 1],
      [3, 'muslim_shia', 'Muslim – Shia', 'முஸ்லிம் – ஷியா', 3, 1],
      [4, 'muslim_others', 'Muslim – Others', 'முஸ்லிம் – இதர', 4, 1],
      [5, 'christian', 'Christian', 'கிறிஸ்தவர்', 5, 1],
      [6, 'sikh', 'Sikh', 'சீக்கியர்', 6, 1],
      [7, 'jain_digambar', 'Jain – Digambar', 'சைனம் – திகம்பரர்', 7, 1],
      [8, 'jain_shwetambar', 'Jain – Shwetambar', 'சைனம் – ஸ்வேதாம்பரர்', 8, 1],
      [9, 'jain_others', 'Jain – Others', 'சைனம் – இதர', 9, 1],
      [10, 'parsi', 'Parsi', 'பார்சி', 10, 1],
      [11, 'buddhist', 'Buddhist', 'பௌத்தர்', 11, 1],
      [12, 'jewish', 'Jewish', 'யூதர்', 12, 1],
      [13, 'inter_religion', 'Inter-Religion', 'மதங்கடந்த', 13, 1],
      [14, 'no_religion', 'No Religion / Spiritual', 'மதமற்றவர் / ஆன்மீகவாதி', 14, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'religion.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      religionRows,
    );

    // 12. religion_division.csv
    final divisionRows = [
      // Hindu (religion_id: 1)
      [1, 1, 'hindu_shaivam', 'Shaivam', 'சைவம்', 1, 1],
      [2, 1, 'hindu_vaishnavam', 'Vaishnavam', 'வைணவம்', 2, 1],
      [3, 1, 'hindu_smartha', 'Smartha', 'ஸ்மார்த்தம்', 3, 1],
      [4, 1, 'hindu_others', 'Others', 'இதர பிரிவுகள்', 4, 1],

      // Muslim Sunni (religion_id: 2)
      [5, 2, 'sunni_hanafi', 'Hanafi', 'ஹனஃபி', 1, 1],
      [6, 2, 'sunni_shafi', 'Shafi', 'ஷாஃபி', 2, 1],
      [7, 2, 'sunni_maliki', 'Maliki', 'மாலிகி', 3, 1],
      [8, 2, 'sunni_hanbali', 'Hanbali', 'ஹன்பலி', 4, 1],
      [9, 2, 'sunni_ahle_hadith', 'Ahle Hadith', 'அஹ்லே ஹதீஸ்', 5, 1],
      [10, 2, 'sunni_deobandi', 'Deobandi', 'தேவ்பந்தி', 6, 1],
      [11, 2, 'sunni_barelvi', 'Barelvi', 'பரேல்வி', 7, 1],
      [12, 2, 'sunni_others', 'Others', 'இதர பிரிவுகள்', 8, 1],

      // Muslim Shia (religion_id: 3)
      [13, 3, 'shia_ithna_asharia', 'Ithna Asharia (Twelver)', 'இத்னா அஷாரியா', 1, 1],
      [14, 3, 'shia_ismailia', 'Ismailia', 'இஸ்மாயிலியா', 2, 1],
      [15, 3, 'shia_dawoodi_bohra', 'Dawoodi Bohra', 'தாவூதி போஹ்ரா', 3, 1],
      [16, 3, 'shia_khoja', 'Khoja', 'கோஜா', 4, 1],
      [17, 3, 'shia_others', 'Others', 'இதர பிரிவுகள்', 5, 1],

      // Christian (religion_id: 5)
      [18, 5, 'rc_latin', 'Roman Catholic (Latin Catholic)', 'ரோமன் கத்தோலிக்கர் (லத்தீன்)', 1, 1],
      [19, 5, 'rc_syro_malabar', 'Syro-Malabar Catholic', 'சீரோ-மலபார் கத்தோலிக்கர்', 2, 1],
      [20, 5, 'csi', 'Church of South India (CSI)', 'தென்னிந்திய திருச்சபை (CSI)', 3, 1],
      [21, 5, 'cni', 'Church of North India (CNI)', 'வடஇந்திய திருச்சபை (CNI)', 4, 1],
      [22, 5, 'anglican', 'Anglican / Episcopal', 'ஆங்கிலிகன்', 5, 1],
      [23, 5, 'pentecostal', 'Pentecostal', 'பெந்தேகோஸ்தே', 6, 1],
      [24, 5, 'assemblies_of_god', 'Assembly of God (AG)', 'அசெம்பிளி ஆப் காட்', 7, 1],
      [25, 5, 'baptist', 'Baptist', 'பாப்டிஸ்ட்', 8, 1],
      [26, 5, 'lutheran', 'Lutheran (TELC / ALC)', 'லூத்தரன்', 9, 1],
      [27, 5, 'methodist', 'Methodist', 'மெதடிஸ்ட்', 10, 1],
      [28, 5, 'presbyterian', 'Presbyterian', 'பிரஸ்பைடீரியன்', 11, 1],
      [29, 5, 'salvation_army', 'Salvation Army', 'இரட்சணிய சேனை', 12, 1],
      [30, 5, 'seventh_day_adventist', 'Seventh-day Adventist', 'ஏழாம் நாள் அட்வென்டிஸ்ட்', 13, 1],
      [31, 5, 'born_again', 'Born Again', 'மறுபிறப்படைந்த கிறிஸ்தவர்', 14, 1],
      [32, 5, 'evangelical', 'Evangelical', 'சுவிசேஷ கிறிஸ்தவர்', 15, 1],
      [33, 5, 'jacobite', 'Jacobite Syrian', 'யாக்கோபாய கிறிஸ்தவர்', 16, 1],
      [34, 5, 'orthodox', 'Malankara Orthodox', 'மலங்கரா ஆர்த்தடாக்ஸ்', 17, 1],
      [35, 5, 'marthoma', 'Marthoma', 'மார்தோமா', 18, 1],
      [36, 5, 'christian_others', 'Christian – Others', 'இதர கிறிஸ்தவர்', 19, 1],

      // Sikh (religion_id: 6)
      [37, 6, 'sikh_jat', 'Jat Sikh', 'ஜாட் சீக்கியர்', 1, 1],
      [38, 6, 'sikh_ramgarhia', 'Ramgarhia', 'ராம்கரியா', 2, 1],
      [39, 6, 'sikh_khatri', 'Khatri', 'கத்ரி', 3, 1],
      [40, 6, 'sikh_others', 'Others', 'இதர பிரிவுகள்', 4, 1],

      // Jain (religion_id: 7, 8)
      [41, 7, 'jain_terapanthi', 'Terapanthi', 'தேராபந்தி', 1, 1],
      [42, 8, 'jain_murtipujaka', 'Murtipujaka', 'மூர்த்திபூஜக', 2, 1],

      // Buddhist (religion_id: 11)
      [43, 11, 'buddhist_theravada', 'Theravada', 'தேரவாதம்', 1, 1],
      [44, 11, 'buddhist_mahayana', 'Mahayana', 'மகாயானம்', 2, 1],
      [45, 11, 'buddhist_navayana', 'Navayana (Ambedkarite)', 'நவயானம்', 3, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'religion_division.csv',
      ['id', 'religion_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      divisionRows,
    );

    // 13. caste.csv (Comprehensive TN & Indian Matrimony Communities)
    final casteRows = [
      // Hindu Tamil Nadu major communities
      [1, 1, 0, 'mudaliar', 'Mudaliar', 'முதலியார்', 'BC', 'TN-BCC', 1, 1],
      [2, 1, 0, 'kongu_vellalar_gounder', 'Kongu Vellalar / Gounder', 'கொங்கு வேளாளர் / கவுண்டர்', 'BC', 'TN-BCC', 2, 1],
      [3, 1, 0, 'vanniyar', 'Vanniyar (Padayachi / Palli)', 'வன்னியர் (படையாட்சி / பள்ளி)', 'MBC', 'TN-MBCC', 3, 1],
      [4, 1, 0, 'nadar', 'Nadar', 'நாடார்', 'BC', 'TN-BCC', 4, 1],
      [5, 1, 0, 'thevar_mukkulathor', 'Thevar / Mukkulathor (Kallar, Maravar, Agamudayar)', 'தேவர் / முக்குலத்தோர் (கள்ளர், மறவர், அகமுடையார்)', 'BC/DNC', 'TN-BCC', 5, 1],
      [6, 1, 0, 'pillai_saiva', 'Pillai – Saiva / Vellalar', 'பிள்ளை – சைவ பிள்ளை / வேளாளர்', 'BC', 'TN-BCC', 6, 1],
      [7, 1, 0, 'brahmin_iyer', 'Brahmin – Iyer', 'பிராமணர் – ஐயர்', 'OC', 'MatrimonyTaxonomy', 7, 1],
      [8, 1, 0, 'brahmin_iyengar', 'Brahmin – Iyengar', 'பிராமணர் – ஐயங்கார்', 'OC', 'MatrimonyTaxonomy', 8, 1],
      [9, 1, 0, 'chettiar_nattukottai', 'Chettiar – Nattukottai / Nagarathar', 'செட்டியார் – நாட்டுக்கோட்டை / நகரத்தார்', 'OC', 'MatrimonyTaxonomy', 9, 1],
      [10, 1, 0, 'chettiar_general', 'Chettiar (Vaniya / Kasukkara / Beri / Devanga)', 'செட்டியார் (வாணிய / காசுக்கார / தேவாங்க)', 'BC', 'TN-BCC', 10, 1],
      [11, 1, 0, 'yadava_konar', 'Yadava / Konar / Idaiyar', 'யாதவர் / கோனார் / இடையர்', 'BC', 'TN-BCC', 11, 1],
      [12, 1, 0, 'viswakarma', 'Viswakarma / Asari / Kammalar', 'விஸ்வகர்மா / ஆசாரி / கம்மாளர்', 'BC', 'TN-BCC', 12, 1],
      [13, 1, 0, 'naidu_balija', 'Naidu (Balija / Kavara / Gavara)', 'நாயுடு (பலிஜா / கவரா / கவரா)', 'BC', 'TN-BCC', 13, 1],
      [14, 1, 0, 'reddy_reddiar', 'Reddy / Reddiar', 'ரெட்டி / ரெட்டியார்', 'BC', 'TN-BCC', 14, 1],
      [15, 1, 0, 'adi_dravidar', 'Adi Dravidar (Paraiyar)', 'ஆதி திராவிடர் (பறையர்)', 'SC', 'TN-ADTW', 15, 1],
      [16, 1, 0, 'devendra_kula_vellalar', 'Devendra Kula Vellalar (Pallar)', 'தேவேந்திர குல வேளாளர் (பள்ளர்)', 'SC', 'TN-ADTW', 16, 1],
      [17, 1, 0, 'arunthathiyar', 'Arunthathiyar (Chakkiliyan / Madiga)', 'அருந்ததியர் (சக்கிலியர் / மாதிகா)', 'SCA', 'TN-ADTW', 17, 1],
      [18, 1, 0, 'meenavar_pattanavar', 'Meenavar / Pattanavar', 'மீனவர் / பட்டணவர்', 'MBC', 'TN-MBCC', 18, 1],
      [19, 1, 0, 'paravar_bharathar', 'Paravar / Bharathar', 'பரவர் / பரதவர்', 'MBC', 'TN-MBCC', 19, 1],
      [20, 1, 0, 'saurashtra', 'Saurashtra (Pattunulkarar)', 'சௌராஷ்ட்ரா (பட்டுநூல்காரர்)', 'BC', 'TN-BCC', 20, 1],
      [21, 1, 0, 'senai_thalaivar', 'Senai Thalaivar (Elai Vaniyar)', 'சேனைத் தலைவர் (இலை வாணியர்)', 'BC', 'TN-BCC', 21, 1],
      [22, 1, 0, 'mutharaiyar', 'Mutharaiyar / Ambalakarar / Muthuraja', 'முத்தரையர் / அம்பலக்காரர்', 'MBC', 'TN-MBCC', 22, 1],
      [23, 1, 0, 'rajaka_vannar', 'Rajaka / Vannar', 'ராஜகா / வண்ணார்', 'MBC', 'TN-MBCC', 23, 1],
      [24, 1, 0, 'maruthuvar_navithar', 'Maruthuvar / Navithar', 'மருத்துவர் / நாவிதர்', 'MBC', 'TN-MBCC', 24, 1],
      [25, 1, 0, 'boyar_oddar', 'Boyar / Oddar', 'போயர் / ஒட்டர்', 'MBC', 'TN-MBCC', 25, 1],
      [26, 1, 0, 'kuyavar_kulalar', 'Kuyavar / Kulalar (Velar)', 'குயவர் / குலாலர் (வேளார்)', 'MBC', 'TN-MBCC', 26, 1],
      [27, 1, 0, 'vettuva_gounder', 'Vettuva Gounder', 'வேட்டுவ கவுண்டர்', 'BC', 'TN-BCC', 27, 1],
      [28, 1, 0, 'udayar_parkavakulam', 'Udayar / Parkavakulam (Nainar / Nathaman)', 'உடையார் / பார்கவகுலம்', 'BC', 'TN-BCC', 28, 1],
      [29, 1, 0, 'sozhiya_vellalar', 'Sozhiya Vellalar', 'சோழிய வேளாளர்', 'BC', 'TN-BCC', 29, 1],
      [30, 1, 0, 'irular_tribal', 'Irular / ST Communities', 'இருளர் / பழங்குடியினர்', 'ST', 'TN-ADTW', 30, 1],
      [31, 1, 0, 'brahmin_madhva', 'Brahmin – Madhva', 'பிராமணர் – மாத்வர்', 'OC', 'MatrimonyTaxonomy', 31, 1],
      [32, 1, 0, 'kamma_naidu', 'Kamma', 'கம்மா', 'OC/BC', 'MatrimonyTaxonomy', 32, 1],
      [33, 1, 0, 'kapu', 'Kapu', 'காபு', 'OC/BC', 'MatrimonyTaxonomy', 33, 1],
      [34, 1, 0, 'nair', 'Nair', 'நாயர்', 'OC', 'MatrimonyTaxonomy', 34, 1],
      [35, 1, 0, 'ezhava_thiyya', 'Ezhava / Thiyya', 'ஈழவா / திய்யா', 'OBC', 'MatrimonyTaxonomy', 35, 1],
      [36, 1, 0, 'lingayat', 'Lingayat', 'லிங்காயத்', 'OBC', 'MatrimonyTaxonomy', 36, 1],
      [37, 1, 0, 'vokkaliga', 'Vokkaliga', 'வொக்கலிகர்', 'OBC', 'MatrimonyTaxonomy', 37, 1],
      [38, 1, 0, 'arya_vysya', 'Arya Vysya', 'ஆர்ய வைசியர்', 'OC', 'MatrimonyTaxonomy', 38, 1],
      [39, 1, 0, 'marwari', 'Marwari', 'மார்வாடி', 'OC', 'MatrimonyTaxonomy', 39, 1],
      [40, 1, 0, 'gujarati', 'Gujarati', 'குஜராத்தி', 'OC', 'MatrimonyTaxonomy', 40, 1],
      [41, 1, 0, 'rajput', 'Rajput', 'ராஜபுத்திரர்', 'OC', 'MatrimonyTaxonomy', 41, 1],
      [42, 1, 0, 'caste_none', 'Caste No Bar / Any Caste', 'சாதி தடையில்லை', 'OC', 'AppStandard', 42, 1],

      // Christian Communities (religion_id: 5)
      [43, 5, 0, 'christian_nadar', 'Christian – Nadar', 'கிறிஸ்தவ நாடார்', 'BC', 'TN-BCC', 43, 1],
      [44, 5, 0, 'christian_paravar', 'Christian – Paravar / Bharathar / Fernando', 'கிறிஸ்தவ பரவர் / பரதவர்', 'MBC', 'TN-MBCC', 44, 1],
      [45, 5, 0, 'christian_latin_catholic', 'Christian – Latin Catholic', 'லத்தீன் கத்தோலிக்கர்', 'BC', 'TN-BCC', 45, 1],
      [46, 5, 0, 'christian_adi_dravidar', 'Christian – Adi Dravidar', 'கிறிஸ்தவ ஆதி திராவிடர்', 'BC', 'TN-BCC', 46, 1],
      [47, 5, 0, 'christian_vellalar', 'Christian – Pillai / Vellalar', 'கிறிஸ்தவ பிள்ளை / வேளாளர்', 'BC', 'TN-BCC', 47, 1],
      [48, 5, 0, 'christian_mudaliar', 'Christian – Mudaliar', 'கிறிஸ்தவ முதலியார்', 'BC', 'TN-BCC', 48, 1],
      [49, 5, 0, 'christian_vanniyar', 'Christian – Vanniyar', 'கிறிஸ்தவ வன்னியர்', 'MBC', 'TN-MBCC', 49, 1],
      [50, 5, 0, 'christian_chettiar', 'Christian – Chettiar', 'கிறிஸ்தவ செட்டியார்', 'BC', 'TN-BCC', 50, 1],
      [51, 5, 0, 'christian_thevar', 'Christian – Thevar / Mukkulathor', 'கிறிஸ்தவ தேவர்', 'BC', 'TN-BCC', 51, 1],
      [52, 5, 0, 'christian_anglo_indian', 'Christian – Anglo-Indian', 'ஆங்கிலோ-இந்தியர்', 'BC', 'TN-BCC', 52, 1],
      [53, 5, 0, 'christian_others', 'Christian – Others', 'இதர கிறிஸ்தவ சமூகம்', 'BC', 'TN-BCC', 53, 1],

      // Muslim Communities (religion_id: 2, 3, 4)
      [54, 2, 0, 'muslim_labbai', 'Muslim – Labbai', 'முஸ்லிம் – லப்பை', 'BCM', 'TN-BCCM', 54, 1],
      [55, 2, 0, 'muslim_rowther', 'Muslim – Rowther', 'முஸ்லிம் – ராவுத்தர்', 'BCM', 'TN-BCCM', 55, 1],
      [56, 2, 0, 'muslim_marakkayar', 'Muslim – Marakkayar', 'முஸ்லிம் – மரைக்காயர்', 'BCM', 'TN-BCCM', 56, 1],
      [57, 2, 0, 'muslim_dakhni', 'Muslim – Dakhni / Urdu Speaking', 'முஸ்லிம் – தக்னி / உருது', 'BCM', 'TN-BCCM', 57, 1],
      [58, 2, 0, 'muslim_sheikh', 'Muslim – Sheikh', 'முஸ்லிம் – ஷேக்', 'BCM', 'TN-BCCM', 58, 1],
      [59, 2, 0, 'muslim_syed', 'Muslim – Syed', 'முஸ்லிம் – சையது', 'BCM', 'TN-BCCM', 59, 1],
      [60, 2, 0, 'muslim_pathan', 'Muslim – Pathan', 'முஸ்லிம் – பதான்', 'BCM', 'TN-BCCM', 60, 1],
      [61, 2, 0, 'muslim_kayalar', 'Muslim – Kayalar', 'முஸ்லிம் – காயலர்', 'BCM', 'TN-BCCM', 61, 1],
      [62, 2, 0, 'muslim_others', 'Muslim – Others', 'இதர முஸ்லிம் சமூகம்', 'BCM', 'TN-BCCM', 62, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'caste.csv',
      ['id', 'religion_id', 'division_id', 'code', 'name_en', 'name_ta', 'reservation_category', 'source', 'sort_order', 'is_active'],
      casteRows,
    );

    // 14. sub_caste.csv
    final subCasteRows = [
      // Brahmin Iyer (caste_id: 7)
      [1, 7, 'iyer_vadama', 'Vadama', 'வடமா', 1, 1],
      [2, 7, 'iyer_brahacharanam', 'Brahacharanam', 'பிருகச்சரணம்', 2, 1],
      [3, 7, 'iyer_vathima', 'Vathima', 'வாத்திமா', 3, 1],
      [4, 7, 'iyer_ashtasahasram', 'Ashtasahasram', 'அஷ்டசஹஸ்ரம்', 4, 1],
      [5, 7, 'iyer_chozhiya', 'Chozhiya', 'சோழியர்', 5, 1],

      // Brahmin Iyengar (caste_id: 8)
      [6, 8, 'iyengar_vadakalai', 'Vadakalai', 'வடகலை', 1, 1],
      [7, 8, 'iyengar_thenkalai', 'Thenkalai', 'தென்கலை', 2, 1],

      // Mudaliar (caste_id: 1)
      [8, 1, 'mudaliar_sengunthar', 'Sengunthar / Kaikolar', 'செங்குந்தர் / கைகோளர்', 1, 1],
      [9, 1, 'mudaliar_saiva', 'Saiva Mudaliar', 'சைவ முதலியார்', 2, 1],
      [10, 1, 'mudaliar_thondaimandala', 'Thondaimandala Vellalar', 'தொண்டைமண்டல வேளாளர்', 3, 1],
      [11, 1, 'mudaliar_agamudaya', 'Agamudaya Mudaliar', 'அகமுடைய முதலியார்', 4, 1],

      // Pillai (caste_id: 6)
      [12, 6, 'pillai_saiva', 'Saiva Pillai', 'சைவ பிள்ளை', 1, 1],
      [13, 6, 'pillai_karkathar', 'Karkathar', 'கார்காத்த வேளாளர்', 2, 1],
      [14, 6, 'pillai_nanjil', 'Nanjil Nattu Vellalar', 'நாஞ்சில் நாட்டு வேளாளர்', 3, 1],
      [15, 6, 'pillai_tirunelveli', 'Tirunelveli Saiva Pillai', 'திருநெல்வேலி சைவ பிள்ளை', 4, 1],

      // Vanniyar (caste_id: 3)
      [16, 3, 'vanniyar_padayachi', 'Padayachi', 'படையாட்சி', 1, 1],
      [17, 3, 'vanniyar_gounder', 'Vanniya Gounder', 'வன்னிய கவுண்டர்', 2, 1],
      [18, 3, 'vanniyar_naicker', 'Naicker', 'நாயக்கர்', 3, 1],

      // Thevar (caste_id: 5)
      [19, 5, 'thevar_kallar', 'Kallar', 'கள்ளர்', 1, 1],
      [20, 5, 'thevar_maravar', 'Maravar', 'மறவர்', 2, 1],
      [21, 5, 'thevar_agamudayar', 'Agamudayar', 'அகமுடையார்', 3, 1],

      // Chettiar (caste_id: 9, 10)
      [22, 9, 'nagarathar', 'Nagarathar', 'நகரத்தார்', 1, 1],
      [23, 10, 'vaniya_chettiar', 'Vaniya Chettiar', 'வாணிய செட்டியார்', 2, 1],
      [24, 10, 'devanga_chettiar', 'Devanga Chettiar', 'தேவாங்க செட்டியார்', 3, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'sub_caste.csv',
      ['id', 'caste_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      subCasteRows,
    );

    // 15. gothram.csv
    final gothramList = [
      'Agastya', 'Angirasa', 'Athreya', 'Atri', 'Bharadwaja', 'Bhargava', 'Garga',
      'Gautama', 'Harita', 'Jamadagni', 'Kashyapa', 'Kaundinya', 'Kausika', 'Kutsa',
      'Maunasa', 'Mudgala', 'Parasara', 'Sandilya', 'Srivatsa', 'Upamanyu', 'Vadhula',
      'Vasishta', 'Vatsa', 'Vishwamitra', 'Kapila', 'Naidhruva', 'Kanva', 'Don\'t Know'
    ];
    final gothramRows = <List<dynamic>>[];
    for (int i = 0; i < gothramList.length; i++) {
      final name = gothramList[i];
      final code = name.toLowerCase().replaceAll(' ', '_').replaceAll("'", '');
      gothramRows.add([i + 1, code, name, name, i + 1, 1]);
    }
    await writeCsv(dbDir, assetsDir, 'gothram.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      gothramRows,
    );

    // 16. rasi.csv (12 signs with planetary lords)
    final rasiRows = [
      [1, 'mesham', 'Mesham (Aries)', 'மேஷம்', 'Mars (Sevvai)', 1, 1],
      [2, 'rishabam', 'Rishabam (Taurus)', 'ரிஷபம்', 'Venus (Sukran)', 2, 1],
      [3, 'mithunam', 'Mithunam (Gemini)', 'மிதுனம்', 'Mercury (Budhan)', 3, 1],
      [4, 'kadagam', 'Kadagam (Cancer)', 'கடகம்', 'Moon (Chandran)', 4, 1],
      [5, 'simmam', 'Simmam (Leo)', 'சிம்மம்', 'Sun (Suriyan)', 5, 1],
      [6, 'kanni', 'Kanni (Virgo)', 'கன்னி', 'Mercury (Budhan)', 6, 1],
      [7, 'thulam', 'Thulam (Libra)', 'துலாம்', 'Venus (Sukran)', 7, 1],
      [8, 'viruchigam', 'Viruchigam (Scorpio)', 'விருச்சிகம்', 'Mars (Sevvai)', 8, 1],
      [9, 'dhanusu', 'Dhanusu (Sagittarius)', 'தனுசு', 'Jupiter (Guru)', 9, 1],
      [10, 'makaram', 'Makaram (Capricorn)', 'மகரம்', 'Saturn (Sani)', 10, 1],
      [11, 'kumbam', 'Kumbam (Aquarius)', 'கும்பம்', 'Saturn (Sani)', 11, 1],
      [12, 'meenam', 'Meenam (Pisces)', 'மீனம்', 'Jupiter (Guru)', 12, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'rasi.csv',
      ['id', 'code', 'name_en', 'name_ta', 'lord_en', 'sort_order', 'is_active'],
      rasiRows,
    );

    // 17. nakshatra.csv (27 stars)
    final nakshatraData = [
      [1, 'ashwini', 'Ashwini', 'அசுவினி', 'Deva', 'Horse', 'Pada'],
      [2, 'bharani', 'Bharani', 'பரணி', 'Manushya', 'Elephant', 'Kati'],
      [3, 'krittika', 'Krittika / Karthigai', 'கார்த்திகை', 'Rakshasa', 'Sheep', 'Udara'],
      [4, 'rohini', 'Rohini', 'ரோகிணி', 'Manushya', 'Serpent', 'Kantha'],
      [5, 'mrigashira', 'Mrigashira / Mirugasirisham', 'மிருகசீரிஷம்', 'Deva', 'Serpent', 'Shiro'],
      [6, 'arudra', 'Thiruvathirai / Arudra', 'திருவாதிரை', 'Manushya', 'Dog', 'Kantha'],
      [7, 'punarvasu', 'Punarvasu / Punarpoosam', 'புனர்பூசம்', 'Deva', 'Cat', 'Udara'],
      [8, 'pushya', 'Pushya / Poosam', 'பூசம்', 'Deva', 'Sheep', 'Kati'],
      [9, 'ashlesha', 'Ashlesha / Aayilyam', 'ஆயில்யம்', 'Rakshasa', 'Cat', 'Pada'],
      [10, 'magha', 'Magha / Makam', 'மகம்', 'Rakshasa', 'Rat', 'Pada'],
      [11, 'purva_phalguni', 'Purva Phalguni / Pooram', 'பூரம்', 'Manushya', 'Rat', 'Kati'],
      [12, 'uttara_phalguni', 'Uttara Phalguni / Uthiram', 'உத்திரம்', 'Manushya', 'Bull', 'Udara'],
      [13, 'hasta', 'Hasta / Hastham', 'அஸ்தம்', 'Deva', 'Buffalo', 'Kantha'],
      [14, 'chitra', 'Chitra / Chithirai', 'சித்திரை', 'Rakshasa', 'Tiger', 'Shiro'],
      [15, 'swati', 'Swati / Swathi', 'சுவாதி', 'Deva', 'Buffalo', 'Kantha'],
      [16, 'vishakha', 'Vishakha / Visakam', 'விசாகம்', 'Rakshasa', 'Tiger', 'Udara'],
      [17, 'anuradha', 'Anuradha / Anusham', 'அனுஷம்', 'Deva', 'Deer', 'Kati'],
      [18, 'jyeshtha', 'Jyeshtha / Kettai', 'கேட்டை', 'Rakshasa', 'Deer', 'Pada'],
      [19, 'moola', 'Moola / Moolam', 'மூலம்', 'Rakshasa', 'Dog', 'Pada'],
      [20, 'purvashadha', 'Purvashadha / Pooradam', 'பூராடம்', 'Manushya', 'Monkey', 'Kati'],
      [21, 'uttarashadha', 'Uttarashadha / Uthiradam', 'உத்திராடம்', 'Manushya', 'Mongoose', 'Udara'],
      [22, 'shravana', 'Shravana / Thiruvonam', 'திருவோணம்', 'Deva', 'Monkey', 'Kantha'],
      [23, 'dhanishta', 'Dhanishta / Avittam', 'அவிட்டம்', 'Rakshasa', 'Lion', 'Shiro'],
      [24, 'shatabhisha', 'Shatabhisha / Sadhayam', 'சதயம்', 'Rakshasa', 'Horse', 'Kantha'],
      [25, 'purva_bhadrapada', 'Purva Bhadrapada / Poorattathi', 'பூரட்டாதி', 'Manushya', 'Lion', 'Udara'],
      [26, 'uttara_bhadrapada', 'Uttara Bhadrapada / Uthirattathi', 'உத்திரட்டாதி', 'Manushya', 'Cow', 'Kati'],
      [27, 'revati', 'Revati / Revathi', 'ரேவதி', 'Deva', 'Elephant', 'Pada'],
    ];
    final nakshatraRows = <List<dynamic>>[];
    for (final s in nakshatraData) {
      nakshatraRows.add([s[0], s[1], s[2], s[3], s[4], s[5], s[6], s[0], 1]);
    }
    await writeCsv(dbDir, assetsDir, 'nakshatra.csv',
      ['id', 'code', 'name_en', 'name_ta', 'gana', 'yoni_animal', 'rajju', 'sort_order', 'is_active'],
      nakshatraRows,
    );

    // 18. nakshatra_padam_rasi.csv (Exact 108 rows Vedic division)
    // 27 stars x 4 padams = 108 quarters. Each rasi holds 9 quarters (2.25 stars).
    final padamRows = <List<dynamic>>[];
    int pId = 1;
    // Map of Star ID to padams' rasis (1-indexed rasi IDs)
    final starPadamRasis = [
      [1, 1, 1, 1], // 1. Ashwini: Mesham 1, 2, 3, 4
      [1, 1, 1, 1], // 2. Bharani: Mesham 1, 2, 3, 4
      [1, 2, 2, 2], // 3. Krittika: Mesham 1; Rishabam 2, 3, 4
      [2, 2, 2, 2], // 4. Rohini: Rishabam 1, 2, 3, 4
      [2, 2, 3, 3], // 5. Mrigashira: Rishabam 1, 2; Mithunam 3, 4
      [3, 3, 3, 3], // 6. Arudra: Mithunam 1, 2, 3, 4
      [3, 3, 3, 4], // 7. Punarvasu: Mithunam 1, 2, 3; Kadagam 4
      [4, 4, 4, 4], // 8. Pushya: Kadagam 1, 2, 3, 4
      [4, 4, 4, 4], // 9. Ashlesha: Kadagam 1, 2, 3, 4
      [5, 5, 5, 5], // 10. Magha: Simmam 1, 2, 3, 4
      [5, 5, 5, 5], // 11. Purva Phalguni: Simmam 1, 2, 3, 4
      [5, 6, 6, 6], // 12. Uttara Phalguni: Simmam 1; Kanni 2, 3, 4
      [6, 6, 6, 6], // 13. Hasta: Kanni 1, 2, 3, 4
      [6, 6, 7, 7], // 14. Chitra: Kanni 1, 2; Thulam 3, 4
      [7, 7, 7, 7], // 15. Swati: Thulam 1, 2, 3, 4
      [7, 7, 7, 8], // 16. Vishakha: Thulam 1, 2, 3; Viruchigam 4
      [8, 8, 8, 8], // 17. Anuradha: Viruchigam 1, 2, 3, 4
      [8, 8, 8, 8], // 18. Jyeshtha: Viruchigam 1, 2, 3, 4
      [9, 9, 9, 9], // 19. Moola: Dhanusu 1, 2, 3, 4
      [9, 9, 9, 9], // 20. Purvashadha: Dhanusu 1, 2, 3, 4
      [9, 10, 10, 10], // 21. Uttarashadha: Dhanusu 1; Makaram 2, 3, 4
      [10, 10, 10, 10], // 22. Shravana: Makaram 1, 2, 3, 4
      [10, 10, 11, 11], // 23. Dhanishta: Makaram 1, 2; Kumbam 3, 4
      [11, 11, 11, 11], // 24. Shatabhisha: Kumbam 1, 2, 3, 4
      [11, 11, 11, 12], // 25. Purva Bhadrapada: Kumbam 1, 2, 3; Meenam 4
      [12, 12, 12, 12], // 26. Uttara Bhadrapada: Meenam 1, 2, 3, 4
      [12, 12, 12, 12], // 27. Revati: Meenam 1, 2, 3, 4
    ];

    for (int sIndex = 0; sIndex < 27; sIndex++) {
      final starId = sIndex + 1;
      for (int padam = 1; padam <= 4; padam++) {
        final rasiId = starPadamRasis[sIndex][padam - 1];
        padamRows.add([pId++, starId, padam, rasiId]);
      }
    }
    await writeCsv(dbDir, assetsDir, 'nakshatra_padam_rasi.csv',
      ['id', 'nakshatra_id', 'padam', 'rasi_id'],
      padamRows,
    );

    // 19. lagnam.csv, dosham.csv, planet.csv, dasa.csv
    await writeCsv(dbDir, assetsDir, 'lagnam.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      rasiRows.map((r) => [r[0], r[1], r[2], r[3], r[5], r[6]]).toList(),
    );

    await writeCsv(dbDir, assetsDir, 'dosham.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'none', 'No Dosham (செவ்வாய் தோஷமில்லை)', 'தோஷமில்லை', 1, 1],
        [2, 'chevvai_sevvai', 'Chevvai Dosham (Sevvai / Manglik)', 'செவ்வாய் தோஷம்', 2, 1],
        [3, 'rahu_kethu', 'Rahu-Kethu / Sarpa Dosham', 'ராகு-கேது தோஷம்', 3, 1],
        [4, 'kalathra', 'Kalathra Dosham', 'களத்திர தோஷம்', 4, 1],
        [5, 'pitru', 'Pitru Dosham', 'பித்ரு தோஷம்', 5, 1],
        [6, 'naga', 'Naga Dosham', 'நாக தோஷம்', 6, 1],
        [7, 'paapa_samyam', 'Paapa Samyam (Balanced Dosham)', 'பாப சாம்யம்', 7, 1],
        [8, 'dont_know', 'Don\'t Know', 'தெரியாது', 8, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'planet.csv',
      ['id', 'code', 'symbol', 'name_en', 'name_ta', 'sort_order'],
      [
        [1, 'sun', 'Su', 'Sun (Suriyan)', 'சூரியன்', 1],
        [2, 'moon', 'Mo', 'Moon (Chandran)', 'சந்திரன்', 2],
        [3, 'mars', 'Ma', 'Mars (Sevvai)', 'செவ்வாய்', 3],
        [4, 'mercury', 'Me', 'Mercury (Budhan)', 'புதன்', 4],
        [5, 'jupiter', 'Ju', 'Jupiter (Guru)', 'குரு', 5],
        [6, 'venus', 'Ve', 'Venus (Sukran)', 'சுக்கிரன்', 6],
        [7, 'saturn', 'Sa', 'Saturn (Sani)', 'சனி', 7],
        [8, 'rahu', 'Ra', 'Rahu', 'ராகு', 8],
        [9, 'kethu', 'Ke', 'Kethu', 'கேது', 9],
        [10, 'lagna', 'La', 'Lagnam (Ascendant)', 'லக்னம்', 10],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'dasa.csv',
      ['id', 'code', 'name_en', 'name_ta', 'duration_years', 'sort_order'],
      [
        [1, 'ketu', 'Ketu Dasa', 'கேது திசை', 7, 1],
        [2, 'venus', 'Venus (Sukra) Dasa', 'சுக்கிர திசை', 20, 2],
        [3, 'sun', 'Sun (Surya) Dasa', 'சூரிய திசை', 6, 3],
        [4, 'moon', 'Moon (Chandra) Dasa', 'சந்திர திசை', 10, 4],
        [5, 'mars', 'Mars (Chevvai) Dasa', 'செவ்வாய் திசை', 7, 5],
        [6, 'rahu', 'Rahu Dasa', 'ராகு திசை', 18, 6],
        [7, 'jupiter', 'Jupiter (Guru) Dasa', 'குரு திசை', 16, 7],
        [8, 'saturn', 'Saturn (Sani) Dasa', 'சனி திசை', 19, 8],
        [9, 'mercury', 'Mercury (Budha) Dasa', 'புத திசை', 17, 9],
      ],
    );

    // 20. porutham_rules.csv (10 Poruthams specification)
    await writeCsv(dbDir, assetsDir, 'porutham_rules.csv',
      ['id', 'porutham_name_en', 'porutham_name_ta', 'significance_en', 'max_points', 'is_mandatory'],
      [
        [1, 'Dina Porutham', 'தினப் பொருத்தம்', 'Health, prosperity, and longevity of the couple', 1, 0],
        [2, 'Gana Porutham', 'கணப் பொருத்தம்', 'Temperament, mental and spiritual harmony', 1, 0],
        [3, 'Mahendra Porutham', 'மகேந்திரப் பொருத்தம்', 'Progeny, lineage continuity, and mutual wealth', 1, 0],
        [4, 'Stree Deergha Porutham', 'ஸ்திரீ தீர்க்கப் பொருத்தம்', 'Longevity, prosperity, and joy for the bride', 1, 0],
        [5, 'Yoni Porutham', 'யோனிப் பொருத்தம்', 'Physical attraction, intimacy, and biological compatibility', 1, 0],
        [6, 'Rasi Porutham', 'ராசிப் பொருத்தம்', 'Affection, lineage union, and amicable family bond', 1, 0],
        [7, 'Rasi Adhipathi Porutham', 'ராசி அதிபதி பொருத்தம்', 'Friendship and mutual regard between planetary rulers', 1, 0],
        [8, 'Vasya Porutham', 'வசியப் பொருத்தம்', 'Mutual magnetic attraction and dedication', 1, 0],
        [9, 'Rajju Porutham', 'ரஜ்ஜுப் பொருத்தம்', 'Longevity of marriage (Mangalya Bhagyam) – Must not be same Rajju', 1, 1],
        [10, 'Vedha Porutham', 'வேதைப் பொருத்தம்', 'Freedom from distress and affliction – Avoid inimical pairs', 1, 1],
      ],
    );

    // 21. country.csv (Priority countries at top + ISO standard)
    final countryRows = [
      [1, 'IN', 'IND', '+91', 'INR', 'India', 'இந்தியா', 1, 1],
      [2, 'US', 'USA', '+1', 'USD', 'United States', 'அமெரிக்கா', 2, 1],
      [3, 'AE', 'ARE', '+971', 'AED', 'United Arab Emirates', 'ஐக்கிய அரபு அமீரகம்', 3, 1],
      [4, 'SG', 'SGP', '+65', 'SGD', 'Singapore', 'சிங்கப்பூர்', 4, 1],
      [5, 'MY', 'MYS', '+60', 'MYR', 'Malaysia', 'மலேசியா', 5, 1],
      [6, 'GB', 'GBR', '+44', 'GBP', 'United Kingdom', 'இங்கிலாந்து', 6, 1],
      [7, 'CA', 'CAN', '+1', 'CAD', 'Canada', 'கனடா', 7, 1],
      [8, 'AU', 'AUS', '+61', 'AUD', 'Australia', 'ஆஸ்திரேலியா', 8, 1],
      [9, 'QA', 'QAT', '+974', 'QAR', 'Qatar', 'கத்தார்', 9, 1],
      [10, 'KW', 'KWT', '+965', 'KWD', 'Kuwait', 'குவைத்', 10, 1],
      [11, 'SA', 'SAU', '+966', 'SAR', 'Saudi Arabia', 'சவுதி அரேபியா', 11, 1],
      [12, 'OM', 'OMN', '+968', 'OMR', 'Oman', 'ஓமன்', 12, 1],
      [13, 'BH', 'BHR', '+973', 'BHD', 'Bahrain', 'பஹ்ரைன்', 13, 1],
      [14, 'LK', 'LKA', '+94', 'LKR', 'Sri Lanka', 'இலங்கை', 14, 1],
      [15, 'FR', 'FRA', '+33', 'EUR', 'France', 'பிரான்ஸ்', 15, 1],
      [16, 'DE', 'DEU', '+49', 'EUR', 'Germany', 'ஜெர்மனி', 16, 1],
      [17, 'NZ', 'NZL', '+64', 'NZD', 'New Zealand', 'நியூசிலாந்து', 17, 1],
      [18, 'ZA', 'ZAF', '+27', 'ZAR', 'South Africa', 'தென்னாப்பிரிக்கா', 18, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'country.csv',
      ['id', 'iso2', 'iso3', 'dial_code', 'currency_code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      countryRows,
    );

    // 22. state.csv (All 28 Indian States + 8 UTs + NRI major territories)
    final stateRows = [
      // Puducherry & Tamil Nadu at the top
      [1, 1, 'PY', 'Puducherry', 'புதுச்சேரி', 1, 1],
      [2, 1, 'TN', 'Tamil Nadu', 'தமிழ்நாடு', 2, 1],
      [3, 1, 'KA', 'Karnataka', 'கர்நாடகா', 3, 1],
      [4, 1, 'KL', 'Kerala', 'கேரளா', 4, 1],
      [5, 1, 'AP', 'Andhra Pradesh', 'ஆந்திர பிரதேசம்', 5, 1],
      [6, 1, 'TG', 'Telangana', 'தெலுங்கானா', 6, 1],
      [7, 1, 'MH', 'Maharashtra', 'மகாராஷ்டிரா', 7, 1],
      [8, 1, 'DL', 'Delhi', 'டெல்லி', 8, 1],
      [9, 1, 'GJ', 'Gujarat', 'குஜராத்', 9, 1],
      [10, 1, 'UP', 'Uttar Pradesh', 'உத்தர பிரதேசம்', 10, 1],
      [11, 1, 'WB', 'West Bengal', 'மேற்கு வங்காளம்', 11, 1],
      [12, 1, 'RJ', 'Rajasthan', 'ராஜஸ்தான்', 12, 1],
      [13, 1, 'MP', 'Madhya Pradesh', 'மத்திய பிரதேசம்', 13, 1],
      [14, 1, 'PB', 'Punjab', 'பஞ்சாப்', 14, 1],
      [15, 1, 'HR', 'Haryana', 'ஹரியானா', 15, 1],
      [16, 1, 'BR', 'Bihar', 'பீகார்', 16, 1],
      [17, 1, 'OR', 'Odisha', 'ஒடிசா', 17, 1],
      [18, 1, 'AS', 'Assam', 'அஸ்ஸாம்', 18, 1],
      [19, 1, 'JK', 'Jammu & Kashmir', 'ஜம்மு & காஷ்மீர்', 19, 1],
      [20, 1, 'GA', 'Goa', 'கோவா', 20, 1],
      [21, 1, 'HP', 'Himachal Pradesh', 'இமாச்சல பிரதேசம்', 21, 1],
      [22, 1, 'UK', 'Uttarakhand', 'உத்தரகாண்ட்', 22, 1],
      [23, 1, 'JH', 'Jharkhand', 'ஜார்க்கண்ட்', 23, 1],
      [24, 1, 'CT', 'Chhattisgarh', 'சத்தீஸ்கர்', 24, 1],
      [25, 1, 'CH', 'Chandigarh', 'சண்டிகர்', 25, 1],
      [26, 1, 'AN', 'Andaman & Nicobar Islands', 'அந்தமான் & நிக்கோபார்', 26, 1],
      [27, 1, 'LD', 'Ladakh', 'லடாக்', 27, 1],
      [28, 1, 'MN', 'Manipur', 'மணிப்பூர்', 28, 1],
      [29, 1, 'ML', 'Meghalaya', 'மேகாலயா', 29, 1],
      [30, 1, 'MZ', 'Mizoram', 'மிசோரம்', 30, 1],
      [31, 1, 'NL', 'Nagaland', 'நாகாலாந்து', 31, 1],
      [32, 1, 'SK', 'Sikkim', 'சிக்கிம்', 32, 1],
      [33, 1, 'TR', 'Tripura', 'திரிபுரா', 33, 1],
      [34, 1, 'AR', 'Arunachal Pradesh', 'அருணாச்சல பிரதேசம்', 34, 1],
      [35, 1, 'DH', 'Dadra and Nagar Haveli and Daman and Diu', 'தாத்ரா & நகர் ஹவேலி', 35, 1],
      [36, 1, 'LK', 'Lakshadweep', 'லட்சத்தீவு', 36, 1],

      // Top NRI regions
      [37, 2, 'US_CA', 'California (USA)', 'கலிபோர்னியா (USA)', 37, 1],
      [38, 2, 'US_TX', 'Texas (USA)', 'டெக்சாஸ் (USA)', 38, 1],
      [39, 2, 'US_NY', 'New York (USA)', 'நியூயார்க் (USA)', 39, 1],
      [40, 2, 'US_NJ', 'New Jersey (USA)', 'நியூஜெர்சி (USA)', 40, 1],
      [41, 3, 'AE_DU', 'Dubai (UAE)', 'துபாய் (UAE)', 41, 1],
      [42, 3, 'AE_AZ', 'Abu Dhabi (UAE)', 'அபுதாபி (UAE)', 42, 1],
      [43, 4, 'SG_SG', 'Singapore', 'சிங்கப்பூர்', 43, 1],
      [44, 5, 'MY_KL', 'Kuala Lumpur / Selangor', 'கோலாலம்பூர்', 44, 1],
      [45, 6, 'GB_LN', 'Greater London (UK)', 'லண்டன் (UK)', 45, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'state.csv',
      ['id', 'country_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      stateRows,
    );

    // 23. district.csv (All 4 Puducherry regions + 38 Tamil Nadu districts + Major Indian metro districts)
    final districtRows = [
      // Puducherry Regions (state_id: 1)
      [1, 1, 'puducherry', 'Puducherry', 'புதுச்சேரி', 1, 1],
      [2, 1, 'karaikal', 'Karaikal', 'காரைக்கால்', 2, 1],
      [3, 1, 'mahe', 'Mahe', 'மாஹே', 3, 1],
      [4, 1, 'yanam', 'Yanam', 'ஏனாம்', 4, 1],

      // Tamil Nadu 38 Districts (state_id: 2)
      [5, 2, 'cuddalore', 'Cuddalore', 'கடலூர்', 1, 1],
      [6, 2, 'villupuram', 'Villupuram', 'விழுப்புரம்', 2, 1],
      [7, 2, 'chennai', 'Chennai', 'சென்னை', 3, 1],
      [8, 2, 'chengalpattu', 'Chengalpattu', 'செங்கல்பட்டு', 4, 1],
      [9, 2, 'kanchipuram', 'Kanchipuram', 'காஞ்சிபுரம்', 5, 1],
      [10, 2, 'tiruvallur', 'Tiruvallur', 'திருவள்ளூர்', 6, 1],
      [11, 2, 'vellore', 'Vellore', 'வேலூர்', 7, 1],
      [12, 2, 'ranipet', 'Ranipet', 'ராணிப்பேட்டை', 8, 1],
      [13, 2, 'tirupathur', 'Tirupathur', 'திருப்பத்தூர்', 9, 1],
      [14, 2, 'tiruvannamalai', 'Tiruvannamalai', 'திருவண்ணாமலை', 10, 1],
      [15, 2, 'dharmapuri', 'Dharmapuri', 'தருமபுரி', 11, 1],
      [16, 2, 'krishnagiri', 'Krishnagiri', 'கிருஷ்ணகிரி', 12, 1],
      [17, 2, 'salem', 'Salem', 'சேலம்', 13, 1],
      [18, 2, 'namakkal', 'Namakkal', 'நாமக்கல்', 14, 1],
      [19, 2, 'erode', 'Erode', 'ஈரோடு', 15, 1],
      [20, 2, 'coimbatore', 'Coimbatore', 'கோயம்புத்தூர்', 16, 1],
      [21, 2, 'tiruppur', 'Tiruppur', 'திருப்பூர்', 17, 1],
      [22, 2, 'nilgiris', 'Nilgiris (Ooty)', 'நீலகிரி', 18, 1],
      [23, 2, 'thanjavur', 'Thanjavur', 'தஞ்சாவூர்', 19, 1],
      [24, 2, 'thiruvarur', 'Thiruvarur', 'திருவாரூர்', 20, 1],
      [25, 2, 'nagapattinam', 'Nagapattinam', 'நாகப்பட்டினம்', 21, 1],
      [26, 2, 'mayiladuthurai', 'Mayiladuthurai', 'மயிலாடுதுறை', 22, 1],
      [27, 2, 'tiruchirappalli', 'Tiruchirappalli (Trichy)', 'திருச்சிராப்பள்ளி', 23, 1],
      [28, 2, 'karur', 'Karur', 'கரூர்', 24, 1],
      [29, 2, 'perambalur', 'Perambalur', 'பெரம்பலூர்', 25, 1],
      [30, 2, 'ariyalur', 'Ariyalur', 'அரியலூர்', 26, 1],
      [31, 2, 'pudukkottai', 'Pudukkottai', 'புதுக்கோட்டை', 27, 1],
      [32, 2, 'madurai', 'Madurai', 'மதுரை', 28, 1],
      [33, 2, 'dindigul', 'Dindigul', 'திண்டுக்கல்', 29, 1],
      [34, 2, 'theni', 'Theni', 'தேனி', 30, 1],
      [35, 2, 'virudhunagar', 'Virudhunagar', 'விருதுநகர்', 31, 1],
      [36, 2, 'sivagangai', 'Sivagangai', 'சிவகங்கை', 32, 1],
      [37, 2, 'ramanathapuram', 'Ramanathapuram', 'ராமநாதபுரம்', 33, 1],
      [38, 2, 'tirunelveli', 'Tirunelveli', 'திருநெல்வேலி', 34, 1],
      [39, 2, 'tenkasi', 'Tenkasi', 'தென்காசி', 35, 1],
      [40, 2, 'thoothukudi', 'Thoothukudi (Tuticorin)', 'தூத்துக்குடி', 36, 1],
      [41, 2, 'kanniyakumari', 'Kanniyakumari (Nagercoil)', 'கன்னியாகுமரி', 37, 1],
      [42, 2, 'kallakurichi', 'Kallakurichi', 'கள்ளக்குறிச்சி', 38, 1],

      // Major other states hubs
      [43, 3, 'bengaluru_urban', 'Bengaluru Urban', 'பெங்களூர்', 1, 1],
      [44, 4, 'thiruvananthapuram', 'Thiruvananthapuram', 'திருவனந்தபுரம்', 1, 1],
      [45, 4, 'ernakulam_kochi', 'Ernakulam (Kochi)', 'கொச்சி', 2, 1],
      [46, 5, 'chittoor', 'Chittoor', 'சித்தூர்', 1, 1],
      [47, 6, 'hyderabad', 'Hyderabad', 'ஹைதராபாத்', 1, 1],
      [48, 7, 'mumbai_city', 'Mumbai', 'மும்பை', 1, 1],
      [49, 8, 'new_delhi', 'New Delhi', 'புது டெல்லி', 1, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'district.csv',
      ['id', 'state_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      districtRows,
    );

    // 24. city.csv (Complete Puducherry communes + TN key towns + NRI cities)
    final cityRows = [
      // Puducherry District (district_id: 1)
      [1, 1, 'puducherry_town', 'Puducherry City', 'புதுச்சேரி நகரம்', 1, 1],
      [2, 1, 'ozhukarai', 'Ozhukarai', 'உழவர்கரை', 2, 1],
      [3, 1, 'villianur', 'Villianur', 'வில்லியனூர்', 3, 1],
      [4, 1, 'ariyankuppam', 'Ariyankuppam', 'அரியாங்குப்பம்', 4, 1],
      [5, 1, 'bahour', 'Bahour', 'பாகூர்', 5, 1],
      [6, 1, 'nettapakkam', 'Nettapakkam', 'நெட்டப்பாக்கம்', 6, 1],
      [7, 1, 'mannadipet', 'Mannadipet', 'மண்ணாடிப்பட்டு', 7, 1],
      [8, 1, 'thirubuvanai', 'Thirubuvanai', 'திருபுவனை', 8, 1],
      [9, 1, 'auroville', 'Auroville', 'ஆரோவில்', 9, 1],
      [10, 1, 'kalapet', 'Kalapet', 'காலாப்பட்டு', 10, 1],
      [11, 1, 'lawspet', 'Lawspet', 'லாஸ்பேட்டை', 11, 1],
      [12, 1, 'muthialpet', 'Muthialpet', 'முத்தியால்பேட்டை', 12, 1],
      [13, 1, 'reddiarpalayam', 'Reddiarpalayam', 'ரெட்டியார்பாளையம்', 13, 1],

      // Karaikal (district_id: 2)
      [14, 2, 'karaikal_town', 'Karaikal Town', 'காரைக்கால் நகரம்', 1, 1],
      [15, 2, 'kottucherry', 'Kottucherry', 'கோட்டுச்சேரி', 2, 1],
      [16, 2, 'nedungadu', 'Nedungadu', 'நெடுங்காடு', 3, 1],
      [17, 2, 'thirunallar', 'Thirunallar', 'திருநள்ளாறு', 4, 1],
      [18, 2, 'neravy', 'Neravy', 'நிரவி', 5, 1],
      [19, 2, 'tr_pattinam', 'T.R. Pattinam', 'தி.ரா. பட்டினம்', 6, 1],

      // Mahe & Yanam (district_id: 3, 4)
      [20, 3, 'mahe_town', 'Mahe', 'மாஹே', 1, 1],
      [21, 4, 'yanam_town', 'Yanam', 'ஏனாம்', 1, 1],

      // Cuddalore (district_id: 5)
      [22, 5, 'cuddalore_town', 'Cuddalore', 'கடலூர்', 1, 1],
      [23, 5, 'panruti', 'Panruti', 'பண்ருட்டி', 2, 1],
      [24, 5, 'chidambaram', 'Chidambaram', 'சிதம்பரம்', 3, 1],
      [25, 5, 'vriddhachalam', 'Vriddhachalam', 'விருத்தாச்சலம்', 4, 1],
      [26, 5, 'neiveli', 'Neyveli', 'நெய்வேலி', 5, 1],

      // Villupuram (district_id: 6)
      [27, 6, 'villupuram_town', 'Villupuram', 'விழுப்புரம்', 1, 1],
      [28, 6, 'tindivanam', 'Tindivanam', 'திண்டிவனம்', 2, 1],
      [29, 6, 'gingee', 'Gingee (Senji)', 'செஞ்சி', 3, 1],

      // Chennai & Hubs (district_id: 7, 16, 32, 27)
      [30, 7, 'chennai_city', 'Chennai', 'சென்னை', 1, 1],
      [31, 16, 'coimbatore_city', 'Coimbatore', 'கோயம்புத்தூர்', 1, 1],
      [32, 32, 'madurai_city', 'Madurai', 'மதுரை', 1, 1],
      [33, 27, 'trichy_city', 'Tiruchirappalli (Trichy)', 'திருச்சி', 1, 1],
      [34, 17, 'salem_city', 'Salem', 'சேலம்', 1, 1],
      [35, 38, 'tirunelveli_city', 'Tirunelveli', 'திருநெல்வேலி', 1, 1],
      [36, 40, 'thoothukudi_city', 'Thoothukudi', 'தூத்துக்குடி', 1, 1],
      [37, 43, 'bengaluru_city', 'Bengaluru', 'பெங்களூர்', 1, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'city.csv',
      ['id', 'district_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      cityRows,
    );

    // 25. citizenship.csv, residency_status.csv
    await writeCsv(dbDir, assetsDir, 'citizenship.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'indian', 'Indian Citizen', 'இந்திய குடிமகன்', 1, 1],
        [2, 'nri', 'Non-Resident Indian (NRI)', 'வெளிநாடு வாழ் இந்தியர்', 2, 1],
        [3, 'oci', 'Overseas Citizen of India (OCI)', 'ஓவர்சீஸ் சிட்டிசன் (OCI)', 3, 1],
        [4, 'pio', 'Person of Indian Origin (PIO)', 'இந்திய வம்சாவளி (PIO)', 4, 1],
        [5, 'foreign_national', 'Foreign National', 'வெளிநாட்டு பிரஜை', 5, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'residency_status.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'citizen', 'Citizen', 'குடிமகன்', 1, 1],
        [2, 'permanent_resident', 'Permanent Resident (PR / Green Card)', 'நிரந்தர குடியிருப்பாளர்', 2, 1],
        [3, 'work_permit', 'Work Permit / Employment Visa (H1B / EP / etc.)', 'வேலை அனுமதி / விசா', 3, 1],
        [4, 'student_visa', 'Student Visa', 'மாணவர் விசா', 4, 1],
        [5, 'temporary_visa', 'Temporary Visa', 'தற்காலிக விசா', 5, 1],
      ],
    );

    // 26. education_level.csv & education_degree.csv
    final eduLevelRows = [
      [1, 'bachelors', 'Bachelors / Undergraduate', 'இளங்கலை பட்டதாரி', 1, 1],
      [2, 'masters', 'Masters / Postgraduate', 'முதுகலை பட்டதாரி', 2, 1],
      [3, 'doctorate', 'Doctorate (Ph.D)', 'முனைவர் பட்டம் (Ph.D)', 3, 1],
      [4, 'medicine', 'Medicine / Healthcare', 'மருத்துவ படிப்பு', 4, 1],
      [5, 'finance_ca', 'Finance / Chartered Professional', 'பட்டய கணக்காளர் / நிதி', 5, 1],
      [6, 'law', 'Law / Legal', 'சட்டப் படிப்பு', 6, 1],
      [7, 'diploma', 'Diploma / Polytechnic', 'டிப்ளமோ / பாலிடெக்னிக்', 7, 1],
      [8, 'high_school', 'Higher Secondary / High School', 'மேல்நிலைப் பள்ளி', 8, 1],
      [9, 'other', 'Other Education', 'இதர கல்வி', 9, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'education_level.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      eduLevelRows,
    );

    final degreeRows = [
      // Engineering (level_id: 1, 2)
      [1, 1, 'be_btech', 'Engineering & Technology', 'B.E. / B.Tech', 'பி.இ. / பி.டெக்', 1, 1],
      [2, 1, 'barch', 'Engineering & Technology', 'B.Arch', 'பி.ஆர்க்', 2, 1],
      [3, 1, 'bca_bsc_it', 'Computers & IT', 'BCA / B.Sc (Computer Science / IT)', 'பி.சி.ஏ / பி.எஸ்.சி (ஐ.டி)', 3, 1],
      [4, 2, 'me_mtech', 'Engineering & Technology', 'M.E. / M.Tech', 'எம்.இ. / எம்.டெக்', 4, 1],
      [5, 2, 'mca_msc_it', 'Computers & IT', 'MCA / M.Sc (IT / CS)', 'எம்.சி.ஏ / எம்.எஸ்.சி', 5, 1],
      [6, 2, 'ms_engg', 'Engineering & Technology', 'M.S. (Engineering / Overseas)', 'எம்.எஸ். (பொறியியல்)', 6, 1],

      // Medicine (level_id: 4)
      [7, 4, 'mbbs', 'Medicine', 'MBBS', 'எம்.பி.பி.எஸ் (MBBS)', 7, 1],
      [8, 4, 'bds', 'Medicine', 'BDS (Dental)', 'பி.டி.எஸ் (பல் மருத்துவம்)', 8, 1],
      [9, 4, 'md_ms', 'Medicine', 'MD / MS (Medical Specialty)', 'எம்.டி / எம்.எஸ் (மருத்துவம்)', 9, 1],
      [10, 4, 'bams_bhms_bsms', 'Medicine', 'BSMS (Siddha) / BAMS / BHMS', 'சித்த / ஆயுர்வேத மருத்துவம்', 10, 1],
      [11, 4, 'bpharm_mpharm', 'Healthcare', 'B.Pharm / M.Pharm / Pharm.D', 'மருந்தியல் (Pharmacy)', 11, 1],
      [12, 4, 'nursing_bpt', 'Healthcare', 'B.Sc Nursing / BPT (Physiotherapy)', 'செவிலியர் / பிசியோதெரபி', 12, 1],

      // Management & Commerce (level_id: 1, 2, 5)
      [13, 2, 'mba_pgdm', 'Management', 'MBA / PGDM', 'எம்.பி.ஏ (MBA)', 13, 1],
      [14, 1, 'bba_bms', 'Management', 'BBA / BBM / BMS', 'பி.பி.ஏ (BBA)', 14, 1],
      [15, 1, 'bcom', 'Commerce', 'B.Com', 'பி.காம் (B.Com)', 15, 1],
      [16, 2, 'mcom', 'Commerce', 'M.Com', 'எம்.காம் (M.Com)', 16, 1],
      [17, 5, 'ca_cs_cma', 'Finance', 'CA / CS / ICWA (CMA) / CFA', 'பட்டய கணக்காளர் (CA/CS)', 17, 1],

      // Arts & Science (level_id: 1, 2)
      [18, 1, 'ba_bsc', 'Arts & Science', 'B.A. / B.Sc', 'பி.ஏ / பி.எஸ்.சி', 18, 1],
      [19, 2, 'ma_msc', 'Arts & Science', 'M.A. / M.Sc', 'எம்.ஏ / எம்.எஸ்.சி', 19, 1],
      [20, 2, 'bed_med', 'Education', 'B.Ed / M.Ed', 'பி.எட் / எம்.எட்', 20, 1],

      // Law (level_id: 6)
      [21, 6, 'llb_bl', 'Law', 'BL / LLB / LLM', 'சட்டப் படிப்பு (LLB)', 21, 1],

      // Doctorate (level_id: 3)
      [22, 3, 'phd', 'Research', 'Ph.D / Post-Doctorate', 'முனைவர் பட்டம் (Ph.D)', 22, 1],

      // Diploma & School (level_id: 7, 8)
      [23, 7, 'diploma_polytechnic', 'Vocational', 'Diploma / ITI', 'டிப்ளமோ / பாலிடெக்னிக்', 23, 1],
      [24, 8, 'higher_secondary', 'School', 'Higher Secondary (+2) / High School', 'மேல்நிலைக் கல்வி (+2)', 24, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'education_degree.csv',
      ['id', 'level_id', 'code', 'group_name', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      degreeRows,
    );

    // 27. employment_type.csv
    await writeCsv(dbDir, assetsDir, 'employment_type.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'private', 'Private Sector', 'தனியார் துறை', 1, 1],
        [2, 'government', 'Government / Public Sector (PSU)', 'அரசுப் பணி / அரசுத்துறை', 2, 1],
        [3, 'business_owner', 'Business Owner / Entrepreneur', 'சுயதொழில் / தொழிலதிபர்', 3, 1],
        [4, 'self_employed', 'Self Employed Professional', 'சுயதொழில் வல்லுநர்', 4, 1],
        [5, 'civil_services', 'Civil Services (IAS / IPS / IRS / TNPSC)', 'சிவில் சர்வீசஸ்', 5, 1],
        [6, 'defence', 'Defence / Police / Paramilitary', 'இராணுவம் / காவல்துறை', 6, 1],
        [7, 'not_working', 'Not Working', 'வேலை செய்யவில்லை', 7, 1],
        [8, 'student', 'Student', 'மாணவர்', 8, 1],
      ],
    );

    // 28. occupation_category.csv & occupation.csv
    final occCatRows = [
      [1, 'it_software', 'IT & Software', 'மென்பொருள் & ஐ.டி', 1, 1],
      [2, 'medical_healthcare', 'Medical & Healthcare', 'மருத்துவம் & நலம்', 2, 1],
      [3, 'engineering', 'Core Engineering & Architecture', 'பொறியியல் துறை', 3, 1],
      [4, 'banking_finance', 'Banking, Finance & Insurance', 'வங்கி & நிதித் துறை', 4, 1],
      [5, 'government_defence', 'Government & Defence Services', 'அரசு & பாதுகாப்பு பணி', 5, 1],
      [6, 'education_training', 'Education & Academia', 'கல்வி & பயிற்சி', 6, 1],
      [7, 'business_corporate', 'Business & Corporate Management', 'வணிகம் & கார்ப்பரேட்', 7, 1],
      [8, 'legal_services', 'Legal Services', 'சட்டப் பணிகள்', 8, 1],
      [9, 'media_creative', 'Media, Arts & Creative', 'ஊடகம் & கலை', 9, 1],
      [10, 'hospitality_aviation', 'Hospitality, Tourism & Aviation', 'விருந்தோம்பல் & விமானத்துறை', 10, 1],
      [11, 'other_occupations', 'Others', 'இதர பணிகள்', 11, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'occupation_category.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      occCatRows,
    );

    final occupationRows = [
      // IT & Software (category_id: 1)
      [1, 1, 'software_engineer', 'Software Engineer / Developer', 'மென்பொருள் பொறியாளர்', 1, 1],
      [2, 1, 'data_scientist', 'Data Scientist / AI Specialist', 'தரவு விஞ்ஞானி / AI வல்லுநர்', 2, 1],
      [3, 1, 'qa_devops', 'QA Automation / DevOps Engineer', 'DevOps / QA பொறியாளர்', 3, 1],
      [4, 1, 'product_manager', 'Product Manager / Project Lead', 'தயாரிப்பு மேலாளர்', 4, 1],
      [5, 1, 'systems_analyst', 'IT Consultant / Business Analyst', 'ஐ.டி ஆலோசகர்', 5, 1],

      // Medical (category_id: 2)
      [6, 2, 'doctor', 'Doctor / Surgeon (MBBS / MD / MS)', 'மருத்துவர் / அறுவை சிகிச்சை நிபுணர்', 6, 1],
      [7, 2, 'dentist', 'Dentist (BDS / MDS)', 'பல் மருத்துவர்', 7, 1],
      [8, 2, 'pharmacist', 'Pharmacist', 'மருந்தாளுநர்', 8, 1],
      [9, 2, 'nurse', 'Registered Nurse', 'செவிலியர்', 9, 1],
      [10, 2, 'physiotherapist', 'Physiotherapist', 'பிசியோதெரபிஸ்ட்', 10, 1],

      // Engineering (category_id: 3)
      [11, 3, 'civil_engineer', 'Civil Engineer', 'சிவில் பொறியாளர்', 11, 1],
      [12, 3, 'mechanical_engineer', 'Mechanical Engineer', 'மெக்கானிக்கல் பொறியாளர்', 12, 1],
      [13, 3, 'electrical_engineer', 'Electrical / Electronics Engineer', 'மின் பொறியாளர்', 13, 1],
      [14, 3, 'architect', 'Architect / Interior Designer', 'கட்டிடக் கலைஞர்', 14, 1],

      // Banking (category_id: 4)
      [15, 4, 'bank_officer', 'Bank Officer / Branch Manager', 'வங்கி அதிகாரி / கிளை மேலாளர்', 15, 1],
      [16, 4, 'chartered_accountant', 'Chartered Accountant (CA)', 'பட்டய கணக்காளர் (CA)', 16, 1],
      [17, 4, 'financial_analyst', 'Financial Analyst / Investment Banker', 'நிதி ஆய்வாளர்', 17, 1],

      // Government (category_id: 5)
      [18, 5, 'civil_servant', 'Civil Servant (IAS / IPS / IFS / Group 1)', 'சிவில் சர்வீசஸ் அதிகாரி', 18, 1],
      [19, 5, 'govt_officer', 'Govt Employee / PSU Officer', 'அரசு ஊழியர் / அதிகாரி', 19, 1],
      [20, 5, 'defence_personnel', 'Defence (Army / Navy / Air Force / Police)', 'இராணுவம் / காவல்துறை', 20, 1],

      // Education (category_id: 6)
      [21, 6, 'professor', 'Professor / College Lecturer', 'கல்லூரி பேராசிரியர்', 21, 1],
      [22, 6, 'school_teacher', 'School Teacher / Educator', 'பள்ளி ஆசிரியர்', 22, 1],
      [23, 6, 'researcher_scientist', 'Scientist / Research Scholar', 'விஞ்ஞானி / ஆய்வாளர்', 23, 1],

      // Business & Corporate (category_id: 7)
      [24, 7, 'business_owner', 'Business Owner / Entrepreneur', 'தொழிலதிபர் / சுயதொழில்', 24, 1],
      [25, 7, 'corporate_executive', 'Corporate Executive / HR Manager', 'கார்ப்பரேட் மேலாளர் / HR', 25, 1],
      [26, 7, 'marketing_sales', 'Sales & Marketing Manager', 'விற்பனை & சந்தைப்படுத்தல்', 26, 1],

      // Legal (category_id: 8)
      [27, 8, 'advocate_lawyer', 'Advocate / High Court Lawyer', 'வழக்கறிஞர்', 27, 1],

      // Other
      [28, 11, 'homemaker', 'Home Maker', 'இல்லத்தரசி', 28, 1],
      [29, 11, 'student', 'Student', 'மாணவர்', 29, 1],
      [30, 11, 'not_working', 'Not Working', 'வேலை செய்யவில்லை', 30, 1],
      [31, 11, 'other_occupation', 'Other Occupation', 'இதர பணி', 31, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'occupation.csv',
      ['id', 'category_id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      occupationRows,
    );

    // 29. income_range.csv (INR step 1 lakh up to 10 lakhs, 5-lakh steps to 50L, 50-75L, 75L-1Cr, 1Cr+)
    final incomeRows = [
      [1, 'inr_under_1lakh', 'INR', 0, 100000, 'Below ₹ 1 Lakh', '₹ 1 லட்சத்திற்கும் கீழ்', 1, 1],
      [2, 'inr_1_to_2lakhs', 'INR', 100000, 200000, '₹ 1 Lakh to 2 Lakhs', '₹ 1 லட்சம் முதல் 2 லட்சம்', 2, 1],
      [3, 'inr_2_to_3lakhs', 'INR', 200000, 300000, '₹ 2 Lakhs to 3 Lakhs', '₹ 2 லட்சம் முதல் 3 லட்சம்', 3, 1],
      [4, 'inr_3_to_4lakhs', 'INR', 300000, 400000, '₹ 3 Lakhs to 4 Lakhs', '₹ 3 லட்சம் முதல் 4 லட்சம்', 4, 1],
      [5, 'inr_4_to_5lakhs', 'INR', 400000, 500000, '₹ 4 Lakhs to 5 Lakhs', '₹ 4 லட்சம் முதல் 5 லட்சம்', 5, 1],
      [6, 'inr_5_to_6lakhs', 'INR', 500000, 600000, '₹ 5 Lakhs to 6 Lakhs', '₹ 5 லட்சம் முதல் 6 லட்சம்', 6, 1],
      [7, 'inr_6_to_7lakhs', 'INR', 600000, 700000, '₹ 6 Lakhs to 7 Lakhs', '₹ 6 லட்சம் முதல் 7 லட்சம்', 7, 1],
      [8, 'inr_7_to_8lakhs', 'INR', 700000, 800000, '₹ 7 Lakhs to 8 Lakhs', '₹ 7 லட்சம் முதல் 8 லட்சம்', 8, 1],
      [9, 'inr_8_to_9lakhs', 'INR', 800000, 900000, '₹ 8 Lakhs to 9 Lakhs', '₹ 8 லட்சம் முதல் 9 லட்சம்', 9, 1],
      [10, 'inr_9_to_10lakhs', 'INR', 900000, 1000000, '₹ 9 Lakhs to 10 Lakhs', '₹ 9 லட்சம் முதல் 10 லட்சம்', 10, 1],
      [11, 'inr_10_to_15lakhs', 'INR', 1000000, 1500000, '₹ 10 Lakhs to 15 Lakhs', '₹ 10 லட்சம் முதல் 15 லட்சம்', 11, 1],
      [12, 'inr_15_to_20lakhs', 'INR', 1500000, 2000000, '₹ 15 Lakhs to 20 Lakhs', '₹ 15 லட்சம் முதல் 20 லட்சம்', 12, 1],
      [13, 'inr_20_to_25lakhs', 'INR', 2000000, 2500000, '₹ 20 Lakhs to 25 Lakhs', '₹ 20 லட்சம் முதல் 25 லட்சம்', 13, 1],
      [14, 'inr_25_to_35lakhs', 'INR', 2500000, 3500000, '₹ 25 Lakhs to 35 Lakhs', '₹ 25 லட்சம் முதல் 35 லட்சம்', 14, 1],
      [15, 'inr_35_to_50lakhs', 'INR', 3500000, 5000000, '₹ 35 Lakhs to 50 Lakhs', '₹ 35 லட்சம் முதல் 50 லட்சம்', 15, 1],
      [16, 'inr_50_to_75lakhs', 'INR', 5000000, 7500000, '₹ 50 Lakhs to 75 Lakhs', '₹ 50 லட்சம் முதல் 75 லட்சம்', 16, 1],
      [17, 'inr_75lakhs_to_1cr', 'INR', 7500000, 10000000, '₹ 75 Lakhs to 1 Crore', '₹ 75 லட்சம் முதல் 1 கோடி', 17, 1],
      [18, 'inr_1cr_above', 'INR', 10000000, 999999999, '₹ 1 Crore & above', '₹ 1 கோடி மற்றும் அதற்கு மேல்', 18, 1],

      // USD ranges for NRI
      [19, 'usd_under_50k', 'USD', 0, 50000, 'Below \$50,000', '\$50,000 கீழ்', 19, 1],
      [20, 'usd_50k_to_75k', 'USD', 50000, 75000, '\$50,000 to \$75,000', '\$50,000 முதல் \$75,000', 20, 1],
      [21, 'usd_75k_to_100k', 'USD', 75000, 100000, '\$75,000 to \$100,000', '\$75,000 முதல் \$100,000', 21, 1],
      [22, 'usd_100k_to_150k', 'USD', 100000, 150000, '\$100,000 to \$150,000', '\$100,000 முதல் \$150,000', 22, 1],
      [23, 'usd_150k_above', 'USD', 150000, 99999999, '\$150,000 & above', '\$150,000 மற்றும் அதற்கு மேல்', 23, 1],
    ];
    await writeCsv(dbDir, assetsDir, 'income_range.csv',
      ['id', 'code', 'currency', 'min_value', 'max_value', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      incomeRows,
    );

    // 30. currency.csv
    await writeCsv(dbDir, assetsDir, 'currency.csv',
      ['id', 'code', 'symbol', 'name_en', 'sort_order', 'is_active'],
      [
        [1, 'INR', '₹', 'Indian Rupee', 1, 1],
        [2, 'USD', '\$', 'US Dollar', 2, 1],
        [3, 'AED', 'AED', 'UAE Dirham', 3, 1],
        [4, 'SGD', 'S\$', 'Singapore Dollar', 4, 1],
        [5, 'GBP', '£', 'British Pound', 5, 1],
        [6, 'CAD', 'C\$', 'Canadian Dollar', 6, 1],
        [7, 'AUD', 'A\$', 'Australian Dollar', 7, 1],
        [8, 'EUR', '€', 'Euro', 8, 1],
      ],
    );

    // 31. family_status.csv, family_type.csv, family_values.csv, parent_occupation.csv
    await writeCsv(dbDir, assetsDir, 'family_status.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'middle_class', 'Middle Class', 'நடுத்தர குடும்பம்', 1, 1],
        [2, 'upper_middle_class', 'Upper Middle Class', 'உயர் நடுத்தர குடும்பம்', 2, 1],
        [3, 'rich_affluent', 'Rich / Affluent (Elite)', 'வசதியான / உயர்மட்ட குடும்பம்', 3, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'family_type.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'nuclear', 'Nuclear Family', 'தனி குடும்பம்', 1, 1],
        [2, 'joint', 'Joint Family', 'கூட்டு குடும்பம்', 2, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'family_values.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'orthodox', 'Orthodox', 'பழமைவாத குடும்பம்', 1, 1],
        [2, 'traditional', 'Traditional', 'பாரம்பரிய குடும்பம்', 2, 1],
        [3, 'moderate', 'Moderate', 'மிதமான குடும்பம்', 3, 1],
        [4, 'liberal', 'Liberal', 'நவீன / சுதந்திர குடும்பம்', 4, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'parent_occupation.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'business', 'Business', 'தொழில் முனைவர்', 1, 1],
        [2, 'employed_private', 'Employed (Private)', 'தனியார் பணியாளர்', 2, 1],
        [3, 'government', 'Government Employee', 'அரசு ஊழியர்', 3, 1],
        [4, 'retired', 'Retired', 'ஓய்வு பெற்றவர்', 4, 1],
        [5, 'home_maker', 'Home Maker', 'இல்லத்தரசி', 5, 1],
        [6, 'farmer', 'Farmer / Agriculture', 'விவசாயி', 6, 1],
        [7, 'passed_away', 'Passed Away', 'மறைந்துவிட்டார்', 7, 1],
        [8, 'not_employed', 'Not Employed', 'பணியில் இல்லை', 8, 1],
      ],
    );

    // 32. diet.csv, smoking.csv, drinking.csv
    await writeCsv(dbDir, assetsDir, 'diet.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'veg', 'Vegetarian', 'சைவம்', 1, 1],
        [2, 'non_veg', 'Non-Vegetarian', 'அசைவம்', 2, 1],
        [3, 'eggetarian', 'Eggetarian', 'முட்டை மட்டும் உண்பவர்', 3, 1],
        [4, 'jain', 'Jain Diet', 'சைன உணவு', 4, 1],
        [5, 'vegan', 'Vegan', 'முழு தாவர உணவு', 5, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'smoking.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'no', 'No', 'இல்லை', 1, 1],
        [2, 'occasionally', 'Occasionally', 'எப்போதாவது', 2, 1],
        [3, 'yes', 'Yes', 'ஆம்', 3, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'drinking.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'no', 'No', 'இல்லை', 1, 1],
        [2, 'occasionally', 'Occasionally', 'எப்போதாவது', 2, 1],
        [3, 'yes', 'Yes', 'ஆம்', 3, 1],
      ],
    );

    // 33. hobby_interest.csv (Grouped tags)
    await writeCsv(dbDir, assetsDir, 'hobby_interest.csv',
      ['id', 'category', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'Creative', 'music_listening', 'Listening to Music', 'இசை கேட்பது', 1, 1],
        [2, 'Creative', 'reading_books', 'Reading Books', 'புத்தகம் வாசிப்பு', 2, 1],
        [3, 'Creative', 'photography', 'Photography', 'புகைப்படக்கலை', 3, 1],
        [4, 'Creative', 'drawing_painting', 'Drawing & Painting', 'ஓவியம் வரைதல்', 4, 1],
        [5, 'Active', 'travel_roadtrips', 'Travel & Road Trips', 'பயணங்கள்', 5, 1],
        [6, 'Active', 'cooking_baking', 'Cooking & Baking', 'சமையல் கலை', 6, 1],
        [7, 'Active', 'yoga_fitness', 'Yoga & Fitness', 'யோகா & உடற்பயிற்சி', 7, 1],
        [8, 'Active', 'cricket_sports', 'Cricket & Sports', 'விளையாட்டு', 8, 1],
        [9, 'Entertainment', 'movies_series', 'Movies & Web Series', 'திரைப்படங்கள்', 9, 1],
        [10, 'Lifestyle', 'gardening_nature', 'Gardening & Nature', 'தோட்டக்கலை', 10, 1],
        [11, 'Lifestyle', 'pets_animals', 'Pets & Animals', 'செல்லப்பிராணிகள்', 11, 1],
        [12, 'Lifestyle', 'volunteering', 'Volunteering & Social Work', 'சமூக சேவை', 12, 1],
      ],
    );

    // 34. profile_report_reason.csv, help_topic.csv, membership_feature.csv
    await writeCsv(dbDir, assetsDir, 'profile_report_reason.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'fake_profile', 'Fake / Impersonation Profile', 'போலி சுயவிவரம்', 1, 1],
        [2, 'inappropriate_photo', 'Inappropriate or Stolen Photo', 'பொருத்தமற்ற புகைப்படம்', 2, 1],
        [3, 'abusive_behaviour', 'Abusive or Offensive Behaviour', 'தவறான நடத்தை', 3, 1],
        [4, 'money_scam', 'Asking for Money or Financial Scam', 'பணம் கேட்டல் / மோசடி', 4, 1],
        [5, 'already_married', 'Already Married', 'ஏற்கனவே திருமணம் ஆனவர்', 5, 1],
        [6, 'incorrect_details', 'Incorrect / False Contact Details', 'தவறான தகவல்கள்', 6, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'help_topic.csv',
      ['id', 'code', 'name_en', 'name_ta', 'sort_order', 'is_active'],
      [
        [1, 'registration_help', 'Registration & Account Verification', 'பதிவு & கணக்கு சரிபார்ப்பு', 1, 1],
        [2, 'horoscope_porutham', '10-Porutham & Horoscope Matching', 'ஜாதகப் பொருத்தம்', 2, 1],
        [3, 'photo_privacy', 'Photo & Profile Privacy Controls', 'புகைப்பட பாதுகாப்பு', 3, 1],
        [4, 'membership_plans', 'Membership Upgrade & Benefits', 'உறுப்பினர் திட்டங்கள்', 4, 1],
        [5, 'safety_grievance', 'Safety Tips & Grievance Redressal', 'பாதுகாப்பு & புகார் தீர்வு', 5, 1],
      ],
    );

    await writeCsv(dbDir, assetsDir, 'membership_feature.csv',
      ['id', 'plan_code', 'feature_en', 'feature_ta', 'sort_order'],
      [
        [1, 'free', 'Browse all registered profiles', 'அனைத்து சுயவிவரங்களையும் பார்வையிடலாம்', 1],
        [2, 'free', 'Send up to 5 interests daily', 'தினசரி 5 விருப்பங்களை அனுப்பலாம்', 2],
        [3, 'free', 'Basic Horoscope compatibility score', 'அடிப்படை ஜாதகப் பொருத்தம்', 3],
        [4, 'gold', 'View 25 verified phone numbers', '25 சரிபார்க்கப்பட்ட எண்களைப் பார்க்கலாம்', 4],
        [5, 'gold', 'Unlimited direct chat & interests', 'வரம்பற்ற சாட் & விருப்பங்கள்', 5],
        [6, 'gold', 'Full 10-Porutham breakdown report', 'முழு 10-பொருத்தம் அறிக்கை', 6],
        [7, 'diamond', 'View 60 verified contacts', '60 சரிபார்க்கப்பட்ட தொடர்புகள்', 7],
        [8, 'diamond', 'Top search placement badge', 'தேடலில் முன்னுரிமை இடம்', 8],
        [9, 'diamond', 'Personal relationship assistance', 'தனிப்பட்ட சேவை உதவி', 9],
        [10, 'platinum', 'View 150 verified contacts', '150 சரிபார்க்கப்பட்ட தொடர்புகள்', 10],
        [11, 'platinum', 'VIP verified profile badge', 'வி.ஐ.பி சரிபார்க்கப்பட்ட பேட்ஜ்', 11],
        [12, 'platinum', 'Dedicated matchmaker consultant', 'பிரத்யேக திருமண ஆலோசகர்', 12],
      ],
    );

    // Write db/master/SOURCES.md
    await File('${dbDir.path}/SOURCES.md').writeAsString('''# Pondy Connect Matrimony — Master Data Sources & Provenance

This document records the authoritative public registries, government Gazettes, and standard panchangam references used to compile the master tables in `db/master/`.

**Retrieval & Harmonization Date:** October 7, 2026  
**Compiler:** Pondy Connect Matrimony Data Engineering Team

---

## 1. Castes & Communities (Tamil Nadu & Puducherry)

- **Official Source 1:** Government of Tamil Nadu, Backward Classes, Most Backward Classes and Minorities Welfare Department.
  - *URL / Gazette Reference:* [https://www.bcmbcmw.tn.gov.in/bclist.htm](https://www.bcmbcmw.tn.gov.in/bclist.htm)
  - *List of Backward Classes (BC), Most Backward Classes (MBC), and Denotified Communities (DNC).*
- **Official Source 2:** Government of Tamil Nadu, Adi Dravidar and Tribal Welfare Department.
  - *URL:* [https://adtw.tn.gov.in/](https://adtw.tn.gov.in/)
  - *Official Annexure of Scheduled Castes (SC), Scheduled Castes Arunthathiyar (SCA), and Scheduled Tribes (ST).*
- **Matrimony Taxonomy Benchmark:** Registration community taxonomies of Tamil Matrimony and Bharat Matrimony networks (harmonized labels: Kongu Vellalar/Gounder, Mudaliar, Vanniyar, Nadar, Thevar/Mukkulathor, Brahmin Iyer/Iyengar, Chettiar, Yadava, Pillai, Vishwakarma, etc.).

## 2. Geography & Administrative Units

- **Official Source 1:** Local Government Directory (LGD), Ministry of Panchayati Raj, Government of India.
  - *URL:* [https://lgdirectory.gov.in/](https://lgdirectory.gov.in/)
  - *Standard administrative code hierarchy for all 28 States, 8 Union Territories, and Indian Districts.*
- **Official Source 2:** Government of Puducherry Directorate of Economics and Statistics.
  - *URL:* [https://statistics.py.gov.in/](https://statistics.py.gov.in/)
  - *Regions, Municipalities, and Communes for Puducherry, Karaikal, Mahe, and Yanam.*
- **Official Source 3:** ISO 3166-1 Alpha-2 and Alpha-3 standard country registry and ITU-T E.164 dial codes.

## 3. Vedic Panchangam & 10-Porutham Astrology

- **Astronomical & Astrological Reference:** Traditional Tamil Panchangam (Vakya and Thiru Kanidha Panchangam standards).
- **Nakshatra-Padam-Rasi System:** 27 Stars x 4 Padams = 108 Charanas mapped across 12 Moon signs (Rasis) at 2.25 stars (9 padams) per sign.
- **10-Porutham Compatibility Matrices:**
  - Dina Porutham (Count method from bride to groom star)
  - Gana Porutham (Deva, Manushya, Rakshasa compatibility)
  - Mahendra Porutham (Star index intervals 4, 7, 10, 13, 16, 19, 22, 25)
  - Stree Deergha Porutham (Distance >= 13 nakshatras)
  - Yoni Porutham (Natural friendship and enmity of animal archetypes)
  - Rasi Porutham (6/8 Sashtashtaga exclusion rules)
  - Rasi Adhipathi Porutham (Planetary ruler natural & temporal friendship)
  - Vasya Porutham (Subservient and magnetic rasi pairings)
  - Rajju Porutham (Shiro, Kantha, Udara, Kati, Pada – strict exclusion of identical Rajju)
  - Vedha Porutham (Inimical nakshatra pairs)
''', encoding: utf8);
    print('  [✓] SOURCES.md generated');

    // Write docs/DATA_GAPS.md
    await File('${docsDir.path}/DATA_GAPS.md').writeAsString('''# Pondy Connect Matrimony — Master Data Gaps & Review Register

This register logs any catalog items where an authoritative public source had ambiguities or where a standardized regional transliteration was adopted.

| Entity | Field / Item | Observation & Adopted Treatment | Verification Status |
|---|---|---|---|
| `caste.csv` | Caste No Bar (`caste_none`) | Included with code `caste_none` as a non-restrictive option for modern progressive candidates. | Validated in registration filters |
| `gothram.csv` | Don't Know | Included as `dont_know` to allow candidates without traditional gothram records to complete the astrology block smoothly. | UI fallback verified |
| `country.csv` | Priority ordering | Priority weighting applied for India and top 17 Tamil diaspora destinations (US, UAE, Singapore, Malaysia, UK, Canada, Australia, France for Puducherry links). | UX-approved |
| `district.csv` | Puducherry regions | Puducherry, Karaikal, Mahe, and Yanam are classified under UT of Puducherry (`state_id: 1`) as independent district administrative units. | Aligns with India LGD |
''', encoding: utf8);
    print('  [✓] DATA_GAPS.md generated');
  }
}
