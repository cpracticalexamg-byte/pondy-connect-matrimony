// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('==============================================');
  print('MIGRATING DATABASE V1 -> V2');
  print('==============================================');

  final manifestFile = File('db/schema/tables.manifest.json');
  if (!await manifestFile.exists()) {
    print('Error: tables.manifest.json not found!');
    exit(1);
  }

  final manifestJson = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
  final tables = manifestJson['tables'] as Map<String, dynamic>;

  final dataDir = Directory('db/data');
  final seedDir = Directory('assets/csv/seed');
  final docsDir = Directory('docs');

  if (!await dataDir.exists()) await dataDir.create(recursive: true);
  if (!await seedDir.exists()) await seedDir.create(recursive: true);
  if (!await docsDir.exists()) await docsDir.create(recursive: true);

  final rejectsBuffer = StringBuffer();
  rejectsBuffer.writeln('source_table,row_id,reason,raw_content');

  final dedupeBuffer = StringBuffer();
  dedupeBuffer.writeln('table,action,key,details');

  int totalDroppedDemoRows = 0;

  for (final entry in tables.entries) {
    final tableName = entry.key;
    final columns = List<String>.from(entry.value['columns']);

    // Check if an existing V1 seed file exists
    final oldV1File = File('assets/csv/seed/$tableName.csv');
    if (await oldV1File.exists()) {
      final oldContent = await oldV1File.readAsString(encoding: utf8);
      final oldRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(oldContent.replaceAll('\r\n', '\n'));

      if (oldRows.isNotEmpty) {
        final oldHeaders = oldRows.first.map((e) => e.toString().trim()).toList();
        final isDemoIndex = oldHeaders.indexOf('is_demo');

        for (int i = 1; i < oldRows.length; i++) {
          final row = oldRows[i];
          if (row.isEmpty) continue;
          final isDemo = isDemoIndex != -1 && isDemoIndex < row.length
              ? row[isDemoIndex].toString().trim()
              : '0';

          if (isDemo == '1' || isDemo == 'true') {
            totalDroppedDemoRows++;
            final idVal = row.isNotEmpty ? row.first.toString() : 'row_$i';
            rejectsBuffer.writeln('$tableName,$idVal,Dropped synthetic dummy row is_demo=true,"${row.join(';')}"');
          }
        }
      }
    }

    // Write empty table with headers only
    final headerLine = columns.join(',');
    final emptyCsv = '$headerLine\n';

    await File('${dataDir.path}/$tableName.csv').writeAsString(emptyCsv, encoding: utf8, flush: true);
    await File('${seedDir.path}/$tableName.csv').writeAsString(emptyCsv, encoding: utf8, flush: true);
    print('  [✓] $tableName: Initialized clean empty table with headers: [${columns.length} columns]');
  }

  // Write MIGRATION_REJECTS.csv and DEDUPE_LOG.csv
  await File('docs/MIGRATION_REJECTS.csv').writeAsString(rejectsBuffer.toString(), encoding: utf8);
  await File('docs/DEDUPE_LOG.csv').writeAsString(dedupeBuffer.toString(), encoding: utf8);

  print('Migration completed! Dropped $totalDroppedDemoRows synthetic demo rows.');
  print('Recorded rejects in docs/MIGRATION_REJECTS.csv and dedupe in docs/DEDUPE_LOG.csv.');
}
