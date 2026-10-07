import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../../domain/models/plan_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class PlanRepository {
  Future<List<PlanModel>> getPlans();
  Future<PlanModel?> getPlanById(String planId);
  Future<bool> subscribeUser(String userId, String planId, String paymentRef);
}

class CsvPlanRepository implements PlanRepository {
  final CsvStore _store;

  CsvPlanRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final raw = await rootBundle.loadString('assets/csv/master/plans.csv');
      final rows = const CsvToListConverter(shouldParseNumbers: false).convert(raw);
      if (rows.isEmpty) return [];

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final plans = <PlanModel>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;
        final map = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          map[headers[j]] = j < row.length ? row[j].toString().trim() : '';
        }
        plans.add(PlanModel.fromMap(map));
      }
      return plans;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<PlanModel?> getPlanById(String planId) async {
    final plans = await getPlans();
    final matches = plans.where((p) => p.planId == planId);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<bool> subscribeUser(String userId, String planId, String paymentRef) async {
    final plan = await getPlanById(planId);
    if (plan == null) return false;

    final subId = await _store.nextId(CsvSchema.subscriptionsTable, 'sub_id', 'SUB', 6);
    final now = DateTime.now();
    final expiry = now.add(Duration(days: plan.durationMonths * 30));

    await _store.insert(CsvSchema.subscriptionsTable, {
      'sub_id': subId,
      'user_id': userId,
      'plan_id': planId,
      'started_at': now.toIso8601String(),
      'expires_at': expiry.toIso8601String(),
      'payment_ref': paymentRef,
      'status': 'active',
    });

    // Update user row
    await _store.update(
      CsvSchema.usersTable,
      {
        'plan_id': planId,
        'plan_expiry': expiry.toIso8601String(),
      },
      (r) => r['user_id'] == userId,
    );

    return true;
  }
}
