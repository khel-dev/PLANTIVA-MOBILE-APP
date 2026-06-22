import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Offline TFLite classifier using the same preprocessing as PLANTIVA_CV/app.py.
class ClassifierService {
  static const String _modelAsset =
      'assets/models/plantiva_banana_model.tflite';
  static const String _labelsAsset = 'assets/models/labels.json';
  static const double _minConfidencePct = 65.0;
  static const double _maxEntropy = 1.6;
  static const double _minTopTwoMarginPct = 15.0;

  Interpreter? _interpreter;
  Map<int, String> _labels = {};
  String? _loadError;

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  int get classCount => _labels.length;

  String? get loadError => _loadError;

  double _entropy(List<double> probs) {
    double h = 0.0;
    for (final p in probs) {
      if (p > 1e-9) h -= p * math.log(p);
    }
    return h;
  }

  String _formatTopInsights(List<double> scores) {
    final probs = scores.map((e) => e.toDouble()).toList();
    final order = List<int>.generate(scores.length, (i) => i);
    order.sort((a, b) => probs[b].compareTo(probs[a]));
    final top = order.take(3).toList();
    final lines = <String>[];
    for (var r = 0; r < top.length; r++) {
      final i = top[r];
      final name = _cleanLabel(_labels[i] ?? '?');
      final pct = (probs[i] * 100).clamp(0.0, 100.0);
      lines.add('${r + 1}. $name - ${pct.toStringAsFixed(1)}%');
    }
    return lines.join('\n');
  }

  String _cleanLabel(String raw) {
    return raw
        .replaceAll('Augmented Banana ', '')
        .replaceAll('Augmented ', '')
        .trim();
  }

  Future<void> loadModel() async {
    _loadError = null;
    _interpreter?.close();
    _interpreter = null;
    _labels = {};

    try {
      final modelData = await rootBundle.load(_modelAsset);
      if (modelData.lengthInBytes == 0) {
        _loadError =
            'Model file is empty. Copy plantiva_banana_model.tflite from PLANTIVA_CV/models into flutter_plantiva/assets/models/.';
        return;
      }

      _interpreter = Interpreter.fromBuffer(modelData.buffer.asUint8List());

      final labelsRaw = await rootBundle.loadString(_labelsAsset);
      if (labelsRaw.trim().isEmpty) {
        _loadError = 'labels.json is empty.';
        _interpreter?.close();
        _interpreter = null;
        return;
      }

      final decoded = jsonDecode(labelsRaw);
      if (decoded is Map) {
        _labels = decoded.map(
          (k, v) => MapEntry(int.parse(k.toString()), v.toString()),
        );
      } else {
        _loadError = 'labels.json must be an object like {"0":"Class A",...}.';
        _interpreter?.close();
        _interpreter = null;
        return;
      }
    } catch (e) {
      _loadError = e.toString();
      _interpreter?.close();
      _interpreter = null;
      _labels = {};
    }
  }

  List<List<List<List<double>>>> _imageToInputNHWC(img.Image resized) {
    return [
      List.generate(224, (y) {
        return List.generate(224, (x) {
          final px = resized.getPixel(x, y);
          return [px.r / 255.0, px.g / 255.0, px.b / 255.0];
        });
      }),
    ];
  }

