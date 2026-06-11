import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';

class ScanAnalyticsData {
  const ScanAnalyticsData({
    required this.scans,
    required this.period,
    required this.totalScans,
    required this.healthyCount,
    required this.diseasedCount,
    required this.distribution,
    required this.mostCommonDisease,
    required this.avgConfidence,
    required this.cropHealthScore,
    required this.weeklyTrend,
    required this.insights,
    required this.recommendations,
    required this.healthyRate,
    required this.monthlyHealthyDelta,
  });

  final List<ScanRecord> scans;
  final AnalyticsPeriod period;
  final int totalScans;
  final int healthyCount;
  final int diseasedCount;
  final Map<String, int> distribution;
  final String mostCommonDisease;
  final double avgConfidence;
  final int cropHealthScore;
  final List<Map<String, dynamic>> weeklyTrend;
  final List<String> insights;
  final List<({String title, String body, String iconKey})> recommendations;
  final double healthyRate;
  final double monthlyHealthyDelta;
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

  Future<List<ScanRecord>> fetchScans({int limit = 200}) async {
    final uid = _auth.currentUser?.uid;
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

  ScanAnalyticsData buildAnalytics(
    List<ScanRecord> allScans,
    AnalyticsPeriod period,
  ) {
    final now = DateTime.now();
    final start = period.startFrom(now);
    final scans = allScans.where((s) {
      final d = s.createdAt;
      return d != null && !d.isBefore(start);
    }).toList();

    final total = scans.length;
    final healthy = scans.where((s) => s.isHealthy).length;
    final diseased = total - healthy;

    final distribution = <String, int>{};
    for (final cat in DiseaseLabels.categories) {
      distribution[cat] = 0;
    }
    for (final s in scans) {
      if (distribution.containsKey(s.category)) {
        distribution[s.category] = distribution[s.category]! + 1;
      }
    }

    final diseasedDist = Map<String, int>.from(distribution)
      ..remove('Healthy Leaf');
    String mostCommon = 'None';
    var maxCount = 0;
    diseasedDist.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        mostCommon = k;
      }
    });

    final confValues = scans.map((s) => s.confidenceValue).where((c) => c > 0);
    final avgConf = confValues.isEmpty
        ? 0.0
        : confValues.reduce((a, b) => a + b) / confValues.length;

    final healthScore = total == 0
        ? 0
        : ((healthy / total) * 70 + (avgConf / 100) * 30).round().clamp(0, 100);

    final weeklyTrend = _buildWeeklyTrend(scans, start, now);
    final healthyRate = total == 0 ? 0.0 : (healthy / total) * 100;
    final monthlyDelta = _monthlyHealthyDelta(allScans);

    return ScanAnalyticsData(
      scans: scans,
      period: period,
      totalScans: total,
      healthyCount: healthy,
      diseasedCount: diseased,
      distribution: distribution,
      mostCommonDisease: mostCommon,
      avgConfidence: avgConf,
      cropHealthScore: healthScore,
      weeklyTrend: weeklyTrend,
      insights: _buildInsights(
        scans: scans,
        distribution: distribution,
        mostCommon: mostCommon,
        healthyRate: healthyRate,
        monthlyDelta: monthlyDelta,
      ),
      recommendations: _buildRecommendations(mostCommon, diseased),
      healthyRate: healthyRate,
      monthlyHealthyDelta: monthlyDelta,
    );
  }

  List<Map<String, dynamic>> _buildWeeklyTrend(
    List<ScanRecord> scans,
    DateTime start,
    DateTime end,
  ) {
    final buckets = <String, Map<String, int>>{};
    for (final s in scans) {
      final d = s.createdAt;
      if (d == null) continue;
      final key = 'W${_weekOfYear(d)}';
      buckets.putIfAbsent(key, () => {});
      final cat = s.isHealthy ? 'Healthy' : s.category;
      buckets[key]![cat] = (buckets[key]![cat] ?? 0) + 1;
    }
    return buckets.entries
        .map((e) => {'label': e.key, 'counts': e.value})
        .toList();
  }

  int _weekOfYear(DateTime d) =>
      ((d.difference(DateTime(d.year, 1, 1)).inDays) / 7).floor() + 1;

  double _monthlyHealthyDelta(List<ScanRecord> all) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    int healthyInRange(List<ScanRecord> list, DateTime from, DateTime to) {
      final filtered = list.where((s) {
        final d = s.createdAt;
        return d != null && !d.isBefore(from) && d.isBefore(to);
      }).toList();
      if (filtered.isEmpty) return 0;
      return filtered.where((s) => s.isHealthy).length;
    }

    final thisTotal = all.where((s) {
      final d = s.createdAt;
      return d != null && !d.isBefore(thisMonth);
    }).length;
    final lastTotal = all.where((s) {
      final d = s.createdAt;
      return d != null && !d.isBefore(lastMonth) && d.isBefore(thisMonth);
    }).length;

    if (thisTotal == 0 || lastTotal == 0) return 0;
    final thisRate = healthyInRange(all, thisMonth, now.add(const Duration(days: 1))) / thisTotal;
    final lastRate = healthyInRange(all, lastMonth, thisMonth) / lastTotal;
    return ((thisRate - lastRate) * 100).roundToDouble();
  }

  List<String> _buildInsights({
    required List<ScanRecord> scans,
    required Map<String, int> distribution,
    required String mostCommon,
    required double healthyRate,
    required double monthlyDelta,
  }) {
    if (scans.isEmpty) {
      return const [
        'No scan data yet for this period. Start scanning banana leaves to unlock AI insights.',
      ];
    }

    final insights = <String>[];
    final total = scans.length;
    final topCount = distribution[mostCommon] ?? 0;
    final topPct = total == 0 ? 0 : ((topCount / total) * 100).round();

    if (mostCommon != 'None' && topCount > 0) {
      insights.add(
        '$mostCommon was the most frequently detected issue this period, accounting for $topPct% of all recorded cases.',
      );
    }

    if (monthlyDelta > 0) {
      insights.add(
        'Healthy scans increased by ${monthlyDelta.abs().round()}% compared to last month.',
      );
    } else if (monthlyDelta < 0) {
      insights.add(
        'Healthy detections decreased by ${monthlyDelta.abs().round()}% — consider increasing field inspections.',
      );
    } else {
      insights.add('Healthy detection rate remained stable compared to last month.');
    }

    insights.add(
      'Your crops show a ${healthyRate.round()}% healthy detection rate across ${scans.length} scans in this period.',
    );

    if (topPct > 25) {
      insights.add(
        'Early intervention is recommended to prevent further spread of $mostCommon in your fields.',
      );
    }

    return insights;
  }

  List<({String title, String body, String iconKey})> _buildRecommendations(
    String mostCommon,
    int diseasedCount,
  ) {
    final recs = <({String title, String body, String iconKey})>[
      (
        title: 'Routine field scanning',
        body: 'Scan banana leaves weekly to catch diseases before they spread across mats.',
        iconKey: 'scan',
      ),
      (
        title: 'Maintain field sanitation',
        body: 'Remove infected debris and disinfect tools between plants.',
        iconKey: 'clean',
      ),
      (
        title: 'Monitor humidity periods',
        body: 'Increase inspection frequency during rainy seasons when fungal diseases thrive.',
        iconKey: 'water',
      ),
    ];

    if (mostCommon != 'None' && diseasedCount > 0) {
      recs.insert(
        0,
        (
          title: 'Address $mostCommon',
          body: 'Monitor farms showing recurring $mostCommon symptoms and apply targeted treatment.',
          iconKey: 'warning',
        ),
      );
    }

    return recs;
  }
}
