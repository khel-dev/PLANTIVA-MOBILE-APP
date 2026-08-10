import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/utils/auth_error_messages.dart';

void main() {
  group('AuthErrorMessages', () {
    test('maps invalid login without revealing account existence', () {
      expect(
        AuthErrorMessages.login(
          FirebaseAuthException(code: 'user-not-found'),
        ),
        'Incorrect email or password.',
      );
      expect(
        AuthErrorMessages.login(
          FirebaseAuthException(code: 'wrong-password'),
        ),
        'Incorrect email or password.',
      );
    });

    test('maps network login failure', () {
      expect(
        AuthErrorMessages.login(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
        'Unable to connect. Please check your internet connection.',
      );
    });

    test('uses safe forgot password response for missing user', () {
      expect(
        AuthErrorMessages.forgotPassword(
          FirebaseAuthException(code: 'user-not-found'),
        ),
        'If an account exists for this email, a password reset link has been requested.',
      );
    });

    test('maps Google cancellation to no alarming message', () {
      expect(
        AuthErrorMessages.googleSignIn(
          FirebaseAuthException(code: 'aborted-by-user'),
        ),
        isEmpty,
      );
    });

    test('maps Google account password changes as provider-managed', () {
      expect(
        AuthErrorMessages.changePassword(
          FirebaseAuthException(code: 'provider-managed-password'),
        ),
        'Password changes for Google accounts are managed through your Google account.',
      );
    });
  });
}
