import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Firebase Crashlytics service for Firebase Kit.
///
/// Provides crash reporting and error logging.
///
/// Example:
/// ```dart
/// FirebaseKitCrashlytics(
///   enableInDevMode: false,
///   recordFlutterErrors: true,
/// )
/// ```
class FirebaseKitCrashlytics extends FirebaseKitService {
  /// Whether to enable crash reporting in debug mode.
  final bool enableInDevMode;

  /// Whether to automatically record Flutter framework errors.
  final bool recordFlutterErrors;

  /// User ID to set on initialization.
  final String? userId;

  /// Custom keys to set on initialization.
  final Map<String, dynamic>? customKeys;

  /// Firebase Crashlytics instance
  FirebaseCrashlytics? _crashlytics;

  /// Get the FirebaseCrashlytics instance
  FirebaseCrashlytics get crashlytics =>
      _crashlytics ?? FirebaseCrashlytics.instance;

  /// Original Flutter error handler
  FlutterExceptionHandler? _originalOnError;

  FirebaseKitCrashlytics({
    this.enableInDevMode = false,
    this.recordFlutterErrors = true,
    this.userId,
    this.customKeys,
  });

  @override
  Future<void> onInit() async {
    _crashlytics = FirebaseCrashlytics.instance;

    // Configure collection based on debug mode
    if (kDebugMode && !enableInDevMode) {
      await crashlytics.setCrashlyticsCollectionEnabled(false);
      FirebaseKitLogger.debug('Crashlytics disabled in debug mode');
      return;
    }

    await crashlytics.setCrashlyticsCollectionEnabled(true);

    // Set user ID
    if (userId != null) {
      await crashlytics.setUserIdentifier(userId!);
    }

    // Set custom keys
    if (customKeys != null) {
      for (final entry in customKeys!.entries) {
        await crashlytics.setCustomKey(entry.key, entry.value);
      }
    }

    // Set up Flutter error recording
    if (recordFlutterErrors) {
      _originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        // Call original handler first
        _originalOnError?.call(details);
        // Then record to Crashlytics
        crashlytics.recordFlutterFatalError(details);
      };

      // Handle errors outside of Flutter
      PlatformDispatcher.instance.onError = (error, stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
    }

    FirebaseKitLogger.debug('Crashlytics initialized');
  }

  /// Record a non-fatal error.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Iterable<Object> information = const [],
  }) async {
    await crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
      information: information,
    );
    FirebaseKitLogger.debug('Crashlytics recorded error: $exception');
  }

  /// Record a fatal error.
  Future<void> recordFatalError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
  }) async {
    await recordError(exception, stack, reason: reason, fatal: true);
  }

  /// Log a message to Crashlytics.
  Future<void> log(String message) async {
    await crashlytics.log(message);
  }

  /// Set the user identifier.
  Future<void> setUserIdentifier(String identifier) async {
    await crashlytics.setUserIdentifier(identifier);
  }

  /// Set a custom key-value pair.
  Future<void> setCustomKey(String key, dynamic value) async {
    await crashlytics.setCustomKey(key, value);
  }

  /// Check if crash collection is enabled.
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return crashlytics.isCrashlyticsCollectionEnabled;
  }

  /// Enable or disable crash collection.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Force a test crash (debug only).
  void crash() {
    if (kDebugMode) {
      crashlytics.crash();
    }
  }

  /// Check if there are unsent reports.
  Future<bool> checkForUnsentReports() async {
    return await crashlytics.checkForUnsentReports();
  }

  /// Send any unsent reports.
  Future<void> sendUnsentReports() async {
    await crashlytics.sendUnsentReports();
  }

  /// Delete any unsent reports.
  Future<void> deleteUnsentReports() async {
    await crashlytics.deleteUnsentReports();
  }

  @override
  String get serviceName => 'FirebaseKitCrashlytics';
}
