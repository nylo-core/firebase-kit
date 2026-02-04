# Firebase Kit

A comprehensive Firebase integration library for Flutter applications. Provides streamlined Firebase services including Analytics, Authentication, Crashlytics, Cloud Firestore, and Cloud Messaging.

## Features

- **FirebaseKitMessaging** - Push notifications, FCM tokens, topic subscriptions
- **FirebaseKitAnalytics** - Event logging, screen tracking, user properties
- **FirebaseKitCrashlytics** - Crash reporting, error logging
- **FirebaseKitAuth** - Authentication state management
- **FirebaseKitFirestore** - Collection helpers, queries, streaming

## Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Configure Firebase for your app:
   ```bash
   flutterfire configure
   ```

4. Add Firebase Kit to your `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_kit: ^1.0.0
   ```

## Quick Start

```dart
import 'package:firebase_kit/firebase_kit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseKit.init(
    DefaultFirebaseOptions.currentPlatform,
    services: [
      FirebaseKitAnalytics(enableAutoTracking: true),
      FirebaseKitMessaging(
        onToken: (token) async {
          print('FCM Token: $token');
        },
      ),
      FirebaseKitCrashlytics(recordFlutterErrors: true),
      FirebaseKitAuth(
        onAuthStateChanged: (user) {
          print('Auth state: ${user?.email}');
        },
      ),
      FirebaseKitFirestore(),
    ],
  );
  
  runApp(MyApp());
}
```

## Getting Services

Access any registered service anywhere in your app:

```dart
// Static helper (recommended)
final messaging = FirebaseKit.service<FirebaseKitMessaging>();

// Via instance
final analytics = FirebaseKit.instance?.getService<FirebaseKitAnalytics>();
```

## Services

### FirebaseKitMessaging

**Configuration:**

```dart
FirebaseKitMessaging(
  autoRequestPermission: true,
  onToken: (token) async {
    // Send token to your server
  },
  onAuthorized: (token) async {
    // Called when permission is granted (authorized or provisional)
    await api.sendToken(token);
  },
  onMessage: (message) {
    // Handle foreground message
  },
  onMessageOpenedApp: (message) {
    // Handle notification tap
  },
  onInitialMessage: (message) {
    // Handle cold-start notification (app was terminated)
  },
  onBackgroundMessage: firebaseMessagingBackgroundHandler, // must be top-level
  subscribeToTopics: ['news', 'offers'],
)
```

**Usage:**

```dart
final messaging = FirebaseKit.service<FirebaseKitMessaging>();

// Get the current FCM token
final token = await messaging?.getToken();

// Access the cached token
final cached = messaging?.token;

// Request permissions manually
final status = await messaging?.requestPermission(provisional: true);

// Topic management
await messaging?.subscribeToTopic('promotions');
await messaging?.unsubscribeFromTopic('promotions');

// Delete token (useful for logout)
await messaging?.deleteToken();

// Get APNS token (iOS only)
final apns = await messaging?.getAPNSToken();

// iOS foreground presentation options
await messaging?.setForegroundNotificationPresentationOptions(
  alert: true,
  badge: true,
  sound: true,
);
```

#### `onAuthorized` callback

The `onAuthorized` callback fires after `requestPermission()` when the user grants notification permission (authorized or provisional). It receives the FCM token, making it useful for sending the token to your server only after permission is confirmed.

**Auto flow** — set the callback in the constructor. When `autoRequestPermission` is `true`, it fires automatically during initialization:

```dart
FirebaseKitMessaging(
  autoRequestPermission: true,
  onAuthorized: (token) async {
    await api.sendToken(token);
  },
)
```

**Manual flow** — pass the callback directly to `requestPermission()`. This overrides the constructor callback:

```dart
final messaging = FirebaseKit.service<FirebaseKitMessaging>();
final status = await messaging?.requestPermission(
  onAuthorized: (token) async {
    await api.sendToken(token);
  },
);
```

#### Static helper

Request permissions and get the FCM token without registering the service:

```dart
await FirebaseKitMessaging.getFcmToken(
  onToken: (token) async {
    await api.sendToken(token);
  },
  provisional: true,
);
```

### FirebaseKitAnalytics

**Configuration:**

```dart
FirebaseKitAnalytics(
  enableAutoTracking: true,
  userId: 'user-123',
  defaultEventParameters: {
    'app_version': '1.0.0',
  },
  userProperties: {
    'plan': 'premium',
  },
  onObserverCreated: (observer) {
    // Add to your MaterialApp navigatorObservers
  },
)
```

**Usage:**

```dart
final analytics = FirebaseKit.service<FirebaseKitAnalytics>();

// Log custom events
await analytics?.logEvent(name: 'purchase', parameters: {'item': 'widget'});

// Screen tracking
await analytics?.setCurrentScreen(screenName: 'HomeScreen');

// User identity
await analytics?.setUserId('user-123');
await analytics?.setUserProperty(name: 'plan', value: 'premium');

// Pre-built events
await analytics?.logLogin(loginMethod: 'google');
await analytics?.logSignUp(signUpMethod: 'email');
await analytics?.logSearch(searchTerm: 'flutter');
await analytics?.logShare(contentType: 'article', itemId: '42', method: 'link');
await analytics?.logPurchase(currency: 'USD', value: 9.99, transactionId: 'tx-1');
await analytics?.logAddToCart(currency: 'USD', value: 9.99);

// Collection control
await analytics?.setAnalyticsCollectionEnabled(false);
await analytics?.resetAnalyticsData();

// Access the NavigatorObserver for your MaterialApp
final observer = analytics?.observer;
```

