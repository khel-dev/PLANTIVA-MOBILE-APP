import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _upsertUserProfile(
      uid: credential.user!.uid,
      email: credential.user!.email ?? email,
      fullName: credential.user!.displayName?.trim().isNotEmpty == true
          ? credential.user!.displayName!
          : 'Plantiva User',
      provider: 'password',
      photoUrl: credential.user!.photoURL,
      extra: {'rememberMe': rememberMe},
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(fullName);
    await _upsertUserProfile(
      uid: credential.user!.uid,
      email: email,
      fullName: fullName,
      provider: 'password',
      photoUrl: credential.user!.photoURL,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _upsertUserProfile(
      uid: userCredential.user!.uid,
      email: userCredential.user!.email ?? googleUser.email,
      fullName: userCredential.user!.displayName?.trim().isNotEmpty == true
          ? userCredential.user!.displayName!
          : (googleUser.displayName ?? 'Plantiva User'),
      provider: 'google',
      photoUrl: userCredential.user!.photoURL ?? googleUser.photoUrl,
    );
    return userCredential;
  }

  Future<void> _upsertUserProfile({
    required String uid,
    required String email,
    required String fullName,
    required String provider,
    String? photoUrl,
    Map<String, dynamic>? extra,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final now = FieldValue.serverTimestamp();
    await userRef.set({
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'provider': provider,
      'photoUrl': photoUrl,
      'updatedAt': now,
      'lastLoginAt': now,
      ...?extra,
    }, SetOptions(merge: true));
    final snapshot = await userRef.get();
    if (!snapshot.exists || snapshot.data()?['createdAt'] == null) {
      await userRef.set({'createdAt': now}, SetOptions(merge: true));
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    return snapshot.data();
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
