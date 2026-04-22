import 'dart:developer' as dev;

enum LogLevel { debug, info, error }

/// Central logging helper.
///
/// - Use [d] for verbose UI/repo traces.
/// - Use [i] for important lifecycle events (sync start/finish, auth, etc.).
/// - Use [e] for exceptions and failures (always include stack trace when possible).
abstract final class AppLogger {
  static void d(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final prefix = switch (level) {
      LogLevel.debug => '[D]',
      LogLevel.info => '[I]',
      LogLevel.error => '[E]',
    };
    dev.log('$prefix $message', error: error, stackTrace: stackTrace);
  }
}
