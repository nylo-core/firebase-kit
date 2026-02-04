import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:service_runner/service_runner.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Main configuration class for Firebase Kit.
///
/// Extends [Runnable] to integrate with the ServiceRunner initialization system.
/// Use this to initialize Firebase and configure services.
///
/// Example:
/// ```dart
/// await ServiceRunner.init(
///   services: [
///     Runnable.add<FirebaseKit>(() {
///       return FirebaseKit.init(
///         DefaultFirebaseOptions.currentPlatform,
///         services: [
///           FirebaseKitMessaging(sendTokenOnBoot: true),
///           FirebaseKitAnalytics(enableAutoTracking: true),
///         ],
///       );
///     }),
///   ],
///   child: const MyApp(),
/// );
///
/// // Access via service helper
/// final firebase = service<FirebaseKit>();
/// final messaging = firebase.getService<FirebaseKitMessaging>();
/// ```
class FirebaseKit extends Runnable {
  /// Singleton instance
  static FirebaseKit? _instance;

  /// Get the singleton instance of FirebaseKit.
  /// Returns null if FirebaseKit has not been initialized.
  static FirebaseKit? get instance => _instance;

  /// Static helper to get a service by type.
  ///
  /// Example:
  /// ```dart
  /// final messaging = FirebaseKit.service<FirebaseKitMessaging>();
  /// ```
  static T? service<T extends FirebaseKitService>() {
    return _instance?.getService<T>();
  }

  /// Firebase configuration options from firebase_options.dart
  final FirebaseOptions options;

  /// List of Firebase services to initialize
  final List<FirebaseKitService> services;

  /// Optional condition to skip Firebase initialization.
  /// Return `false` to skip initialization (e.g., in test mode).
  final bool Function()? condition;

  /// Optional Firebase app name. Defaults to `Firebase.app`.
  final String? name;

  /// Whether Firebase has been initialized
  bool _isInitialized = false;

  /// Get whether Firebase is initialized
  bool get isInitialized => _isInitialized;

  /// Stored Firebase app instance
  FirebaseApp? _app;

  /// Get the Firebase app instance
  FirebaseApp? get app => _app;

  FirebaseKit._({
    required this.options,
    this.services = const [],
    this.condition,
    this.name,
  }) {
    _instance = this;
  }

  /// Async factory - returns `Future<FirebaseKit>` for `ServiceRunner.init()`
  ///
  /// Example:
  /// ```dart
  /// Runnable.add<FirebaseKit>(() {
  ///   return FirebaseKit.init(
  ///     DefaultFirebaseOptions.currentPlatform,
  ///     services: [
  ///       FirebaseKitMessaging(),
  ///       FirebaseKitAnalytics(),
  ///     ],
  ///   );
  /// }),
  /// ```
  static Future<FirebaseKit> init(
    FirebaseOptions options, {
    List<FirebaseKitService> services = const [],
    bool Function()? condition,
    String? name,
  }) async {
    return FirebaseKit._(
      options: options,
      services: services,
      condition: condition,
      name: name,
    );
  }

  @override
  Future<void> onInit() async {
    if (condition != null && !condition!()) {
      FirebaseKitLogger.info(
          'Firebase initialization skipped (condition returned false)');
      return;
    }

    try {
      _app = await Firebase.initializeApp(
        name: name,
        options: options,
      );
      _isInitialized = true;
      FirebaseKitLogger.info('Firebase initialized successfully');

      for (final service in services) {
        try {
          await service.onInit();
          FirebaseKitLogger.debug('${service.serviceName} initialized');
        } catch (e, stackTrace) {
          FirebaseKitLogger.error(
              'Failed to initialize ${service.serviceName}: $e');
          if (kDebugMode) {
            FirebaseKitLogger.error(stackTrace.toString());
          }
        }
      }
    } catch (e, stackTrace) {
      FirebaseKitLogger.error('Firebase initialization failed: $e');
      if (kDebugMode) {
        FirebaseKitLogger.error(stackTrace.toString());
      }
      rethrow;
    }
  }

  @override
  Future<void> onReady() async {
    for (final service in services) {
      try {
        await service.onReady();
      } catch (e) {
        FirebaseKitLogger.error('${service.serviceName} onReady failed: $e');
      }
    }
  }

  @override
  Future<void> onAppReady() async {
    if (!_isInitialized) return;

    for (final service in services) {
      try {
        await service.onAppReady();
      } catch (e) {
        FirebaseKitLogger.error('${service.serviceName} onAppReady failed: $e');
      }
    }
  }

  /// Get a child service by type.
  ///
  /// Example:
  /// ```dart
  /// final firebase = service<FirebaseKit>();
  /// final messaging = firebase.getService<FirebaseKitMessaging>();
  /// ```
  T? getService<T extends FirebaseKitService>() {
    try {
      return services.firstWhere((s) => s is T) as T;
    } catch (_) {
      return null;
    }
  }

  /// Check if a service is registered.
  bool hasService<T extends FirebaseKitService>() {
    return services.any((s) => s is T);
  }

  @override
  String get serviceName => 'FirebaseKit';
}
