import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Structured application logger to eliminate raw print() calls.
class AppLogger {
  static void debug(String message, {String? tag, Object? error}) {
    _log(LogLevel.debug, message, tag: tag, error: error);
  }

  static void info(String message, {String? tag, Object? error}) {
    _log(LogLevel.info, message, tag: tag, error: error);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final prefix = switch (level) {
      LogLevel.debug => '🐛 [DEBUG]',
      LogLevel.info => 'ℹ️ [INFO]',
      LogLevel.warning => '⚠️ [WARN]',
      LogLevel.error => '🛑 [ERROR]',
    };

    final tagStr = tag != null ? '[$tag] ' : '';
    debugPrint('$prefix $tagStr$message');

    if (error != null) {
      debugPrint('   Details: $error');
    }
    if (stackTrace != null && (level == LogLevel.warning || level == LogLevel.error)) {
      debugPrint('   StackTrace:\n$stackTrace');
    }
  }
}
