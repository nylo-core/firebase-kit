import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Firebase Firestore service for Firebase Kit.
///
/// Provides collection helpers and model serialization.
///
/// Example:
/// ```dart
/// FirebaseKitFirestore(
///   settings: Settings(
///     persistenceEnabled: true,
///   ),
/// )
/// ```
class FirebaseKitFirestore extends FirebaseKitService {
  /// Firestore settings.
  final Settings? settings;

  /// Firebase Firestore instance
  FirebaseFirestore? _firestore;

  /// Get the FirebaseFirestore instance
  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;

  FirebaseKitFirestore({
    this.settings,
  });

  @override
  Future<void> onInit() async {
    _firestore = FirebaseFirestore.instance;

    // Apply settings
    if (settings != null) {
      firestore.settings = settings!;
    }

    FirebaseKitLogger.debug('Firestore initialized');
  }

  /// Get a collection reference.
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return firestore.collection(path);
  }

  /// Get a document reference.
  DocumentReference<Map<String, dynamic>> doc(String path) {
    return firestore.doc(path);
  }

  /// Get a typed collection reference with model conversion.
  CollectionReference<T> typedCollection<T>(
    String path, {
    required T Function(Map<String, dynamic> data) fromJson,
    required Map<String, dynamic> Function(T model) toJson,
  }) {
    return firestore.collection(path).withConverter<T>(
          fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
          toFirestore: (model, _) => toJson(model),
        );
  }

  /// Get all documents from a collection.
  Future<List<Map<String, dynamic>>> getAll(String path) async {
    final snapshot = await collection(path).get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Get a single document by ID.
  Future<Map<String, dynamic>?> getById(String path, String id) async {
    final snapshot = await collection(path).doc(id).get();
    if (!snapshot.exists) return null;
    return {'id': snapshot.id, ...snapshot.data()!};
  }

  /// Add a document to a collection.
  Future<String> add(String path, Map<String, dynamic> data) async {
    final docRef = await collection(path).add(data);
    return docRef.id;
  }

  /// Set a document (create or overwrite).
  Future<void> set(
    String path,
    String id,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await collection(path).doc(id).set(data, SetOptions(merge: merge));
  }

  /// Update a document.
  Future<void> update(String path, String id, Map<String, dynamic> data) async {
    await collection(path).doc(id).update(data);
  }

  /// Delete a document.
  Future<void> delete(String path, String id) async {
    await collection(path).doc(id).delete();
  }

  /// Query documents.
  Future<List<Map<String, dynamic>>> query(
    String path, {
    List<QueryFilter>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = collection(path);

    // Apply where clauses
    if (where != null) {
      for (final filter in where) {
        query = _applyFilter(query, filter);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Apply a filter to a query.
  Query<Map<String, dynamic>> _applyFilter(
    Query<Map<String, dynamic>> query,
    QueryFilter filter,
  ) {
    switch (filter.operator) {
      case QueryOperator.isEqualTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case QueryOperator.isNotEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case QueryOperator.isLessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case QueryOperator.isLessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case QueryOperator.isGreaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case QueryOperator.isGreaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case QueryOperator.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case QueryOperator.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case QueryOperator.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case QueryOperator.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
      case QueryOperator.isNull:
        return query.where(filter.field, isNull: filter.value);
    }
  }

  /// Stream a collection.
  Stream<List<Map<String, dynamic>>> streamCollection(String path) {
    return collection(path).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  /// Stream a document.
  Stream<Map<String, dynamic>?> streamDocument(String path, String id) {
    return collection(path).doc(id).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return {'id': snapshot.id, ...snapshot.data()!};
    });
  }

  /// Run a batch operation.
  Future<void> batch(
    Future<void> Function(WriteBatch batch) operations,
  ) async {
    final batch = firestore.batch();
    await operations(batch);
    await batch.commit();
  }

  /// Run a transaction.
  Future<T> transaction<T>(
    Future<T> Function(Transaction transaction) operations,
  ) async {
    return await firestore.runTransaction(operations);
  }

  /// Get server timestamp.
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Increment a field.
  FieldValue increment(num value) => FieldValue.increment(value);

  /// Add to array.
  FieldValue arrayUnion(List<dynamic> elements) =>
      FieldValue.arrayUnion(elements);

  /// Remove from array.
  FieldValue arrayRemove(List<dynamic> elements) =>
      FieldValue.arrayRemove(elements);

  /// Delete a field.
  FieldValue get deleteField => FieldValue.delete();

  @override
  String get serviceName => 'FirebaseKitFirestore';
}

/// Query filter for Firestore queries.
class QueryFilter {
  final String field;
  final QueryOperator operator;
  final dynamic value;

  QueryFilter(this.field, this.operator, this.value);

  /// Create an equals filter.
  factory QueryFilter.equals(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isEqualTo, value);

  /// Create a not equals filter.
  factory QueryFilter.notEquals(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isNotEqualTo, value);

  /// Create a less than filter.
  factory QueryFilter.lessThan(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isLessThan, value);

  /// Create a less than or equal filter.
  factory QueryFilter.lessThanOrEqual(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isLessThanOrEqualTo, value);

  /// Create a greater than filter.
  factory QueryFilter.greaterThan(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isGreaterThan, value);

  /// Create a greater than or equal filter.
  factory QueryFilter.greaterThanOrEqual(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.isGreaterThanOrEqualTo, value);

  /// Create an array contains filter.
  factory QueryFilter.arrayContains(String field, dynamic value) =>
      QueryFilter(field, QueryOperator.arrayContains, value);

  /// Create an array contains any filter.
  factory QueryFilter.arrayContainsAny(String field, List<dynamic> values) =>
      QueryFilter(field, QueryOperator.arrayContainsAny, values);

  /// Create a where in filter.
  factory QueryFilter.whereIn(String field, List<dynamic> values) =>
      QueryFilter(field, QueryOperator.whereIn, values);

  /// Create a where not in filter.
  factory QueryFilter.whereNotIn(String field, List<dynamic> values) =>
      QueryFilter(field, QueryOperator.whereNotIn, values);

  /// Create an is null filter.
  factory QueryFilter.isNull(String field, bool isNull) =>
      QueryFilter(field, QueryOperator.isNull, isNull);
}

/// Query operators for Firestore queries.
enum QueryOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}
