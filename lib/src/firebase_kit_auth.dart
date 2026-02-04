import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_kit_service.dart';
import 'firebase_kit_logger.dart';

/// Firebase Authentication service for Firebase Kit.
///
/// Provides authentication state management.
///
/// Example:
/// ```dart
/// FirebaseKitAuth(
///   onAuthStateChanged: (user) {
///     if (user != null) {
///       print('Logged in: ${user.email}');
///     } else {
///       print('Logged out');
///     }
///   },
/// )
/// ```
class FirebaseKitAuth extends FirebaseKitService {
  /// Callback when auth state changes.
  final void Function(User? user)? onAuthStateChanged;

  /// Callback when ID token changes.
  final void Function(User? user)? onIdTokenChanged;

  /// Whether to persist auth state.
  final bool persistSession;

  /// Firebase Auth instance
  FirebaseAuth? _auth;

  /// Get the FirebaseAuth instance
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  /// Auth state subscription
  StreamSubscription<User?>? _authStateSubscription;

  /// ID token subscription
  StreamSubscription<User?>? _idTokenSubscription;

  FirebaseKitAuth({
    this.onAuthStateChanged,
    this.onIdTokenChanged,
    this.persistSession = true,
  });

  @override
  Future<void> onInit() async {
    _auth = FirebaseAuth.instance;

    // Set persistence (web only)
    if (!persistSession) {
      try {
        await auth.setPersistence(Persistence.NONE);
      } catch (_) {
        // setPersistence throws on native platforms, which is expected
      }
    }

    // Listen to auth state changes
    _authStateSubscription = auth.authStateChanges().listen((User? user) async {
      FirebaseKitLogger.debug('Auth state changed: ${user?.uid ?? 'null'}');
      onAuthStateChanged?.call(user);
    });

    // Listen to ID token changes
    if (onIdTokenChanged != null) {
      _idTokenSubscription = auth.idTokenChanges().listen((User? user) {
        onIdTokenChanged?.call(user);
      });
    }
  }

  /// Get the current user.
  User? get currentUser => auth.currentUser;

  /// Check if user is signed in.
  bool get isSignedIn => currentUser != null;

  /// Get the current user's ID token.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await currentUser?.getIdToken(forceRefresh);
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Create user with email and password.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in anonymously.
  Future<UserCredential> signInAnonymously() async {
    return await auth.signInAnonymously();
  }

  /// Sign in with credential (for social auth).
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await auth.signInWithCredential(credential);
  }

  /// Sign out.
  Future<void> signOut() async {
    await auth.signOut();
    FirebaseKitLogger.debug('User signed out');
  }

  /// Send password reset email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  /// Send email verification.
  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  /// Update user profile.
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    await currentUser?.updateDisplayName(displayName);
    await currentUser?.updatePhotoURL(photoURL);
  }

  /// Update email.
  Future<void> updateEmail(String email) async {
    await currentUser?.verifyBeforeUpdateEmail(email);
  }

  /// Update password.
  Future<void> updatePassword(String password) async {
    await currentUser?.updatePassword(password);
  }

  /// Delete user account.
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }

  /// Re-authenticate user (required before sensitive operations).
  Future<UserCredential?> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    return await currentUser?.reauthenticateWithCredential(credential);
  }

  /// Link account with credential.
  Future<UserCredential?> linkWithCredential(AuthCredential credential) async {
    return await currentUser?.linkWithCredential(credential);
  }

  /// Unlink provider from account.
  Future<User?> unlinkFromProvider(String providerId) async {
    return await currentUser?.unlink(providerId);
  }

  /// Reload user data.
  Future<void> reloadUser() async {
    await currentUser?.reload();
  }

  /// Clean up subscriptions
  void dispose() {
    _authStateSubscription?.cancel();
    _idTokenSubscription?.cancel();
  }

  @override
  String get serviceName => 'FirebaseKitAuth';
}
