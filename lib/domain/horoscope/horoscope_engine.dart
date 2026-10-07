class PoruthamItem {
  final String name;
  final String tamilName;
  final bool isMatched;
  final String importance; // Crucial, High, Medium, Moderate
  final String description;

  const PoruthamItem({
    required this.name,
    required this.tamilName,
    required this.isMatched,
    required this.importance,
    required this.description,
  });
}

class HoroscopeResult {
  final int matchedCount; // out of 10
  final bool isRajjuMatched;
  final bool isDoshamCompatible;
  final List<PoruthamItem> items;
  final String overallVerdict;

  const HoroscopeResult({
    required this.matchedCount,
    required this.isRajjuMatched,
    required this.isDoshamCompatible,
    required this.items,
    required this.overallVerdict,
  });
}

class HoroscopeEngine {
  static final HoroscopeEngine instance = HoroscopeEngine._();
  HoroscopeEngine._();

  static const List<String> stars = [
    'ashwini',
    'bharani',
    'krittika',
    'rohini',
    'mrighasira',
    'ardra',
    'punarvasu',
    'pushya',
    'ashlesha',
    'magha',
    'purvaphalguni',
    'uttaraphalguni',
    'hastha',
    'chitra',
    'swati',
    'vishakha',
    'anuradha',
    'jyeshtha',
    'moola',
    'purvashada',
    'uttarashada',
    'shravana',
    'dhanishta',
    'shatabhisha',
    'purvabhadrapada',
    'uttarabhadrapada',
    'revati',
  ];

  static const Map<String, String> rajjuGroups = {
    'ashwini': 'Kati', 'bharani': 'Udara', 'krittika': 'Kanta', 'rohini': 'Siras', 'mrighasira': 'Kanta',
    'ardra': 'Udara', 'punarvasu': 'Kati', 'pushya': 'Pada', 'ashlesha': 'Pada', 'magha': 'Kati',
    'purvaphalguni': 'Udara', 'uttaraphalguni': 'Kanta', 'hastha': 'Siras', 'chitra': 'Kanta', 'swati': 'Udara',
    'vishakha': 'Kati', 'anuradha': 'Pada', 'jyeshtha': 'Pada', 'moola': 'Kati', 'purvashada': 'Udara',
    'uttarashada': 'Kanta', 'shravana': 'Siras', 'dhanishta': 'Kanta', 'shatabhisha': 'Udara',
    'purvabhadrapada': 'Kati', 'uttarabhadrapada': 'Pada', 'revati': 'Pada',
  };

  static const Map<String, String> ganaGroups = {
    'ashwini': 'Deva', 'bharani': 'Manushya', 'krittika': 'Rakshasa', 'rohini': 'Manushya',
    'mrighasira': 'Deva', 'ardra': 'Manushya', 'punarvasu': 'Deva', 'pushya': 'Deva',
    'ashlesha': 'Rakshasa', 'magha': 'Rakshasa', 'purvaphalguni': 'Manushya', 'uttaraphalguni': 'Manushya',
    'hastha': 'Deva', 'chitra': 'Rakshasa', 'swati': 'Deva', 'vishakha': 'Rakshasa',
    'anuradha': 'Deva', 'jyeshtha': 'Rakshasa', 'moola': 'Rakshasa', 'purvashada': 'Manushya',
    'uttarashada': 'Manushya', 'shravana': 'Deva', 'dhanishta': 'Rakshasa', 'shatabhisha': 'Rakshasa',
    'purvabhadrapada': 'Manushya', 'uttarabhadrapada': 'Manushya', 'revati': 'Deva',
  };

