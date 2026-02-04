/// Abstract base class for Firebase Kit services.
///
/// Extend this class to create custom Firebase service configurations.
///
/// Example:
/// ```dart
/// class MyCustomService extends FirebaseKitService {
///   @override
///   Future<void> onInit() async {
///     // Initialize your service
///   }
/// }
/// ```
abstract class FirebaseKitService {
  /// Called when the service is initialized.
  /// Override this to set up your service.
  Future<void> onInit() async {}

  /// Called after all services have been initialized.
  /// Override this for post-initialization setup.
  Future<void> onReady() async {}

  /// Called when the app is ready and navigation is available.
  /// Useful for deep linking from notifications.
  Future<void> onAppReady() async {}

  /// Get the service name for logging.
  String get serviceName => runtimeType.toString();
}
