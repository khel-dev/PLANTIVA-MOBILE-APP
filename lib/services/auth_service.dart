import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    unawaited(
      _upsertUserProfile(
        uid: credential.user!.uid,
        email: credential.user!.email ?? email,
        fullName: credential.user!.displayName?.trim(),
        provider: 'password',
        photoUrl: credential.user!.photoURL,
        extra: {'rememberMe': rememberMe},
      ).catchError((Object e, StackTrace stackTrace) {
        debugPrint('User profile sync after login failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? contactNumber,
    String? farmLocation,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim();
    final cleanPhone = (contactNumber ?? '').trim();
    final cleanLocation = (farmLocation ?? '').trim();

    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    }

    await credential.user?.reload();
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'registration-user-missing',
        message: 'Account was created, but the user session was not returned.',
      );
    }

    try {
      await _saveRegistrationProfile(
        user: user,
        fullName: cleanName,
        email: cleanEmail,
        phoneNumber: cleanPhone,
        location: cleanLocation,
      );
    } catch (e, stackTrace) {
      debugPrint('Registration profile setup failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw FirebaseAuthException(
        code: 'profile-setup-failed',
        message: 'Account created, but profile setup failed. Please retry.',
      );
    }
  }

  Future<void> saveCurrentUserRegistrationProfile({
    required String fullName,
    required String email,
    String? contactNumber,
    String? farmLocation,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found for profile setup.',
      );
    }

    await _saveRegistrationProfile(
      user: user,
      fullName: fullName.trim(),
      email: email.trim(),
      phoneNumber: (contactNumber ?? '').trim(),
      location: (farmLocation ?? '').trim(),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInReady();
    final GoogleSignInAccount googleUser;
    try {
      googleUser = await GoogleSignIn.instance.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign-in was cancelled.',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.description ?? e.toString(),
      );
    }
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    unawaited(
      _upsertUserProfile(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email ?? googleUser.email,
        fullName: userCredential.user!.displayName?.trim().isNotEmpty == true
            ? userCredential.user!.displayName!
            : (googleUser.displayName ?? 'Plantiva User'),
        provider: 'google',
        photoUrl: userCredential.user!.photoURL ?? googleUser.photoUrl,
      ).catchError((Object e, StackTrace stackTrace) {
        debugPrint('User profile sync after Google login failed: $e');
        debugPrintStack(stackTrace: stackTrace);
      }),
    );
    return userCredential;
  }

  Future<void> _upsertUserProfile({
    required String uid,
    required String email,
    required String? fullName,
    required String provider,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final now = FieldValue.serverTimestamp();
    final cleanName = fullName?.trim();
    final data = <String, dynamic>{
      'uid': uid,
      'email': email,
      'provider': provider,
      'photoUrl': photoUrl,
      'updatedAt': now,
      'lastLoginAt': now,
      ...?extra,
    };
    if (cleanName != null && cleanName.isNotEmpty) {
      data['fullName'] = cleanName;
    }

    await userRef.set(data, SetOptions(merge: true));
    final snapshot = await userRef.get();
    if (!snapshot.exists || snapshot.data()?['createdAt'] == null) {
      await userRef.set({'createdAt': now}, SetOptions(merge: true));
    }
  }

  Future<void> _saveRegistrationProfile({
    required User user,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String location,
  }) async {
    if (fullName.isNotEmpty) {
      try {
        await user.updateDisplayName(fullName).timeout(
              const Duration(seconds: 8),
            );
        await user.reload();
      } catch (e) {
        debugPrint('updateDisplayName failed (non-fatal): $e');
      }
    }

    await _upsertUserProfile(
      uid: user.uid,
      email: user.email ?? email,
      fullName: fullName,
      provider: 'password',
      photoUrl: user.photoURL,
      extra: {
        'phoneNumber': phoneNumber,
        'contactNumber': phoneNumber,
        'location': location,
        'farmLocation': location,
      },
    ).timeout(
      const Duration(seconds: 12),
    );
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data();
  }

  Future<void> signOut() async {
    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }
}
