import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Offline TFLite classifier — same preprocessing as `PLANTIVA_CV/app.py`
/// (RGB, 224×224, values / 255).
class ClassifierService {
  static const String _modelAsset = 'assets/models/plantiva_banana_model.tflite';
  static const String _labelsAsset = 'assets/models/labels.json';

  Interpreter? _interpreter;
  Map<int, String> _labels = {};
  String? _loadError;

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  int get classCount => _labels.length;

  String? get loadError => _loadError;

  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return [];
    final maxL = logits.reduce(math.max);
    final exps = logits.map((z) => math.exp(z - maxL)).toList();
    final sum = exps.fold<double>(0, (a, b) => a + b);
    if (sum == 0) return List<double>.filled(logits.length, 1 / logits.length);
    return exps.map((e) => e / sum).toList();
  }

  String _formatTopInsights(List<double> scores) {
    final probs = _softmax(scores.map((e) => e.toDouble()).toList());
    final order = List<int>.generate(scores.length, (i) => i);
    order.sort((a, b) => probs[b].compareTo(probs[a]));
    final top = order.take(3).toList();
    final lines = <String>[];
    for (var r = 0; r < top.length; r++) {
      final i = top[r];
      final name = _cleanLabel(_labels[i] ?? '?');
      final pct = (probs[i] * 100).clamp(0.0, 100.0);
      lines.add('${r + 1}. $name — ${pct.toStringAsFixed(1)}%');
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
      };
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return {
          'label': 'Error',
          'confidence': '0%',
          'raw_label': 'Could not decode image.',
        };
      }

      final rgb = decoded.numChannels == 3
          ? decoded
          : decoded.convert(numChannels: 3);
      final resized = img.copyResize(rgb, width: 224, height: 224);

      final input = _imageToInputNHWC(resized);
      final outShape = _interpreter!.getOutputTensor(0).shape;
      final classCount = outShape.length >= 2 ? outShape[1] : outShape.last;

      final output = [
        List<double>.filled(classCount, 0),
      ];

      _interpreter!.run(input, output);

      final scores = output[0];
      var maxIndex = 0;
      var maxScore = scores[0];
      for (var i = 1; i < scores.length; i++) {
        if (scores[i] > maxScore) {
          maxScore = scores[i];
          maxIndex = i;
        }
      }

      final rawLabel = _labels[maxIndex] ?? 'Unknown';
      final clean = _cleanLabel(rawLabel);
      final confidencePct = (maxScore * 100).clamp(0.0, 100.0);
      final insights = scores.length >= 2 ? _formatTopInsights(scores) : '';

      return {
        'label': clean,
        'confidence': '${confidencePct.toStringAsFixed(1)}%',
        'raw_label': rawLabel,
        if (insights.isNotEmpty) 'insights': insights,
      };
    } catch (e) {
      return {
        'label': 'Error',
        'confidence': '0%',
        'raw_label': e.toString(),
      };
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _labels = {};
  }
}
