import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/firebase_mocks.dart';

void main() {
  setupFirebaseCoreMocks();

  group('FirebaseKitFirestore', () {
    group('constructor', () {
      test('creates instance with default options', () {
        final firestore = FirebaseKitFirestore();

        expect(firestore.settings, isNull);
      });

      test('creates instance with custom settings', () {
        const settings = Settings(
          persistenceEnabled: true,
          cacheSizeBytes: 10000000,
        );

        final firestore = FirebaseKitFirestore(settings: settings);

        expect(firestore.settings, equals(settings));
      });
    });

    group('configuration options', () {
      test('can configure persistence', () {
        const settings = Settings(persistenceEnabled: false);
        final firestore = FirebaseKitFirestore(settings: settings);
        expect(firestore.settings?.persistenceEnabled, isFalse);
      });

      test('can configure cache size', () {
        const settings = Settings(cacheSizeBytes: 5000000);
        final firestore = FirebaseKitFirestore(settings: settings);
        expect(firestore.settings?.cacheSizeBytes, equals(5000000));
      });
    });

    group('serviceName', () {
      test('returns correct name', () {
        final firestore = FirebaseKitFirestore();

        expect(firestore.serviceName, equals('FirebaseKitFirestore'));
      });
    });
  });

  group('QueryFilter', () {
    test('QueryFilter.equals creates correct filter', () {
      final filter = QueryFilter.equals('name', 'John');

      expect(filter.field, equals('name'));
      expect(filter.operator, equals(QueryOperator.isEqualTo));
      expect(filter.value, equals('John'));
    });

    test('QueryFilter.notEquals creates correct filter', () {
      final filter = QueryFilter.notEquals('status', 'deleted');

      expect(filter.field, equals('status'));
      expect(filter.operator, equals(QueryOperator.isNotEqualTo));
      expect(filter.value, equals('deleted'));
    });

    test('QueryFilter.lessThan creates correct filter', () {
      final filter = QueryFilter.lessThan('age', 30);

      expect(filter.field, equals('age'));
      expect(filter.operator, equals(QueryOperator.isLessThan));
      expect(filter.value, equals(30));
    });

    test('QueryFilter.lessThanOrEqual creates correct filter', () {
      final filter = QueryFilter.lessThanOrEqual('price', 100.0);

      expect(filter.field, equals('price'));
      expect(filter.operator, equals(QueryOperator.isLessThanOrEqualTo));
      expect(filter.value, equals(100.0));
    });

    test('QueryFilter.greaterThan creates correct filter', () {
      final filter = QueryFilter.greaterThan('count', 5);

      expect(filter.field, equals('count'));
      expect(filter.operator, equals(QueryOperator.isGreaterThan));
      expect(filter.value, equals(5));
    });

    test('QueryFilter.greaterThanOrEqual creates correct filter', () {
      final filter = QueryFilter.greaterThanOrEqual('rating', 4.5);

      expect(filter.field, equals('rating'));
      expect(filter.operator, equals(QueryOperator.isGreaterThanOrEqualTo));
      expect(filter.value, equals(4.5));
    });

    test('QueryFilter.arrayContains creates correct filter', () {
      final filter = QueryFilter.arrayContains('tags', 'featured');

      expect(filter.field, equals('tags'));
      expect(filter.operator, equals(QueryOperator.arrayContains));
      expect(filter.value, equals('featured'));
    });

    test('QueryFilter.arrayContainsAny creates correct filter', () {
      final filter = QueryFilter.arrayContainsAny('categories', ['A', 'B']);

      expect(filter.field, equals('categories'));
      expect(filter.operator, equals(QueryOperator.arrayContainsAny));
      expect(filter.value, equals(['A', 'B']));
    });

    test('QueryFilter.whereIn creates correct filter', () {
      final filter = QueryFilter.whereIn('status', ['active', 'pending']);

      expect(filter.field, equals('status'));
      expect(filter.operator, equals(QueryOperator.whereIn));
      expect(filter.value, equals(['active', 'pending']));
    });

    test('QueryFilter.whereNotIn creates correct filter', () {
      final filter = QueryFilter.whereNotIn('role', ['banned', 'suspended']);

      expect(filter.field, equals('role'));
      expect(filter.operator, equals(QueryOperator.whereNotIn));
      expect(filter.value, equals(['banned', 'suspended']));
    });

    test('QueryFilter.isNull creates correct filter', () {
      final filter = QueryFilter.isNull('deletedAt', true);

      expect(filter.field, equals('deletedAt'));
      expect(filter.operator, equals(QueryOperator.isNull));
      expect(filter.value, isTrue);
    });

    test('basic QueryFilter constructor works', () {
      final filter = QueryFilter('field', QueryOperator.isEqualTo, 'value');

      expect(filter.field, equals('field'));
      expect(filter.operator, equals(QueryOperator.isEqualTo));
      expect(filter.value, equals('value'));
    });
  });

  group('QueryOperator', () {
    test('all operators are defined', () {
      expect(QueryOperator.values.length, equals(11));
      expect(QueryOperator.values, contains(QueryOperator.isEqualTo));
      expect(QueryOperator.values, contains(QueryOperator.isNotEqualTo));
      expect(QueryOperator.values, contains(QueryOperator.isLessThan));
      expect(QueryOperator.values, contains(QueryOperator.isLessThanOrEqualTo));
      expect(QueryOperator.values, contains(QueryOperator.isGreaterThan));
      expect(
          QueryOperator.values, contains(QueryOperator.isGreaterThanOrEqualTo));
      expect(QueryOperator.values, contains(QueryOperator.arrayContains));
      expect(QueryOperator.values, contains(QueryOperator.arrayContainsAny));
      expect(QueryOperator.values, contains(QueryOperator.whereIn));
      expect(QueryOperator.values, contains(QueryOperator.whereNotIn));
      expect(QueryOperator.values, contains(QueryOperator.isNull));
    });
  });
}
