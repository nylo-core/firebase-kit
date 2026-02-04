import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks/firebase_mocks.dart';
import 'mocks/mock_firebase_kit_service.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKit', () {
    group('init()', () {
      test('creates instance successfully', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        expect(firebaseKit, isNotNull);
        expect(firebaseKit, isA<FirebaseKit>());
      });

      test('stores options correctly', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        expect(firebaseKit.options, equals(testFirebaseOptions));
      });

      test('stores services list', () async {
        final service1 = MockFirebaseKitService();
        final service2 = AnotherMockService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service1, service2],
        );

        expect(firebaseKit.services.length, equals(2));
      });

      test('stores condition function', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          condition: () => true,
        );

        expect(firebaseKit.condition, isNotNull);
      });

      test('stores custom name', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          name: 'CustomApp',
        );

        expect(firebaseKit.name, equals('CustomApp'));
      });
    });

    group('onInit()', () {
      test('initializes Firebase Core', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        await firebaseKit.onInit();

        expect(firebaseKit.isInitialized, isTrue);
        expect(firebaseKit.app, isNotNull);
      });

      test('calls onInit() on all child services', () async {
        final service1 = MockFirebaseKitService();
        final service2 = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service1, service2],
        );

        await firebaseKit.onInit();

        expect(service1.onInitCalled, isTrue);
        expect(service2.onInitCalled, isTrue);
      });

      test('condition returning false skips initialization', () async {
        final service = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service],
          condition: () => false,
        );

        await firebaseKit.onInit();

        expect(firebaseKit.isInitialized, isFalse);
        expect(service.onInitCalled, isFalse);
      });

      test('service error in onInit() does not prevent other services',
          () async {
        final failingService = MockFirebaseKitService(shouldThrowOnInit: true);
        final successService = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [failingService, successService],
        );

        await firebaseKit.onInit();

        expect(failingService.onInitCalled, isFalse);
        expect(successService.onInitCalled, isTrue);
      });
    });

    group('onReady()', () {
      test('calls onReady() on all child services', () async {
        final service1 = MockFirebaseKitService();
        final service2 = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service1, service2],
        );

        await firebaseKit.onReady();

        expect(service1.onReadyCalled, isTrue);
        expect(service2.onReadyCalled, isTrue);
      });

      test('service error in onReady() does not prevent other services',
          () async {
        final failingService = MockFirebaseKitService(shouldThrowOnReady: true);
        final successService = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [failingService, successService],
        );

        await firebaseKit.onReady();

        expect(successService.onReadyCalled, isTrue);
      });
    });

    group('onAppReady()', () {
      test('calls onAppReady() on all child services when initialized',
          () async {
        final service1 = MockFirebaseKitService();
        final service2 = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service1, service2],
        );

        await firebaseKit.onInit();
        await firebaseKit.onAppReady();

        expect(service1.onAppReadyCalled, isTrue);
        expect(service2.onAppReadyCalled, isTrue);
      });

      test('skips if not initialized', () async {
        final service = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service],
          condition: () => false,
        );

        await firebaseKit.onInit();
        await firebaseKit.onAppReady();

        expect(firebaseKit.isInitialized, isFalse);
        expect(service.onAppReadyCalled, isFalse);
      });

      test('service error in onAppReady() does not prevent other services',
          () async {
        final failingService =
            MockFirebaseKitService(shouldThrowOnAppReady: true);
        final successService = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [failingService, successService],
        );

        await firebaseKit.onInit();
        await firebaseKit.onAppReady();

        expect(successService.onAppReadyCalled, isTrue);
      });
    });

    group('getService<T>()', () {
      test('returns correct service type', () async {
        final mockService = MockFirebaseKitService();
        final anotherService = AnotherMockService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [mockService, anotherService],
        );

        final retrieved = firebaseKit.getService<MockFirebaseKitService>();

        expect(retrieved, isNotNull);
        expect(retrieved, equals(mockService));
      });

      test('returns null for missing service', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        final retrieved = firebaseKit.getService<MockFirebaseKitService>();

        expect(retrieved, isNull);
      });

      test('returns first matching service when multiple exist', () async {
        final service1 = MockFirebaseKitService(customName: 'First');
        final service2 = MockFirebaseKitService(customName: 'Second');

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service1, service2],
        );

        final retrieved = firebaseKit.getService<MockFirebaseKitService>();

        expect(retrieved, equals(service1));
        expect(retrieved?.serviceName, equals('First'));
      });
    });

    group('hasService<T>()', () {
      test('returns true when service exists', () async {
        final mockService = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [mockService],
        );

        expect(firebaseKit.hasService<MockFirebaseKitService>(), isTrue);
      });

      test('returns false when service does not exist', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        expect(firebaseKit.hasService<MockFirebaseKitService>(), isFalse);
      });
    });

    group('isInitialized', () {
      test('is false before onInit()', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        expect(firebaseKit.isInitialized, isFalse);
      });

      test('is true after successful onInit()', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        await firebaseKit.onInit();

        expect(firebaseKit.isInitialized, isTrue);
      });

      test('is false when condition returns false', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
          condition: () => false,
        );

        await firebaseKit.onInit();

        expect(firebaseKit.isInitialized, isFalse);
      });
    });

    group('serviceName', () {
      test('returns "FirebaseKit"', () async {
        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [],
        );

        expect(firebaseKit.serviceName, equals('FirebaseKit'));
      });
    });

    group('lifecycle order', () {
      test('onInit is called before onReady and onAppReady', () async {
        final service = MockFirebaseKitService();

        final firebaseKit = await FirebaseKit.init(
          testFirebaseOptions,
          services: [service],
        );

        await firebaseKit.onInit();
        await firebaseKit.onReady();
        await firebaseKit.onAppReady();

        expect(service.callOrder, equals(['onInit', 'onReady', 'onAppReady']));
      });
    });
  });
}
