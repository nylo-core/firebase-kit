## 1.1.1 - 2026-03-02

### Changed
- Bump `firebase_core` to `^4.4.0`
- Bump `firebase_messaging` to `^16.1.1`
- Bump `firebase_analytics` to `^12.1.2`
- Bump `firebase_crashlytics` to `^5.0.7`
- Bump `firebase_auth` to `^6.1.4`
- Bump `cloud_firestore` to `^6.1.2`

## 1.1.0 - 2026-03-02

### Added
- `enableLogging` parameter on `FirebaseKit.init()` to control debug logging output (defaults to `true`)

## 1.0.0

- Initial release
- FirebaseKitMessaging: Push notifications, FCM tokens, topic subscriptions, `onAuthorized` callback
- FirebaseKitAnalytics: Event logging, screen tracking, user properties
- FirebaseKitCrashlytics: Crash reporting, error logging
- FirebaseKitAuth: Authentication state management
- FirebaseKitFirestore: Collection helpers, typed converters, queries, streaming
