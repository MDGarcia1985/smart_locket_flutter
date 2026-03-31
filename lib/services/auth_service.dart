/// Authentication Service (Firebase)
///
/// Production auth using Firebase Authentication:
/// - Email/password (create account + sign in)
/// - Google Sign-In
/// - Apple Sign-In (iOS)
library;

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Authentication service backed by Firebase Auth.
///
/// Exposes a single [userStream] and [currentUser]; sign-in methods return
/// `null` on success or an error message [String] on failure.
class AuthService {
  static final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static User? _currentUser;
  static final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  static StreamSubscription<firebase_auth.User?>? _authSubscription;

  static void _ensureAuthListener() {
    _authSubscription ??= _auth.authStateChanges().listen((firebaseUser) {
      _currentUser = firebaseUser == null ? null : _fromFirebaseUser(firebaseUser);
      if (!_userController.isClosed) _userController.add(_currentUser);
    });
  }

  /// Stream of auth state. Listen to react to sign-in/sign-out.
  static Stream<User?> get userStream {
    _ensureAuthListener();
    return _userController.stream;
  }

  /// Currently signed-in user, or null.
  static User? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      _currentUser = null;
      return null;
    }
    _currentUser ??= _fromFirebaseUser(firebaseUser);
    return _currentUser;
  }

  static User _fromFirebaseUser(firebase_auth.User fu) {
    final providerId = fu.providerData.isNotEmpty
        ? fu.providerData.first.providerId
        : 'firebase';
    AuthProvider provider = AuthProvider.email;
    if (providerId.contains('google')) {
      provider = AuthProvider.google;
    } else if (providerId.contains('apple')) {
      provider = AuthProvider.apple;
    }
    final email = fu.email ?? fu.providerData
        .map((e) => e.email)
        .whereType<String>()
        .firstOrNull ?? '';
    final name = fu.displayName ?? email.split('@').first;
    return User(
      id: fu.uid,
      email: email,
      name: name.isNotEmpty ? name : 'User',
      provider: provider,
    );
  }

  /// Sign in with email and password.
  /// Returns null on success, or an error message on failure.
  static Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Sign-in failed. Please try again.';
    }
  }

  /// Create account with email and password.
  /// Returns null on success, or an error message on failure.
  static Future<String?> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Could not create account. Please try again.';
    }
  }

  /// Send password reset email.
  /// Returns null on success, or an error message on failure.
  static Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Could not send reset email.';
    }
  }

  /// Sign in with Google.
  /// Returns null on success, or an error message on failure.
  static Future<String?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return 'Sign-in was cancelled.';

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Google sign-in failed. Please try again.';
    }
  }

  /// Sign in with Apple (supported on iOS and optionally Android).
  /// Returns null on success, or an error message on failure.
  static Future<String?> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      return 'Apple Sign-In is only available on Apple devices.';
    }
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(oauthCredential);
      if (_auth.currentUser != null && _auth.currentUser!.displayName == null) {
        final name = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
        if (name.isNotEmpty) {
          await _auth.currentUser!.updateDisplayName(name);
        }
      }
      return null;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return 'Sign-in was cancelled.';
      }
      return e.message;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return _authErrorMessage(e);
    } catch (e) {
      return 'Apple sign-in failed. Please try again.';
    }
  }

  /// Sign out the current user (Firebase + Google Sign-In if used).
  static Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    _currentUser = null;
    if (!_userController.isClosed) _userController.add(null);
  }

  /// Whether a user is currently signed in.
  static bool get isSignedIn => _auth.currentUser != null;

  /// User-friendly message from Firebase auth exception.
  static String _authErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Sign-in failed. Please try again.';
    }
  }
}

/// App-level user model (mapped from Firebase User).
class User {
  final String id;
  final String email;
  final String name;
  final AuthProvider provider;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.provider,
  });
}

enum AuthProvider { email, google, apple }
