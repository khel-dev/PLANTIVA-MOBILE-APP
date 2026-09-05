import 'package:flutter_plantiva/services/image_quality_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';

class ScanInputPipelineResult {
  const ScanInputPipelineResult({
    required this.passedInputGates,
    required this.result,
  });

  final bool passedInputGates;
  final Map<String, String> result;
}

class ScanInputPipeline {
  static Future<ScanInputPipelineResult> run({
    required Future<ImageQualityResult> Function() qualityCheck,
    required Future<InputValidatorResult> Function() semanticCheck,
    required Future<Map<String, String>> Function() diseaseClassification,
  }) async {
    final quality = await qualityCheck();
    if (!quality.isUsable) {
      return ScanInputPipelineResult(
        passedInputGates: false,
        result: {
          'label': 'Unclear Image',
          'confidence': '0%',
          'raw_label': quality.userMessage,
          'validation_status': 'imageQualityRejected',
          'validation_message': quality.userMessage,
          'quality_code': quality.wireCode,
        },
      );
    }

    final semantic = await semanticCheck();
    if (!semantic.isBananaAccepted) {
      return const ScanInputPipelineResult(
        passedInputGates: false,
        result: {
          'label': 'Not a Banana Leaf',
          'confidence': '0%',
          'raw_label': 'Please scan a clear banana leaf.',
          'validation_status': 'unrelatedOrUnreliable',
          'validation_message': 'Please scan a clear banana leaf.',
        },
      );
    }

    return ScanInputPipelineResult(
      passedInputGates: true,
      result: await diseaseClassification(),
    );
  }
}
