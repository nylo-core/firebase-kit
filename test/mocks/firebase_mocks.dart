import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock Firebase options for testing
const testFirebaseOptions = FirebaseOptions(
  apiKey: 'test-api-key',
  appId: 'test-app-id',
  messagingSenderId: 'test-messaging-sender-id',
  projectId: 'test-project-id',
);

/// Sets up Firebase Core mocks for testing.
///
/// Call this at the start of your test file's main() or in setUp().
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setupFirebaseCoreMocksPlatform();
}

/// Sets up the mock platform for Firebase Core.
void setupFirebaseCoreMocksPlatform() {
  final mockPlatform = MockFirebaseCorePlatform();
  FirebasePlatform.instance = mockPlatform;
}

/// Mock implementation of FirebasePlatform for testing.
class MockFirebaseCorePlatform extends FirebasePlatform {
  MockFirebaseCorePlatform() : super();

  FirebaseAppPlatform? _app;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (_app == null) {
      throw FirebaseException(
        plugin: 'core',
        message:
            'No Firebase App \'$name\' has been created - call Firebase.initializeApp()',
      );
    }
    return _app!;
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _app = MockFirebaseAppPlatform(
      name ?? defaultFirebaseAppName,
      options ?? testFirebaseOptions,
    );
    return _app!;
  }

  @override
  List<FirebaseAppPlatform> get apps => _app != null ? [_app!] : [];
}

/// Mock implementation of FirebaseAppPlatform for testing.
class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);

  @override
  bool get isAutomaticDataCollectionEnabled => true;

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}

  @override
  Future<void> delete() async {}
}
