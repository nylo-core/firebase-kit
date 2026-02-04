import 'package:firebase_kit/firebase_kit.dart';

/// Mock implementation of FirebaseKitService for testing lifecycle methods.
class MockFirebaseKitService extends FirebaseKitService {
  /// Whether onInit() was called
  bool onInitCalled = false;

  /// Whether onReady() was called
  bool onReadyCalled = false;

  /// Whether onAppReady() was called
  bool onAppReadyCalled = false;

  /// Order in which lifecycle methods were called
  final List<String> callOrder = [];

  /// Whether to throw an exception in onInit()
  bool shouldThrowOnInit = false;

  /// Whether to throw an exception in onReady()
  bool shouldThrowOnReady = false;

  /// Whether to throw an exception in onAppReady()
  bool shouldThrowOnAppReady = false;

  /// Custom name for the service
  final String? customName;

  MockFirebaseKitService({
    this.customName,
    this.shouldThrowOnInit = false,
    this.shouldThrowOnReady = false,
    this.shouldThrowOnAppReady = false,
  });

  @override
  Future<void> onInit() async {
    if (shouldThrowOnInit) {
      throw Exception('MockFirebaseKitService onInit error');
    }
    onInitCalled = true;
    callOrder.add('onInit');
  }

  @override
  Future<void> onReady() async {
    if (shouldThrowOnReady) {
      throw Exception('MockFirebaseKitService onReady error');
    }
    onReadyCalled = true;
    callOrder.add('onReady');
  }

  @override
  Future<void> onAppReady() async {
    if (shouldThrowOnAppReady) {
      throw Exception('MockFirebaseKitService onAppReady error');
    }
    onAppReadyCalled = true;
    callOrder.add('onAppReady');
  }

  @override
  String get serviceName => customName ?? 'MockFirebaseKitService';

  /// Reset all state for reuse in tests
  void reset() {
    onInitCalled = false;
    onReadyCalled = false;
    onAppReadyCalled = false;
    callOrder.clear();
    shouldThrowOnInit = false;
    shouldThrowOnReady = false;
    shouldThrowOnAppReady = false;
  }
}

/// Another mock service for testing service retrieval
class AnotherMockService extends FirebaseKitService {
  bool initialized = false;

  @override
  Future<void> onInit() async {
    initialized = true;
  }

  @override
  String get serviceName => 'AnotherMockService';
}
