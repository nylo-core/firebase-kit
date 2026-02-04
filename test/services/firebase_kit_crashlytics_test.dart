import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKitCrashlytics', () {
    group('constructor', () {
      test('creates instance with default options', () {
        final crashlytics = FirebaseKitCrashlytics();

        expect(crashlytics.enableInDevMode, isFalse);
        expect(crashlytics.recordFlutterErrors, isTrue);
        expect(crashlytics.userId, isNull);
        expect(crashlytics.customKeys, isNull);
      });

      test('creates instance with custom options', () {
        final crashlytics = FirebaseKitCrashlytics(
          enableInDevMode: true,
          recordFlutterErrors: false,
          userId: 'crash-user-123',
          customKeys: {'environment': 'staging'},
        );

        expect(crashlytics.enableInDevMode, isTrue);
        expect(crashlytics.recordFlutterErrors, isFalse);
        expect(crashlytics.userId, equals('crash-user-123'));
        expect(crashlytics.customKeys, equals({'environment': 'staging'}));
      });
    });

    group('configuration options', () {
      test('enableInDevMode defaults to false', () {
        final crashlytics = FirebaseKitCrashlytics();
        expect(crashlytics.enableInDevMode, isFalse);
      });

      test('recordFlutterErrors defaults to true', () {
        final crashlytics = FirebaseKitCrashlytics();
        expect(crashlytics.recordFlutterErrors, isTrue);
      });

      test('can set custom user ID', () {
        final crashlytics = FirebaseKitCrashlytics(userId: 'my-user-id');
        expect(crashlytics.userId, equals('my-user-id'));
      });

      test('can set multiple custom keys', () {
        final keys = {
          'app_version': '1.0.0',
          'build_number': 42,
          'environment': 'production',
        };
        final crashlytics = FirebaseKitCrashlytics(customKeys: keys);
        expect(crashlytics.customKeys, equals(keys));
      });

      test('custom keys can have different value types', () {
        final keys = {
          'string_key': 'value',
          'int_key': 123,
          'double_key': 1.5,
          'bool_key': true,
        };
        final crashlytics = FirebaseKitCrashlytics(customKeys: keys);
        expect(crashlytics.customKeys!['string_key'], isA<String>());
        expect(crashlytics.customKeys!['int_key'], isA<int>());
        expect(crashlytics.customKeys!['double_key'], isA<double>());
        expect(crashlytics.customKeys!['bool_key'], isA<bool>());
      });
    });

    group('serviceName', () {
      test('returns correct name', () {
        final crashlytics = FirebaseKitCrashlytics();

        expect(crashlytics.serviceName, equals('FirebaseKitCrashlytics'));
      });
    });
  });
}
