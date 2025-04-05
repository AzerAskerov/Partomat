class Logger {
  static void init() {
    // Initialize logger
  }

  static void debug(String message) {
    print('DEBUG: $message');
  }

  static void info(String message) {
    print('INFO: $message');
  }

  static void warning(String message) {
    print('WARNING: $message');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    print('ERROR: $message');
    if (error != null) print('Error details: $error');
    if (stackTrace != null) print('Stack trace: $stackTrace');
  }
} 