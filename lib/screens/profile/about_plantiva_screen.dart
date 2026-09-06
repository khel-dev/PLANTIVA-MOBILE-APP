import 'package:flutter/material.dart';
import 'package:flutter_plantiva/config/app_colors.dart';
import 'package:flutter_plantiva/utils/plantiva_feedback.dart';
import 'package:flutter_plantiva/widgets/plantiva_decorated_background.dart';
import 'package:url_launcher/url_launcher.dart';

const plantivaWebsiteUrl = 'https://plantiva-capstone.netlify.app/';
const plantivaTeamMembers = <String>[
  'Queljayver D. Bustamante',
  'Earl John Bio',
  'James Ray Ancog',
  'Niel John Elio',
];

class AboutPlantivaScreen extends StatelessWidget {
  const AboutPlantivaScreen({super.key});

  Future<void> _openWebsite(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse(plantivaWebsiteUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _showLaunchError(context);
      }
    } catch (_) {
      if (context.mounted) _showLaunchError(context);
    }
  }

  void _showLaunchError(BuildContext context) {
    PlantivaFeedback.show(
      context,
      message: 'Unable to open the PLANTIVA website.',
      type: PlantivaFeedbackType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202422),
        title: const Text(
          'About PLANTIVA',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: PlantivaDecoratedBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              _section(
                icon: Icons.eco_outlined,
                title: 'PLANTIVA',
                child: const Text(
                  'PLANTIVA is an image-based banana leaf screening application '
                  'developed to help users identify visible patterns associated '
                  'with common banana diseases and plant conditions. It provides '
                  'accessible disease information, management guidance, scan '
                  'history, and crop insights to support informed farm monitoring.\n\n'
                  'PLANTIVA is designed as a decision-support and educational tool '
                  'and does not replace professional agricultural diagnosis.',
                  style: TextStyle(height: 1.55, color: Color(0xFF4F5752)),
                ),
              ),
              const SizedBox(height: 14),
              _section(
                icon: Icons.groups_outlined,
                title: 'Meet the Team',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Developed by four 4th-year Bachelor of Science in Information Technology students from Philippine Women's College of Davao.",
                      style: TextStyle(
                        height: 1.5,
                        color: Color(0xFF4F5752),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...plantivaTeamMembers.map(
                      (name) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 19,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Our goal is to explore how mobile technology and artificial '
                      'intelligence can make plant-health information more '
                      'accessible and useful to banana growers and agricultural '
                      'communities.',
                      style: TextStyle(
                        height: 1.5,
                        color: Color(0xFF4F5752),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () => _openWebsite(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Visit PLANTIVA Website'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'PLANTIVA provides image-based screening and educational guidance. '
                  'Results should be confirmed through appropriate agricultural '
                  'assessment when necessary.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E8E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF202422),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
