import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/data/repositories/master_data_repository.dart';
import 'package:pondy_connect_matrimony/domain/horoscope/horoscope_engine.dart';
import 'package:pondy_connect_matrimony/features/horoscope/widgets/south_indian_chart_grid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 7: Master Data Accessors and Cascading Tests', () {
    final repo = MasterDataRepository.instance;

    test('MasterDataRepository loads subcastes and filters by caste', () async {
      final allSubcastes = await repo.getSubcastes();
      expect(allSubcastes, isNotEmpty);

      final mudaliarSubs = await repo.getSubcastes(casteId: 'mudaliar');
      expect(mudaliarSubs, isNotEmpty);
      expect(mudaliarSubs.every((s) => s.extras['caste_id'] == 'mudaliar' || s.id == 'subcaste_none'), isTrue);
    });

    test('MasterDataRepository loads Puducherry communes and cities', () async {
      final communes = await repo.getPondicherryCommunes();
      expect(communes, isNotEmpty);
      expect(communes.any((c) => c.nameEn.toLowerCase().contains('oulgaret')), isTrue);

      final cities = await repo.getCities();
      expect(cities, isNotEmpty);
    });

    test('MasterDataRepository loads countries and states', () async {
      final countries = await repo.getCountries();
      expect(countries, isNotEmpty);
      expect(countries.any((c) => c.id == 'IND'), isTrue);

      final states = await repo.getStates(countryId: 'IND');
      expect(states, isNotEmpty);
      expect(states.any((s) => s.id == 'PY' || s.nameEn.contains('Puducherry')), isTrue);
    });
  });

  group('Phase 7: Horoscope 10-Porutham Engine and Chart Grid Tests', () {
    test('HoroscopeEngine correctly evaluates 10 Poruthams with Rajju and Dosham', () {
      final engine = HoroscopeEngine.instance;

      final res = engine.evaluatePorutham(
        brideStar: 'ashwini',
        groomStar: 'bharani',
        brideRasi: 'Mesham',
        groomRasi: 'Mesham',
      );

      expect(res.items.length, 10);
      expect(res.isRajjuMatched, isTrue); // Ashwini (Kati) vs Bharani (Udara)
      expect(res.matchedCount, greaterThanOrEqualTo(5));
      expect(res.overallVerdict, contains('Porutham'));
    });

    testWidgets('SouthIndianChartGrid renders all 12 houses and courtyard correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SouthIndianChartGrid(
              title: 'ராசி கட்டம்',
              subtitle: 'மணமகன்',
              lagnaHouse: 1, // Mesham
              planetsInHouses: {
                1: ['லக்', 'சூரி'],
                4: ['குரு'],
                7: ['சந்'],
              },
            ),
          ),
        ),
      );

      expect(find.text('ராசி கட்டம்'), findsOneWidget);
      expect(find.text('மணமகன்'), findsOneWidget);
      expect(find.text('மேஷம்'), findsOneWidget);
      expect(find.text('ரிஷபம்'), findsOneWidget);
      expect(find.text('மீனம்'), findsOneWidget);
      expect(find.text('சூரி'), findsOneWidget);
      expect(find.text('குரு'), findsOneWidget);
      expect(find.text('சந்'), findsOneWidget);
    });
  });
}
