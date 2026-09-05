import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/services/image_quality_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';
import 'package:flutter_plantiva/services/scan_input_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Input validator mapping and threshold', () {
    test('uses the approved class order', () {
      expect(
        InputValidatorResult.classOrder,
        const ['banana_leaf', 'other_plant_leaf', 'non_plant'],
      );
    });

    test('accepts banana at 0.95', () {
      final result = InputValidatorResult.fromProbabilities([0.95, 0.03, 0.02]);
      expect(result.predictedClass, 'banana_leaf');
      expect(result.isBananaAccepted, isTrue);
    });

    test('rejects banana below the 0.60 threshold', () {
      final result = InputValidatorResult.fromProbabilities([0.59, 0.30, 0.11]);
      expect(result.predictedClass, 'banana_leaf');
      expect(result.isBananaAccepted, isFalse);
    });

    test('rejects high-confidence other plant and non-plant classes', () {
      final otherPlant =
          InputValidatorResult.fromProbabilities([0.005, 0.99, 0.005]);
      final nonPlant =
          InputValidatorResult.fromProbabilities([0.005, 0.005, 0.99]);

      expect(otherPlant.predictedClass, 'other_plant_leaf');
      expect(otherPlant.isBananaAccepted, isFalse);
      expect(nonPlant.predictedClass, 'non_plant');
      expect(nonPlant.isBananaAccepted, isFalse);
    });
  });

  group('Image quality threshold boundaries', () {
    test('uses the approved darkness boundaries', () {
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(mean: 19.999),
        ).code,
        ImageQualityCode.tooDark,
      );
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(lowRatio: 0.95),
        ).code,
        ImageQualityCode.tooDark,
      );
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(mean: 20, lowRatio: 0.949),
        ).code,
        ImageQualityCode.ok,
      );
    });

    test('requires all approved overexposure conditions', () {
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(mean: 225, nearWhiteRatio: 0.10, dynamicRange: 80),
        ).code,
        ImageQualityCode.tooBright,
      );
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(mean: 225, nearWhiteRatio: 0.099, dynamicRange: 80),
        ).code,
        ImageQualityCode.ok,
      );
    });

    test('uses strict blur and low-information boundaries', () {
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(laplacianVariance: 19.999),
        ).code,
        ImageQualityCode.tooBlurry,
      );
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(standardDeviation: 4.999),
        ).code,
        ImageQualityCode.lowVisualInformation,
      );
      expect(
        ImageQualityService.evaluateMetrics(
          _metrics(dynamicRange: 14.999),
        ).code,
        ImageQualityCode.lowVisualInformation,
      );
    });
  });

  group('Pipeline routing', () {
    test('quality rejection skips semantic and disease callbacks', () async {
      var semanticCalls = 0;
      var diseaseCalls = 0;

      final result = await ScanInputPipeline.run(
        qualityCheck: () async => ImageQualityService.evaluateMetrics(
          _metrics(mean: 10),
        ),
        semanticCheck: () async {
          semanticCalls++;
          return _acceptedBanana;
        },
        diseaseClassification: () async {
          diseaseCalls++;
          return _validDiagnosis;
        },
      );

      expect(result.passedInputGates, isFalse);
      expect(result.result['validation_status'], 'imageQualityRejected');
      expect(semanticCalls, 0);
      expect(diseaseCalls, 0);
    });

    test('semantic rejection skips disease callback', () async {
      var diseaseCalls = 0;

      final result = await ScanInputPipeline.run(
        qualityCheck: () async =>
            ImageQualityService.evaluateMetrics(_metrics()),
        semanticCheck: () async => InputValidatorResult.fromProbabilities(
          [0.05, 0.90, 0.05],
        ),
        diseaseClassification: () async {
          diseaseCalls++;
          return _validDiagnosis;
        },
      );

      expect(result.passedInputGates, isFalse);
      expect(result.result['validation_status'], 'unrelatedOrUnreliable');
      expect(diseaseCalls, 0);
    });

    test('accepted banana invokes disease classifier exactly once', () async {
      var diseaseCalls = 0;

      final result = await ScanInputPipeline.run(
        qualityCheck: () async =>
            ImageQualityService.evaluateMetrics(_metrics()),
        semanticCheck: () async => _acceptedBanana,
        diseaseClassification: () async {
          diseaseCalls++;
          return _validDiagnosis;
        },
      );

      expect(result.passedInputGates, isTrue);
      expect(result.result, _validDiagnosis);
      expect(diseaseCalls, 1);
    });
  });

  group('Phase 1G challenge parity', () {
    final challengeRoot = Directory(
      '../PLANTIVA_CV/validator/data/challenge/quality_failures',
    );
    final expected = <String, ImageQualityCode>{
      'extreme_darkness': ImageQualityCode.tooDark,
      'extreme_overexposure': ImageQualityCode.tooBright,
      'random_noise': ImageQualityCode.ok,
      'severe_blur': ImageQualityCode.tooBlurry,
      'solid_black': ImageQualityCode.tooDark,
      'solid_white': ImageQualityCode.tooBright,
    };

    for (final entry in expected.entries) {
      test(
        '${entry.key} matches the Python quality decision',
        () {
          final file = File(
            '${challengeRoot.path}/${entry.key}/challenge_${entry.key}.png',
          );
          final result = ImageQualityService().analyzeBytes(
            file.readAsBytesSync(),
          );
          expect(result.code, entry.value);
        },
        skip: !challengeRoot.existsSync(),
      );
    }
  });

  test('Flutter TFLite validator asset loads and returns finite outputs',
      () async {
    final challenge = File(
      '../PLANTIVA_CV/validator/data/challenge/quality_failures/'
      'random_noise/challenge_random_noise.png',
    );
    if (!challenge.existsSync()) return;

    final service = InputValidatorService();
    addTearDown(service.close);
    await service.loadModel();

    expect(service.isReady, isTrue, reason: service.loadError);
    final result = await service.validate(challenge);
    final probabilities = [
      result.bananaProbability,
      result.otherPlantProbability,
      result.nonPlantProbability,
    ];
    expect(probabilities, hasLength(3));
    expect(probabilities.every((value) => value.isFinite), isTrue);
    expect(result.predictedClass,
        InputValidatorResult.classOrder[result.predictedIndex]);
    expect(result.bananaProbability, closeTo(0.4597475, 0.02));
    expect(result.isBananaAccepted, isFalse);
  },
      skip: Platform.isWindows
          ? 'tflite_flutter has no Windows native library in this setup; '
              'Android is verified by the debug build.'
          : false);
}

const _acceptedBanana = InputValidatorResult(
  predictedIndex: 0,
  predictedClass: 'banana_leaf',
  bananaProbability: 0.95,
  otherPlantProbability: 0.03,
  nonPlantProbability: 0.02,
  isBananaAccepted: true,
);

const _validDiagnosis = <String, String>{
  'label': 'Banana Healthy Leaf',
  'confidence': '95%',
  'validation_status': 'validDiagnosis',
};

ImageQualityMetrics _metrics({
  double mean = 100,
  double median = 100,
  double lowRatio = 0,
  double nearWhiteRatio = 0,
  double dynamicRange = 100,
  double standardDeviation = 30,
  double laplacianVariance = 100,
}) {
  return ImageQualityMetrics(
    meanLuminance: mean,
    medianLuminance: median,
    lowPixelRatio: lowRatio,
    nearWhitePixelRatio: nearWhiteRatio,
    dynamicRange: dynamicRange,
    luminanceStandardDeviation: standardDeviation,
    laplacianVariance: laplacianVariance,
  );
}
