import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_lock.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/domain/location/geo_utils.dart';
import 'package:pondy_connect_matrimony/domain/location/location_service.dart';
import 'package:pondy_connect_matrimony/features/location/screens/privacy_location_screen.dart';
import 'package:pondy_connect_matrimony/features/location/widgets/location_permission_sheet.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    CsvLock.reset();
    CsvStore.instance.clearCache();
    tempDir = await Directory.systemTemp.createTemp('pondy_loc_test_');
    await CsvStore.instance.initialize(customDir: tempDir);
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('GeoUtils Unit Tests', () {
    test('Haversine distance calculation is accurate for known coordinates', () {
      final whiteTown = GeoUtils.districtCentroids['white_town']!; // 11.9333, 79.8333
      final lawspet = GeoUtils.districtCentroids['lawspet']!;       // 11.9610, 79.8160
      final cuddalore = GeoUtils.districtCentroids['cuddalore']!;   // 11.7480, 79.7714
      final chennai = GeoUtils.districtCentroids['chennai']!;       // 13.0827, 80.2707

      // Lawspet to White Town is ~3.5 km
      final distWhiteTownLawspet = GeoUtils.haversineDistanceKm(whiteTown, lawspet);
      expect(distWhiteTownLawspet, greaterThan(2.5));
      expect(distWhiteTownLawspet, lessThan(4.5));

      // White Town to Cuddalore is ~21 km
      final distWhiteTownCuddalore = GeoUtils.haversineDistanceKm(whiteTown, cuddalore);
      expect(distWhiteTownCuddalore, greaterThan(18.0));
      expect(distWhiteTownCuddalore, lessThan(25.0));

      // White Town to Chennai is ~135 km
      final distWhiteTownChennai = GeoUtils.haversineDistanceKm(whiteTown, chennai);
      expect(distWhiteTownChennai, greaterThan(120.0));
      expect(distWhiteTownChennai, lessThan(160.0));
    });

    test('snapToCoarseGrid snaps raw GPS coordinates to coarse grid with jitter', () {
      const rawGps = GeoPoint(11.9335678, 79.8334123);
      final snapped1 = GeoUtils.snapToCoarseGrid(rawGps, profileId: 'PROFILE_A');
      final snapped2 = GeoUtils.snapToCoarseGrid(rawGps, profileId: 'PROFILE_A');
      final snappedDifferentProfile = GeoUtils.snapToCoarseGrid(rawGps, profileId: 'PROFILE_B');

      // Deterministic per profile
      expect(snapped1.latitude, snapped2.latitude);
      expect(snapped1.longitude, snapped2.longitude);

      // Raw coordinates are NOT preserved
      expect(snapped1.latitude, isNot(equals(rawGps.latitude)));
      expect(snapped1.longitude, isNot(equals(rawGps.longitude)));

      // Snapped distance is within ~500m of raw
      final offsetKm = GeoUtils.haversineDistanceKm(rawGps, snapped1);
      expect(offsetKm, lessThan(0.6));

      // Different profiles receive distinct jitter values
      expect(snapped1, isNot(equals(snappedDifferentProfile)));
    });

    test('encodeGeohash generates 5-character geohash correctly', () {
      final hash = GeoUtils.encodeGeohash(11.9333, 79.8333, precision: 5);
      expect(hash.length, 5);
      expect(hash.startsWith('tf0'), isTrue); // Puducherry region prefix
    });

    test('formatDistance obeys all §4 formatting & safety rules', () {
      // 1. Target hidden returns null
      expect(GeoUtils.formatDistance(1.5, shareMode: 'hidden'), isNull);

      // 2. Below 0.3 km displays as "< 0.5 km away" (prevents trilateration)
      expect(GeoUtils.formatDistance(0.1, shareMode: 'precise'), '< 0.5 km away');
      expect(GeoUtils.formatDistance(0.25, shareMode: 'precise'), '< 0.5 km away');

      // 3. Under 10 km in precise mode -> 1 decimal place
      expect(GeoUtils.formatDistance(0.8, shareMode: 'precise'), '0.8 km away');
      expect(GeoUtils.formatDistance(3.42, shareMode: 'precise'), '3.4 km away');
      expect(GeoUtils.formatDistance(7.99, shareMode: 'precise'), '8.0 km away');

      // 4. Under 10 km in approx mode -> rounded to nearest integer km
      expect(GeoUtils.formatDistance(3.4, shareMode: 'approx'), '~3 km away');
      expect(GeoUtils.formatDistance(3.8, shareMode: 'approx'), '~4 km away');

      // 5. Above 10 km -> rounded to nearest 1 km
      expect(GeoUtils.formatDistance(12.3, shareMode: 'precise'), '12 km away');
      expect(GeoUtils.formatDistance(42.7, shareMode: 'precise'), '43 km away');
      expect(GeoUtils.formatDistance(150.1, shareMode: 'approx'), '~150 km away');

      // 6. Null distance with district fallback
      expect(GeoUtils.formatDistance(null, cityOrDistrict: 'Puducherry'), 'in Puducherry');
      expect(GeoUtils.formatDistance(null), isNull);
    });
  });

  group('LocationService Integration & In-Memory Spatial Index', () {
    test('saveProfileLocation saves coarse location and updates spatial index', () async {
      final locService = LocationService.instance;
      const raw = GeoPoint(11.9610, 79.8160); // Lawspet

      await locService.saveProfileLocation(
        profileId: 'TEST_PROF_01',
        rawPoint: raw,
        shareMode: 'precise',
        source: 'gps',
      );

      final rec = locService.getLocationRecord('TEST_PROF_01');
      expect(rec, isNotNull);
      expect(rec!.profileId, 'TEST_PROF_01');
      expect(rec.geohash5.length, 5);
      expect(rec.shareMode, 'precise');

      // Verify stored row in CsvStore has no raw GPS coordinates
      final rows = await CsvStore.instance.query(
        CsvSchema.profileLocationsTable,
        (r) => r['profile_id'] == 'TEST_PROF_01',
      );
      expect(rows.length, 1);
      final storedLat = double.parse(rows.first['lat_coarse']!);
      final storedLng = double.parse(rows.first['lng_coarse']!);
      expect(storedLat, isNot(equals(raw.latitude)));
      expect(storedLng, isNot(equals(raw.longitude)));
    });

    test('getDistanceToCandidate computes distance from in-memory viewer location', () async {
      final locService = LocationService.instance;

      // Set viewer location to White Town
      locService.setMockLocation('white_town');

      // Save a candidate in Lawspet
      await locService.saveProfileLocation(
        profileId: 'CAND_LAWSPET',
        rawPoint: GeoUtils.districtCentroids['lawspet']!,
        shareMode: 'precise',
      );

      // Save a candidate in Chennai
      await locService.saveProfileLocation(
        profileId: 'CAND_CHENNAI',
        rawPoint: GeoUtils.districtCentroids['chennai']!,
        shareMode: 'precise',
      );

      final distLawspet = locService.getDistanceToCandidate('CAND_LAWSPET');
      expect(distLawspet, isNotNull);
      expect(distLawspet!, greaterThan(2.0));
      expect(distLawspet, lessThan(5.0));

      final distChennai = locService.getDistanceToCandidate('CAND_CHENNAI');
      expect(distChennai, isNotNull);
      expect(distChennai!, greaterThan(120.0));

      // Radius filter: Lawspet is within 10 km, Chennai is not
      final within10km = locService.getCandidateIdsWithinRadius(10.0);
      expect(within10km.contains('CAND_LAWSPET'), isTrue);
      expect(within10km.contains('CAND_CHENNAI'), isFalse);
    });

    test('Target with share_mode hidden returns null distance', () async {
      final locService = LocationService.instance;
      locService.setMockLocation('white_town');

      await locService.saveProfileLocation(
        profileId: 'CAND_SECRET',
        rawPoint: GeoUtils.districtCentroids['lawspet']!,
        shareMode: 'hidden',
      );

      final dist = locService.getDistanceToCandidate('CAND_SECRET');
      expect(dist, isNull);

      final formatted = locService.getFormattedDistance('CAND_SECRET');
      expect(formatted, isNull);
    });
  });

  group('Location UI Components', () {
    testWidgets('LocationPermissionSheet renders explainer and handles button actions', (tester) async {
      bool manualClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationPermissionSheet(
              onManualSelected: () => manualClicked = true,
            ),
          ),
        ),
      );

      expect(find.text('Show Matches Near You'), findsOneWidget);
      expect(find.textContaining('100% Privacy Protected'), findsOneWidget);
      expect(find.text('Allow Location Access'), findsOneWidget);
      expect(find.text('Set City / District Manually'), findsOneWidget);

      await tester.tap(find.text('Set City / District Manually'));
      await tester.pump();
      expect(manualClicked, isTrue);
    });

    testWidgets('PrivacyLocationScreen renders privacy settings and mock location dev tools', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PrivacyLocationScreen(),
          ),
        ),
      );

      expect(find.text('Privacy & Location'), findsOneWidget);
      expect(find.text('Location Privacy Guarantee'), findsOneWidget);
      expect(find.text('Show my distance to others'), findsOneWidget);
      expect(find.text('Precise-ish (0.1 km)'), findsOneWidget);
      expect(find.text('Approximate (nearest km)'), findsOneWidget);
      expect(find.text('Save Settings'), findsOneWidget);
      expect(find.text('Dev Tool: Mock My Location'), findsOneWidget);

      // Select Approximate radio
      await tester.tap(find.text('Approximate (nearest km)'));
      await tester.pump();

      // Tap Save Settings
      await tester.runAsync(() async {
        await tester.tap(find.text('Save Settings'));
        await Future.delayed(const Duration(milliseconds: 150));
      });
      await tester.pump();

      expect(find.text('Privacy & Location settings saved'), findsOneWidget);
    });
  });
}
