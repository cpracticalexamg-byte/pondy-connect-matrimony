import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phase 9: 10 Men + 10 Women Sample Profiles & Purge Tests', () {
    final usersFile = File('db/data/users.csv');
    final profilesFile = File('db/data/profiles.csv');

    test('db/data/ contains authentic sample profiles flagged with is_sample = 1', () async {
      expect(await usersFile.exists(), isTrue);
      expect(await profilesFile.exists(), isTrue);

      final usersRaw = await usersFile.readAsString();
      final usersRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(usersRaw.replaceAll('\r\n', '\n'));
      final userHeaders = usersRows.first.map((e) => e.toString().trim()).toList();
      final isSampleUserIdx = userHeaders.indexOf('is_sample');
      expect(isSampleUserIdx, isNot(-1));

      final sampleUsers = usersRows.skip(1).where((r) => r.length > isSampleUserIdx && r[isSampleUserIdx].toString() == '1').toList();
      expect(sampleUsers.length, 20);

      final profilesRaw = await profilesFile.readAsString();
      final profilesRows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(profilesRaw.replaceAll('\r\n', '\n'));
      final profileHeaders = profilesRows.first.map((e) => e.toString().trim()).toList();
      final isSampleProfIdx = profileHeaders.indexOf('is_sample');
      final genderProfIdx = profileHeaders.indexOf('gender');
      final nameProfIdx = profileHeaders.indexOf('name');
      final aboutProfIdx = profileHeaders.indexOf('about_me');

      expect(isSampleProfIdx, isNot(-1));
      expect(genderProfIdx, isNot(-1));

      final sampleProfiles = profilesRows.skip(1).where((r) => r.length > isSampleProfIdx && r[isSampleProfIdx].toString() == '1').toList();
      expect(sampleProfiles.length, 20);

      final men = sampleProfiles.where((r) => r[genderProfIdx].toString() == 'Male').toList();
      final women = sampleProfiles.where((r) => r[genderProfIdx].toString() == 'Female').toList();

      expect(men.length, 10);
      expect(women.length, 10);

      // Verify authentic names and dignified Puducherry bios
      for (final p in sampleProfiles) {
        final name = p[nameProfIdx].toString();
        final bio = p[aboutProfIdx].toString();
        expect(name, isNotEmpty);
        expect(name.toLowerCase(), isNot(contains('test')));
        expect(name.toLowerCase(), isNot(contains('dummy')));
        expect(bio, isNotEmpty);
        expect(bio.toLowerCase(), isNot(contains('lorem')));
        expect(bio, anyOf(contains('Puducherry'), contains('Pondicherry'), contains('Karaikal')));
      }
    });
  });
}
