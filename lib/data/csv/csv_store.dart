import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'csv_lock.dart';
import 'csv_schema.dart';

class CsvStore {
  static CsvStore? _instance;
  static CsvStore get instance => _instance ??= CsvStore._();

  CsvStore._();

  Directory? _dbDirectory;
  final Map<String, List<Map<String, String>>> _memoryCache = {};
  bool _initialized = false;

  bool _isCustomDir = false;

  Future<void> initialize({Directory? customDir}) async {
    if (_initialized && customDir == null) return;

    _isCustomDir = customDir != null;
    if (customDir != null) {
      _dbDirectory = customDir;
    } else {
      final appDocs = await getApplicationDocumentsDirectory();
      _dbDirectory = Directory('${appDocs.path}/pondy_db');
    }

    if (!await _dbDirectory!.exists()) {
      await _dbDirectory!.create(recursive: true);
    }

    await _initSchemaAndSeeds();
    _initialized = true;
  }

  Future<void> _initSchemaAndSeeds() async {
    // Check if _meta exists
    final metaFile = File('${_dbDirectory!.path}/${CsvSchema.metaTable}.csv');
    if (!await metaFile.exists()) {
      // First launch: initialize all tables with headers
      for (final entry in CsvSchema.tableColumns.entries) {
        final tableFile = File('${_dbDirectory!.path}/${entry.key}.csv');
        if (!await tableFile.exists()) {
          // Check if seed exists in assets/csv/seed/{table}.csv
          String initialCsv = '';
          if (_isCustomDir) {
            final header = const ListToCsvConverter().convert([entry.value]);
            initialCsv = '$header\r\n';
          } else {
            try {
              initialCsv = await rootBundle.loadString('assets/csv/seed/${entry.key}.csv');
            } catch (_) {
              final header = const ListToCsvConverter().convert([entry.value]);
              initialCsv = '$header\r\n';
            }
          }
          await tableFile.writeAsString(initialCsv, encoding: utf8, flush: true);
        }
      }

      // Write meta
      final metaContent = const ListToCsvConverter().convert([
        ['key', 'value'],
        ['schema_version', CsvSchema.currentVersion.toString()],
        ['initialized_at', DateTime.now().toIso8601String()],
      ]);
      await metaFile.writeAsString('$metaContent\r\n', encoding: utf8, flush: true);
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized || _dbDirectory == null) {
      await initialize();
    }
  }

  File _getTableFile(String table) {
    if (_dbDirectory == null) {
      throw StateError('CsvStore not initialized. Call initialize() first.');
    }
    return File('${_dbDirectory!.path}/$table.csv');
  }

  /// Read all rows for a table
  Future<List<Map<String, String>>> readAll(String table) async {
    await _ensureInitialized();
    if (_memoryCache.containsKey(table)) {
      return List<Map<String, String>>.from(_memoryCache[table]!);
    }

    return await CsvLock.synchronized(table, () async {
      final file = _getTableFile(table);
      if (!await file.exists()) {
        final columns = CsvSchema.tableColumns[table] ?? [];
        if (columns.isNotEmpty) {
          final header = const ListToCsvConverter().convert([columns]);
          await file.writeAsString('$header\r\n', encoding: utf8, flush: true);
        }
        _memoryCache[table] = [];
        return [];
      }

      final content = await file.readAsString(encoding: utf8);
      if (content.trim().isEmpty) {
        _memoryCache[table] = [];
        return [];
      }

      List<List<dynamic>> rows;
      if (content.length > 50000) {
        rows = await compute(_parseCsvIsolate, content);
      } else {
        rows = const CsvToListConverter(shouldParseNumbers: false).convert(content);
      }

      if (rows.isEmpty) {
        _memoryCache[table] = [];
        return [];
      }

      final headers = rows.first.map((e) => e.toString().trim()).toList();
      final result = <Map<String, String>>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) {
          continue;
        }
        final map = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          final val = j < row.length ? row[j].toString().trim() : '';
          map[headers[j]] = val;
        }
        result.add(map);
      }

