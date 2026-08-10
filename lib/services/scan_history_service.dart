import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ScanPersistenceException implements Exception {
  const ScanPersistenceException(this.code, this.userMessage, [this.cause]);

  final String code;
  final String userMessage;
  final Object? cause;

  @override
  String toString() => 'ScanPersistenceException($code): $userMessage';
}

class ScanHistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;
  static final Map<String, Future<String?>> _pendingSaves = {};
  static final Map<String, _RecentSave> _recentSaves = {};
  static const Duration _duplicateWindow = Duration(minutes: 2);

  static bool _shouldPersist(String label) {
    final l = label.toLowerCase().trim();
    if (l.isEmpty) return false;
    if (l.contains('model not ready')) return false;
    if (l == 'error') return false;
    if (l.contains('not a banana leaf')) return false;
    if (l.contains('unable to determine')) return false;
    if (l.contains('low confidence')) return false;
    if (l.contains('unclear image')) return false;
    if (l.contains('invalid image')) return false;
    if (l.contains('cannot connect')) return false;
    return true;
  }

  static bool _isValidDiagnosis(Map<String, String> result) {
    final status = result['validation_status'];
    return status == 'validDiagnosis' && _shouldPersist(result['label'] ?? '');
  }

  static String? _uid() => _auth.currentUser?.uid;

  /// Copies scan image to app documents for persistent local access.
  static Future<String?> _persistLocalImage(String sourcePath) async {
    try {
      final src = File(sourcePath);
      if (!await src.exists()) {
        debugPrint(
          'PLANTIVA scan image copy failed: source not found $sourcePath',
        );
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(dir.path, 'scans'));
      if (!await scansDir.exists()) await scansDir.create(recursive: true);
      final name =
          'scan_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
      final dest = File(p.join(scansDir.path, name));
      await src.copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('PLANTIVA scan image copy failed: $e');
      return sourcePath;
    }
  }

  static Future<String> _uploadImage(
    String uid,
    String scanId,
    String localPath,
  ) async {
    try {
      final ref = _storage.ref().child('users/$uid/scans/$scanId.jpg');
      await ref.putFile(File(localPath)).timeout(const Duration(seconds: 45));
      return await ref.getDownloadURL().timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('PLANTIVA Firebase Storage upload failed: $e');
      throw ScanPersistenceException(
        'storage-upload-failed',
        'Scan image upload failed. Please check your connection and try again.',
        e,
      );
    }
  }

  static Future<String?> recordScan(
    Map<String, String> result, {
    required String imagePath,
  }) async {
    final label = result['label'] ?? '';
    if (!_isValidDiagnosis(result)) {
      debugPrint('PLANTIVA scan rejected, not saved: $label '
          '(${result['validation_status'] ?? 'no validation status'})');
      return null;
    }

    final uid = _uid();
    if (uid == null) {
      debugPrint('PLANTIVA Firestore save skipped: no signed-in user.');
      return null;
    }

    final saveKey = _saveKey(uid, result, imagePath);
    _pruneRecentSaves();
    final recent = _recentSaves[saveKey];
    if (recent != null) return recent.scanId;
    final pending = _pendingSaves[saveKey];
    if (pending != null) return pending;

    final saveFuture = _recordValidScan(uid, result, imagePath: imagePath);
    _pendingSaves[saveKey] = saveFuture;
    try {
      final scanId = await saveFuture;
      if (scanId != null) {
        _recentSaves[saveKey] = _RecentSave(scanId, DateTime.now());
      }
      return scanId;
    } finally {
      _pendingSaves.remove(saveKey);
    }
  }

  static Future<String?> _recordValidScan(
    String uid,
    Map<String, String> result, {
    required String imagePath,
  }) async {
    final label = result['label'] ?? '';
    final enriched = ScanDiagnosisHelper.enrichResult(result);
    final userRef = _db.collection('users').doc(uid);
    final scanRef = userRef.collection('scans').doc();
    final scanId = scanRef.id;

    final localPath = await _persistLocalImage(imagePath);
    if (localPath == null) {
      throw const ScanPersistenceException(
        'local-image-missing',
        'The scan image could not be prepared. Please scan again.',
      );
    }

    final imageUrl = await _uploadImage(uid, scanId, localPath);

    final batch = _db.batch();
    batch.set(scanRef, {
      'label': label,
      'confidence': enriched['confidence'] ?? '',
      'rawLabel': enriched['raw_label'] ?? '',
      'severity': enriched['severity'] ?? '',
      'summary': enriched['summary'] ?? '',
      'recommendations': enriched['recommendations'] ?? '',
      'severityAction': enriched['severityAction'] ?? '',
      if ((enriched['insights'] ?? '').trim().isNotEmpty)
        'insights': enriched['insights'],
      'imagePath': localPath,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      userRef,
      {
        'totalScans': FieldValue.increment(1),
        'lastScanLabel': label,
        'lastScanAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    try {
      await batch.commit().timeout(const Duration(seconds: 20));
      return scanId;
    } catch (e) {
      debugPrint('PLANTIVA Firestore scan save failed: $e');
      await _cleanupUploadedScanImage(uid, scanId);
      throw ScanPersistenceException(
        'firestore-save-failed',
        'Scan save failed. Please check your connection and try again.',
        e,
      );
    }
  }

  static Stream<List<ScanRecord>> watchScans({int limit = 50}) {
    final uid = _uid();
    if (uid == null) return Stream.value(const []);

    return _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map(ScanRecord.fromDoc).toList());
  }

  static Future<List<ScanRecord>> fetchScans({int limit = 200}) async {
    final uid = _uid();
    if (uid == null) return [];

    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(ScanRecord.fromDoc).toList();
  }

  static Future<void> deleteScan(
    String scanId, {
    String? imageUrl,
    String? imagePath,
  }) async {
    final uid = _uid();
    if (uid == null) {
      throw const ScanPersistenceException(
        'delete-unauthenticated',
        'Please sign in again before deleting this scan.',
      );
    }

    await _deleteStorageImageIfPresent(imageUrl);

    final userRef = _db.collection('users').doc(uid);
    final scanRef = userRef.collection('scans').doc(scanId);

    try {
      await _db.runTransaction((tx) async {
        final scanSnap = await tx.get(scanRef);
        if (!scanSnap.exists) return;

        final userSnap = await tx.get(userRef);
        final data = userSnap.data();
        final currentTotal = (data?['totalScans'] as num?)?.toInt();
        final nextTotal =
            currentTotal == null ? 0 : (currentTotal - 1).clamp(0, 1 << 31);

        tx.delete(scanRef);
        tx.set(
          userRef,
          {
            'totalScans': nextTotal,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }).timeout(const Duration(seconds: 20));
      await _deleteLocalScanImageIfSafe(imagePath);
    } catch (e) {
      debugPrint('PLANTIVA scan delete failed: $e');
      throw ScanPersistenceException(
        'firestore-delete-failed',
        'Scan delete failed. Please check your connection and try again.',
        e,
      );
    }
  }

  static String _saveKey(
    String uid,
    Map<String, String> result,
    String imagePath,
  ) {
    return [
      uid,
      imagePath,
      result['label'] ?? '',
      result['raw_label'] ?? '',
      result['confidence'] ?? '',
      result['validation_status'] ?? '',
    ].join('|');
  }

  static void _pruneRecentSaves() {
    final now = DateTime.now();
    _recentSaves.removeWhere(
      (_, save) => now.difference(save.savedAt) > _duplicateWindow,
    );
  }

  static Future<void> _cleanupUploadedScanImage(
      String uid, String scanId) async {
    try {
      await _storage
          .ref()
          .child('users/$uid/scans/$scanId.jpg')
          .delete()
          .timeout(const Duration(seconds: 15));
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        debugPrint('PLANTIVA uploaded scan cleanup failed: $e');
      }
    } catch (e) {
      debugPrint('PLANTIVA uploaded scan cleanup failed: $e');
    }
  }

  static Future<void> _deleteStorageImageIfPresent(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) return;
    try {
      await _storage
          .refFromURL(imageUrl)
          .delete()
          .timeout(const Duration(seconds: 20));
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      debugPrint('PLANTIVA Firebase Storage delete failed: $e');
      throw ScanPersistenceException(
        'storage-delete-failed',
        'Scan image delete failed. Please check your connection and try again.',
        e,
      );
    } on ArgumentError catch (e) {
      debugPrint('PLANTIVA invalid scan imageUrl skipped during delete: $e');
    } on TimeoutException catch (e) {
      debugPrint('PLANTIVA Firebase Storage delete timed out: $e');
      throw ScanPersistenceException(
        'storage-delete-timeout',
        'Scan image delete timed out. Please try again.',
        e,
      );
    } catch (e) {
      debugPrint('PLANTIVA Firebase Storage delete failed: $e');
      throw ScanPersistenceException(
        'storage-delete-failed',
        'Scan image delete failed. Please check your connection and try again.',
        e,
      );
    }
  }

  static Future<void> _deleteLocalScanImageIfSafe(String? imagePath) async {
    if (imagePath == null || imagePath.trim().isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = p.normalize(p.join(dir.path, 'scans'));
      final target = p.normalize(imagePath);
      if (!p.isWithin(scansDir, target)) return;

      final file = File(target);
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('PLANTIVA local scan image cleanup skipped: $e');
    }
  }

  static Future<List<ScanRecord>> relatedScans(
    String category, {
    String? excludeId,
    int limit = 5,
  }) async {
    final all = await fetchScans(limit: 100);
    return all
        .where((s) => s.category == category && s.id != excludeId)
        .take(limit)
        .toList();
  }
}

class _RecentSave {
  const _RecentSave(this.scanId, this.savedAt);

  final String scanId;
  final DateTime savedAt;
}
