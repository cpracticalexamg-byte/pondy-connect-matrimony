// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('==============================================');
  print('MIGRATING DATABASE V2 -> V3');
  print('==============================================');

  final manifestFile = File('db/schema/tables.manifest.json');
  if (!await manifestFile.exists()) {
    print('Error: db/schema/tables.manifest.json not found!');
    exit(1);
  }

  final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final tables = manifest['tables'] as Map<String, dynamic>;

  final dataDir = Directory('db/data');
  final seedDir = Directory('assets/csv/seed');

  if (!await dataDir.exists()) await dataDir.create(recursive: true);
  if (!await seedDir.exists()) await seedDir.create(recursive: true);

  for (final entry in tables.entries) {
    final tableName = entry.key;
    final spec = entry.value as Map<String, dynamic>;
    final expectedCols = List<String>.from(spec['columns']);

    for (final dir in [dataDir, seedDir]) {
      final file = File('${dir.path}/$tableName.csv');
      if (!await file.exists()) {
        // Table doesn't exist, create it with header line
        final headerLine = expectedCols.join(',');
        await file.writeAsString('$headerLine\n', encoding: utf8, flush: true);
        print('  [+] Created new table $tableName.csv in ${dir.path}');
      } else {
        // Table exists, check if headers need alignment
        final content = await file.readAsString(encoding: utf8);
        final rawRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(content.replaceAll('\r\n', '\n'));

        if (rawRows.isEmpty) {
          final headerLine = expectedCols.join(',');
          await file.writeAsString('$headerLine\n', encoding: utf8, flush: true);
          print('  [*] Initialized empty table $tableName.csv in ${dir.path}');
        } else {
          final existingHeaders = rawRows.first.map((e) => e.toString().trim()).toList();
          final bool headersMatch = existingHeaders.length == expectedCols.length &&
              List.generate(expectedCols.length, (i) => existingHeaders[i] == expectedCols[i])
                  .every((b) => b);

          if (!headersMatch) {
            // Remap existing data rows to new columns
            final List<List<dynamic>> newRows = [expectedCols];
            for (int i = 1; i < rawRows.length; i++) {
              final oldRow = rawRows[i];
              if (oldRow.isEmpty || (oldRow.length == 1 && oldRow.first.toString().trim().isEmpty)) continue;
              final newRow = <dynamic>[];
              for (final col in expectedCols) {
                final oldIdx = existingHeaders.indexOf(col);
                if (oldIdx != -1 && oldIdx < oldRow.length) {
                  newRow.add(oldRow[oldIdx]);
                } else {
                  newRow.add('');
                }
              }
              newRows.add(newRow);
            }
            final newCsv = const ListToCsvConverter(eol: '\n').convert(newRows);
            await file.writeAsString('$newCsv\n', encoding: utf8, flush: true);
            print('  [^] Migrated columns for $tableName.csv in ${dir.path} (${rawRows.length - 1} rows preserved)');
          }
        }
      }
    }
  }

  // Populate Seed Plans if plans.csv has 0 data rows
  await _seedPlansIfEmpty(File('${dataDir.path}/plans.csv'));
  await _seedPlansIfEmpty(File('${seedDir.path}/plans.csv'));

  // Populate Field Visibility if field_visibility.csv has 0 data rows
  await _seedFieldVisibilityIfEmpty(File('${dataDir.path}/field_visibility.csv'));
  await _seedFieldVisibilityIfEmpty(File('${seedDir.path}/field_visibility.csv'));

  // Update schema_meta to version 3.0.0
  await _updateSchemaMeta(File('${dataDir.path}/schema_meta.csv'));
  await _updateSchemaMeta(File('${seedDir.path}/schema_meta.csv'));

  print('Migration to V3 completed successfully.');
}