      _memoryCache[table] = result;
      return List<Map<String, String>>.from(result);
    });
  }

  /// Insert a single row with atomic write and cache update
  Future<void> insert(String table, Map<String, String> row) async {
    await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      rows.add(Map<String, String>.from(row));
      await _writeAllInternal(table, rows);
      _memoryCache[table] = rows;
    });
  }

  /// Bulk insert rows
  Future<void> insertAll(String table, List<Map<String, String>> newRows) async {
    await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      rows.addAll(newRows.map((r) => Map<String, String>.from(r)));
      await _writeAllInternal(table, rows);
      _memoryCache[table] = rows;
    });
  }

  /// Update rows matching the predicate
  Future<int> update(
    String table,
    Map<String, String> values,
    bool Function(Map<String, String>) where,
  ) async {
    return await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      int updatedCount = 0;

      for (int i = 0; i < rows.length; i++) {
        if (where(rows[i])) {
          rows[i].addAll(values);
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await _writeAllInternal(table, rows);
        _memoryCache[table] = rows;
      }

      return updatedCount;
    });
  }

  /// Delete rows matching the predicate
  Future<int> delete(
    String table,
    bool Function(Map<String, String>) where,
  ) async {
    return await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      final initialCount = rows.length;
      rows.removeWhere(where);
      final deletedCount = initialCount - rows.length;

      if (deletedCount > 0) {
        await _writeAllInternal(table, rows);
        _memoryCache[table] = rows;
      }

      return deletedCount;
    });
  }

  /// Query rows using predicate
  Future<List<Map<String, String>>> query(
    String table,
    bool Function(Map<String, String>) predicate,
  ) async {
    final rows = await readAll(table);
    return rows.where(predicate).toList();
  }

  /// Generate next ID with prefix (e.g. PC000123)
  Future<String> nextId(String table, String idColumn, String prefix, int digits) async {
    final rows = await readAll(table);
    int maxNumber = 0;

    for (final row in rows) {
      final id = row[idColumn] ?? '';
      if (id.startsWith(prefix)) {
        final numPart = id.substring(prefix.length);
        final val = int.tryParse(numPart);
        if (val != null && val > maxNumber) {
          maxNumber = val;
        }
      }
    }

    final nextVal = maxNumber + 1;
    return '$prefix${nextVal.toString().padLeft(digits, '0')}';
  }

  /// Atomic write: write to table.csv.tmp then rename
  Future<void> _writeAllInternal(String table, List<Map<String, String>> rows) async {
    final file = _getTableFile(table);
    final tmpFile = File('${file.path}.tmp');

    final columns = CsvSchema.tableColumns[table] ??
        (rows.isNotEmpty ? rows.first.keys.toList() : <String>[]);

    final csvRows = <List<dynamic>>[];
    csvRows.add(columns);

    for (final row in rows) {
      final list = columns.map((col) => row[col] ?? '').toList();
      csvRows.add(list);
    }

    final content = const ListToCsvConverter(eol: '\r\n').convert(csvRows);
    await tmpFile.writeAsString(content, encoding: utf8, flush: true);

    if (await file.exists()) {
      await file.delete();
    }
    await tmpFile.rename(file.path);
  }

  /// Row counts for all tables
  Future<Map<String, int>> getRowCounts() async {
    final counts = <String, int>{};
    for (final table in CsvSchema.tableColumns.keys) {
      final rows = await readAll(table);
      counts[table] = rows.length;
    }
    return counts;
  }

  /// Export all CSVs as a zip archive
  Future<List<int>> exportAsZip() async {
    await _ensureInitialized();
    final archive = Archive();
    for (final table in CsvSchema.tableColumns.keys) {
      final file = _getTableFile(table);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile('$table.csv', bytes.length, bytes));
      }
    }
    final encoder = ZipEncoder();
    return encoder.encode(archive)!;
  }

  /// Reset all tables to empty headers or bundled seeds
  Future<void> resetDatabase() async {
    _memoryCache.clear();
    if (_dbDirectory != null && await _dbDirectory!.exists()) {
      await _dbDirectory!.delete(recursive: true);
      await _dbDirectory!.create(recursive: true);
    }
    _initialized = false;
    await initialize();
  }

  /// Invalidate cache
  void invalidateCache([String? table]) {
    if (table != null) {
      _memoryCache.remove(table);
    } else {
      _memoryCache.clear();
    }
  }
}

List<List<dynamic>> _parseCsvIsolate(String content) {
  return const CsvToListConverter(shouldParseNumbers: false).convert(content);
}
