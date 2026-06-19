import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plantiva/screens/treatment_recommendation_screen.dart';

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

  String _getSeverity(String label, String confidence) {
    if (label.toLowerCase().contains('healthy')) return 'None';
    final conf = double.tryParse(confidence.replaceAll('%', '')) ?? 0;
    if (conf >= 90) return 'High';
    if (conf >= 70) return 'Moderate';
    return 'Low';
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High':
        return const Color(0xFFD32F2F);
      case 'Moderate':
        return const Color(0xFFB8860B);
      case 'Low':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF388E3C);
    }
  }

  String _getSeverityAction(String severity) {
    switch (severity) {
      case 'High':
        return 'Immediate action required within 24 hours to prevent spread.';
      case 'Moderate':
        return 'Action recommended within 48 hours to prevent spread.';
      case 'Low':
        return 'Monitor closely and apply preventive measures.';
      default:
        return 'Plant is in good condition.';
    }
  }

  String _getAboutCondition(String label) {
    final l = label.toLowerCase();
    if (l.contains('healthy')) {
      return 'Your banana plant is in excellent condition. The leaf shows no signs of disease or pest damage. Continue your current care routine to maintain plant health.';
    } else if (l.contains('black sigatoka')) {
      return 'Black Sigatoka is a serious fungal disease caused by Mycosphaerella fijiensis. It produces dark streaks and spots on leaves, reducing photosynthesis and causing premature ripening and significant yield loss.';
    } else if (l.contains('yellow sigatoka')) {
      return 'Yellow Sigatoka is a fungal disease caused by Mycosphaerella musicola. It creates yellowish streaks on leaves that significantly reduces the photosynthetic area, leading to yield reduction in banana plants.';
    } else if (l.contains('panama')) {
      return 'Panama Disease is a devastating soil-borne fungal disease caused by Fusarium oxysporum. It blocks the water-conducting vessels of the plant, causing wilting and eventual plant death. No chemical cure exists.';
    } else if (l.contains('moko')) {
      return 'Moko Disease is a bacterial wilt caused by Ralstonia solanacearum. It is one of the most destructive banana diseases, causing internal browning and complete plant collapse. Highly contagious.';
    } else if (l.contains('bract mosaic')) {
      return 'Bract Mosaic Virus Disease is caused by the Banana Bract Mosaic Virus (BBrMV), transmitted by aphids. It causes mosaic patterns on bracts and leaves, leading to reduced yield and poor fruit quality.';
    } else if (l.contains('insect pest')) {
      return 'Insect Pest Disease refers to damage caused by various insects attacking the banana leaf. This includes thrips, aphids, and weevils that feed on leaf tissue, causing characteristic damage patterns.';
    }
    return 'Consult your local agricultural extension officer for proper diagnosis and treatment.';
  }

  String _getRecommendation(String label) {
    final l = label.toLowerCase();
    if (l.contains('healthy')) {
      return '• Continue regular watering and fertilization\n• Monitor weekly for early signs of disease\n• Maintain proper spacing for air circulation\n• Apply preventive fungicide monthly';
    } else if (l.contains('black sigatoka')) {
      return '• Apply systemic fungicide immediately\n• Remove and destroy all infected leaves\n• Improve air circulation around plants\n• Avoid overhead irrigation\n• Apply fungicide every 3-4 weeks';
    } else if (l.contains('yellow sigatoka')) {
      return '• Apply appropriate fungicide spray\n• Remove severely infected leaves\n• Ensure proper drainage\n• Avoid waterlogging around roots\n• Monitor spread to nearby plants';
    } else if (l.contains('panama')) {
      return '• No chemical cure — remove infected plants\n• Destroy infected plants completely\n• Avoid replanting bananas in same soil\n• Use disease-resistant varieties\n• Disinfect all farming tools';
    } else if (l.contains('moko')) {
      return '• Destroy infected plants immediately\n• Disinfect tools with 10% bleach solution\n• Avoid wounding healthy plants\n• Report to local agriculture office\n• Quarantine affected area';
    } else if (l.contains('bract mosaic')) {
      return '• Remove and destroy infected plants\n• Control aphid populations with insecticide\n• Use virus-free planting materials\n• No chemical treatment available for virus\n• Monitor neighboring plants closely';
    } else if (l.contains('insect pest')) {
      return '• Apply appropriate insecticide\n• Remove heavily damaged leaves\n• Use sticky traps to monitor pests\n• Consider biological control methods\n• Inspect plants weekly for new damage';
    }
    return '• Consult local agricultural extension officer\n• Document symptoms for proper diagnosis\n• Isolate affected plants if possible';
  }

  @override
  Widget build(BuildContext context) {
    final label = result['label'] ?? 'Unknown';
    final confidence = result['confidence'] ?? '0%';
    final isHealthy = label.toLowerCase().contains('healthy');
    final severity = _getSeverity(label, confidence);
    final severityColor = _getSeverityColor(severity);
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
                                final text =
                                    'Plantiva diagnosis\n$label\nConfidence: $confidence';
                                await Clipboard.setData(
                                    ClipboardData(text: text));
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Diagnosis copied — paste into SMS, Messenger, or notes.',
                                    ),
                                  ),
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
                          // Diagnosis card
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
                                          'DIAGNOSIS',
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

                                // Confidence and Severity row
                                Row(
                                  children: [
                                    // Confidence
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9F9F9),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Confidence',
                                              style: TextStyle(
                                                color: Colors.grey[500],
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
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: confidenceValue / 100,
                                                backgroundColor:
                                                    Colors.grey[200],
                                                color: const Color(0xFF2E7D32),
                                                minHeight: 5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    // Severity
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9F9F9),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Severity',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              severity,
                                              style: TextStyle(
                                                color: severityColor,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              _getSeverityAction(severity),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 10,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    'Normalized scores show how the model weighs similar diseases. Your top diagnosis still uses the same winner-take-all rule as your Python API.',
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
                                      severity: severity,
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'This scan was not saved. Please check your connection or Firestore rules.',
                                          ),
                                        ),
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
