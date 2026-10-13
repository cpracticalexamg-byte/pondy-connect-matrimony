import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/app_logger.dart';
import '../../data/csv/csv_schema.dart';
import '../../data/csv/csv_store.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../models/plan_model.dart';
import 'entitlements_model.dart';

class EntitlementsEngine {
  final CsvStore _store;

  EntitlementsEngine({CsvStore? store}) : _store = store ?? CsvStore.instance;

  Future<Entitlements> getEntitlements(String userId) async {
    if (userId.isEmpty) {
      return Entitlements.free();
    }

    try {
      // 1. Fetch active subscriptions for user
      final subRows = await _store.query(
        CsvSchema.subscriptionsTable,
        (r) => r['user_id'] == userId && r['status'] == 'active',
      );

      if (subRows.isEmpty) {
        return await _buildFreeWithVisibility();
      }

      // Check valid non-expired subscription
      final now = DateTime.now();
      Map<String, String>? validSub;
      PlanModel? activePlan;

      // Sort by newest started_at
      final sortedSubs = List<Map<String, String>>.from(subRows);
      sortedSubs.sort((a, b) {
        final aTime = DateTime.tryParse(a['started_at'] ?? '') ?? DateTime(1970);
        final bTime = DateTime.tryParse(b['started_at'] ?? '') ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      for (final sub in sortedSubs) {
        final expStr = sub['expires_at'] ?? '';
        final exp = DateTime.tryParse(expStr);
        if (exp != null && now.isAfter(exp)) {
          // Grace instant expired: auto-downgrade row status
          await _store.update(
            CsvSchema.subscriptionsTable,
            {'status': 'expired', 'updated_at': now.toIso8601String()},
            (r) => r['subscription_id'] == sub['subscription_id'],
          );
          continue;
        }

        // Active subscription found
        validSub = sub;
        final planId = sub['plan_id'] ?? '';
        activePlan = await _getPlan(planId);
        if (activePlan != null) break;
      }

      if (validSub == null || activePlan == null) {
        return await _buildFreeWithVisibility();
      }

      final expiry = DateTime.tryParse(validSub['expires_at'] ?? '');
      final subWindowId = validSub['subscription_id'] ?? '';

      // Count contact views used within this subscription window
      final contactViews = await _store.query(
        CsvSchema.contactViewsTable,
        (r) =>
            r['viewer_profile_id'] == userId ||
            (subWindowId.isNotEmpty && r['quota_window_id'] == subWindowId),
      );

      final uniqueProfilesViewed = contactViews
          .map((r) => r['viewed_profile_id'] ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .length;

      final visibilityMap = await _loadFieldVisibility(activePlan.tier);

      int remainingContacts = activePlan.contactViewLimit;
      if (remainingContacts > 0) {
        remainingContacts = (activePlan.contactViewLimit - uniqueProfilesViewed).clamp(0, 9999).toInt();
      }

      // Count views today for daily cap
      final todayStr = now.toIso8601String().substring(0, 10);
      final viewsToday = contactViews.where((r) {
        final viewedAt = r['viewed_at'] ?? '';
        return viewedAt.startsWith(todayStr);
      }).length;

      return Entitlements(
        tier: activePlan.tier,
        planName: activePlan.name,
        expiry: expiry,
        contactViewsRemaining: remainingContacts,
        dailyContactCap: activePlan.dailyContactCap,
        dailyContactsViewedToday: viewsToday,
        canMessage: activePlan.unlimitedMessages,
        canViewHoroscope: activePlan.unlimitedHoroscope,
        canViewVerifiedPhotos: activePlan.verifiedPhotoAccess,
        maxInterestsPerDay: 999999,
        fieldVisibility: visibilityMap,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to compute entitlements for $userId', tag: 'EntitlementsEngine', error: e, stackTrace: stack);
      return Entitlements.free();
    }
  }

  Future<PlanModel?> _getPlan(String planIdOrCode) async {
    final rows = await _store.query(
      CsvSchema.plansTable,
      (r) => r['plan_id'] == planIdOrCode || r['code'] == planIdOrCode,
    );
    if (rows.isNotEmpty) {
      return PlanModel.fromMap(rows.first);
    }
    return null;
  }

  Future<Entitlements> _buildFreeWithVisibility() async {
    final visibilityMap = await _loadFieldVisibility('free');
    return Entitlements(
      tier: 'free',
      planName: 'Free Member',
      expiry: null,
      contactViewsRemaining: 0,
      dailyContactCap: 0,
      dailyContactsViewedToday: 0,
      canMessage: false,
      canViewHoroscope: false,
      canViewVerifiedPhotos: false,
      maxInterestsPerDay: 10,
      fieldVisibility: visibilityMap,
    );
  }

  Future<Map<String, bool>> _loadFieldVisibility(String tier) async {
    try {
      final rows = await _store.readAll(CsvSchema.fieldVisibilityTable);
      if (rows.isEmpty) return _defaultFieldVisibility(tier);

      final tierCol = tier == 'till_u_marry' ? 'till_u_marry' : (tier == 'prime_gold' ? 'prime_gold' : (tier == 'gold' ? 'gold' : 'free'));

      final map = <String, bool>{};
      for (final r in rows) {
        final field = r['field_code'] ?? '';
        if (field.isEmpty) continue;
        final val = r[tierCol] ?? '';
        map[field] = val == '1' || val.toLowerCase() == 'true';
      }
      return map.isNotEmpty ? map : _defaultFieldVisibility(tier);
    } catch (_) {
      return _defaultFieldVisibility(tier);
    }
  }

  Map<String, bool> _defaultFieldVisibility(String tier) {
    switch (tier) {
      case 'till_u_marry':
      case 'prime_gold':
        return {
          'caste': true,
          'sub_caste': true,
          'gothram': true,
          'employment_type': true,
          'annual_income': true,
          'education_level': true,
          'occupation': true,
          'family_status': true,
          'general_details': true,
          'dob': true,
          'star': true,
          'rasi': true,
          'horoscope_chart': true,
          'institution': true,
          'employer': true,
          'verified_photos': true,
          'contact_number': true,
        };
      case 'gold':
        return {
          'caste': true,
          'sub_caste': true,
          'gothram': true,
          'employment_type': true,
          'annual_income': true,
          'education_level': true,
          'occupation': true,
          'family_status': true,
          'general_details': true,
          'dob': true,
          'star': true,
          'rasi': true,
          'horoscope_chart': true,
          'institution': true,
          'employer': true,
          'verified_photos': false,
          'contact_number': true,
        };
      case 'free':
      default:
        return {
          'caste': true,
          'sub_caste': true,
          'gothram': true,
          'employment_type': true,
          'annual_income': true,
          'education_level': true,
          'occupation': true,
          'family_status': true,
          'general_details': true,
          'dob': false,
          'star': false,
          'rasi': false,
          'horoscope_chart': false,
          'institution': false,
          'employer': false,
          'verified_photos': false,
          'contact_number': false,
        };
    }
  }
}

final entitlementsEngineProvider = Provider<EntitlementsEngine>((ref) {
  return EntitlementsEngine();
});

final entitlementsProvider = FutureProvider<Entitlements>((ref) async {
  final auth = ref.watch(authStateProvider);
  final userId = auth.user?.userId ?? '';
  final engine = ref.watch(entitlementsEngineProvider);
  return engine.getEntitlements(userId);
});
