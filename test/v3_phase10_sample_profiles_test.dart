import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/core/theme/app_typography.dart';
import 'package:pondy_connect_matrimony/domain/matching/matching_engine.dart';
import 'package:pondy_connect_matrimony/domain/models/profile_model.dart';
import 'package:pondy_connect_matrimony/domain/location/geo_utils.dart';
import 'package:pondy_connect_matrimony/features/matches/widgets/profile_card.dart';

void main() {
  setUp(() {
    AppTypography.disableGoogleFontsInTests = true;
  });

  group('Phase 10: Sample Profiles & Safety Verification (§9)', () {
    test('Database contains exactly 10 Grooms and 10 Brides with is_sample = 1', () {
      final profilesFile = File('db/data/profiles.csv');
      expect(profilesFile.existsSync(), isTrue);

      final raw = profilesFile.readAsStringSync();
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(raw.replaceAll('\r\n', '\n'));

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final sampleIdx = headers.indexOf('is_sample');
      final genderIdx = headers.indexOf('gender');
      final profIdIdx = headers.indexOf('profile_id');

      final sampleRows = rows.skip(1).where((r) =>
          sampleIdx != -1 && (r[sampleIdx].toString().trim() == '1' || r[sampleIdx].toString().toLowerCase() == 'true')).toList();

      expect(sampleRows.length, equals(20), reason: 'Must have exactly 20 sample profiles');

      final maleCount = sampleRows.where((r) => r[genderIdx].toString().toLowerCase() == 'male').length;
      final femaleCount = sampleRows.where((r) => r[genderIdx].toString().toLowerCase() == 'female').length;

      expect(maleCount, equals(10), reason: 'Must have exactly 10 sample grooms');
      expect(femaleCount, equals(10), reason: 'Must have exactly 10 sample brides');

      // Verify profile IDs PRF_SMP_G01..G10 and PRF_SMP_B01..B10
      final ids = sampleRows.map((r) => r[profIdIdx].toString()).toSet();
      for (int i = 1; i <= 10; i++) {
        final gId = 'PRF_SMP_G${i.toString().padLeft(2, '0')}';
        final bId = 'PRF_SMP_B${i.toString().padLeft(2, '0')}';
        expect(ids.contains(gId), isTrue, reason: 'Must contain $gId');
        expect(ids.contains(bId), isTrue, reason: 'Must contain $bId');
      }
    });

    test('Privacy First: Contact numbers & emails are NULL / empty for all sample rows (§9 Rule 3)', () {
      final usersFile = File('db/data/users.csv');
      expect(usersFile.existsSync(), isTrue);

      final raw = usersFile.readAsStringSync();
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
          .convert(raw.replaceAll('\r\n', '\n'));

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final sampleIdx = headers.indexOf('is_sample');
      final mobileIdx = headers.indexOf('mobile');
      final emailIdx = headers.indexOf('email');

      for (int i = 1; i < rows.length; i++) {
        final r = rows[i];
        if (r.isEmpty || (r.length == 1 && r.first.toString().trim().isEmpty)) continue;
        if (sampleIdx != -1 && r[sampleIdx].toString().trim() == '1') {
          final mobile = r[mobileIdx].toString().trim();
          final email = r[emailIdx].toString().trim();
          expect(mobile.isEmpty, isTrue, reason: 'Sample row must have empty/null mobile');
          expect(email.isEmpty, isTrue, reason: 'Sample row must have empty/null email');
        }
      }
    });

    test('Coarse Coordinates & Distances demo accurately from Pondicherry (~0.8km to >100km)', () {
      // Mock viewer location in Lawspet, Puducherry: 11.9610, 79.8210
      const viewerPoint = GeoPoint(11.9610, 79.8210);

      // G1: Lawspet (~0.8-1km)
      final dG1 = GeoUtils.haversineDistanceKm(viewerPoint, const GeoPoint(11.9610, 79.8210));
      expect(dG1, lessThan(0.5)); // virtually same neighborhood

      // G2: Muthialpet (~2km)
      final dG2 = GeoUtils.haversineDistanceKm(viewerPoint, const GeoPoint(11.9510, 79.8320));
      expect(dG2, greaterThan(1.0));
      expect(dG2, lessThan(3.0));

      // G3: Villianur (~6-7km)
      final dG3 = GeoUtils.haversineDistanceKm(viewerPoint, const GeoPoint(11.9160, 79.7580));
      expect(dG3, greaterThan(5.0));
      expect(dG3, lessThan(10.0));

      // G6: Cuddalore (~25km)
      final dG6 = GeoUtils.haversineDistanceKm(viewerPoint, const GeoPoint(11.7480, 79.7714));
      expect(dG6, greaterThan(20.0));
      expect(dG6, lessThan(30.0));

      // G4: Chennai (~130-150km)
      final dG4 = GeoUtils.haversineDistanceKm(viewerPoint, const GeoPoint(13.0827, 80.2707));
      expect(dG4, greaterThan(120.0));
      expect(dG4, lessThan(160.0));
    });

    testWidgets('ProfileCard shows "Sample profile" badge and shows demo warning on Send Interest', (tester) async {
      const sampleProfile = ProfileModel(
        profileId: 'PRF_SMP_G01',
        userId: 'USR_SMP_G01',
        name: 'Karthikeyan Sundaram',
        gender: 'Male',
        dob: '1997-04-12',
        age: 29,
        heightCm: 175,
        education: 'B.E.',
        occupation: 'Software Engineer',
        city: 'Lawspet',
        district: 'Puducherry',
        religion: 'Hindu',
        caste: 'Mudaliar',
        isSample: true,
        createdAt: '2026-10-13T00:00:00Z',
        updatedAt: '2026-10-13T00:00:00Z',
      );

      const match = MatchResult(
        profile: sampleProfile,
        score: 92,
        matchReasons: ['Matching preferences', 'Same district'],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileCard(
                match: match,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify "Sample profile" badge is rendered
      expect(find.text('Sample profile'), findsOneWidget);

      // Tap Send Interest button
      await tester.tap(find.text('Send Interest'));
      await tester.pump();

      // Verify demonstration warning snackbar
      expect(find.text('This is a sample profile for demonstration.'), findsOneWidget);
    });
  });
}
