/// Shared diagnosis logic for ResultScreen and ScanDetailsScreen.
class ScanDiagnosisHelper {
  static String severity(String label, String confidence) {
    if (label.toLowerCase().contains('healthy')) return 'None';
    final conf = double.tryParse(confidence.replaceAll('%', '')) ?? 0;
    if (conf >= 90) return 'High';
    if (conf >= 70) return 'Moderate';
    return 'Low';
  }

  static String severityAction(String severity) {
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

  static String aboutCondition(String label) {
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

  static String recommendations(String label) {
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

  static double parseConfidence(String confidence) {
    return double.tryParse(confidence.replaceAll('%', '')) ?? 0;
  }

  static Map<String, String> enrichResult(Map<String, String> result) {
    final label = result['label'] ?? 'Unknown';
    final confidence = result['confidence'] ?? '0%';
    final sev = severity(label, confidence);
    return {
      ...result,
      'severity': sev,
      'summary': aboutCondition(label),
      'recommendations': recommendations(label),
      'severityAction': severityAction(sev),
    };
  }
}
