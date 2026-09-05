import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/services/scan_analytics_service.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 5, 12);

  ScanRecord scan(
    String id,
    String label, {
    String confidence = '90%',
    DateTime? createdAt,
  }) {
    return ScanRecord(
      id: id,
      label: label,
      category: DiseaseLabels.normalize(label),
      confidence: confidence,
      createdAt: createdAt ?? now,
    );
  }

  group('scan analytics calculations', () {
    test('7 healthy scans out of 10 produces a 70 percent healthy rate', () {
      final scans = [
        for (var i = 0; i < 7; i++) scan('healthy-$i', 'Healthy Leaf'),
        scan('moko-1', 'Moko Disease'),
        scan('moko-2', 'Moko Disease'),
        scan('panama-1', 'Panama Disease'),
      ];

      final data = calculateScanAnalytics(
        scans,
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.totalScans, 10);
      expect(data.healthyCount, 7);
      expect(data.healthyRate, 70);
    });

    test('3 non-healthy scans out of 10 produces a 30 percent disease rate',
        () {
      final scans = [
        for (var i = 0; i < 7; i++) scan('healthy-$i', 'Healthy Leaf'),
        for (var i = 0; i < 3; i++) scan('moko-$i', 'Moko Disease'),
      ];

      final data = calculateScanAnalytics(
        scans,
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.diseasedCount, 3);
      expect(data.diseaseDetectionRate, 30);
    });

    test('no scans produces no percentage instead of a fake zero percent', () {
      final data = calculateScanAnalytics(
        const [],
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.totalScans, 0);
      expect(data.healthyRate, isNull);
      expect(data.diseaseDetectionRate, isNull);
      expect(data.mostCommonDisease, isNull);
    });

    test('most detected condition ignores Healthy Leaf', () {
      final data = calculateScanAnalytics(
        [
          for (var i = 0; i < 5; i++) scan('healthy-$i', 'Healthy Leaf'),
          for (var i = 0; i < 3; i++) scan('moko-$i', 'Moko Disease'),
          scan('panama-1', 'Panama Disease'),
        ],
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.mostCommonDisease, 'Moko Disease');
    });

    test('classification confidence does not affect wellness rates', () {
      final lowHealthyConfidence = calculateScanAnalytics(
        [
          scan('healthy', 'Healthy Leaf', confidence: '51%'),
          scan('disease', 'Moko Disease', confidence: '99%'),
        ],
        AnalyticsPeriod.allTime,
        now: now,
      );
      final highHealthyConfidence = calculateScanAnalytics(
        [
          scan('healthy', 'Healthy Leaf', confidence: '99%'),
          scan('disease', 'Moko Disease', confidence: '51%'),
        ],
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(lowHealthyConfidence.healthyRate, 50);
      expect(highHealthyConfidence.healthyRate, 50);
      expect(lowHealthyConfidence.diseaseDetectionRate, 50);
      expect(highHealthyConfidence.diseaseDetectionRate, 50);
    });

    test('Bunchy Top Disease is counted in the official distribution', () {
      final data = calculateScanAnalytics(
        [
          scan('bbtd-1', 'BBTD'),
          scan('bbtd-2', 'Banana Bunchy Top Disease'),
        ],
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.totalScans, 2);
      expect(data.distribution['Bunchy Top Disease'], 2);
      expect(data.mostCommonDisease, 'Bunchy Top Disease');
    });

    test('unrecognized legacy records do not enter valid-scan metrics', () {
      final data = calculateScanAnalytics(
        [
          scan('valid', 'Healthy Leaf'),
          scan('invalid', 'Unable to Identify Disease'),
        ],
        AnalyticsPeriod.allTime,
        now: now,
      );

      expect(data.totalScans, 1);
      expect(data.healthyCount, 1);
      expect(data.healthyRate, 100);
    });

    test('trend uses only dates that contain actual scans', () {
      final data = calculateScanAnalytics(
        [
          scan(
            'healthy-1',
            'Healthy Leaf',
            createdAt: DateTime(2026, 9, 1, 8),
          ),
          scan(
            'disease-1',
            'Moko Disease',
            createdAt: DateTime(2026, 9, 1, 9),
          ),
          scan(
            'healthy-2',
            'Healthy Leaf',
            createdAt: DateTime(2026, 9, 3, 8),
          ),
        ],
        AnalyticsPeriod.week,
        now: now,
      );

      expect(data.trend, hasLength(2));
      expect(data.trend.first.label, 'Sep 1');
      expect(data.trend.first.healthyCount, 1);
      expect(data.trend.first.nonHealthyCount, 1);
      expect(data.trend.last.label, 'Sep 3');
      expect(data.trend.last.healthyCount, 1);
      expect(data.trend.last.nonHealthyCount, 0);
    });
  });
}
