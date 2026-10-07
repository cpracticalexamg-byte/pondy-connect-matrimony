import 'dart:async';

/// Re-entrant per-table asynchronous lock to prevent concurrent write corruptions.
class CsvLock {
  static final Map<String, Completer<void>?> _locks = {};

  static Future<T> synchronized<T>(String tableName, Future<T> Function() computation) async {
    // Re-entrant: if current Zone already holds the lock for this table, proceed directly
    if (Zone.current[tableName] == true) {
      return await computation();
    }

    while (_locks[tableName] != null) {
      await _locks[tableName]!.future;
    }

    final completer = Completer<void>();
    _locks[tableName] = completer;

    try {
      return await runZoned(
        () async => await computation(),
        zoneValues: {tableName: true},
      );
    } finally {
      _locks[tableName] = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }
}
