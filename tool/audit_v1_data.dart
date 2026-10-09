// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('==============================================');
  print('V1 CSV DATA AUDIT');
  print('==============================================');

  final masterDir = Directory('assets/csv/master');
  final seedDir = Directory('assets/csv/seed');

  print('\n--- 1. MASTER CSV AUDIT ---');
  if (await masterDir.exists()) {
    final files = masterDir.listSync().whereType<File>().where((f) => f.path.endsWith('.csv')).toList();
    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      final rawContent = await file.readAsString(encoding: utf8);
      final content = rawContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(content);
      if (rows.isEmpty) {
        print('$filename: EMPTY FILE');
        continue;
      }
      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final dataRows = rows.skip(1).toList();

      int exactDuplicates = 0;
      final seenRows = <String>{};
      final seenCodes = <String>{};
      int duplicateCodes = 0;
      int trailingSpaceIssues = 0;
      int tamilEncodingIssues = 0;

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;
        final rowStr = row.map((e) => e.toString().trim()).join('||');
        if (seenRows.contains(rowStr)) {
          exactDuplicates++;
        } else {
          seenRows.add(rowStr);
        }

        final code = row.isNotEmpty ? row.first.toString().trim() : '';
        if (seenCodes.contains(code)) {
          duplicateCodes++;
        } else {
          seenCodes.add(code);
        }

        for (final cell in row) {
          final s = cell.toString();
          if (s != s.trim()) trailingSpaceIssues++;
          // check tamil text
          if (s.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
            // Tamil text present; check if valid utf8 or replacement chars
            if (s.contains('\uFFFD') || s.contains('?')) {
              tamilEncodingIssues++;
            }
          }
        }
      }

      print('[$filename] Rows: ${dataRows.length}, Headers: $headers, Exact Dupes: $exactDuplicates, Code Dupes: $duplicateCodes, Trailing Sp: $trailingSpaceIssues, Tamil Issues: $tamilEncodingIssues');
    }
  }

  print('\n--- 2. SEED CSV AUDIT ---');
  if (await seedDir.exists()) {
    final files = seedDir.listSync().whereType<File>().where((f) => f.path.endsWith('.csv')).toList();
    final tableData = <String, List<Map<String, String>>>{};

    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      final tableName = filename.replaceAll('.csv', '');
      final rawContent = await file.readAsString(encoding: utf8);
      final content = rawContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(content);
      if (rows.isEmpty) {
        print('$filename: EMPTY');
        continue;
      }
      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final dataRows = rows.skip(1).toList();

      final list = <Map<String, String>>[];
      int exactDuplicates = 0;
      final seenRows = <String>{};
      int trailingSpaces = 0;
      int demoCount = 0;

      for (final row in dataRows) {
        if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;
        final rowStr = row.map((e) => e.toString().trim()).join('||');
        if (seenRows.contains(rowStr)) {
          exactDuplicates++;
        } else {
          seenRows.add(rowStr);
        }

        final map = <String, String>{};
        for (int i = 0; i < headers.length; i++) {
          final val = i < row.length ? row[i].toString() : '';
          if (val != val.trim()) trailingSpaces++;
          map[headers[i]] = val.trim();
        }
        if (map['is_demo'] == 'true' || map['is_demo'] == '1') {
          demoCount++;
        }
        list.add(map);
      }
      tableData[tableName] = list;

      print('[$filename] Rows: ${list.length}, Exact Dupes: $exactDuplicates, is_demo count: $demoCount, Trailing Spaces: $trailingSpaces');
    }

    // Foreign Key and Consistency Checks
    print('\n--- 3. REFERENTIAL INTEGRITY & DATA QUALITY ---');
    final users = tableData['users'] ?? [];
    final profiles = tableData['profiles'] ?? [];
    final partnerPrefs = tableData['partner_prefs'] ?? [];
    final photos = tableData['photos'] ?? [];

    final userIds = users.map((u) => u['user_id']!).toSet();
    final profileIds = profiles.map((p) => p['profile_id']!).toSet();

    // Check profiles -> users FK
    int orphanProfiles = 0;
    for (final p in profiles) {
      if (!userIds.contains(p['user_id'])) {
        orphanProfiles++;
      }
    }
    print('Orphan profiles (missing user_id): $orphanProfiles');

    // Check partner_prefs -> profiles FK
    int orphanPrefs = 0;
    for (final pref in partnerPrefs) {
      if (!profileIds.contains(pref['profile_id'])) {
        orphanPrefs++;
      }
    }
    print('Orphan partner_prefs (missing profile_id): $orphanPrefs');

    // Check photos -> profiles FK
    int orphanPhotos = 0;
    for (final ph in photos) {
      if (!profileIds.contains(ph['profile_id'])) {
        orphanPhotos++;
      }
    }
    print('Orphan photos (missing profile_id): $orphanPhotos');

    // Check Near-duplicates in Profiles (normalised name + dob + gender)
    final nearDupeMap = <String, List<String>>{};
    for (final p in profiles) {
      final key = '${p['name']?.toLowerCase().replaceAll(' ', '')}_${p['dob']}_${p['gender']}';
      nearDupeMap.putIfAbsent(key, () => []).add(p['profile_id']!);
    }
    int nearDupeGroups = 0;
    int nearDupeProfiles = 0;
    nearDupeMap.forEach((k, v) {
      if (v.length > 1) {
        nearDupeGroups++;
        nearDupeProfiles += v.length;
      }
    });
    print('Near-duplicate profile clusters: $nearDupeGroups (affecting $nearDupeProfiles profiles)');

    // Check Date format consistency in profiles (dob)
    int invalidDobs = 0;
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    for (final p in profiles) {
      final dob = p['dob'] ?? '';
      if (dob.isNotEmpty && !dateRegex.hasMatch(dob)) {
        invalidDobs++;
      }
    }
    print('Invalid DOB formats (expected YYYY-MM-DD): $invalidDobs');

    // Check Empty Required columns in profiles
    int emptyNames = profiles.where((p) => (p['name'] ?? '').isEmpty).length;
    int emptyGenders = profiles.where((p) => (p['gender'] ?? '').isEmpty).length;
    int emptyReligions = profiles.where((p) => (p['religion'] ?? '').isEmpty).length;
    int emptyDistricts = profiles.where((p) => (p['district'] ?? '').isEmpty).length;
    print('Empty required fields - Name: $emptyNames, Gender: $emptyGenders, Religion: $emptyReligions, District: $emptyDistricts');

    // Case difference check in enums
    final religionValues = profiles.map((p) => p['religion'] ?? '').toSet();
    print('Distinct religion values in profiles: $religionValues');
    final casteValues = profiles.map((p) => p['caste'] ?? '').toSet();
    print('Distinct caste values count in profiles: ${casteValues.length}');
  }
}
