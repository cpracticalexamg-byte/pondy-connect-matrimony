import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/models/plan_model.dart';
import '../csv/csv_schema.dart';
import '../csv/csv_store.dart';

abstract class PlanRepository {
  Future<List<PlanModel>> getPlans();
  Future<List<PlanModel>> getRegularPlans();
  Future<List<PlanModel>> getExclusivePlans();
  Future<PlanModel?> getPlanById(String planId);
  Future<PlanModel?> getPlanByCode(String code);
}

class CsvPlanRepository implements PlanRepository {
  final CsvStore _store;

  CsvPlanRepository({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final rows = await _store.query(
        CsvSchema.plansTable,
        (r) => (r['is_active'] ?? '1') == '1' || (r['is_active'] ?? '').toLowerCase() == 'true',
      );

      if (rows.isNotEmpty) {
        final list = rows.map((m) => PlanModel.fromMap(m)).toList();
        list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        return list;
      }

      // Fallback from asset if table query is empty
      final raw = await rootBundle.loadString('assets/csv/seed/plans.csv');
      final lines = const LineSplitter().convert(raw);
      if (lines.length <= 1) return [];

      final headers = lines.first.split(',').map((e) => e.trim()).toList();
      final plans = <PlanModel>[];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isEmpty) continue;
        // Simple CSV splitter handling quotes
        final parts = _parseCsvLine(line);
        final map = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          map[headers[j]] = j < parts.length ? parts[j].trim() : '';
        }
        plans.add(PlanModel.fromMap(map));
      }
      plans.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return plans;
    } catch (e, stack) {
      AppLogger.error('Failed to load plans', tag: 'PlanRepository', error: e, stackTrace: stack);
      return [];
    }
  }

  @override
  Future<List<PlanModel>> getRegularPlans() async {
    final all = await getPlans();
    return all.where((p) => !p.isExclusive).toList();
  }

  @override
  Future<List<PlanModel>> getExclusivePlans() async {
    final all = await getPlans();
    return all.where((p) => p.isExclusive).toList();
  }

  @override
  Future<PlanModel?> getPlanById(String planId) async {
    final plans = await getPlans();
    final matches = plans.where((p) => p.planId == planId || p.code == planId);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<PlanModel?> getPlanByCode(String code) async {
    final plans = await getPlans();
    final matches = plans.where((p) => p.code == code);
    return matches.isNotEmpty ? matches.first : null;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}
