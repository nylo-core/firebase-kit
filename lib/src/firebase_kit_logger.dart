import 'package:flutter/foundation.dart';

/// Simple logger for Firebase Kit.
///
/// Logs messages to the console in debug mode.
class FirebaseKitLogger {
  /// Whether logging is enabled.
  static bool enabled = true;

  /// Log an info message.
  static void info(String message) {
    if (enabled && kDebugMode) {
      debugPrint('[FirebaseKit] INFO: $message');
    }
  }

  /// Log a debug message.
  static void debug(String message) {
    if (enabled && kDebugMode) {
      debugPrint('[FirebaseKit] DEBUG: $message');
    }
  }

  /// Log an error message.
  static void error(String message) {
    if (enabled && kDebugMode) {
      debugPrint('[FirebaseKit] ERROR: $message');
    }
  }

  /// Log a warning message.
  static void warning(String message) {
    if (enabled && kDebugMode) {
      debugPrint('[FirebaseKit] WARNING: $message');
    }
  }
}
