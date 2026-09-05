import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class InputValidatorResult {
  const InputValidatorResult({
    required this.predictedIndex,
    required this.predictedClass,
    required this.bananaProbability,
    required this.otherPlantProbability,
    required this.nonPlantProbability,
    required this.isBananaAccepted,
  });

  static const classOrder = <String>[
    'banana_leaf',
    'other_plant_leaf',
    'non_plant',
  ];
  static const bananaClassIndex = 0;
  static const bananaThreshold = 0.60;

  final int predictedIndex;
  final String predictedClass;
  final double bananaProbability;
  final double otherPlantProbability;
  final double nonPlantProbability;
  final bool isBananaAccepted;

  static InputValidatorResult fromProbabilities(List<double> probabilities) {
    if (probabilities.length != classOrder.length ||
        probabilities.any((value) => !value.isFinite)) {
      throw ArgumentError.value(
        probabilities,
        'probabilities',
        'Expected three finite validator probabilities.',
      );
    }

    var predictedIndex = 0;
    for (var index = 1; index < probabilities.length; index++) {
      if (probabilities[index] > probabilities[predictedIndex]) {
        predictedIndex = index;
      }
    }

    return InputValidatorResult(
      predictedIndex: predictedIndex,
      predictedClass: classOrder[predictedIndex],
      bananaProbability: probabilities[0],
      otherPlantProbability: probabilities[1],
      nonPlantProbability: probabilities[2],
      isBananaAccepted: predictedIndex == bananaClassIndex &&
          probabilities[bananaClassIndex] >= bananaThreshold,
    );
  }
}

class InputValidatorService {
  static const modelAsset = 'assets/models/plantiva_input_validator.tflite';

  Interpreter? _interpreter;
  String? _loadError;

  bool get isReady => _interpreter != null;
  String? get loadError => _loadError;

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    _loadError = null;

    try {
      final modelData = await rootBundle.load(modelAsset);
      if (modelData.lengthInBytes == 0) {
        throw StateError('Input validator model asset is empty.');
      }

      final interpreter =
          Interpreter.fromBuffer(modelData.buffer.asUint8List());
      final input = interpreter.getInputTensor(0);
      final output = interpreter.getOutputTensor(0);
      if (!listEquals(input.shape, const [1, 224, 224, 3]) ||
          input.type != TensorType.float32 ||
          !listEquals(output.shape, const [1, 3]) ||
          output.type != TensorType.float32) {
        interpreter.close();
        throw StateError(
          'Unexpected input validator tensors: '
          '${input.shape}/${input.type} -> ${output.shape}/${output.type}',
        );
      }
      _interpreter = interpreter;
    } catch (error) {
      _loadError = error.toString();
      _interpreter?.close();
      _interpreter = null;
      debugPrint('PLANTIVA input validator load failed: $error');
    }
  }

  Future<InputValidatorResult> validate(File imageFile) async {
    return validateBytes(await imageFile.readAsBytes());
  }

  InputValidatorResult validateBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The selected file could not be decoded.');
    }
    return validateImage(decoded);
  }

  InputValidatorResult validateImage(img.Image decoded) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError(_loadError ?? 'Input validator is not loaded.');
    }

    final rgb =
        decoded.numChannels == 3 ? decoded : decoded.convert(numChannels: 3);
    final resized = img.copyResize(
      rgb,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.nearest,
    );
    final input = [
      List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resized.getPixel(x, y);
          // The model contains its own MobileNetV3 rescaling. Keep 0-255 values.
          return <double>[
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        }),
      ),
    ];
    final output = [List<double>.filled(3, 0)];
    interpreter.run(input, output);
    return InputValidatorResult.fromProbabilities(output[0]);
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
