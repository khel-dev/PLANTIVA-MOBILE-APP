import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ImageQualityCode {
  ok,
  tooDark,
  tooBright,
  tooBlurry,
  lowVisualInformation,
}

class ImageQualityMetrics {
  const ImageQualityMetrics({
    required this.meanLuminance,
    required this.medianLuminance,
    required this.lowPixelRatio,
    required this.nearWhitePixelRatio,
    required this.dynamicRange,
    required this.luminanceStandardDeviation,
    required this.laplacianVariance,
  });

  final double meanLuminance;
  final double medianLuminance;
  final double lowPixelRatio;
  final double nearWhitePixelRatio;
  final double dynamicRange;
  final double luminanceStandardDeviation;
  final double laplacianVariance;
}

class ImageQualityResult {
  const ImageQualityResult({required this.code, required this.metrics});

  final ImageQualityCode code;
  final ImageQualityMetrics metrics;

  bool get isUsable => code == ImageQualityCode.ok;

  String get wireCode => switch (code) {
        ImageQualityCode.ok => 'OK',
        ImageQualityCode.tooDark => 'TOO_DARK',
        ImageQualityCode.tooBright => 'TOO_BRIGHT',
        ImageQualityCode.tooBlurry => 'TOO_BLURRY',
        ImageQualityCode.lowVisualInformation => 'LOW_VISUAL_INFORMATION',
      };

  String get userMessage => switch (code) {
        ImageQualityCode.ok => 'Image quality is suitable for analysis.',
        ImageQualityCode.tooDark =>
          'The image is too dark. Please take another photo in better lighting.',
        ImageQualityCode.tooBright =>
          'The image is too bright. Please avoid strong glare or direct light.',
        ImageQualityCode.tooBlurry =>
          'The image is blurry. Hold the camera steady and try again.',
        ImageQualityCode.lowVisualInformation =>
          'The image is unclear. Please capture the banana leaf clearly.',
      };
}

class ImageQualityService {
  static const analysisSize = 256;
  static const meanDarkThreshold = 20.0;
  static const lowLuminanceValue = 20.0;
  static const lowPixelRatioThreshold = 0.95;
  static const meanBrightThreshold = 225.0;
  static const nearWhiteValue = 245.0;
  static const nearWhiteRatioThreshold = 0.10;
  static const brightDynamicRangeThreshold = 80.0;
  static const blurVarianceThreshold = 20.0;
  static const lowInformationDeviationThreshold = 5.0;
  static const lowInformationRangeThreshold = 15.0;

  Future<ImageQualityResult> analyze(File imageFile) async {
    return analyzeBytes(await imageFile.readAsBytes());
  }

  ImageQualityResult analyzeBytes(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('The selected file could not be decoded.');
    }
    return analyzeImage(decoded);
  }

  ImageQualityResult analyzeImage(img.Image decoded) {
    final rgb =
        decoded.numChannels == 3 ? decoded : decoded.convert(numChannels: 3);
    final resized = img.copyResize(
      rgb,
      width: analysisSize,
      height: analysisSize,
      interpolation: img.Interpolation.linear,
    );
    final luminance = List<double>.filled(analysisSize * analysisSize, 0);
    var sum = 0.0;
    var lowPixels = 0;
    var nearWhitePixels = 0;

    for (var y = 0; y < analysisSize; y++) {
      for (var x = 0; x < analysisSize; x++) {
        final pixel = resized.getPixel(x, y);
        final value = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b)
            .roundToDouble();
        final index = y * analysisSize + x;
        luminance[index] = value;
        sum += value;
        if (value <= lowLuminanceValue) lowPixels++;
        if (value >= nearWhiteValue) nearWhitePixels++;
      }
    }

    final mean = sum / luminance.length;
    var squaredDifferenceSum = 0.0;
    for (final value in luminance) {
      final difference = value - mean;
      squaredDifferenceSum += difference * difference;
    }

    final sorted = List<double>.from(luminance)..sort();
    final p5 = _percentile(sorted, 0.05);
    final p95 = _percentile(sorted, 0.95);
    final metrics = ImageQualityMetrics(
      meanLuminance: mean,
      medianLuminance: _percentile(sorted, 0.50),
      lowPixelRatio: lowPixels / luminance.length,
      nearWhitePixelRatio: nearWhitePixels / luminance.length,
      dynamicRange: p95 - p5,
      luminanceStandardDeviation:
          math.sqrt(squaredDifferenceSum / luminance.length),
      laplacianVariance: _laplacianVariance(luminance),
    );
    return evaluateMetrics(metrics);
  }

  static ImageQualityResult evaluateMetrics(ImageQualityMetrics metrics) {
    final isTooDark = metrics.meanLuminance < meanDarkThreshold ||
        metrics.lowPixelRatio >= lowPixelRatioThreshold;
    final isTooBright = metrics.meanLuminance >= meanBrightThreshold &&
        metrics.nearWhitePixelRatio >= nearWhiteRatioThreshold &&
        metrics.dynamicRange <= brightDynamicRangeThreshold;
    final hasLowInformation =
        metrics.luminanceStandardDeviation < lowInformationDeviationThreshold ||
            metrics.dynamicRange < lowInformationRangeThreshold;
    final isTooBlurry = metrics.laplacianVariance < blurVarianceThreshold;

    final code = isTooDark
        ? ImageQualityCode.tooDark
        : isTooBright
            ? ImageQualityCode.tooBright
            : hasLowInformation
                ? ImageQualityCode.lowVisualInformation
                : isTooBlurry
                    ? ImageQualityCode.tooBlurry
                    : ImageQualityCode.ok;
    return ImageQualityResult(code: code, metrics: metrics);
  }

  static double _percentile(List<double> sorted, double percentile) {
    final position = (sorted.length - 1) * percentile;
    final lower = position.floor();
    final upper = position.ceil();
    if (lower == upper) return sorted[lower];
    final fraction = position - lower;
    return sorted[lower] + (sorted[upper] - sorted[lower]) * fraction;
  }

  static int _reflect101(int value) {
    if (value < 0) return -value;
    if (value >= analysisSize) return (2 * analysisSize) - value - 2;
    return value;
  }

  static double _laplacianVariance(List<double> luminance) {
    var sum = 0.0;
    var squaredSum = 0.0;
    for (var y = 0; y < analysisSize; y++) {
      final top = _reflect101(y - 1);
      final bottom = _reflect101(y + 1);
      for (var x = 0; x < analysisSize; x++) {
        final left = _reflect101(x - 1);
        final right = _reflect101(x + 1);
        final center = luminance[y * analysisSize + x];
        final laplacian = 2 *
                (luminance[top * analysisSize + left] +
                    luminance[top * analysisSize + right] +
                    luminance[bottom * analysisSize + left] +
                    luminance[bottom * analysisSize + right]) -
            8 * center;
        sum += laplacian;
        squaredSum += laplacian * laplacian;
      }
    }
    final count = luminance.length;
    final mean = sum / count;
    return (squaredSum / count) - (mean * mean);
  }
}
