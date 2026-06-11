import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ScanHistoryService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _storage = FirebaseStorage.instance;

  static bool _shouldPersist(String label) {
    final l = label.toLowerCase().trim();
    if (l.isEmpty) return false;
    if (l.contains('model not ready')) return false;
    if (l == 'error') return false;
    if (l.contains('cannot connect')) return false;
    return true;
  }

  static String? _uid() => _auth.currentUser?.uid;

  /// Copies scan image to app documents for persistent local access.
  static Future<String?> _persistLocalImage(String sourcePath) async {
    try {
      final src = File(sourcePath);
      if (!await src.exists()) return null;
      final dir = await getApplicationDocumentsDirectory();
      final scansDir = Directory(p.join(dir.path, 'scans'));
      if (!await scansDir.exists()) await scansDir.create(recursive: true);
      final name = 'scan_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}';
      final dest = File(p.join(scansDir.path, name));
      await src.copy(dest.path);
      return dest.path;
    } catch (_) {
      return sourcePath;
    }
  }

  static Future<String?> _uploadImage(String uid, String scanId, String localPath) async {
    try {
      final ref = _storage.ref().child('users/$uid/scans/$scanId.jpg');
      await ref.putFile(File(localPath));
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> recordScan(
    Map<String, String> result, {
    required String imagePath,
  }) async {
    final label = result['label'] ?? '';
    if (!_shouldPersist(label)) return null;

    final uid = _uid();
    if (uid == null) return null;

    final enriched = ScanDiagnosisHelper.enrichResult(result);
    final userRef = _db.collection('users').doc(uid);
    final scanRef = userRef.collection('scans').doc();
    final scanId = scanRef.id;

    final localPath = await _persistLocalImage(imagePath);
    final imageUrl = localPath != null
        ? await _uploadImage(uid, scanId, localPath)
        : null;

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
      if (localPath != null) 'imagePath': localPath,
      if (imageUrl != null) 'imageUrl': imageUrl,
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
    await batch.commit();
    return scanId;
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

  static Future<void> deleteScan(String scanId, {String? imageUrl}) async {
    final uid = _uid();
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .doc(scanId)
        .delete();

    await _db.collection('users').doc(uid).set(
      {'totalScans': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (_) {}
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
