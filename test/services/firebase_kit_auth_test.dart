import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKitAuth', () {
    group('constructor', () {
      test('creates instance with default options', () {
        final auth = FirebaseKitAuth();

        expect(auth.onAuthStateChanged, isNull);
        expect(auth.onIdTokenChanged, isNull);
        expect(auth.persistSession, isTrue);
      });

      test('creates instance with custom options', () {
        void authCallback(User? user) {}
        void tokenCallback(User? user) {}

        final auth = FirebaseKitAuth(
          onAuthStateChanged: authCallback,
          onIdTokenChanged: tokenCallback,
          persistSession: false,
        );

        expect(auth.onAuthStateChanged, equals(authCallback));
        expect(auth.onIdTokenChanged, equals(tokenCallback));
        expect(auth.persistSession, isFalse);
      });
    });

    group('configuration options', () {
      test('persistSession defaults to true', () {
        final auth = FirebaseKitAuth();
        expect(auth.persistSession, isTrue);
      });

      test('can disable session persistence', () {
        final auth = FirebaseKitAuth(persistSession: false);
        expect(auth.persistSession, isFalse);
      });

      test('accepts auth state change callback', () {
        final auth = FirebaseKitAuth(
          onAuthStateChanged: (user) {
            // Callback would handle auth state changes
          },
        );
        expect(auth.onAuthStateChanged, isNotNull);
      });

      test('accepts ID token change callback', () {
        final auth = FirebaseKitAuth(
          onIdTokenChanged: (user) {
            // Callback would handle token changes
          },
        );
        expect(auth.onIdTokenChanged, isNotNull);
      });

      test('can have both callbacks set', () {
        final auth = FirebaseKitAuth(
          onAuthStateChanged: (user) {},
          onIdTokenChanged: (user) {},
        );
        expect(auth.onAuthStateChanged, isNotNull);
        expect(auth.onIdTokenChanged, isNotNull);
      });
    });

    group('serviceName', () {
      test('returns correct name', () {
        final auth = FirebaseKitAuth();

        expect(auth.serviceName, equals('FirebaseKitAuth'));
      });
    });
  });
}