Future<void> _seedPlansIfEmpty(File file) async {
  if (!await file.exists()) return;
  final content = await file.readAsString(encoding: utf8);
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(content.replaceAll('\r\n', '\n'));

  final dataRows = rows.skip(1).where((r) => r.isNotEmpty && r.first.toString().trim().isNotEmpty).toList();
  if (dataRows.isEmpty) {
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final planRows = [
      headers,
      [
        'plan_gold_3m', 'gold_3m', 'Gold · 3 Months', 'gold', '999', '0',
        '', '', '90', '3', '40', '40', '1', '1', '0', '0', '0', '0',
        '["40 contacts","Unlimited chat","Horoscope"]', '1', '1'
      ],
      [
        'plan_prime_gold_3m', 'prime_gold_3m', 'Prime Gold · 3 Months', 'prime_gold', '1999', '0',
        '', '', '90', '3', '-1', '50', '1', '1', '1', '0', '0', '0',
        '["Unlimited contacts*","Unlimited chat","Horoscope","Verified photos"]', '2', '1'
      ],
      [
        'plan_prime_till_marry', 'prime_till_marry', 'Prime – Till U Marry', 'till_u_marry', '4999', '0',
        '', '', '730', '24', '-1', '50', '1', '1', '1', '1', '0', '1',
        '["Longest validity","Unlimited contacts*","Unlimited chat","Horoscope","Verified photos"]', '3', '1'
      ],
      [
        'plan_boost_15', 'highlighter_15d', 'Profile Highlighter · 15 Days', 'highlighter', '199', '0',
        '', '', '15', '0', '0', '0', '0', '0', '0', '0', '1', '0',
        '["Featured at top for 15 days"]', '4', '1'
      ],
      [
        'plan_boost_45', 'highlighter_45d', 'Profile Highlighter · 45 Days', 'highlighter', '499', '0',
        '', '', '45', '0', '0', '0', '0', '0', '0', '0', '1', '0',
        '["Featured at top for 45 days"]', '5', '1'
      ],
      [
        'plan_boost_90', 'highlighter_90d', 'Profile Highlighter · 90 Days', 'highlighter', '899', '0',
        '', '', '90', '0', '0', '0', '0', '0', '0', '0', '1', '0',
        '["Featured at top for 90 days"]', '6', '1'
      ],
    ];
    final csv = const ListToCsvConverter(eol: '\n').convert(planRows);
    await file.writeAsString('$csv\n', encoding: utf8, flush: true);
    print('  [+] Seeded V3 plans into ${file.path}');
  }
}

Future<void> _seedFieldVisibilityIfEmpty(File file) async {
  if (!await file.exists()) return;
  final content = await file.readAsString(encoding: utf8);
  final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(content.replaceAll('\r\n', '\n'));

  final dataRows = rows.skip(1).where((r) => r.isNotEmpty && r.first.toString().trim().isNotEmpty).toList();
  if (dataRows.isEmpty) {
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final visibilityRows = [
      headers,
      ['caste', '1', '1', '1', '1'],
      ['sub_caste', '1', '1', '1', '1'],
      ['gothram', '1', '1', '1', '1'],
      ['employment_type', '1', '1', '1', '1'],
      ['annual_income', '1', '1', '1', '1'],
      ['education_level', '1', '1', '1', '1'],
      ['occupation', '1', '1', '1', '1'],
      ['family_status', '1', '1', '1', '1'],
      ['general_details', '1', '1', '1', '1'],
      ['dob', '0', '1', '1', '1'],
      ['star', '0', '1', '1', '1'],
      ['rasi', '0', '1', '1', '1'],
      ['horoscope_chart', '0', '1', '1', '1'],
      ['institution', '0', '1', '1', '1'],
      ['employer', '0', '1', '1', '1'],
      ['verified_photos', '0', '0', '1', '1'],
      ['contact_number', '0', '1', '1', '1'],
    ];
    final csv = const ListToCsvConverter(eol: '\n').convert(visibilityRows);
    await file.writeAsString('$csv\n', encoding: utf8, flush: true);
    print('  [+] Seeded field visibility rules into ${file.path}');
  }
}

Future<void> _updateSchemaMeta(File file) async {
  if (!await file.exists()) return;
  final now = DateTime.now().toUtc().toIso8601String();
  final metaRows = [
    ['key', 'value', 'created_at', 'updated_at'],
    ['schema_version', '3.0.0', now, now],
    ['v3_migration_at', now, now, now],
  ];
  final csv = const ListToCsvConverter(eol: '\n').convert(metaRows);
  await file.writeAsString('$csv\n', encoding: utf8, flush: true);
}
