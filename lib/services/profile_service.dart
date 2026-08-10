import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  String? get uid => _auth.currentUser?.uid;

  bool get isPasswordAccount {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((p) => p.providerId == 'password');
  }

  Stream<DocumentSnapshot> userStream() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _db.collection('users').doc(id).snapshots();
  }

  Future<void> updateProfile({
    String? fullName,
    String? contactNumber,
    String? farmLocation,
  }) async {
    final id = uid;
    if (id == null) return;
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (fullName != null) data['fullName'] = fullName.trim();
    if (contactNumber != null) {
      data['phoneNumber'] = contactNumber.trim();
      data['contactNumber'] = contactNumber.trim();
    }
    if (farmLocation != null) {
      data['location'] = farmLocation.trim();
      data['farmLocation'] = farmLocation.trim();
    }
    await _db.collection('users').doc(id).set(data, SetOptions(merge: true));
    if (fullName != null && fullName.trim().isNotEmpty) {
      await _auth.currentUser?.updateDisplayName(fullName.trim());
    }
  }

  Future<String?> pickAndUploadPhoto(ImageSource source) async {
    final id = uid;
    if (id == null) return null;

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final ref = _storage.ref().child('users/$id/profile.jpg');
    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    await _db.collection('users').doc(id).set(
      {'photoUrl': url, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    await _auth.currentUser?.updatePhotoURL(url);
    return url;
  }

  Future<void> removePhoto() async {
    final id = uid;
    if (id == null) return;
    try {
      await _storage.ref().child('users/$id/profile.jpg').delete();
    } catch (_) {}
    await _db.collection('users').doc(id).set(
      {
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp()
      },
      SetOptions(merge: true),
    );
    await _auth.currentUser?.updatePhotoURL(null);
  }

  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    final id = uid;
    if (id == null) return;
    await _db.collection('users').doc(id).set(
      {
        'notificationSettings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (!isPasswordAccount) {
      throw FirebaseAuthException(
        code: 'provider-managed-password',
        message:
            'Password changes for Google accounts are managed through Google.',
      );
    }
    if (user?.email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'No email associated with this account.',
      );
    }
    final cred = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    final id = uid;
    if (user == null || id == null) return;

    if (!isPasswordAccount) {
      throw FirebaseAuthException(
        code: 'provider-managed-password',
        message:
            'Google accounts require Google reauthentication before deletion.',
      );
    }

    if (user.email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'No email associated with this account.',
      );
    }

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(cred);

    try {
      await _storage.ref().child('users/$id/profile.jpg').delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        throw FirebaseAuthException(
          code: 'storage-cleanup-failed',
          message: 'Profile image cleanup failed.',
        );
      }
    }

    try {
      final scans =
          await _db.collection('users').doc(id).collection('scans').get();
      for (final doc in scans.docs) {
        final url = doc.data()['imageUrl'] as String?;
        if (url != null && url.isNotEmpty) {
          try {
            await _storage.refFromURL(url).delete();
          } on FirebaseException catch (e) {
            if (e.code != 'object-not-found') {
              throw FirebaseAuthException(
                code: 'storage-cleanup-failed',
                message: 'Scan image cleanup failed.',
              );
            }
          } on ArgumentError {
            // Existing invalid URLs should not block account deletion.
          }
        }
        await doc.reference.delete();
      }
      await _db.collection('users').doc(id).delete();
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      throw FirebaseAuthException(
        code: 'firestore-cleanup-failed',
        message: 'Account data cleanup failed.',
      );
    }

    await user.delete();
  }
}
