import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';
import 'package:intl/intl.dart';

class ScanTrendPoint {
  const ScanTrendPoint({
    required this.date,
    required this.label,
    required this.healthyCount,
    required this.nonHealthyCount,
  });

  final DateTime date;
  final String label;
  final int healthyCount;
  final int nonHealthyCount;
}

class ScanAnalyticsData {
  const ScanAnalyticsData({
    required this.scans,
    required this.period,
    required this.totalScans,
    required this.healthyCount,
    required this.diseasedCount,
    required this.distribution,
    required this.mostCommonDisease,
    required this.trend,
    required this.insights,
    required this.recommendations,
    required this.healthyRate,
    required this.diseaseDetectionRate,
    required this.monthlyHealthyDelta,
  });

  final List<ScanRecord> scans;
  final AnalyticsPeriod period;
  final int totalScans;
  final int healthyCount;
  final int diseasedCount;
  final Map<String, int> distribution;
  final String? mostCommonDisease;
  final List<ScanTrendPoint> trend;
  final List<String> insights;
  final List<({String title, String body, String iconKey})> recommendations;
  final double? healthyRate;
  final double? diseaseDetectionRate;
  final double? monthlyHealthyDelta;

  bool get hasData => totalScans > 0;
}

class ScanAnalyticsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<List<ScanRecord>> watchScans({int limit = 200}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);

    return _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(ScanRecord.fromDoc).toList());
  }

  Future<List<ScanRecord>> fetchScans({int? limit}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];

    final scans = _db.collection('users').doc(uid).collection('scans');
    final snap = limit == null
        ? await scans.get()
        : await scans.orderBy('createdAt', descending: true).limit(limit).get();
    final records = snap.docs.map(ScanRecord.fromDoc).toList()
      ..sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });
    return records;
  }

  ScanAnalyticsData buildAnalytics(
    List<ScanRecord> allScans,
    AnalyticsPeriod period,
  ) {
    return calculateScanAnalytics(allScans, period, now: DateTime.now());
  }
}

/// Calculates dashboard metrics from recognized, saved scan records only.
ScanAnalyticsData calculateScanAnalytics(
  List<ScanRecord> allScans,
  AnalyticsPeriod period, {
  required DateTime now,
}) {
  final eligible = allScans
      .where((scan) => DiseaseLabels.categories.contains(scan.category))
      .toList();
  final start = period.startFrom(now);
  final scans = eligible.where((scan) {
    if (period == AnalyticsPeriod.allTime) return true;
    final date = scan.createdAt;
    return date != null && !date.isBefore(start) && !date.isAfter(now);
  }).toList();

  final distribution = <String, int>{
    for (final category in DiseaseLabels.categories) category: 0,
  };
  for (final scan in scans) {
    distribution[scan.category] = (distribution[scan.category] ?? 0) + 1;
  }

  final total = scans.length;
  final healthy = distribution['Healthy Leaf'] ?? 0;
  final diseased = total - healthy;
  final healthyRate = total == 0 ? null : healthy / total * 100;
  final diseaseRate = total == 0 ? null : diseased / total * 100;
  final mostCommon = _mostCommonNonHealthy(distribution);
  final monthlyDelta = _monthlyHealthyDelta(eligible, now);

  return ScanAnalyticsData(
    scans: scans,
    period: period,
    totalScans: total,
    healthyCount: healthy,
    diseasedCount: diseased,
    distribution: distribution,
    mostCommonDisease: mostCommon,
    trend: _buildTrend(scans, period),
    insights: _buildInsights(
      total: total,
      healthy: healthy,
      diseased: diseased,
      healthyRate: healthyRate,
      mostCommon: mostCommon,
    ),
    recommendations: _buildRecommendations(mostCommon, diseased),
    healthyRate: healthyRate,
    diseaseDetectionRate: diseaseRate,
    monthlyHealthyDelta: monthlyDelta,
  );
}

