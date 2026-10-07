import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

class MasterItem {
  final String id;
  final String nameEn;
  final String nameTa;
  final Map<String, dynamic> extras;

  const MasterItem({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    this.extras = const {},
  });

  String localizedName(String locale) => locale == 'ta' ? nameTa : nameEn;
}

class MasterDataRepository {
  static final MasterDataRepository instance = MasterDataRepository._();
  MasterDataRepository._();

  final Map<String, List<MasterItem>> _cache = {};

  Future<List<MasterItem>> _loadMaster(String filename, MasterItem Function(Map<String, String>) mapper) async {
    if (_cache.containsKey(filename)) {
      return _cache[filename]!;
    }

    try {
      final raw = await rootBundle.loadString('assets/csv/master/$filename');
      final rows = const CsvToListConverter(shouldParseNumbers: false).convert(raw);
      if (rows.isEmpty) return [];

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final items = <MasterItem>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) continue;
        final map = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          map[headers[j]] = j < row.length ? row[j].toString().trim() : '';
        }
        items.add(mapper(map));
      }

      _cache[filename] = items;
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<List<MasterItem>> getReligions() {
    return _loadMaster('religions.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getDivisions({String? religionId}) async {
    final list = await _loadMaster('divisions.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {'religion_id': m['religion_id'] ?? ''},
    ));
    if (religionId == null || religionId.isEmpty) return list;
    return list.where((item) {
      final rel = item.extras['religion_id'] as String? ?? '';
      return rel == 'all' || rel == religionId || item.id == 'none';
    }).toList();
  }

  Future<List<MasterItem>> getCastes({String? religionId}) async {
    final list = await _loadMaster('castes.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {'religion_id': m['religion_id'] ?? ''},
    ));
    if (religionId == null || religionId.isEmpty) return list;
    return list.where((item) {
      final rel = item.extras['religion_id'] as String? ?? '';
      return rel == 'all' || rel == religionId || item.id == 'caste_none';
    }).toList();
  }

  Future<List<MasterItem>> getMotherTongues() {
    return _loadMaster('mother_tongues.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getStars() {
    return _loadMaster('stars.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['star_name_en'] ?? '',
      nameTa: m['star_name_ta'] ?? '',
      extras: {'rasi_ids': (m['rasi_ids'] ?? '').split(';')},
    ));
  }

  Future<List<MasterItem>> getRasis() {
    return _loadMaster('rasis.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['rasi_name_en'] ?? '',
      nameTa: m['rasi_name_ta'] ?? '',
      extras: {'lord_en': m['lord_en'] ?? ''},
    ));
  }

  Future<List<MasterItem>> getDoshams() {
    return _loadMaster('doshams.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getHeights() {
    return _loadMaster('heights.csv', (m) => MasterItem(
      id: m['cm'] ?? '',
      nameEn: m['formatted_en'] ?? '',
      nameTa: m['formatted_ta'] ?? '',
      extras: {'cm': int.tryParse(m['cm'] ?? '0') ?? 0},
    ));
  }

  Future<List<MasterItem>> getEducationLevels() {
    return _loadMaster('education_levels.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {'category': m['category'] ?? ''},
    ));
  }

  Future<List<MasterItem>> getOccupations() {
    return _loadMaster('occupations.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {'category': m['category'] ?? ''},
    ));
  }

  Future<List<MasterItem>> getIncomeRanges() {
    return _loadMaster('income_ranges.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['label_en'] ?? '',
      nameTa: m['label_ta'] ?? '',
      extras: {
        'min': int.tryParse(m['min_inr'] ?? '0') ?? 0,
        'max': int.tryParse(m['max_inr'] ?? '0') ?? 0,
      },
    ));
  }

  Future<List<MasterItem>> getDistricts() {
    return _loadMaster('districts.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['district_en'] ?? '',
      nameTa: m['district_ta'] ?? '',
      extras: {'state': m['state'] ?? ''},
    ));
  }

  Future<List<MasterItem>> getMaritalStatuses() {
    return _loadMaster('marital_statuses.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getFamilyStatus() {
    return _loadMaster('family_status.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getFamilyType() {
    return _loadMaster('family_type.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getFamilyValues() {
    return _loadMaster('family_values.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getDiet() {
    return _loadMaster('diet.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getEmploymentTypes() {
    return _loadMaster('employment_types.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }
}
