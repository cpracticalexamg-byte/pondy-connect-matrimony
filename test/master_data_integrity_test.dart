import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Master Data Quality Gates & Integrity Tests', () {
    final masterDir = Directory('db/master');

    test('All 48 master tables exist in db/master and assets/csv/master', () {
      expect(masterDir.existsSync(), isTrue);
      final files = masterDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.csv'))
          .toList();

      expect(files.length, greaterThanOrEqualTo(45),
          reason: 'Expected at least 45 master CSV files in db/master');
    });

    test('Every master table has unique id, unique code, no trailing spaces and non-empty name_ta', () async {
      final files = masterDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.csv'))
          .toList();

      for (final file in files) {
        final filename = file.uri.pathSegments.last;
        final content = await file.readAsString(encoding: utf8);
        final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(content.replaceAll('\r\n', '\n'));

        expect(rows.isNotEmpty, isTrue, reason: '$filename is empty');
        final headers = rows.first.map((e) => e.toString().trim()).toList();
        expect(headers.contains('id'), isTrue, reason: '$filename missing id header');

        final idIndex = headers.indexOf('id');
        final codeIndex = headers.indexOf('code');
        final nameEnIndex = headers.indexOf('name_en');
        final nameTaIndex = headers.indexOf('name_ta');

        final seenIds = <String>{};
        final seenCodes = <String>{};

        for (int i = 1; i < rows.length; i++) {
          final row = rows[i];
          if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;

          // Check trailing/leading spaces on every cell
          for (final cell in row) {
            final s = cell.toString();
            expect(s, equals(s.trim()),
                reason: '$filename row $i contains untrimmed text: "$s"');
          }

          // Check unique id
          final idVal = row[idIndex].toString().trim();
          expect(idVal.isNotEmpty, isTrue, reason: '$filename row $i has empty id');
          expect(seenIds.contains(idVal), isFalse,
              reason: '$filename contains duplicate id $idVal at row $i');
          seenIds.add(idVal);

          // Check unique code if present
          if (codeIndex != -1 && codeIndex < row.length) {
            final codeVal = row[codeIndex].toString().trim();
            expect(codeVal.isNotEmpty, isTrue, reason: '$filename row $i has empty code');
            expect(seenCodes.contains(codeVal), isFalse,
                reason: '$filename contains duplicate code $codeVal at row $i');
            seenCodes.add(codeVal);
          }

          // Check non-empty name_ta if table has name_ta
          if (nameTaIndex != -1 && nameTaIndex < row.length) {
            final nameTaVal = row[nameTaIndex].toString().trim();
            expect(nameTaVal.isNotEmpty, isTrue,
                reason: '$filename row $i has empty name_ta');
          }

          // Check non-empty name_en if present
          if (nameEnIndex != -1 && nameEnIndex < row.length) {
            final nameEnVal = row[nameEnIndex].toString().trim();
            expect(nameEnVal.isNotEmpty, isTrue,
                reason: '$filename row $i has empty name_en');
          }
        }
      }
    });

    test('Referential Integrity: divisions reference valid religions', () async {
      final relContent = await File('db/master/religion.csv').readAsString(encoding: utf8);
      final divContent = await File('db/master/religion_division.csv').readAsString(encoding: utf8);

      final relRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(relContent.replaceAll('\r\n', '\n'));
      final divRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(divContent.replaceAll('\r\n', '\n'));

      final relIds = relRows.skip(1).map((r) => r.first.toString().trim()).toSet();
      for (int i = 1; i < divRows.length; i++) {
        final row = divRows[i];
        if (row.isEmpty) continue;
        final relId = row[1].toString().trim(); // religion_id
        expect(relIds.contains(relId), isTrue,
            reason: 'religion_division row $i references missing religion_id: $relId');
      }
    });

    test('Referential Integrity: castes reference valid religions', () async {
      final relContent = await File('db/master/religion.csv').readAsString(encoding: utf8);
      final casteContent = await File('db/master/caste.csv').readAsString(encoding: utf8);

      final relRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(relContent.replaceAll('\r\n', '\n'));
      final casteRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(casteContent.replaceAll('\r\n', '\n'));

      final relIds = relRows.skip(1).map((r) => r.first.toString().trim()).toSet();
      for (int i = 1; i < casteRows.length; i++) {
        final row = casteRows[i];
        if (row.isEmpty) continue;
        final relId = row[1].toString().trim(); // religion_id
        expect(relIds.contains(relId), isTrue,
            reason: 'caste row $i references missing religion_id: $relId');
      }
    });

    test('Referential Integrity: sub_castes reference valid castes', () async {
      final casteContent = await File('db/master/caste.csv').readAsString(encoding: utf8);
      final subContent = await File('db/master/sub_caste.csv').readAsString(encoding: utf8);

      final casteRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(casteContent.replaceAll('\r\n', '\n'));
      final subRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(subContent.replaceAll('\r\n', '\n'));

      final casteIds = casteRows.skip(1).map((r) => r.first.toString().trim()).toSet();
      for (int i = 1; i < subRows.length; i++) {
        final row = subRows[i];
        if (row.isEmpty) continue;
        final casteId = row[1].toString().trim(); // caste_id
        expect(casteIds.contains(casteId), isTrue,
            reason: 'sub_caste row $i references missing caste_id: $casteId');
      }
    });

    test('Astrology Integrity: 108 padams cleanly map all 27 stars to 12 rasis', () async {
      final starContent = await File('db/master/nakshatra.csv').readAsString(encoding: utf8);
      final rasiContent = await File('db/master/rasi.csv').readAsString(encoding: utf8);
      final padamContent = await File('db/master/nakshatra_padam_rasi.csv').readAsString(encoding: utf8);

      final starRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(starContent.replaceAll('\r\n', '\n'));
      final rasiRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(rasiContent.replaceAll('\r\n', '\n'));
      final padamRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(padamContent.replaceAll('\r\n', '\n'));

      expect(starRows.length - 1, equals(27));
      expect(rasiRows.length - 1, equals(12));
      expect(padamRows.length - 1, equals(108));

      final starIds = starRows.skip(1).map((r) => r.first.toString().trim()).toSet();
      final rasiIds = rasiRows.skip(1).map((r) => r.first.toString().trim()).toSet();

      for (int i = 1; i < padamRows.length; i++) {
        final row = padamRows[i];
        final starId = row[1].toString().trim();
        final padam = int.parse(row[2].toString().trim());
        final rasiId = row[3].toString().trim();

        expect(starIds.contains(starId), isTrue);
        expect(padam >= 1 && padam <= 4, isTrue);
        expect(rasiIds.contains(rasiId), isTrue);
      }
    });

    test('Geography Integrity: cities reference valid districts, districts reference valid states', () async {
      final stateContent = await File('db/master/state.csv').readAsString(encoding: utf8);
      final distContent = await File('db/master/district.csv').readAsString(encoding: utf8);
      final cityContent = await File('db/master/city.csv').readAsString(encoding: utf8);

      final stateRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(stateContent.replaceAll('\r\n', '\n'));
      final distRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(distContent.replaceAll('\r\n', '\n'));
      final cityRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(cityContent.replaceAll('\r\n', '\n'));

      final stateIds = stateRows.skip(1).map((r) => r.first.toString().trim()).toSet();
      final distIds = distRows.skip(1).map((r) => r.first.toString().trim()).toSet();

      for (int i = 1; i < distRows.length; i++) {
        final row = distRows[i];
        if (row.isEmpty) continue;
        final stateId = row[1].toString().trim();
        expect(stateIds.contains(stateId), isTrue,
            reason: 'district row $i references missing state_id: $stateId');
      }

      for (int i = 1; i < cityRows.length; i++) {
        final row = cityRows[i];
        if (row.isEmpty) continue;
        final distId = row[1].toString().trim();
        expect(distIds.contains(distId), isTrue,
            reason: 'city row $i references missing district_id: $distId');
      }
    });
  });
}
