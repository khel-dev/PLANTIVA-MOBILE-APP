import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMessages {
  static String login(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Unable to log in. Please try again.';
    }

    switch (error.code) {
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      default:
        return 'Unable to log in. Please try again.';
    }
  }

  static String googleSignIn(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Google sign-in failed. Please try again.';
    }

    switch (error.code) {
      case 'aborted-by-user':
        return '';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email. Please sign in using the original method.';
      case 'invalid-credential':
      case 'credential-already-in-use':
        return 'Google sign-in could not be completed. Please try again.';
      default:
        return 'Google sign-in failed. Please try again.';
    }
  }

  static String registration(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Registration failed. Please try again.';
    }

    switch (error.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists. Please log in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email registration is not enabled for this app.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      case 'profile-setup-failed':
        return 'Account created, but profile setup failed. Please retry.';
      case 'registration-user-missing':
        return 'Account was created, but the session was not ready. Please log in.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  static String forgotPassword(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Unable to request a password reset. Please try again.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many reset attempts. Please try again later.';
      case 'user-not-found':
        return 'If an account exists for this email, a password reset link has been requested.';
      default:
        return 'Unable to request a password reset. Please try again.';
    }
  }

  static String changePassword(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Failed to update password. Please try again.';
    }

    switch (error.code) {
      case 'provider-managed-password':
        return 'Password changes for Google accounts are managed through your Google account.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'The current password is incorrect.';
      case 'weak-password':
        return 'Your new password is too weak. Please use a stronger password.';
      case 'requires-recent-login':
        return 'Please log in again before changing your password.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      default:
        return 'Failed to update password. Please try again.';
    }
  }

  static String deleteAccount(Object error) {
    if (error is! FirebaseAuthException) {
      return 'Failed to delete account. Please try again.';
    }

    switch (error.code) {
      case 'provider-managed-password':
        return 'Google accounts must be managed through Google before account deletion can continue.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'The password is incorrect.';
      case 'requires-recent-login':
        return 'Please log in again before deleting your account.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      case 'storage-cleanup-failed':
      case 'firestore-cleanup-failed':
        return 'Account deletion could not finish safely. Please check your connection and try again.';
      default:
        return 'Failed to delete account. Please try again.';
    }
  }

  static String logout(Object error) {
    return 'Unable to sign out. Please check your connection and try again.';
  }
}
