import 'package:flutter_plantiva/data/treatment_guidance_data.dart';

/// Shared educational copy for scan results and saved scan details.
class ScanDiagnosisHelper {
  static String aboutCondition(String label) =>
      TreatmentGuidanceData.resolve(label).summary;

  static String recommendations(String label) =>
      TreatmentGuidanceData.resolve(label).plainText;

  static double parseConfidence(String confidence) {
    return double.tryParse(confidence.replaceAll('%', '')) ?? 0;
  }

  static Map<String, String> enrichResult(Map<String, String> result) {
    final label = result['label'] ?? 'Unknown';
    return {
      ...result,
      'summary': aboutCondition(label),
      'recommendations': recommendations(label),
    };
  }
}
