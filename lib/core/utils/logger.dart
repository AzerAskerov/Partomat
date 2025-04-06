import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class Logger {
  static bool _isInitialized = false;
  static DateTime? _startTime;

  static void init() {
    if (!_isInitialized) {
      _startTime = DateTime.now();
      _isInitialized = true;
      info('Logger initialized at ${_startTime!.toIso8601String()}');
    }
  }

  static String _getTimestamp() {
    final now = DateTime.now();
    final duration = _startTime != null ? now.difference(_startTime!) : Duration.zero;
    return '[${now.toIso8601String()}] [${duration.inMilliseconds}ms]';
  }

  static void debug(String message) {
    final timestamp = _getTimestamp();
    if (kDebugMode) {
      print('$timestamp [DEBUG] $message');
    }
    developer.log(message, name: 'DEBUG', time: DateTime.now());
  }

  static void info(String message) {
    final timestamp = _getTimestamp();
    if (kDebugMode) {
      print('$timestamp [INFO] $message');
    }
    developer.log(message, name: 'INFO', time: DateTime.now());
  }

  static void warning(String message) {
    final timestamp = _getTimestamp();
    if (kDebugMode) {
      print('$timestamp [WARNING] $message');
    }
    developer.log(message, name: 'WARNING', time: DateTime.now());
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final timestamp = _getTimestamp();
    if (kDebugMode) {
      print('$timestamp [ERROR] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
    developer.log(
      message,
      name: 'ERROR',
      time: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }
} 