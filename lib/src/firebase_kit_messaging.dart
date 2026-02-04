import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Firebase Cloud Messaging service for Firebase Kit.
///
/// Handles push notifications, FCM tokens, and message handling.
///
/// Example:
/// ```dart
/// FirebaseKitMessaging(
///   autoRequestPermission: true,
///   onToken: (token) async {
///     // Send token to your server
///     await api.updateFcmToken(token);
///   },
///   onMessage: (message) {
///     // Handle foreground message
///     print('Got message: ${message.notification?.title}');
///   },
///   onMessageOpenedApp: (message) {
///     // Handle notification tap when app is in background
///     final route = message.data['route'];
///     if (route != null) routeTo(route);
///   },
///   onInitialMessage: (message) {
///     // Handle cold-start notification (app was terminated)
///     final route = message.data['route'];
///     if (route != null) routeTo(route);
///   },
///   subscribeToTopics: ['news', 'offers'],
/// )
/// ```
class FirebaseKitMessaging extends FirebaseKitService {
  /// Whether to automatically request notification permissions on boot.
  final bool autoRequestPermission;

  /// Callback when FCM token is received or refreshed.
  final Future<void> Function(String token)? onToken;

  /// Callback for foreground messages.
  final void Function(RemoteMessage message)? onMessage;

  /// Callback when user taps notification while app is in background.
  final void Function(RemoteMessage message)? onMessageOpenedApp;

  /// Background message handler. Must be a top-level function.
  final Future<void> Function(RemoteMessage message)? onBackgroundMessage;

  /// Callback for cold-start notification (app was terminated).
  /// Called in onAppReady after navigation is available.
  final void Function(RemoteMessage message)? onInitialMessage;

  /// Callback when notification permission is authorized or provisional.
  /// Receives the FCM token after permission is granted.
  final Future<void> Function(String token)? onAuthorized;

  /// Topics to subscribe to on boot.
  final List<String>? subscribeToTopics;

  /// Delay before handling initial message (allows app to settle).
  final Duration initialMessageDelay;

  /// Firebase Messaging instance
  FirebaseMessaging? _messaging;

  /// Get the FirebaseMessaging instance
  FirebaseMessaging get messaging => _messaging ?? FirebaseMessaging.instance;

  /// Stored FCM token
  String? _token;

  /// Get the current FCM token
  String? get token => _token;

  /// Stored initial message for cold-start
  RemoteMessage? _initialMessage;

  FirebaseKitMessaging({
    this.autoRequestPermission = false,
    this.onToken,
    this.onAuthorized,
    this.onMessage,
    this.onMessageOpenedApp,
    this.onBackgroundMessage,
    this.onInitialMessage,
    this.subscribeToTopics,
    this.initialMessageDelay = const Duration(milliseconds: 500),
  });

  @override
  Future<void> onInit() async {
    _messaging = FirebaseMessaging.instance;

    // Request permissions
    if (autoRequestPermission) {
      await requestPermission();
    }

    // Listen for token refresh
    _messaging!.onTokenRefresh.listen((token) async {
      _token = token;
      if (onToken != null) {
        await onToken!(token);
      }
    });

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FirebaseKitLogger.debug(
          'Foreground message received: ${message.messageId}');
      onMessage?.call(message);
    });

    // Set up background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      FirebaseKitLogger.debug('Notification opened app: ${message.messageId}');
      onMessageOpenedApp?.call(message);
    });

    // Register background handler if provided
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage!);
    }

    // Subscribe to topics
    if (subscribeToTopics != null) {
      for (final topic in subscribeToTopics!) {
        await subscribeToTopic(topic);
      }
    }

    // Check for initial message (cold start)
    _initialMessage = await messaging.getInitialMessage();
    if (_initialMessage != null) {
      FirebaseKitLogger.debug(
          'Initial message found: ${_initialMessage!.messageId}');
    }
  }

  @override
  Future<void> onAppReady() async {
    // Handle initial message after app is ready (navigation available)
    if (_initialMessage != null && onInitialMessage != null) {
      await Future.delayed(initialMessageDelay);
      onInitialMessage!(_initialMessage!);
      _initialMessage = null;
    }
  }

  /// Request notification permissions.
  ///
  /// Returns the [AuthorizationStatus] after requesting permissions.
  /// If authorized or provisional, fetches the FCM token and invokes
  /// the [onAuthorized] callback (parameter overrides constructor value).
  Future<AuthorizationStatus> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
    Future<void> Function(String token)? onAuthorized,
  }) async {
    final settings = await messaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );

    final callback = onAuthorized ?? this.onAuthorized;
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      final token = await messaging.getToken();
      _token = token;
      if (token != null && callback != null) {
        await callback(token);
      }
    }

    FirebaseKitLogger.debug(
        'Notification permission status: ${settings.authorizationStatus}');
    return settings.authorizationStatus;
  }

  /// Get the current FCM token.
  Future<String?> getToken() async {
    _token = await messaging.getToken();
    return _token;
  }

  /// Subscribe to a topic.
  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
    FirebaseKitLogger.debug('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
    FirebaseKitLogger.debug('Unsubscribed from topic: $topic');
  }

  /// Delete the FCM token (useful for logout).
  Future<void> deleteToken() async {
    await messaging.deleteToken();
    _token = null;
    FirebaseKitLogger.debug('FCM token deleted');
  }

  /// Get the APNS token (iOS only).
  Future<String?> getAPNSToken() async {
    return await messaging.getAPNSToken();
  }

  /// Set foreground notification presentation options (iOS).
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
  }

  /// Request notification permissions and retrieve the FCM token.
  ///
  /// This is a static convenience method that can be called without
  /// registering the service with FirebaseKit.
  ///
  /// Example:
  /// ```dart
  /// await FirebaseKitMessaging.getFcmToken(
  ///   onToken: (token) async {
  ///     await api.updateFcmToken(token);
  ///   },
  ///   provisional: true,
  /// );
  /// ```
  static Future<void> getFcmToken({
    required Future<void> Function(String token) onToken,
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: alert,
      announcement: announcement,
      badge: badge,
      carPlay: carPlay,
      criticalAlert: criticalAlert,
      provisional: provisional,
      sound: sound,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await onToken(token);
    }
  }

  @override
  String get serviceName => 'FirebaseKitMessaging';
}