  HoroscopeResult evaluatePorutham({
    required String brideStar,
    required String groomStar,
    required String brideRasi,
    required String groomRasi,
    String brideDosham = 'none',
    String groomDosham = 'none',
  }) {
    final bStarClean = _clean(brideStar);
    final gStarClean = _clean(groomStar);

    int bIndex = stars.indexOf(bStarClean);
    int gIndex = stars.indexOf(gStarClean);
    if (bIndex < 0) bIndex = 0;
    if (gIndex < 0) gIndex = 1;

    // Star difference (from bride to groom, 1-indexed)
    final diff = ((gIndex - bIndex + 27) % 27) + 1;

    // 1. Dina Porutham (Health & Longevity)
    final dinaMatches = [2, 4, 6, 8, 9, 11, 13, 15, 18, 20, 24, 26].contains(diff);
    final dina = PoruthamItem(
      name: 'Dina Porutham',
      tamilName: 'தினப் பொருத்தம்',
      isMatched: dinaMatches,
      importance: 'High',
      description: dinaMatches ? 'Blessed with sound health, longevity and good fortune.' : 'Moderate planetary distance.',
    );

    // 2. Gana Porutham (Temperament)
    final bGana = ganaGroups[bStarClean] ?? 'Deva';
    final gGana = ganaGroups[gStarClean] ?? 'Deva';
    bool ganaMatch = (bGana == gGana) || (bGana == 'Deva' && gGana == 'Manushya') || (bGana == 'Manushya' && gGana == 'Deva');
    if (bGana == 'Deva' && gGana == 'Rakshasa') ganaMatch = false;
    if (bGana == 'Manushya' && gGana == 'Rakshasa') ganaMatch = false;

    final gana = PoruthamItem(
      name: 'Gana Porutham',
      tamilName: 'கணப் பொருத்தம்',
      isMatched: ganaMatch,
      importance: 'High',
      description: ganaMatch ? 'Harmonious mutual understanding & temperament.' : 'Difference in temperaments; mutual adjustment needed.',
    );

    // 3. Mahendra Porutham (Progeny & Wealth)
    final mahendraMatches = [4, 7, 10, 13, 16, 19, 22, 25].contains(diff);
    final mahendra = PoruthamItem(
      name: 'Mahendra Porutham',
      tamilName: 'மகேந்திரப் பொருத்தம்',
      isMatched: mahendraMatches,
      importance: 'High',
      description: mahendraMatches ? 'Favours lineage continuity, healthy progeny and prosperity.' : 'Neutral progeny alignment.',
    );

    // 4. Stree Deergha Porutham (Bride Longevity)
    final streeMatch = diff >= 13;
    final stree = PoruthamItem(
      name: 'Stree Deergha Porutham',
      tamilName: 'ஸ்திரீ தீர்க்கப் பொருத்தம்',
      isMatched: streeMatch,
      importance: 'Moderate',
      description: streeMatch ? 'Ensures long, happy and prosperous life for the bride.' : 'Acceptable if other key poruthams match.',
    );

    // 5. Yoni Porutham (Mutual Affection)
    final yoniMatch = (bIndex % 4) == (gIndex % 4) || (diff % 2 == 0);
    final yoni = PoruthamItem(
      name: 'Yoni Porutham',
      tamilName: 'யோனிப் பொருத்தம்',
      isMatched: yoniMatch,
      importance: 'High',
      description: yoniMatch ? 'Harmonious emotional and physical connection.' : 'Average compatibility in mutual attraction.',
    );

    // 6. Rasi Porutham (Lineage & Harmony)
    final rasiMatch = brideRasi.toLowerCase() == groomRasi.toLowerCase() || (diff % 7 == 0) || (diff == 7);
    final rasi = PoruthamItem(
      name: 'Rasi Porutham',
      tamilName: 'ராசிப் பொருத்தம்',
      isMatched: rasiMatch,
      importance: 'High',
      description: rasiMatch ? 'Excellent unity, family happiness and understanding.' : 'Different moon signs; balance through friendship.',
    );

    // 7. Rasi Adhipathi Porutham (Lords Friendship)
    final adhipathiMatch = (bIndex + gIndex) % 3 != 0;
    final adhipathi = PoruthamItem(
      name: 'Rasi Adhipathi',
      tamilName: 'ராசி அதிபதி பொருத்தம்',
      isMatched: adhipathiMatch,
      importance: 'Medium',
      description: adhipathiMatch ? 'Planetary lords share friendly or neutral alignment.' : 'Planetary rulers require prayerful consideration.',
    );

    // 8. Vasya Porutham (Attraction & Love)
    final vasyaMatch = (bIndex + gIndex) % 2 == 0;
    final vasya = PoruthamItem(
      name: 'Vasya Porutham',
      tamilName: 'வசியப் பொருத்தம்',
      isMatched: vasyaMatch,
      importance: 'Medium',
      description: vasyaMatch ? 'Mutual respect, magnetic attraction and lasting affection.' : 'Standard alignment.',
    );

    // 9. Rajju Porutham (Crucial Mangalya Bhagyam)
    final bRajju = rajjuGroups[bStarClean] ?? 'Kati';
    final gRajju = rajjuGroups[gStarClean] ?? 'Udara';
    final rajjuMatch = bRajju != gRajju; // Must NOT be in the same Rajju!
    final rajju = PoruthamItem(
      name: 'Rajju Porutham',
      tamilName: 'ரஜ்ஜுப் பொருத்தம் (மாங்கல்ய பலம்)',
      isMatched: rajjuMatch,
      importance: 'Crucial (Must Match)',
      description: rajjuMatch
          ? 'Different Rajjus ($bRajju vs $gRajju). Mangalya Bhagyam fully protected!'
          : 'Same Rajju ($bRajju). Classical texts advise matching with alternative astrological remedies.',
    );

    // 10. Vedha Porutham (Affliction Avoidance)
    final vedhaMatch = ((bIndex - gIndex).abs() != 18);
    final vedha = PoruthamItem(
      name: 'Vedha Porutham',
      tamilName: 'வேதைப் பொருத்தம்',
      isMatched: vedhaMatch,
      importance: 'Crucial',
      description: vedhaMatch ? 'No astrological friction; smooth married life.' : 'Mutual vedha identified.',
    );

    final items = [dina, gana, mahendra, stree, yoni, rasi, adhipathi, vasya, rajju, vedha];
    final matchCount = items.where((e) => e.isMatched).length;

    // Dosham compatibility
    final bHasDosham = brideDosham.toLowerCase().contains('sevvai') || brideDosham.toLowerCase().contains('rahu');
    final gHasDosham = groomDosham.toLowerCase().contains('sevvai') || groomDosham.toLowerCase().contains('rahu');
    final isDoshamComp = (bHasDosham == gHasDosham);

    String verdict;
    if (rajjuMatch && matchCount >= 7) {
      verdict = 'Uthama Porutham (Highly Auspicious Match) 🌟';
    } else if (rajjuMatch && matchCount >= 5) {
      verdict = 'Madhyama Porutham (Good Match with Remedial Blessings) 👍';
    } else {
      verdict = 'Adhama Porutham (Requires In-Depth Astrologer Consultation)';
    }

    return HoroscopeResult(
      matchedCount: matchCount,
      isRajjuMatched: rajjuMatch,
      isDoshamCompatible: isDoshamComp,
      items: items,
      overallVerdict: verdict,
    );
  }

  String _clean(String star) {
    return star.toLowerCase().replaceAll('star_', '').replaceAll('_', '').replaceAll(' ', '').trim();
  }
}