### FirebaseKitCrashlytics

**Configuration:**

```dart
FirebaseKitCrashlytics(
  enableInDevMode: false,
  recordFlutterErrors: true,
  userId: 'user-123',
  customKeys: {
    'environment': 'production',
    'feature_flag': true,
  },
)
```

**Usage:**

```dart
final crashlytics = FirebaseKit.service<FirebaseKitCrashlytics>();

// Record errors
await crashlytics?.recordError(exception, stackTrace, reason: 'API call failed');
await crashlytics?.recordFatalError(exception, stackTrace);

// Breadcrumb logging
await crashlytics?.log('User tapped checkout button');

// User identity
await crashlytics?.setUserIdentifier('user-123');

// Custom keys for crash context
await crashlytics?.setCustomKey('screen', 'checkout');

// Unsent report management
final hasUnsent = await crashlytics?.checkForUnsentReports();
await crashlytics?.sendUnsentReports();
await crashlytics?.deleteUnsentReports();

// Collection control
await crashlytics?.setCrashlyticsCollectionEnabled(true);
final enabled = await crashlytics?.isCrashlyticsCollectionEnabled();

// Force a test crash (debug only)
crashlytics?.crash();
```

### FirebaseKitAuth

**Configuration:**

```dart
FirebaseKitAuth(
  persistSession: true,
  onAuthStateChanged: (user) {
    if (user != null) {
      print('Logged in: ${user.email}');
    } else {
      print('Logged out');
    }
  },
  onIdTokenChanged: (user) {
    // Token refreshed
  },
)
```

**Usage:**

```dart
final auth = FirebaseKit.service<FirebaseKitAuth>();

// Check auth state
final isSignedIn = auth?.isSignedIn;
final user = auth?.currentUser;

// Sign in
await auth?.signInWithEmailAndPassword(email: 'user@example.com', password: 'password');
await auth?.signInAnonymously();
await auth?.signInWithCredential(googleCredential);

// Create account
await auth?.createUserWithEmailAndPassword(email: 'user@example.com', password: 'password');

// Get ID token
final token = await auth?.getIdToken(forceRefresh: true);

// Profile management
await auth?.updateProfile(displayName: 'Jane', photoURL: 'https://...');
await auth?.updateEmail('new@example.com');
await auth?.updatePassword('newPassword');

// Account operations
await auth?.sendEmailVerification();
await auth?.sendPasswordResetEmail(email: 'user@example.com');
await auth?.reloadUser();

// Link / unlink providers
await auth?.linkWithCredential(credential);
await auth?.unlinkFromProvider('google.com');

// Re-authenticate (required before sensitive operations)
await auth?.reauthenticateWithCredential(credential);

// Sign out & delete
await auth?.signOut();
await auth?.deleteAccount();
```

### FirebaseKitFirestore

**Configuration:**

```dart
FirebaseKitFirestore(
  settings: Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  ),
)
```

**Usage:**

```dart
final firestore = FirebaseKit.service<FirebaseKitFirestore>();

// CRUD operations
final id = await firestore?.add('users', {'name': 'Jane', 'age': 30});
final user = await firestore?.getById('users', 'user-123');
final allUsers = await firestore?.getAll('users');
await firestore?.set('users', 'user-123', {'name': 'Jane'}, merge: true);
await firestore?.update('users', 'user-123', {'age': 31});
await firestore?.delete('users', 'user-123');

// Query with filters
final results = await firestore?.query(
  'users',
  where: [
    QueryFilter.equals('isActive', true),
    QueryFilter.greaterThan('age', 18),
  ],
  orderBy: 'createdAt',
  descending: true,
  limit: 10,
);

// Real-time streams
final usersStream = firestore?.streamCollection('users');
final userStream = firestore?.streamDocument('users', 'user-123');

// Typed collections with model conversion
final usersRef = firestore?.typedCollection<User>(
  'users',
  fromJson: (data) => User.fromJson(data),
  toJson: (user) => user.toJson(),
);

// References
final colRef = firestore?.collection('users');
final docRef = firestore?.doc('users/user-123');

// Batch writes
await firestore?.batch((batch) async {
  batch.set(docRef!, {'name': 'Jane'});
  batch.update(docRef, {'age': 31});
});

// Transactions
await firestore?.transaction((tx) async {
  final snapshot = await tx.get(docRef!);
  tx.update(docRef, {'count': (snapshot.data()?['count'] ?? 0) + 1});
  return null;
});

// Field value helpers
firestore?.serverTimestamp;       // FieldValue.serverTimestamp()
firestore?.increment(1);          // FieldValue.increment(1)
firestore?.arrayUnion(['tag']);    // FieldValue.arrayUnion(['tag'])
firestore?.arrayRemove(['tag']);   // FieldValue.arrayRemove(['tag'])
firestore?.deleteField;            // FieldValue.delete()
```

## App Ready Lifecycle

If your services need navigation context (e.g., deep linking), call `onAppReady()` after your app is fully initialized:

```dart
// In your app initialization
await FirebaseKit.instance?.onAppReady();
```

## License

MIT License
