import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKitMessaging', () {
    group('constructor', () {
      test('creates instance with default options', () {
        final messaging = FirebaseKitMessaging();

        expect(messaging.autoRequestPermission, isTrue);
        expect(messaging.subscribeToTopics, isNull);
        expect(messaging.onToken, isNull);
        expect(messaging.onMessage, isNull);
        expect(messaging.onMessageOpenedApp, isNull);
        expect(messaging.onBackgroundMessage, isNull);
        expect(messaging.onInitialMessage, isNull);
      });

      test('creates instance with custom options', () {
        final messaging = FirebaseKitMessaging(
          autoRequestPermission: false,
          subscribeToTopics: ['news', 'offers'],
          initialMessageDelay: const Duration(seconds: 1),
        );

        expect(messaging.autoRequestPermission, isFalse);
        expect(messaging.subscribeToTopics, equals(['news', 'offers']));
        expect(
            messaging.initialMessageDelay, equals(const Duration(seconds: 1)));
      });

      test('accepts token callback', () async {
        String? receivedToken;
        final messaging = FirebaseKitMessaging(
          onToken: (token) async {
            receivedToken = token;
          },
        );

        expect(messaging.onToken, isNotNull);

        // Manually test the callback
        await messaging.onToken!('test-token');
        expect(receivedToken, equals('test-token'));
      });

      test('accepts message callbacks', () {
        final messaging = FirebaseKitMessaging(
          onMessage: (message) {
            // Handle foreground messages
          },
          onMessageOpenedApp: (message) {
            // Handle notification tap when app was in background
          },
        );

        expect(messaging.onMessage, isNotNull);
        expect(messaging.onMessageOpenedApp, isNotNull);
      });

      test('accepts initial message callback', () {
        final messaging = FirebaseKitMessaging(
          onInitialMessage: (message) {
            // Handle cold-start notification
          },
        );

        expect(messaging.onInitialMessage, isNotNull);
      });
    });

    group('serviceName', () {
      test('returns correct name', () {
        final messaging = FirebaseKitMessaging();

        expect(messaging.serviceName, equals('FirebaseKitMessaging'));
      });
    });

    group('configuration options', () {
      test('autoRequestPermission defaults to true', () {
        final messaging = FirebaseKitMessaging();
        expect(messaging.autoRequestPermission, isTrue);
      });

      test('initialMessageDelay has default value', () {
        final messaging = FirebaseKitMessaging();
        expect(messaging.initialMessageDelay,
            equals(const Duration(milliseconds: 500)));
      });
    });
  });
}
