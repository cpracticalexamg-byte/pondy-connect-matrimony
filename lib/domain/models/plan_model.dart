import 'dart:convert';

class PlanModel {
  final String planId;
  final String name;
  final int priceInr;
  final int durationMonths;
  final int contactsViewLimit;
  final bool chatEnabled;
  final bool highlight;
  final bool horoscopeMatch;
  final String badge;
  final String description;
  final List<String> features;

  const PlanModel({
    required this.planId,
    required this.name,
    required this.priceInr,
    required this.durationMonths,
    required this.contactsViewLimit,
    this.chatEnabled = false,
    this.highlight = false,
    this.horoscopeMatch = true,
    this.badge = '',
    this.description = '',
    this.features = const [],
  });

  factory PlanModel.fromMap(Map<String, String> map) {
    String badge = '';
    String desc = '';
    List<String> feats = [];
    final jsonStr = map['features_json'] ?? '';
    if (jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        badge = decoded['badge']?.toString() ?? '';
        desc = decoded['desc']?.toString() ?? '';
        if (decoded['features'] is List) {
          feats = (decoded['features'] as List).map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return PlanModel(
      planId: map['plan_id'] ?? '',
      name: map['name'] ?? '',
      priceInr: int.tryParse(map['price_inr'] ?? '0') ?? 0,
      durationMonths: int.tryParse(map['duration_months'] ?? '1') ?? 1,
      contactsViewLimit: int.tryParse(map['contacts_view_limit'] ?? '0') ?? 0,
      chatEnabled: (map['chat_enabled'] ?? 'false').toLowerCase() == 'true',
      highlight: (map['highlight'] ?? 'false').toLowerCase() == 'true',
      horoscopeMatch: (map['horoscope_match'] ?? 'true').toLowerCase() == 'true',
      badge: badge,
      description: desc,
      features: feats,
    );
  }
}

