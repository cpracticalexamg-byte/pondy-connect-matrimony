// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';

void main() async {
  print('=== PURGING ALL SAMPLE PROFILES (is_sample = 1 / PRF_SMP_) ===');
  await purgeSamples();
  print('=== PURGE COMPLETE: ALL SAMPLE RECORDS REMOVED CLEANLY ===');
}

Future<void> purgeSamples() async {
  final dataDir = Directory('db/data');
  if (!await dataDir.exists()) {
    print('Error: Directory db/data does not exist.');
    exit(1);
  }

  int totalPurged = 0;
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

    final originalCount = rows.length - 1;
    final keptRows = <List<dynamic>>[rows.first];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;

      bool isSample = false;
      if (sampleColIdx != -1 && sampleColIdx < row.length) {
        final val = row[sampleColIdx].toString().trim();
        if (val == '1' || val.toLowerCase() == 'true') {
          isSample = true;
        }
      }
      if (profIdIdx != -1 && profIdIdx < row.length) {
        final pId = row[profIdIdx].toString().trim();
        if (pId.startsWith('PRF_SMP_') || pId.startsWith('PRF_SAMPLE_')) {
          isSample = true;
        }
      }
      if (userIdIdx != -1 && userIdIdx < row.length) {
        final uId = row[userIdIdx].toString().trim();
        if (uId.startsWith('USR_SMP_') || uId.startsWith('USR_SAMPLE_')) {
          isSample = true;
        }
      }

      if (isSample) {
        totalPurged++;
      } else {
        keptRows.add(row);
      }
    }

    final purgedCount = originalCount - (keptRows.length - 1);
    if (purgedCount > 0) {
      final newCsv = const ListToCsvConverter(eol: '\n').convert(keptRows);
      await file.writeAsString('$newCsv\n', encoding: utf8, flush: true);
      print('  Purged $purgedCount sample rows from ${file.path.split(Platform.pathSeparator).last}');
    }
  }

  print('Total sample rows removed across database: $totalPurged');
}
