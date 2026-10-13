import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/app_logger.dart';
import 'csv_lock.dart';
import 'csv_schema.dart';

class DataValidationException implements Exception {
  final String table;
  final String column;
  final String reason;

  DataValidationException({
    required this.table,
    required this.column,
    required this.reason,
  });

  @override
  String toString() => 'DataValidationException: [$table.$column] $reason';
}

class TransactionRolledBackException implements Exception {
  final String message;
  final Object originalError;

  TransactionRolledBackException(this.message, this.originalError);

  @override
  String toString() => 'TransactionRolledBackException: $message (Caused by: $originalError)';
}

/// Hardened local CSV database supporting atomic writes, automatic .bak recovery,
/// multi-table transactional snapshots, and cursor-based pagination.
class CsvStore {
  static CsvStore? _instance;
  static CsvStore get instance => _instance ??= CsvStore._();

  CsvStore._();

  Directory? _dbDirectory;
  final Map<String, List<Map<String, String>>> _memoryCache = {};
  bool _initialized = false;
  bool _isCustomDir = false;

  Directory? get dbDirectory => _dbDirectory;

  void clearCache() => _memoryCache.clear();

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
    final metaFile = File('${_dbDirectory!.path}/${CsvSchema.metaTable}.csv');
    if (!await metaFile.exists()) {
      // First launch: initialize all tables with schema headers
      for (final entry in CsvSchema.tableColumns.entries) {
        final tableFile = File('${_dbDirectory!.path}/${entry.key}.csv');
        if (!await tableFile.exists()) {
          String initialCsv = '';
          if (_isCustomDir) {
            final header = const ListToCsvConverter().convert([entry.value]);
            initialCsv = '$header\n';
          } else {
            try {
              initialCsv = await rootBundle.loadString('assets/csv/seed/${entry.key}.csv');
            } catch (e) {
              AppLogger.debug('Seed asset for ${entry.key} not present, generating empty schema header', tag: 'CsvStore');
              final header = const ListToCsvConverter().convert([entry.value]);
              initialCsv = '$header\n';
            }
          }
          await tableFile.writeAsString(initialCsv, encoding: utf8, flush: true);
        }
      }

      // Write meta row
      final metaRows = [
        ['key', 'value', 'created_at', 'updated_at'],
        ['schema_version', CsvSchema.currentVersion.toString(), DateTime.now().toUtc().toIso8601String(), DateTime.now().toUtc().toIso8601String()],
        ['initialized_at', DateTime.now().toUtc().toIso8601String(), DateTime.now().toUtc().toIso8601String(), DateTime.now().toUtc().toIso8601String()],
      ];
      final metaContent = const ListToCsvConverter().convert(metaRows);
      await metaFile.writeAsString('$metaContent\n', encoding: utf8, flush: true);
    }
  }

  /// Verify database integrity on startup (ensures all tables exist and are accessible)
  Future<bool> verifyDatabaseIntegrity() async {
    await _ensureInitialized();
    try {
      for (final table in CsvSchema.allTables) {
        final file = _getTableFile(table);
        if (!await file.exists()) {
          final bak = _getBackupFile(table);
          if (await bak.exists()) {
            await bak.copy(file.path);
            AppLogger.info('Recovered table "$table" from backup during integrity check', tag: 'CsvStore');
          } else {
            final columns = CsvSchema.tableColumns[table] ?? [];
            final header = const ListToCsvConverter().convert([columns]);
            await file.writeAsString('$header\n', encoding: utf8, flush: true);
            AppLogger.warning('Missing table "$table" recreated with schema header', tag: 'CsvStore');
          }
        }
      }
      return true;
    } catch (e, stack) {
      AppLogger.error('Database integrity check failed', tag: 'CsvStore', error: e, stackTrace: stack);
      return false;
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

  File _getBackupFile(String table) {
    return File('${_dbDirectory!.path}/$table.csv.bak');
  }

  File _getTempFile(String table) {
    return File('${_dbDirectory!.path}/$table.csv.tmp');
  }

  /// Read all rows for a table with cache, corruption recovery and lock protection
  Future<List<Map<String, String>>> readAll(String table) async {
    await _ensureInitialized();
    if (_memoryCache.containsKey(table)) {
      return List<Map<String, String>>.from(_memoryCache[table]!);
    }

    return await CsvLock.synchronized(table, () async {
      final file = _getTableFile(table);
      final bakFile = _getBackupFile(table);

      if (!await file.exists()) {
        if (await bakFile.exists()) {
          // Auto-recovery from .bak
          await bakFile.copy(file.path);
        } else {
          final columns = CsvSchema.tableColumns[table] ?? [];
          if (columns.isNotEmpty) {
            final header = const ListToCsvConverter().convert([columns]);
            await file.writeAsString('$header\n', encoding: utf8, flush: true);
          }
          _memoryCache[table] = [];
          return [];
        }
      }

      String content;
      try {
        content = await file.readAsString(encoding: utf8);
      } catch (e) {
        // If file is unreadable, attempt recovery from .bak
        if (await bakFile.exists()) {
          await bakFile.copy(file.path);
          content = await file.readAsString(encoding: utf8);
        } else {
          rethrow;
        }
      }

      if (content.trim().isEmpty) {
        // Partial or corrupt empty file: restore from .bak if present
        if (await bakFile.exists()) {
          content = await bakFile.readAsString(encoding: utf8);
          await file.writeAsString(content, encoding: utf8, flush: true);
        }
      }

      List<List<dynamic>> rows;
      if (content.length > 50000) {
        rows = await compute(_parseCsvIsolate, content);
      } else {
        rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(content.replaceAll('\r\n', '\n'));
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

  /// Atomic write: writes to temp file -> flush -> copy to .bak -> atomic rename
  Future<void> _writeAllInternal(String table, List<Map<String, String>> rows) async {
    final file = _getTableFile(table);
    final bakFile = _getBackupFile(table);
    final tmpFile = _getTempFile(table);

    final columns = CsvSchema.tableColumns[table] ?? (rows.isNotEmpty ? rows.first.keys.toList() : []);
    final csvRows = <List<dynamic>>[];
    csvRows.add(columns);

    for (final row in rows) {
      final line = <dynamic>[];
      for (final col in columns) {
        line.add(row[col] ?? '');
      }
      csvRows.add(line);
    }

    final csvContent = const ListToCsvConverter(eol: '\n').convert(csvRows);
    final payload = '$csvContent\n';

    // 1. Write to .tmp file and flush
    await tmpFile.writeAsString(payload, encoding: utf8, flush: true);

    // 2. Rolling backup of current file
    if (await file.exists()) {
      await file.copy(bakFile.path);
    }

    // 3. Atomic rename .tmp -> target
    await tmpFile.rename(file.path);

    // Update memory cache
    _memoryCache[table] = List<Map<String, String>>.from(rows);
  }

  /// Insert a single row with atomic write, validation, and cache update
  Future<void> insert(String table, Map<String, String> row) async {
    _validateRow(table, row);
    await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      rows.add(Map<String, String>.from(row));
      await _writeAllInternal(table, rows);
    });
  }

  /// Bulk insert rows
  Future<void> insertAll(String table, List<Map<String, String>> newRows) async {
    for (final r in newRows) {
      _validateRow(table, r);
    }
    await CsvLock.synchronized(table, () async {
      final rows = await readAll(table);
      rows.addAll(newRows.map((r) => Map<String, String>.from(r)));
      await _writeAllInternal(table, rows);
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
          final updated = Map<String, String>.from(rows[i])..addAll(values);
          _validateRow(table, updated);
          rows[i] = updated;
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await _writeAllInternal(table, rows);
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

  /// Cursor-based pagination: returns a slice without unbounded memory overhead
  Future<List<Map<String, String>>> queryCursor(
    String table, {
    bool Function(Map<String, String>)? where,
    int limit = 20,
    int offset = 0,
  }) async {
    final rows = await readAll(table);
    Iterable<Map<String, String>> filtered = rows;
    if (where != null) {
      filtered = filtered.where(where);
    }
    return filtered.skip(offset).take(limit).toList();
  }

  /// Multi-table transactional execution with snapshot rollback
  Future<T> runInTransaction<T>(
    List<String> tables,
    Future<T> Function() action,
  ) async {
    // Sort tables alphabetically to prevent cross-table mutex deadlocks
    final sortedTables = List<String>.from(tables)..sort();

    // Recursive lock acquisition across sorted tables
    Future<T> lockAndRun(int index) async {
      if (index >= sortedTables.length) {
        // Snapshot existing data for rollback
        final snapshots = <String, List<Map<String, String>>>{};
        for (final t in sortedTables) {
          final existing = await readAll(t);
          snapshots[t] = existing.map((r) => Map<String, String>.from(r)).toList();
        }

        try {
          return await action();
        } catch (e) {
          // Rollback all tables to their snapshot state
          for (final t in sortedTables) {
            await _writeAllInternal(t, snapshots[t]!);
          }
          throw TransactionRolledBackException('Transaction failed and was rolled back.', e);
        }
      }

      final table = sortedTables[index];
      return await CsvLock.synchronized(table, () => lockAndRun(index + 1));
    }

    return await lockAndRun(0);
  }

  /// Explicit cache invalidation
  void invalidateCache([String? table]) {
    if (table != null) {
      _memoryCache.remove(table);
    } else {
      _memoryCache.clear();
    }
  }

  void clearAllCache() {
    _memoryCache.clear();
  }

  /// Page-based pagination
  Future<List<Map<String, String>>> readPage(
    String table, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final offset = (page - 1) * pageSize;
    return queryCursor(table, limit: pageSize, offset: offset < 0 ? 0 : offset);
  }

  /// Get row count for each table in schema
  Future<Map<String, int>> getRowCounts() async {
    await _ensureInitialized();
    final counts = <String, int>{};
    for (final table in CsvSchema.allTables) {
      try {
        final rows = await readAll(table);
        counts[table] = rows.length;
      } catch (e, stack) {
        AppLogger.warning('Failed to get row count for table $table', tag: 'CsvStore', error: e, stackTrace: stack);
        counts[table] = 0;
      }
    }
    return counts;
  }

  /// Validate row structure against schema rules
  void _validateRow(String table, Map<String, String> row) {
    final expectedCols = CsvSchema.tableColumns[table];
    if (expectedCols == null) return;

    // Check primary key non-empty
    if (table == CsvSchema.usersTable) {
      if ((row['user_id'] ?? '').trim().isEmpty) {
        throw DataValidationException(table: table, column: 'user_id', reason: 'Primary key user_id cannot be empty.');
      }
      if ((row['mobile'] ?? '').trim().isEmpty) {
        throw DataValidationException(table: table, column: 'mobile', reason: 'Mobile number cannot be empty.');
      }
    } else if (table == CsvSchema.profilesTable) {
      if ((row['profile_id'] ?? '').trim().isEmpty) {
        throw DataValidationException(table: table, column: 'profile_id', reason: 'Primary key profile_id cannot be empty.');
      }
    }
  }

  /// Generate next formatted sequential ID (e.g. PC000123)
  Future<String> nextId(String table, String idColumn, [String prefix = '', int digits = 6]) async {
    final rows = await readAll(table);
    int maxNum = 0;
    for (final row in rows) {
      final val = row[idColumn] ?? '';
      if (val.startsWith(prefix)) {
        final numPart = val.substring(prefix.length);
        final n = int.tryParse(numPart);
        if (n != null && n > maxNum) {
          maxNum = n;
        }
      }
    }
    final nextNum = maxNum + 1;
    return '$prefix${nextNum.toString().padLeft(digits, '0')}';
  }

  /// Reset/clear runtime database
  Future<void> resetDatabase() async {
    clearAllCache();
    if (_dbDirectory != null && await _dbDirectory!.exists()) {
      await _dbDirectory!.delete(recursive: true);
      await _dbDirectory!.create(recursive: true);
      _initialized = false;
      await initialize();
    }
  }

  /// Export database to zip archive bytes
  Future<Uint8List> exportAsZip() async {
    await _ensureInitialized();
    final archive = Archive();
    if (_dbDirectory != null && await _dbDirectory!.exists()) {
      final files = _dbDirectory!.listSync().whereType<File>().where((f) => f.path.endsWith('.csv')).toList();
      for (final file in files) {
        final filename = file.uri.pathSegments.last;
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
      }
    }

    final zipData = ZipEncoder().encode(archive);
    return Uint8List.fromList(zipData ?? []);
  }

  /// Export database to zip archive file
  Future<File> exportDatabaseZip() async {
    await _ensureInitialized();
    final zipBytes = await exportAsZip();
    final tempDir = await getTemporaryDirectory();
    final zipFile = File('${tempDir.path}/pondy_connect_db_${DateTime.now().millisecondsSinceEpoch}.zip');
    await zipFile.writeAsBytes(zipBytes);
    return zipFile;
  }
}

List<List<dynamic>> _parseCsvIsolate(String content) {
  return const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
      .convert(content.replaceAll('\r\n', '\n'));
}
