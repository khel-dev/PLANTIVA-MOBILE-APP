import 'package:flutter/material.dart';

enum DiseaseCategory { fungal, viral, bacterial, pest, healthy }

enum DiseaseRisk { low, moderate, high }

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
      case DiseaseCategory.healthy:
        return const Color(0xFF2E7D32);
    }
  }
}

extension DiseaseRiskX on DiseaseRisk {
  String get label {
    switch (this) {
      case DiseaseRisk.low:
        return 'Low Risk';
      case DiseaseRisk.moderate:
        return 'Moderate Risk';
      case DiseaseRisk.high:
        return 'High Risk';
    }
  }

  Color get color {
    switch (this) {
      case DiseaseRisk.low:
        return const Color(0xFF388E3C);
      case DiseaseRisk.moderate:
        return const Color(0xFFF57F17);
      case DiseaseRisk.high:
        return const Color(0xFFD32F2F);
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
    required this.duration,
    required this.searchQuery,
  });

  final String title;
  final String channel;
  final String duration;
  final String searchQuery;

  String get watchUrl =>
      'https://www.youtube.com/results?search_query=${Uri.encodeComponent(searchQuery)}';
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
    required this.risk,
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
  });

  final String id;
  final String name;
  final String shortName;
  final DiseaseCategory category;
  final DiseaseRisk risk;
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
}
