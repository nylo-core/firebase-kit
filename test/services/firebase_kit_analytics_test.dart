import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKitAnalytics', () {
    group('constructor', () {
      test('creates instance with default options', () {
        final analytics = FirebaseKitAnalytics();

        expect(analytics.enableAutoTracking, isTrue);
        expect(analytics.defaultEventParameters, isNull);
        expect(analytics.userId, isNull);
        expect(analytics.userProperties, isNull);
        expect(analytics.onObserverCreated, isNull);
      });

      test('creates instance with custom options', () {
        final analytics = FirebaseKitAnalytics(
          enableAutoTracking: false,
          defaultEventParameters: {'app_version': '1.0.0'},
          userId: 'user-123',
          userProperties: {'subscription': 'premium'},
        );

        expect(analytics.enableAutoTracking, isFalse);
        expect(
            analytics.defaultEventParameters, equals({'app_version': '1.0.0'}));
        expect(analytics.userId, equals('user-123'));
        expect(analytics.userProperties, equals({'subscription': 'premium'}));
      });

      test('accepts onObserverCreated callback', () {
        final analytics = FirebaseKitAnalytics(
          onObserverCreated: (observer) {
            // Callback would store the observer for navigation tracking
          },
        );

        expect(analytics.onObserverCreated, isNotNull);
      });
    });

    group('configuration options', () {
      test('enableAutoTracking defaults to true', () {
        final analytics = FirebaseKitAnalytics();
        expect(analytics.enableAutoTracking, isTrue);
      });

      test('can disable auto tracking', () {
        final analytics = FirebaseKitAnalytics(enableAutoTracking: false);
        expect(analytics.enableAutoTracking, isFalse);
      });

      test('accepts default event parameters map', () {
        final params = {'version': '2.0', 'build': 123};
        final analytics = FirebaseKitAnalytics(defaultEventParameters: params);
        expect(analytics.defaultEventParameters, equals(params));
      });

      test('accepts user properties map', () {
        final props = {'tier': 'gold', 'country': 'US'};
        final analytics = FirebaseKitAnalytics(userProperties: props);
        expect(analytics.userProperties, equals(props));
      });
    });

    group('serviceName', () {
      test('returns correct name', () {
        final analytics = FirebaseKitAnalytics();

        expect(analytics.serviceName, equals('FirebaseKitAnalytics'));
      });
    });

    group('observer', () {
      test('observer is initially null before initialization', () {
        final analytics = FirebaseKitAnalytics(enableAutoTracking: true);
        expect(analytics.observer, isNull);
      });
    });
  });
}
