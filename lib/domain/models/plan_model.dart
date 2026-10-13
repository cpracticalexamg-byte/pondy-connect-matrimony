import 'dart:convert';
import '../../core/utils/app_logger.dart';

class PlanModel {
  final String planId;
  final String code;
  final String name;
  final String tier; // 'gold', 'prime_gold', 'till_u_marry', 'highlighter'
  final int priceInr;
  final int listPrice;
  final String promoStart;
  final String promoEnd;
  final int durationDays;
  final int durationMonths;
  final int contactViewLimit; // -1 for unlimited
  final int dailyContactCap;
  final bool unlimitedMessages;
  final bool unlimitedHoroscope;
  final bool verifiedPhotoAccess;
  final bool isBestValue;
  final bool isExclusive;
  final bool endsOnMarriage;
  final List<String> features;
  final int sortOrder;
  final bool isActive;

  const PlanModel({
    required this.planId,
    required this.code,
    required this.name,
    required this.tier,
    required this.priceInr,
    this.listPrice = 0,
    this.promoStart = '',
    this.promoEnd = '',
    this.durationDays = 90,
    this.durationMonths = 3,
    this.contactViewLimit = 40,
    this.dailyContactCap = 40,
    this.unlimitedMessages = true,
    this.unlimitedHoroscope = true,
    this.verifiedPhotoAccess = false,
    this.isBestValue = false,
    this.isExclusive = false,
    this.endsOnMarriage = false,
    this.features = const [],
    this.sortOrder = 1,
    this.isActive = true,
  });

  bool get hasActivePromotion {
    if (listPrice <= priceInr) return false;
    if (promoStart.isEmpty || promoEnd.isEmpty) return false;
    try {
      final now = DateTime.now();
      final start = DateTime.parse(promoStart);
      final end = DateTime.parse(promoEnd);
      return now.isAfter(start) && now.isBefore(end);
    } catch (_) {
      return false;
    }
  }

  int get discountPercentage {
    if (!hasActivePromotion || listPrice <= 0) return 0;
    return (((listPrice - priceInr) / listPrice) * 100).round();
  }

  String get perMonthBadge {
    if (endsOnMarriage || durationMonths <= 0) return '';
    final perMonth = (priceInr / durationMonths).round();
    return '~₹$perMonth per month';
  }

  factory PlanModel.fromMap(Map<String, String> map) {
    List<String> feats = [];
    final jsonStr = map['features_json'] ?? '';
    if (jsonStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          feats = decoded.map((e) => e.toString()).toList();
        } else if (decoded is Map && decoded['features'] is List) {
          feats = (decoded['features'] as List).map((e) => e.toString()).toList();
        }
      } catch (e) {
        AppLogger.warning('Failed to parse features_json for plan ${map['plan_id']}', tag: 'PlanModel', error: e);
      }
    }

    return PlanModel(
      planId: map['plan_id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      tier: map['tier'] ?? 'gold',
      priceInr: int.tryParse(map['price_inr'] ?? '0') ?? 0,
      listPrice: int.tryParse(map['list_price'] ?? '0') ?? 0,
      promoStart: map['promo_start'] ?? '',
      promoEnd: map['promo_end'] ?? '',
      durationDays: int.tryParse(map['duration_days'] ?? '90') ?? 90,
      durationMonths: int.tryParse(map['duration_months'] ?? '3') ?? 3,
      contactViewLimit: int.tryParse(map['contact_view_limit'] ?? '40') ?? 40,
      dailyContactCap: int.tryParse(map['daily_contact_cap'] ?? '40') ?? 40,
      unlimitedMessages: (map['unlimited_messages'] ?? 'true').toLowerCase() == 'true' || (map['unlimited_messages'] == '1'),
      unlimitedHoroscope: (map['unlimited_horoscope'] ?? 'true').toLowerCase() == 'true' || (map['unlimited_horoscope'] == '1'),
      verifiedPhotoAccess: (map['verified_photo_access'] ?? 'false').toLowerCase() == 'true' || (map['verified_photo_access'] == '1'),
      isBestValue: (map['is_best_value'] ?? 'false').toLowerCase() == 'true' || (map['is_best_value'] == '1'),
      isExclusive: (map['is_exclusive'] ?? 'false').toLowerCase() == 'true' || (map['is_exclusive'] == '1'),
      endsOnMarriage: (map['ends_on_marriage'] ?? 'false').toLowerCase() == 'true' || (map['ends_on_marriage'] == '1'),
      features: feats,
      sortOrder: int.tryParse(map['sort_order'] ?? '1') ?? 1,
      isActive: (map['is_active'] ?? 'true').toLowerCase() == 'true' || (map['is_active'] == '1'),
    );
  }

  Map<String, String> toMap() {
    return {
      'plan_id': planId,
      'code': code,
      'name': name,
      'tier': tier,
      'price_inr': priceInr.toString(),
      'list_price': listPrice.toString(),
      'promo_start': promoStart,
      'promo_end': promoEnd,
      'duration_days': durationDays.toString(),
      'duration_months': durationMonths.toString(),
      'contact_view_limit': contactViewLimit.toString(),
      'daily_contact_cap': dailyContactCap.toString(),
      'unlimited_messages': unlimitedMessages ? '1' : '0',
      'unlimited_horoscope': unlimitedHoroscope ? '1' : '0',
      'verified_photo_access': verifiedPhotoAccess ? '1' : '0',
      'is_best_value': isBestValue ? '1' : '0',
      'is_exclusive': isExclusive ? '1' : '0',
      'ends_on_marriage': endsOnMarriage ? '1' : '0',
      'features_json': jsonEncode(features),
      'sort_order': sortOrder.toString(),
      'is_active': isActive ? '1' : '0',
    };
  }
}
