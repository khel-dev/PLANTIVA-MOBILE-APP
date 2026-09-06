import 'package:flutter/material.dart';

enum DiseaseCategory { fungal, viral, bacterial, pest, postharvest, healthy }

extension DiseaseCategoryX on DiseaseCategory {
  String get label {
    switch (this) {
      case DiseaseCategory.fungal:
        return 'Fungal';
      case DiseaseCategory.viral:
        return 'Viral';
      case DiseaseCategory.bacterial:
        return 'Bacterial';
      case DiseaseCategory.pest:
        return 'Pest-related';
      case DiseaseCategory.postharvest:
        return 'Postharvest';
      case DiseaseCategory.healthy:
        return 'Healthy';
    }
  }

  Color get color {
    switch (this) {
      case DiseaseCategory.fungal:
        return const Color(0xFF6A1B9A);
      case DiseaseCategory.viral:
        return const Color(0xFF1565C0);
      case DiseaseCategory.bacterial:
        return const Color(0xFFC62828);
      case DiseaseCategory.pest:
        return const Color(0xFF00695C);
      case DiseaseCategory.postharvest:
        return const Color(0xFF795548);
      case DiseaseCategory.healthy:
        return const Color(0xFF2E7D32);
    }
  }
}

class DiseaseSymptom {
  const DiseaseSymptom({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class DiseaseCause {
  const DiseaseCause({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class DiseaseTreatment {
  const DiseaseTreatment({
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;
}

class DiseaseVideo {
  const DiseaseVideo({
    required this.title,
    required this.channel,
    required this.url,
    this.isVideo = false,
  });

  final String title;
  final String channel;
  final String url;
  final bool isVideo;

  Uri? get uri {
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) return null;
    if (parsed.scheme != 'https' && parsed.scheme != 'http') return null;
    return parsed;
  }
}

class DiseaseSource {
  const DiseaseSource({required this.name, required this.url});

  final String name;
  final String url;

  Uri? get uri {
    final parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme) return null;
    if (parsed.scheme != 'https' && parsed.scheme != 'http') return null;
    return parsed;
  }
}

class DiseaseQuickFact {
  const DiseaseQuickFact({required this.label, required this.value});

  final String label;
  final String value;
}

class DiseaseGuideItem {
  const DiseaseGuideItem({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.imageUrl,
    required this.fallbackAsset,
    required this.summary,
    required this.overview,
    required this.whyDangerous,
    required this.symptoms,
    required this.causes,
    required this.prevention,
    required this.treatments,
    required this.videos,
    required this.quickFacts,
    required this.farmerTips,
    required this.relatedIds,
    required this.searchKeywords,
    this.scientificName,
    this.isAiDetectable = true,
    this.modelLabel,
    this.sources = const [],
  });

  final String id;
  final String name;
  final String shortName;
  final DiseaseCategory category;
  final String imageUrl;
  final String fallbackAsset;
  final String summary;
  final String overview;
  final String whyDangerous;
  final List<DiseaseSymptom> symptoms;
  final List<DiseaseCause> causes;
  final List<String> prevention;
  final List<DiseaseTreatment> treatments;
  final List<DiseaseVideo> videos;
  final List<DiseaseQuickFact> quickFacts;
  final List<String> farmerTips;
  final List<String> relatedIds;
  final List<String> searchKeywords;
  final String? scientificName;
  final bool isAiDetectable;
  final String? modelLabel;
  final List<DiseaseSource> sources;
}
