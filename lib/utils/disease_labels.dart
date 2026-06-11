import 'package:flutter/material.dart';

/// Normalizes model / Firestore scan labels into PLANTIVA disease categories.
class DiseaseLabels {
  static const categories = <String>[
    'Black Sigatoka',
    'Bract Mosaic Virus',
    'Healthy Leaf',
    'Insect Pest',
    'Moko Disease',
    'Panama Disease',
    'Yellow Sigatoka',
  ];

  static String normalize(String? raw) {
    final l = (raw ?? '').toLowerCase();
    if (l.contains('black sigatoka')) return 'Black Sigatoka';
    if (l.contains('bract mosaic') || l.contains('mosaic')) {
      return 'Bract Mosaic Virus';
    }
    if (l.contains('healthy')) return 'Healthy Leaf';
    if (l.contains('insect') || l.contains('pest')) return 'Insect Pest';
    if (l.contains('moko')) return 'Moko Disease';
    if (l.contains('panama') || l.contains('fusarium')) return 'Panama Disease';
    if (l.contains('yellow sigatoka')) return 'Yellow Sigatoka';
    return raw?.trim().isNotEmpty == true ? raw!.trim() : 'Unknown';
  }

  static bool isHealthy(String? raw) =>
      normalize(raw) == 'Healthy Leaf';

  static bool isDiseased(String? raw) => !isHealthy(raw);

  static String displaySubtitle(String category) {
    switch (category) {
      case 'Panama Disease':
        return 'Fusarium Wilt (Panama Disease)';
      case 'Bract Mosaic Virus':
        return 'Banana Bract Mosaic Virus (BBMV)';
      default:
        return category;
    }
  }

  static Color colorFor(String category) {
    switch (category) {
      case 'Healthy Leaf':
        return const Color(0xFF2E7D32);
      case 'Black Sigatoka':
        return const Color(0xFF1B4332);
      case 'Yellow Sigatoka':
        return const Color(0xFFF57F17);
      case 'Panama Disease':
        return const Color(0xFFEF6C00);
      case 'Moko Disease':
        return const Color(0xFFC62828);
      case 'Bract Mosaic Virus':
        return const Color(0xFF6A1B9A);
      case 'Insect Pest':
        return const Color(0xFF00695C);
      default:
        return const Color(0xFF546E7A);
    }
  }

  static IconData iconFor(String category) {
    switch (category) {
      case 'Healthy Leaf':
        return Icons.eco_rounded;
      case 'Black Sigatoka':
      case 'Yellow Sigatoka':
        return Icons.coronavirus_outlined;
      case 'Panama Disease':
        return Icons.water_drop_outlined;
      case 'Moko Disease':
        return Icons.biotech_outlined;
      case 'Bract Mosaic Virus':
        return Icons.bug_report_outlined;
      case 'Insect Pest':
        return Icons.pest_control_outlined;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
