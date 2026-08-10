import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';
import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';

class ScanRecord {
  const ScanRecord({
    required this.id,
    required this.label,
    required this.category,
    required this.confidence,
    required this.createdAt,
    this.imagePath,
    this.imageUrl,
    this.imageBase64,
    this.rawLabel,
    this.severity,
    this.summary,
    this.recommendations,
    this.severityAction,
    this.insights,
  });

  final String id;
  final String label;
  final String category;
  final String confidence;
  final DateTime? createdAt;
  final String? imagePath;
  final String? imageUrl;
  final String? imageBase64;
  final String? rawLabel;
  final String? severity;
  final String? summary;
  final String? recommendations;
  final String? severityAction;
  final String? insights;

  bool get isHealthy => DiseaseLabels.isHealthy(label);

  double get confidenceValue => ScanDiagnosisHelper.parseConfidence(confidence);

  String get effectiveSeverity =>
      severity ?? ScanDiagnosisHelper.severity(label, confidence);

  String get effectiveSummary =>
      summary ?? ScanDiagnosisHelper.aboutCondition(label);

  String get effectiveRecommendations =>
      recommendations ?? ScanDiagnosisHelper.recommendations(label);

  Map<String, String> toResultMap() => {
        'label': label,
        'confidence': confidence,
        if (rawLabel != null) 'raw_label': rawLabel!,
        if (insights != null) 'insights': insights!,
        'severity': effectiveSeverity,
        'summary': effectiveSummary,
        'recommendations': effectiveRecommendations,
      };

  factory ScanRecord.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = m[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    DateTime? readDate(List<String> keys) {
      for (final key in keys) {
        final value = m[key];
        if (value is Timestamp) return value.toDate();
        if (value is DateTime) return value;
        if (value is String) return DateTime.tryParse(value);
      }
      return null;
    }

    final label = readString(['label', 'disease_name', 'diseaseName']) ?? '';
    final conf = readString(['confidence', 'confidenceScore']) ?? '';
    return ScanRecord(
      id: doc.id,
      label: label,
      category: DiseaseLabels.normalize(label),
      confidence: conf,
      createdAt: readDate(['createdAt', 'timestamp', 'scan_date']),
      imagePath: readString(['imagePath', 'image_path']),
      imageUrl: readString(['imageUrl', 'image_url']),
      imageBase64: readString(['imageBase64', 'image_base64']),
      rawLabel: readString(['rawLabel', 'raw_label']),
      severity: readString(['severity']),
      summary: readString(['summary']),
      recommendations: readString(['recommendations', 'recommendation']),
      severityAction: readString(['severityAction', 'severity_action']),
      insights: readString(['insights']),
    );
  }
}

enum AnalyticsPeriod { week, month, threeMonths, year }

extension AnalyticsPeriodX on AnalyticsPeriod {
  String get label {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.threeMonths:
        return 'Last 3 Months';
      case AnalyticsPeriod.year:
        return 'This Year';
    }
  }

  DateTime startFrom(DateTime now) {
    switch (this) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month, 1);
      case AnalyticsPeriod.threeMonths:
        return DateTime(now.year, now.month - 2, 1);
      case AnalyticsPeriod.year:
        return DateTime(now.year, 1, 1);
    }
  }
}

String relativeScanTime(DateTime? date) {
  if (date == null) return 'Recently';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  String two(int n) => n.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${two(date.hour)}:${two(date.minute)}';
}
