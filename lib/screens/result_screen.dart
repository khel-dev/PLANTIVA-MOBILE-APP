import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/screens/treatment_recommendation_screen.dart';
import 'package:flutter_plantiva/utils/plantiva_feedback.dart';
import 'package:flutter_plantiva/utils/scan_diagnosis_helper.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, String> result;
  final String? savedScanId;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
    this.savedScanId,
  });

  String _getAboutCondition(String label) {
    return ScanDiagnosisHelper.aboutCondition(label);
  }

  String _getRecommendation(String label) {
    return ScanDiagnosisHelper.recommendations(label);
  }

  bool _isInvalidResult(Map<String, String> result) {
    final status = result['validation_status'];
    if (status != null && status != 'validDiagnosis') return true;
    final label = (result['label'] ?? '').toLowerCase();
    return label.contains('not a banana leaf') ||
        label.contains('unable to determine') ||
        label.contains('low confidence') ||
        label.contains('unclear image') ||
        label.contains('invalid image') ||
        label.contains('model not ready') ||
        label == 'error';
  }

  String _invalidTitle(String label) {
    final l = label.toLowerCase();
    if (l.contains('unable to classify')) {
      return 'Unable to classify this image reliably';
    }
    if (l.contains('not a banana leaf')) return 'Please capture a banana leaf';
    if (l.contains('low confidence')) return 'Unable to identify disease';
    if (l.contains('unclear image')) return 'Image quality insufficient';
    if (l.contains('invalid image')) return 'Invalid image';
    if (l.contains('model not ready') || l == 'error') {
      return 'Scan could not be completed';
    }
    return 'Unable to identify disease';
  }

  Widget _buildInvalidResult(BuildContext context) {
    final label = result['label'] ?? 'Unable to Determine';
    final reason = (result['validation_message'] ??
            result['raw_label'] ??
            'The scan was rejected because the classifier could not produce a reliable result.')
        .trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Scan Review',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 220,
                    color: const Color(0xFFE8F5E9),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFEF6C00),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _invalidTitle(label),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This image was not added to your scans.',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      reason,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.55,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for a better scan',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B4332),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    _Tip(text: 'Keep one banana leaf clearly visible.'),
                    _Tip(text: 'Avoid blurry or dark images.'),
                    _Tip(text: 'Use good natural lighting.'),
                    _Tip(text: 'Focus on one leaf and fill the frame.'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, 'camera'),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Retake Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B4332),
                        side: const BorderSide(
                          color: Color(0xFF1B4332),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'gallery'),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose Another'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = result['label'] ?? 'Unknown';
    final confidence = result['confidence'] ?? '0%';
    if (_isInvalidResult(result)) {
      return _buildInvalidResult(context);
    }
    final isHealthy = label.toLowerCase().contains('healthy');
    final confidenceValue =
        double.tryParse(confidence.replaceAll('%', '')) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with back button overlay
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                          child: Image.file(
                            File(imagePath),
                            height: 260,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Share button
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () async {
                                final label = result['label'] ?? 'Unknown';
                                final confidence = result['confidence'] ?? '0%';
                                final text = 'PLANTIVA Classification Result\n'
                                    '$label\n'
                                    'AI Classification Confidence: $confidence\n\n'
                                    'PLANTIVA provides image-based screening and educational information. Visual symptoms may overlap between conditions.';
                                await Clipboard.setData(
                                    ClipboardData(text: text));
                                if (!context.mounted) return;
                                PlantivaFeedback.show(
                                  context,
                                  message: 'Classification result copied.',
                                  type: PlantivaFeedbackType.success,
                                );
                              },
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.share_outlined,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Analyzed badge
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF2E7D32),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'ANALYZED',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Classification result card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CLASSIFICATION RESULT',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          label,
                                          style: const TextStyle(
                                            color: Color(0xFF1B1B1B),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.eco,
                                        color: Color(0xFF2E7D32),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9F9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AI Classification Confidence',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${confidenceValue.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: confidenceValue / 100,
                                          backgroundColor: Colors.grey[200],
                                          color: const Color(0xFF2E7D32),
                                          minHeight: 5,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'This score reflects how strongly the model matched the image to this class. It does not measure disease severity.',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 11,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'PLANTIVA provides image-based screening and educational information. Visual symptoms may overlap between conditions.',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          if ((result['insights'] ?? '').trim().isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2918),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF2FBF4B)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.analytics_outlined,
                                        color: Colors.greenAccent.shade400,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'AI runner-ups',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    result['insights']!.trim(),
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.88),
                                      height: 1.55,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'These scores show how the model weighs similar classes. They do not validate whether the image is a banana leaf or measure disease severity.',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.55),
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // About this condition
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey[600],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'About this Condition',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getAboutCondition(label),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // View Treatment button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        TreatmentRecommendationScreen(
                                      imagePath: imagePath,
                                      label: label,
                                      confidence: confidence,
                                      summary: _getAboutCondition(label),
                                      recommendation: _getRecommendation(label),
                                      isHealthy: isHealthy,
                                      savedScanId: savedScanId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.medical_services_outlined),
                              label:
                                  const Text('View Treatment Recommendations'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B4332),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Bottom action buttons
                          Row(
                            children: [
                              // Scan Again
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Scan Again'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1B4332),
                                    side: const BorderSide(
                                      color: Color(0xFF1B4332),
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Save Result
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (savedScanId == null) {
                                      PlantivaFeedback.show(
                                        context,
                                        message:
                                            'This scan was not saved. Please check your connection or Firestore rules.',
                                        type: PlantivaFeedbackType.warning,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    savedScanId == null
                                        ? Icons.bookmark_border
                                        : Icons.bookmark_added,
                                  ),
                                  label: Text(
                                    savedScanId == null ? 'Not Saved' : 'Saved',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: savedScanId == null
                                        ? Colors.grey.shade700
                                        : const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF2E7D32),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2D3A31),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
