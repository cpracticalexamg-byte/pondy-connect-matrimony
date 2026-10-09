// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('==============================================');
  print('DETERMINISTIC DATABASE DE-DUPLICATION');
  print('==============================================');

  final dataDir = Directory('db/data');
  final dedupeLogFile = File('docs/DEDUPE_LOG.csv');

  int totalMerged = 0;
  final logEntries = <String>[];
  logEntries.add('table,action,key,details');

  // Tables to check for duplicates
  final tablesToCheck = ['users', 'profiles', 'interests', 'shortlists', 'blocks'];

  for (final table in tablesToCheck) {
    final file = File('${dataDir.path}/$table.csv');
    if (!await file.exists()) continue;

    final content = await file.readAsString(encoding: utf8);
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(content.replaceAll('\r\n', '\n'));

    if (rows.length <= 1) continue;

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final dataRows = rows.skip(1).toList();

    final seenKeys = <String, List<dynamic>>{};
    final uniqueRows = <List<dynamic>>[];

    for (final row in dataRows) {
      if (row.isEmpty) continue;
      String key;
      if (table == 'users') {
        final mobileIdx = headers.indexOf('mobile');
        key = mobileIdx != -1 ? row[mobileIdx].toString().trim() : row.first.toString();
      } else if (table == 'profiles') {
        final nameIdx = headers.indexOf('name');
        final dobIdx = headers.indexOf('dob');
        key = '${row[nameIdx].toString().trim().toLowerCase()}_${row[dobIdx].toString().trim()}';
      } else if (table == 'interests') {
        final fromIdx = headers.indexOf('from_profile_id');
        final toIdx = headers.indexOf('to_profile_id');
        key = '${row[fromIdx]}_${row[toIdx]}';
      } else if (table == 'shortlists') {
        final pIdx = headers.indexOf('profile_id');
        final targetIdx = headers.indexOf('target_profile_id');
        key = '${row[pIdx]}_${row[targetIdx]}';
      } else {
        key = row.first.toString();
      }

      if (seenKeys.containsKey(key)) {
        totalMerged++;
        logEntries.add('$table,merged_duplicate,$key,"Retained oldest record"');
      } else {
        seenKeys[key] = row;
        uniqueRows.add(row);
      }
    }

    if (uniqueRows.length != dataRows.length) {
      final buffer = StringBuffer();
      buffer.writeln(headers.join(','));
      for (final r in uniqueRows) {
        buffer.writeln(r.join(','));
      }
      await file.writeAsString(buffer.toString(), encoding: utf8, flush: true);
      print('  [✓] $table: Deduplicated ${dataRows.length - uniqueRows.length} redundant rows.');
    }
  }

  await dedupeLogFile.writeAsString(logEntries.join('\n'), encoding: utf8);
  print('De-duplication completed! Total merged: $totalMerged. Log: docs/DEDUPE_LOG.csv');
}
