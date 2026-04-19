import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Persists scan metadata to Firestore (`users/{uid}/scans`) for the home feed.
/// Images stay on-device; only labels and scores are stored.
class ScanHistoryService {
  static bool _shouldPersist(String label) {
    final l = label.toLowerCase().trim();
    if (l.isEmpty) return false;
    if (l.contains('model not ready')) return false;
    if (l == 'error') return false;
    if (l.contains('cannot connect')) return false;
    return true;
  }

  static Future<void> recordScan(Map<String, String> result) async {
    final label = result['label'] ?? '';
    if (!_shouldPersist(label)) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;
    final userRef = db.collection('users').doc(user.uid);
    final scanRef = userRef.collection('scans').doc();

    final batch = db.batch();
    batch.set(scanRef, {
      'label': label,
      'confidence': result['confidence'] ?? '',
      'rawLabel': result['raw_label'] ?? '',
      if ((result['insights'] ?? '').trim().isNotEmpty)
        'insights': result['insights'],
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
  }
}
