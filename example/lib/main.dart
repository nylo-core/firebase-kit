// ignore_for_file: avoid_print

import 'package:firebase_kit/firebase_kit.dart';
import 'package:flutter/material.dart';

// TODO: Generate this file by running: flutterfire configure
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FirebaseKit with your services
  // await FirebaseKit.init(
  //   options: DefaultFirebaseOptions.currentPlatform,
  //   services: [
  //     FirebaseKitAuth(),
  //     FirebaseKitAnalytics(),
  //     FirebaseKitCrashlytics(),
  //     FirebaseKitFirestore(),
  //     FirebaseKitMessaging(),
  //   ],
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Firebase Kit Example')),
      ),
    );
  }
}

// ============================================================================
// Authentication Example
// ============================================================================

Future<void> authExample() async {
  final FirebaseKitAuth? auth = FirebaseKit.service<FirebaseKitAuth>();

  if (auth == null) {
    print('FirebaseKitAuth service not initialized.');
    return;
  }

  // Sign in with email and password
  final userCredential = await auth.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'password123',
  );
  print('Signed in: ${userCredential.user?.email}');

  // Create a new user
  await auth.createUserWithEmailAndPassword(
    email: 'newuser@example.com',
    password: 'password123',
  );

  // Listen to auth state changes
  auth.auth.authStateChanges().listen((user) {
    print('Auth state changed: ${user?.email}');
  });

  // Sign out
  await auth.signOut();
}

// ============================================================================
// Analytics Example
// ============================================================================

Future<void> analyticsExample() async {
  final analytics = FirebaseKit.service<FirebaseKitAnalytics>();

  if (analytics == null) {
    print('FirebaseKitAnalytics service not initialized.');
    return;
  }

  // Log a custom event
  await analytics.logEvent(name: 'button_clicked', parameters: {
    'button_id': 'submit_form',
    'screen': 'home',
  });

  // Set current screen
  await analytics.setCurrentScreen(screenName: 'HomeScreen');

  // Log login event
  await analytics.logLogin(loginMethod: 'email');

  // Log purchase event
  await analytics.logPurchase(
    currency: 'USD',
    value: 9.99,
  );

  // Get navigator observer for automatic screen tracking
  final observer = analytics.observer;
  print('Navigator observer: $observer');
}

// ============================================================================
// Crashlytics Example
// ============================================================================

Future<void> crashlyticsExample() async {
  final crashlytics = FirebaseKit.service<FirebaseKitCrashlytics>();

  if (crashlytics == null) {
    print('FirebaseKitCrashlytics service not initialized.');
    return;
  }

  // Record a non-fatal error
  try {
    throw Exception('Something went wrong');
  } catch (e, stackTrace) {
    await crashlytics.recordError(e, stackTrace, reason: 'Example error');
  }

  // Log a message
  await crashlytics.log('User performed action X');

  // Set user identifier
  await crashlytics.setUserIdentifier('user_123');
}

// ============================================================================
// Firestore Example
// ============================================================================

Future<void> firestoreExample() async {
  final firestore = FirebaseKit.service<FirebaseKitFirestore>();

  if (firestore == null) {
    print('FirebaseKitFirestore service not initialized.');
    return;
  }

  // Add a document
  final docId = await firestore.add('users', {
    'name': 'John Doe',
    'email': 'john@example.com',
    'createdAt': DateTime.now().toIso8601String(),
  });
  print('Added document: $docId');

  // Query documents with filters
  final users = await firestore.query(
    'users',
    where: [
      QueryFilter.equals('name', 'John Doe'),
    ],
  );
  print('Found ${users.length} users');

  // Get all documents
  final allUsers = await firestore.getAll('users');
  print('Total users: ${allUsers.length}');

  // Update a document
  await firestore.update('users', docId, {'name': 'Jane Doe'});

  // Delete a document
  await firestore.delete('users', docId);
}

// ============================================================================
// Messaging Example
// ============================================================================

Future<void> messagingExample() async {
  final messaging = FirebaseKit.service<FirebaseKitMessaging>();

  if (messaging == null) {
    print('FirebaseKitMessaging service not initialized.');
    return;
  }

  // Get FCM token
  final token = messaging.token;
  print('FCM Token: $token');

  // Request permission (if not auto-requested during init)
  await messaging.requestPermission();

  // Subscribe to a topic
  await messaging.subscribeToTopic('news');

  // Unsubscribe from a topic
  await messaging.unsubscribeFromTopic('news');
}
