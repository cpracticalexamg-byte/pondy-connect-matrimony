import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/domain/horoscope/horoscope_engine.dart';

void main() {
  group('HoroscopeEngine 10-Porutham Tests', () {
    test('Calculates 10-Porutham items accurately', () {
      final result = HoroscopeEngine.instance.evaluatePorutham(
        brideStar: 'star_rohini', // Siras Rajju, Manushya Gana
        groomStar: 'star_hastha', // Siras Rajju (same) or test different
        brideRasi: 'Rishabam',
        groomRasi: 'Kanni',
      );

      expect(result.items.length, equals(10));
      expect(result.matchedCount, greaterThan(0));
      expect(result.overallVerdict.isNotEmpty, isTrue);
    });

    test('Identifies Rajju Porutham mismatch when stars belong to same Rajju', () {
      // Rohini (Siras) and Hastha (Siras)
      final resultSameRajju = HoroscopeEngine.instance.evaluatePorutham(
        brideStar: 'rohini',
        groomStar: 'hastha',
        brideRasi: 'Rishabam',
        groomRasi: 'Kanni',
      );
      expect(resultSameRajju.isRajjuMatched, isFalse);

      // Ashwini (Kati) and Bharani (Udara) - different Rajjus
      final resultDiffRajju = HoroscopeEngine.instance.evaluatePorutham(
        brideStar: 'ashwini',
        groomStar: 'bharani',
        brideRasi: 'Mesham',
        groomRasi: 'Mesham',
      );
      expect(resultDiffRajju.isRajjuMatched, isTrue);
    });

    test('Evaluates Sevvai Dosham compatibility', () {
      // Both have Sevvai dosham -> compatible
      final bothWithDosham = HoroscopeEngine.instance.evaluatePorutham(
        brideStar: 'ashwini',
        groomStar: 'bharani',
        brideRasi: 'Mesham',
        groomRasi: 'Mesham',
        brideDosham: 'sevvai_dosham',
        groomDosham: 'sevvai_dosham',
      );
      expect(bothWithDosham.isDoshamCompatible, isTrue);

      // One has Sevvai dosham, other has none -> incompatible
      final oneWithDosham = HoroscopeEngine.instance.evaluatePorutham(
        brideStar: 'ashwini',
        groomStar: 'bharani',
        brideRasi: 'Mesham',
        groomRasi: 'Mesham',
        brideDosham: 'sevvai_dosham',
        groomDosham: 'none',
      );
      expect(oneWithDosham.isDoshamCompatible, isFalse);
    });
  });
}
