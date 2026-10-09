import 'dart:async';
import '../../core/utils/app_logger.dart';

/// FIFO queue item for table lock requests.
class _LockRequest {
  final String id;
  final Completer<void> completer;
  final DateTime createdAt;

  _LockRequest(this.id)
      : completer = Completer<void>(),
        createdAt = DateTime.now();
}

/// Dedicated FIFO queue per table guaranteeing sequential access without deadlocks.
class _TableLockQueue {
  final String tableName;
  _LockRequest? _currentLock;
  final List<_LockRequest> _queue = [];
  int _counter = 0;

  _TableLockQueue(this.tableName);

  Future<T> acquireAndRun<T>(
    Future<T> Function() computation,
    Duration timeout,
  ) async {
    final requestId = '${tableName}_${++_counter}';
    final request = _LockRequest(requestId);

    if (_currentLock == null) {
      _currentLock = request;
    } else {
      _queue.add(request);
      try {
        await request.completer.future.timeout(
          timeout,
          onTimeout: () {
            _queue.remove(request);
            throw TimeoutException(
              'CsvLock: Timeout after ${timeout.inSeconds}s waiting for lock on table "$tableName". Active owner: ${_currentLock?.id}',
            );
          },
        );
      } catch (e, stack) {
        _queue.remove(request);
        AppLogger.warning('CsvLock acquisition failed for table "$tableName"', tag: 'CsvLock', error: e, stackTrace: stack);
        rethrow;
      }
    }

    try {
      return await runZoned(
        () async => await computation(),
        zoneValues: {'lock_$tableName': requestId},
      );
    } finally {
      _release(request);
    }
  }

  void _release(_LockRequest request) {
    if (_currentLock == request) {
      if (_queue.isNotEmpty) {
        final next = _queue.removeAt(0);
        _currentLock = next;
        if (!next.completer.isCompleted) {
          next.completer.complete();
        }
      } else {
        _currentLock = null;
      }
    } else {
      _queue.remove(request);
    }
  }
}

/// Hardened per-table asynchronous mutex with FIFO queuing, re-entrancy, and 5-second timeout.
class CsvLock {
  static final Map<String, _TableLockQueue> _queues = {};

  static Future<T> synchronized<T>(
    String tableName,
    Future<T> Function() computation, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    // Re-entrant: if current execution zone already owns the lock for this table, proceed directly
    if (Zone.current['lock_$tableName'] != null) {
      return await computation();
    }

    final queue = _queues.putIfAbsent(tableName, () => _TableLockQueue(tableName));
    return await queue.acquireAndRun(computation, timeout);
  }

  /// Reset all locks (for tests)
  static void reset() {
    _queues.clear();
  }
}
