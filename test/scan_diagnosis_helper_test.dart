import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScanDiagnosisHelper safety', () {
    test('does not derive severity or urgency from model confidence', () {
      final result = ScanDiagnosisHelper.enrichResult({
        'label': 'Black Sigatoka Disease',
        'confidence': '99.9%',
        'validation_status': 'validDiagnosis',
      });

      expect(result.containsKey('severity'), isFalse);
      expect(result.containsKey('severityAction'), isFalse);
    });

    test('healthy guidance does not recommend preventive fungicide', () {
      final guidance = ScanDiagnosisHelper.recommendations('Healthy Leaf');

      expect(guidance.toLowerCase(), isNot(contains('fungicide')));
    });

    test('insect category does not claim a specific pest identification', () {
      final summary = ScanDiagnosisHelper.aboutCondition('Insect Pest Disease');

      expect(summary, contains('exact insect cannot be identified'));
      expect(summary.toLowerCase(), isNot(contains('aphid')));
      expect(summary.toLowerCase(), isNot(contains('thrips')));
      expect(summary.toLowerCase(), isNot(contains('weevil')));
    });
  });
}
