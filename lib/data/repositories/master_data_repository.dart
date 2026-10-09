import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../../core/utils/app_logger.dart';

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
      String raw = '';
      final file = File('assets/csv/master/$filename');
      if (await file.exists()) {
        raw = await file.readAsString();
      } else {
        final dbFile = File('db/master/$filename');
        if (await dbFile.exists()) {
          raw = await dbFile.readAsString();
        } else {
          raw = await rootBundle.loadString('assets/csv/master/$filename');
        }
      }

      if (raw.trim().isEmpty) {
        try {
          raw = await rootBundle.loadString('assets/csv/master/$filename');
        } catch (_) {}
      }

      final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(normalized);
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
    } catch (e, stack) {
      AppLogger.error('Failed to load master CSV $filename', tag: 'MasterDataRepository', error: e, stackTrace: stack);
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

  static const Map<String, String> _casteIdToCode = {
    '1': 'mudaliar',
    '2': 'kongu_vellalar_gounder',
    '3': 'vanniyar',
    '4': 'nadar',
    '5': 'thevar_mukkulathor',
    '6': 'pillai_saiva',
    '7': 'brahmin_iyer',
    '8': 'brahmin_iyengar',
    '9': 'chettiar_nattukottai',
    '10': 'chettiar_general',
    '11': 'yadava_konar',
    '12': 'viswakarma',
    '13': 'naidu_balija',
    '14': 'reddy_reddiar',
    '15': 'adi_dravidar',
    '16': 'devendra_kula_vellalar',
    '17': 'arunthathiyar',
    '18': 'meenavar_pattanavar',
    '19': 'paravar_bharathar',
    '20': 'saurashtra',
    '21': 'senai_thalaivar',
    '22': 'mutharaiyar',
    '23': 'rajaka_vannar',
    '24': 'maruthuvar_navithar',
  };

  static const Map<String, String> _casteCodeToId = {
    'mudaliar': '1',
    'kongu_vellalar_gounder': '2',
    'vanniyar': '3',
    'nadar': '4',
    'thevar_mukkulathor': '5',
    'pillai_saiva': '6',
    'brahmin_iyer': '7',
    'brahmin_iyengar': '8',
    'chettiar_nattukottai': '9',
    'chettiar_general': '10',
    'yadava_konar': '11',
    'viswakarma': '12',
    'naidu_balija': '13',
    'reddy_reddiar': '14',
    'adi_dravidar': '15',
    'devendra_kula_vellalar': '16',
    'arunthathiyar': '17',
    'meenavar_pattanavar': '18',
    'paravar_bharathar': '19',
    'saurashtra': '20',
    'senai_thalaivar': '21',
    'mutharaiyar': '22',
    'rajaka_vannar': '23',
    'maruthuvar_navithar': '24',
  };

  Future<List<MasterItem>> getEmploymentTypes() {
    return _loadMaster('employment_type.csv', (m) => MasterItem(id: m['id'] ?? '', nameEn: m['name_en'] ?? '', nameTa: m['name_ta'] ?? ''));
  }

  Future<List<MasterItem>> getSubcastes({String? casteId}) async {
    final list = await _loadMaster('sub_caste.csv', (m) {
      final rawCasteId = m['caste_id'] ?? '';
      final code = _casteIdToCode[rawCasteId] ?? rawCasteId;
      return MasterItem(
        id: m['code'] ?? m['id'] ?? '',
        nameEn: m['name_en'] ?? '',
        nameTa: m['name_ta'] ?? '',
        extras: {
          'caste_id': code,
          'numeric_caste_id': rawCasteId,
        },
      );
    });
    if (casteId == null || casteId.isEmpty) return list;
    final normalizedCasteCode = _casteIdToCode[casteId] ?? casteId;
    final normalizedCasteId = _casteCodeToId[casteId] ?? casteId;
    return list.where((item) =>
      item.extras['caste_id'] == normalizedCasteCode ||
      item.extras['numeric_caste_id'] == normalizedCasteId ||
      item.id == 'subcaste_none'
    ).toList();
  }

  Future<List<MasterItem>> getCountries() {
    return _loadMaster('country.csv', (m) => MasterItem(
      id: (m['iso3']?.isNotEmpty ?? false) ? m['iso3']! : (m['id'] ?? ''),
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {
        'id': m['id'] ?? '',
        'iso2': m['iso2'] ?? '',
        'iso3': m['iso3'] ?? '',
        'dial_code': m['dial_code'] ?? '',
        'currency_code': m['currency_code'] ?? '',
      },
    ));
  }

  Future<List<MasterItem>> getStates({String? countryId}) async {
    final list = await _loadMaster('state.csv', (m) {
      final rawCountryId = m['country_id'] ?? '';
      final countryIso3 = rawCountryId == '1' ? 'IND' : rawCountryId;
      return MasterItem(
        id: (m['code']?.isNotEmpty ?? false) ? m['code']! : (m['id'] ?? ''),
        nameEn: m['name_en'] ?? '',
        nameTa: m['name_ta'] ?? '',
        extras: {
          'id': m['id'] ?? '',
          'code': m['code'] ?? '',
          'country_id': countryIso3,
          'numeric_country_id': rawCountryId,
        },
      );
    });
    if (countryId == null || countryId.isEmpty) return list;
    return list.where((item) =>
      item.extras['country_id'] == countryId ||
      item.extras['numeric_country_id'] == countryId
    ).toList();
  }

  Future<List<MasterItem>> getCities({String? districtId}) async {
    final list = await _loadMaster('city.csv', (m) => MasterItem(
      id: m['code'] ?? m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {
        'id': m['id'] ?? '',
        'district_id': m['district_id'] ?? '',
        'code': m['code'] ?? '',
      },
    ));
    if (districtId == null || districtId.isEmpty) return list;
    return list.where((item) => item.extras['district_id'] == districtId).toList();
  }

  Future<List<MasterItem>> getPondicherryCommunes() async {
    final cities = await getCities(districtId: '1');
    return cities.map((c) {
      String nameEn = c.nameEn;
      if (c.id == 'ozhukarai' || c.nameEn.toLowerCase().contains('ozhukarai')) {
        nameEn = 'Oulgaret (Ozhukarai)';
      }
      return MasterItem(
        id: c.id,
        nameEn: nameEn,
        nameTa: c.nameTa,
        extras: {
          'region': 'Puducherry',
          'type': (c.id == 'puducherry_town' || c.id == 'ozhukarai') ? 'Municipality' : 'Commune',
        },
      );
    }).toList();
  }

  Future<List<MasterItem>> getHobbies() {
    return _loadMaster('hobby_interest.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
      extras: {'category': m['category'] ?? ''},
    ));
  }

  Future<List<MasterItem>> getLanguages() {
    return _loadMaster('language_known.csv', (m) => MasterItem(
      id: m['id'] ?? '',
      nameEn: m['name_en'] ?? '',
      nameTa: m['name_ta'] ?? '',
    ));
  }
}
