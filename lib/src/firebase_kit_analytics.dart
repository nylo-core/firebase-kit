import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Firebase Analytics service for Firebase Kit.
///
/// Provides automatic screen tracking and manual event logging.
///
/// Example:
/// ```dart
/// FirebaseKitAnalytics(
///   enableAutoTracking: true,
///   defaultEventParameters: {
///     'app_version': '1.0.0',
///   },
/// )
/// ```
class FirebaseKitAnalytics extends FirebaseKitService {
  /// Whether to enable automatic screen tracking via NavigatorObserver.
  final bool enableAutoTracking;

  /// Default parameters to include with every event.
  final Map<String, Object>? defaultEventParameters;

  /// User ID to set on initialization.
  final String? userId;

  /// User properties to set on initialization.
  final Map<String, String>? userProperties;

  /// Callback to add the observer to your navigator.
  final void Function(NavigatorObserver observer)? onObserverCreated;

  /// Firebase Analytics instance
  FirebaseAnalytics? _analytics;

  /// Get the FirebaseAnalytics instance
  FirebaseAnalytics get analytics => _analytics ?? FirebaseAnalytics.instance;

  /// Navigator observer for automatic screen tracking
  FirebaseAnalyticsObserver? _observer;

  /// Get the navigator observer
  FirebaseAnalyticsObserver? get observer => _observer;

  FirebaseKitAnalytics({
    this.enableAutoTracking = true,
    this.defaultEventParameters,
    this.userId,
    this.userProperties,
    this.onObserverCreated,
  });

  @override
  Future<void> onInit() async {
    _analytics = FirebaseAnalytics.instance;

    // Set default event parameters
    if (defaultEventParameters != null) {
      await analytics.setDefaultEventParameters(defaultEventParameters);
    }

    // Set user ID
    if (userId != null) {
      await analytics.setUserId(id: userId);
    }

    // Set user properties
    if (userProperties != null) {
      for (final entry in userProperties!.entries) {
        await analytics.setUserProperty(name: entry.key, value: entry.value);
      }
    }

    // Create observer for auto tracking
    if (enableAutoTracking) {
      _observer = FirebaseAnalyticsObserver(analytics: analytics);
    }
  }

  @override
  Future<void> onReady() async {
    // Notify about observer creation
    if (enableAutoTracking && _observer != null && onObserverCreated != null) {
      onObserverCreated!(_observer!);
      FirebaseKitLogger.debug('Firebase Analytics auto-tracking enabled');
    }
  }

  /// Log a custom event.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await analytics.logEvent(name: name, parameters: parameters);
    FirebaseKitLogger.debug('Analytics event: $name');
  }

  /// Set the current user ID.
  Future<void> setUserId(String? id) async {
    await analytics.setUserId(id: id);
  }

  /// Set a user property.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await analytics.setUserProperty(name: name, value: value);
  }

  /// Log the current screen.
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    await analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Log a login event.
  Future<void> logLogin({String? loginMethod}) async {
    await analytics.logLogin(loginMethod: loginMethod);
  }

  /// Log a sign up event.
  Future<void> logSignUp({required String signUpMethod}) async {
    await analytics.logSignUp(signUpMethod: signUpMethod);
  }

  /// Log a purchase event.
  Future<void> logPurchase({
    String? currency,
    double? value,
    String? transactionId,
    List<AnalyticsEventItem>? items,
  }) async {
    await analytics.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
      items: items,
    );
  }

  /// Log an add to cart event.
  Future<void> logAddToCart({
    String? currency,
    double? value,
    List<AnalyticsEventItem>? items,
  }) async {
    await analytics.logAddToCart(
      currency: currency,
      value: value,
      items: items,
    );
  }

  /// Log a search event.
  Future<void> logSearch({required String searchTerm}) async {
    await analytics.logSearch(searchTerm: searchTerm);
  }

  /// Log a share event.
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  /// Reset analytics data (useful for logout).
  Future<void> resetAnalyticsData() async {
    await analytics.resetAnalyticsData();
    FirebaseKitLogger.debug('Analytics data reset');
  }

  /// Enable or disable analytics collection.
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await analytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  String get serviceName => 'FirebaseKitAnalytics';
}
