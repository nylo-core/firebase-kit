/// Firebase Kit - A comprehensive Firebase integration library.
///
/// This library provides streamlined Firebase services for Flutter applications.
///
/// Example:
/// ```dart
/// import 'package:firebase_kit/firebase_kit.dart';
///
/// // Initialize Firebase Kit
/// await FirebaseKit.init(
///   DefaultFirebaseOptions.currentPlatform,
///   services: [
///     FirebaseKitMessaging(sendTokenOnBoot: true),
///     FirebaseKitAnalytics(enableAutoTracking: true),
///     FirebaseKitCrashlytics(recordFlutterErrors: true),
///     FirebaseKitAuth(),
///     FirebaseKitFirestore(),
///   ],
/// );
/// ```
library;

export 'src/firebase_kit_base.dart';
export 'src/firebase_kit_service.dart';
export 'src/firebase_kit_logger.dart';
export 'src/firebase_kit_messaging.dart';
export 'src/firebase_kit_analytics.dart';
export 'src/firebase_kit_crashlytics.dart';
export 'src/firebase_kit_auth.dart';
export 'src/firebase_kit_firestore.dart';

// Re-export Firebase packages
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
