import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expanded;

  static const _faqs = [
    (
      'How PLANTIVA Works',
      'PLANTIVA uses on-device AI to analyze photos of banana leaves. '
          'Take a clear photo, and our model detects diseases like Black Sigatoka, '
          'Panama Disease, and more — then provides treatment recommendations.',
    ),
    (
      'How to Scan Banana Leaves Properly',
      'Use natural daylight, focus on a single leaf, fill the frame, '
          'and avoid shadows. Hold the phone steady and capture both damaged '
          'and healthy areas for best accuracy.',
    ),
    (
      'What diseases can PLANTIVA detect?',
      'Our model detects Black Sigatoka, Yellow Sigatoka, Panama Disease, '
          'Moko Disease, Bract Mosaic Virus, Insect Pest damage, and Healthy leaves.',
    ),
    (
      'Is my data stored securely?',
      'Scan results and profile data are stored in Firebase with industry-standard '
          'security. Images are uploaded to Firebase Storage linked to your account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202422),
        title: const Text(
          'Help Center',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...List.generate(_faqs.length, (i) {
            final f = _faqs[i];
            final open = _expanded == i;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: open
                      ? AppColors.green.withValues(alpha: 0.3)
                      : const Color(0xFFE8E8E8),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => _expanded = open ? null : i),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                f.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Icon(
                              open
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.green,
                            ),
                          ],
                        ),
                        if (open) ...[
                          const SizedBox(height: 10),
                          Text(
                            f.$2,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              height: 1.5,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          _actionTile(
            Icons.mail_outline,
            'Contact Support',
            'support@plantiva.app',
            () => launchUrl(Uri.parse('mailto:support@plantiva.app')),
          ),
          const SizedBox(height: 10),
          _actionTile(
            Icons.report_problem_outlined,
            'Report a Problem',
            'Tell us about bugs or issues',
            () {
              launchUrl(
                Uri.parse(
                  'mailto:support@plantiva.app?subject=PLANTIVA%20Bug%20Report',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.green),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFC0C0C0)),
            ],
          ),
        ),
      ),
    );
  }
}
