import 'package:flutter_plantiva/models/disease_guide.dart';

/// Versioned, local farmer guidance for one scanner-supported class.
class TreatmentGuidance {
  const TreatmentGuidance({
    required this.id,
    required this.version,
    required this.normalizedClass,
    required this.title,
    required this.summary,
    required this.immediateActions,
    required this.management,
    required this.prevention,
    required this.whenToSeekHelp,
    required this.importantNote,
    required this.sources,
    this.isHealthy = false,
    this.isBroadCategory = false,
  });

  final String id;
  final String version;
  final String normalizedClass;
  final String title;
  final String summary;
  final List<String> immediateActions;
  final List<String> management;
  final List<String> prevention;
  final List<String> whenToSeekHelp;
  final String importantNote;
  final List<DiseaseSource> sources;
  final bool isHealthy;
  final bool isBroadCategory;

  String get plainText {
    String section(String title, List<String> items) =>
        '$title\n${items.map((item) => '- $item').join('\n')}';

    return [
      section(
        isHealthy ? 'Keep Monitoring' : 'Immediate Actions',
        immediateActions,
      ),
      section(isHealthy ? 'Good Practices' : 'Management', management),
      section('Prevention', prevention),
      section(
        isHealthy ? 'When to Seek Advice' : 'When to Seek Help',
        whenToSeekHelp,
      ),
      'Important Note\n$importantNote',
    ].join('\n\n');
  }
}
