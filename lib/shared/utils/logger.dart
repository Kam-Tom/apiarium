import 'package:flutter/foundation.dart';

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
  nothing, // No logs will be shown
}

/// A simple static logger utility for the application
class Logger {
  // Current log level - defaults to verbose in debug mode, info in release
  static LogLevel _currentLevel = kDebugMode ? LogLevel.verbose : LogLevel.info;

  // Setter for log level
  static set logLevel(LogLevel level) => _currentLevel = level;

  // Check if a message at the given level should be logged
  static bool _shouldLog(LogLevel level) => level.index >= _currentLevel.index;

  // Log a verbose message
  static void v(String message, {String? tag}) {
    if (_shouldLog(LogLevel.verbose)) {
      _log('VERBOSE', message, tag);
    }
  }

  // Log a debug message
  static void d(String message, {String? tag}) {
    if (_shouldLog(LogLevel.debug)) {
      _log('DEBUG', message, tag);
    }
  }

  // Log an info message
  static void i(String message, {String? tag}) {
    if (_shouldLog(LogLevel.info)) {
      _log('INFO', message, tag);
    }
  }

  // Log a warning message
  static void w(String message, {String? tag}) {
    if (_shouldLog(LogLevel.warning)) {
      _log('WARNING', message, tag);
    }
  }

  // Log an error message
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (_shouldLog(LogLevel.error)) {
      _log('ERROR', message, tag);
      if (error != null) {
        _log('ERROR', 'Error details: $error', tag);
      }
      if (stackTrace != null) {
        _log('ERROR', 'Stack trace: $stackTrace', tag);
      }
    }
  }

  // Internal log printer
  static void _log(String level, String message, String? tag) {
    final now = DateTime.now();
    final logTag = tag != null ? '[$tag]' : '';
    final formattedMessage = '${now.toString().substring(0, 19)} [$level] $logTag $message';
    
    // In debug mode, print to console
    if (kDebugMode) {
      debugPrint(formattedMessage);
    }
    
  }
}