String? _mostCommonNonHealthy(Map<String, int> distribution) {
  String? mostCommon;
  var highestCount = 0;
  for (final category in DiseaseLabels.categories) {
    if (category == 'Healthy Leaf') continue;
    final count = distribution[category] ?? 0;
    if (count > highestCount) {
      highestCount = count;
      mostCommon = category;
    }
  }
  return mostCommon;
}

List<ScanTrendPoint> _buildTrend(
  List<ScanRecord> scans,
  AnalyticsPeriod period,
) {
  final buckets = <DateTime, ({int healthy, int nonHealthy})>{};
  for (final scan in scans) {
    final date = scan.createdAt;
    if (date == null) continue;
    final bucket = period == AnalyticsPeriod.allTime
        ? DateTime(date.year, date.month)
        : DateTime(date.year, date.month, date.day);
    final current = buckets[bucket] ?? (healthy: 0, nonHealthy: 0);
    buckets[bucket] = scan.isHealthy
        ? (healthy: current.healthy + 1, nonHealthy: current.nonHealthy)
        : (healthy: current.healthy, nonHealthy: current.nonHealthy + 1);
  }

  final dates = buckets.keys.toList()..sort();
  final format = period == AnalyticsPeriod.allTime
      ? DateFormat('MMM yy')
      : DateFormat('MMM d');
  return dates.map((date) {
    final counts = buckets[date]!;
    return ScanTrendPoint(
      date: date,
      label: format.format(date),
      healthyCount: counts.healthy,
      nonHealthyCount: counts.nonHealthy,
    );
  }).toList();
}

double? _monthlyHealthyDelta(List<ScanRecord> all, DateTime now) {
  final thisMonth = DateTime(now.year, now.month, 1);
  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final lastMonth = DateTime(now.year, now.month - 1, 1);

  double? rate(DateTime from, DateTime to) {
    final scans = all.where((scan) {
      final date = scan.createdAt;
      return date != null && !date.isBefore(from) && date.isBefore(to);
    }).toList();
    if (scans.isEmpty) return null;
    return scans.where((scan) => scan.isHealthy).length / scans.length * 100;
  }

  final current = rate(thisMonth, nextMonth);
  final previous = rate(lastMonth, thisMonth);
  if (current == null || previous == null) return null;
  return current - previous;
}

List<String> _buildInsights({
  required int total,
  required int healthy,
  required int diseased,
  required double? healthyRate,
  required String? mostCommon,
}) {
  if (total == 0) {
    return const [
      'No scan data yet. Scan banana leaves to start seeing recorded-scan insights.',
    ];
  }

  final noun = total == 1 ? 'scan was' : 'scans were';
  final insights = <String>[
    '$healthy of $total recorded $noun classified as Healthy Leaf '
        '(${healthyRate!.round()}%).',
    '$diseased of $total recorded $noun classified as a non-healthy condition.',
  ];
  if (mostCommon != null) {
    insights.add(
      '${_displayCategory(mostCommon)} was the most frequently recorded '
      'non-healthy condition in this period.',
    );
  }
  if (total < 5) {
    insights.add(
      'This summary is based on a small number of recorded scans. More scans '
      'will provide a clearer monitoring history.',
    );
  }
  return insights;
}

List<({String title, String body, String iconKey})> _buildRecommendations(
  String? mostCommon,
  int diseasedCount,
) {
  final recommendations = <({String title, String body, String iconKey})>[
    (
      title: 'Continue routine scanning',
      body:
          'Record clear banana leaf scans regularly to build a useful comparison over time.',
      iconKey: 'scan',
    ),
    (
      title: 'Maintain field sanitation',
      body: 'Remove infected debris and disinfect tools between plants.',
      iconKey: 'clean',
    ),
  ];
  if (mostCommon != null && diseasedCount > 0) {
    recommendations.insert(
      0,
      (
        title: 'Review ${_displayCategory(mostCommon)} guidance',
        body:
            'Compare affected plants and consult a local agriculture technician when symptoms persist.',
        iconKey: 'warning',
      ),
    );
  }
  return recommendations;
}

String _displayCategory(String category) =>
    category == 'Insect Pest' ? 'Insect Pest Damage' : category;