  Future<Map<String, String>> classify(File imageFile) async {
    if (_interpreter == null || _labels.isEmpty) {
      return {
        'label': 'Model not ready',
        'confidence': '0%',
        'raw_label': _loadError ?? 'Call loadModel() after app start.',
        'validation_status': 'modelError',
        'validation_message':
            'The AI model is not ready. Please reopen the scanner and try again.',
      };
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        debugPrint(
          'PLANTIVA classifier: invalid image decode for ${imageFile.path}',
        );
        return {
          'label': 'Invalid Image',
          'confidence': '0%',
          'raw_label': 'Could not decode image.',
          'validation_status': 'imageDecodeError',
          'validation_message':
              'The selected file could not be read as an image.',
        };
      }

      final rgb =
          decoded.numChannels == 3 ? decoded : decoded.convert(numChannels: 3);
      final resized = img.copyResize(rgb, width: 224, height: 224);

      final input = _imageToInputNHWC(resized);
      final outShape = _interpreter!.getOutputTensor(0).shape;
      final classCount = outShape.length >= 2 ? outShape[1] : outShape.last;

      final output = [
        List<double>.filled(classCount, 0),
      ];

      _interpreter!.run(input, output);

      final scores = output[0];
      final order = List<int>.generate(scores.length, (i) => i);
      order.sort((a, b) => scores[b].compareTo(scores[a]));
      final maxIndex = order.first;
      final maxScore = scores[maxIndex];
      final secondScore = order.length > 1 ? scores[order[1]] : 0.0;

      final probs = scores.map((e) => e.toDouble()).toList();
      final entropyVal = _entropy(probs);
      final confidencePct = (maxScore * 100).clamp(0.0, 100.0);
      final secondConfidencePct = (secondScore * 100).clamp(0.0, 100.0);
      final marginPct = (confidencePct - secondConfidencePct).clamp(0.0, 100.0);
      final insights = scores.length >= 2 ? _formatTopInsights(scores) : '';

      if (entropyVal > _maxEntropy) {
        return {
          'label': 'Not a Banana Leaf',
          'confidence': '0%',
          'raw_label':
              'The image does not appear to be a banana leaf. Please capture a clear photo of a banana leaf.',
          'validation_status': 'unrelatedOrUnreliable',
          'validation_message':
              'The AI could not confirm that this is a clear banana leaf image.',
          'entropy': entropyVal.toStringAsFixed(3),
          'top2_margin': '${marginPct.toStringAsFixed(1)}%',
          if (insights.isNotEmpty) 'insights': insights,
        };
      }

      final rawLabel = _labels[maxIndex] ?? 'Unknown';
      final clean = _cleanLabel(rawLabel);

      if (confidencePct < _minConfidencePct) {
        return {
          'label': 'Low Confidence',
          'confidence': '${confidencePct.toStringAsFixed(1)}%',
          'raw_label':
              'Low confidence - please retake photo with better lighting and focus on one clear leaf.',
          'validation_status': 'lowConfidence',
          'validation_message':
              'The image does not provide enough confidence for a reliable diagnosis.',
          'entropy': entropyVal.toStringAsFixed(3),
          'top2_margin': '${marginPct.toStringAsFixed(1)}%',
          if (insights.isNotEmpty) 'insights': insights,
        };
      }

      if (marginPct < _minTopTwoMarginPct) {
        return {
          'label': 'Unclear Image',
          'confidence': '${confidencePct.toStringAsFixed(1)}%',
          'raw_label':
              'The top disease predictions are too close. Please retake a clearer banana leaf photo.',
          'validation_status': 'highUncertainty',
          'validation_message':
              'The AI found similar disease patterns and cannot make a safe diagnosis.',
          'entropy': entropyVal.toStringAsFixed(3),
          'top2_margin': '${marginPct.toStringAsFixed(1)}%',
          if (insights.isNotEmpty) 'insights': insights,
        };
      }

      return {
        'label': clean,
        'confidence': '${confidencePct.toStringAsFixed(1)}%',
        'raw_label': rawLabel,
        'validation_status': 'validDiagnosis',
        'entropy': entropyVal.toStringAsFixed(3),
        'top2_margin': '${marginPct.toStringAsFixed(1)}%',
        if (insights.isNotEmpty) 'insights': insights,
      };
    } catch (e) {
      debugPrint('PLANTIVA classifier error: $e');
      return {
        'label': 'Error',
        'confidence': '0%',
        'raw_label': e.toString(),
        'validation_status': 'modelError',
        'validation_message':
            'The AI model could not complete this scan. Please try again.',
      };
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _labels = {};
  }
}
