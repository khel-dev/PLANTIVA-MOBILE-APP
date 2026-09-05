/// Shared educational copy for scan results and saved scan details.
class ScanDiagnosisHelper {
  static String aboutCondition(String label) {
    final l = label.toLowerCase();
    if (l.contains('healthy')) {
      return 'No obvious visual signs matching the supported disease classes were identified in this image. A healthy classification does not guarantee that the entire plant is free from disease or pests.';
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
    } else if (l.contains('bunchy top')) {
      return 'Banana Bunchy Top Disease is a serious viral disease spread mainly by banana aphids and infected planting materials. Infected plants can become stunted and unproductive, so early reporting and careful field action are important.';
    } else if (l.contains('insect pest')) {
      return 'Insect Pest Damage is a general image-classification category for visible feeding or pest-related leaf damage. The exact insect cannot be identified by this model and requires closer inspection.';
    }
    return 'This is an image-based screening result. Consult a local agricultural extension officer for confirmation and appropriate management.';
  }

  static String recommendations(String label) {
    final l = label.toLowerCase();
    if (l.contains('healthy')) {
      return '• Continue regular monitoring and appropriate crop care\n• Check new leaves for changes after heavy rain or stress\n• Maintain clean tools, suitable spacing, and good drainage\n• Scan again if visible symptoms develop';
    } else if (l.contains('black sigatoka')) {
      return '• Review management options with a local agriculture technician\n• Remove and destroy all infected leaves\n• Improve air circulation around plants\n• Avoid overhead irrigation\n• Follow product labels and local guidance when using fungicides';
    } else if (l.contains('yellow sigatoka')) {
      return '• Apply appropriate fungicide spray\n• Remove severely infected leaves\n• Ensure proper drainage\n• Avoid waterlogging around roots\n• Monitor spread to nearby plants';
    } else if (l.contains('panama')) {
      return '• No chemical cure — remove infected plants\n• Destroy infected plants completely\n• Avoid replanting bananas in same soil\n• Use disease-resistant varieties\n• Disinfect all farming tools';
    } else if (l.contains('moko')) {
      return '• Mark and isolate the suspected plant while seeking confirmation\n• Disinfect tools with 10% bleach solution\n• Avoid wounding healthy plants\n• Report to local agriculture office\n• Follow official guidance for the affected area';
    } else if (l.contains('bract mosaic')) {
      return '• Remove and destroy infected plants\n• Control aphid populations with insecticide\n• Use virus-free planting materials\n• No chemical treatment available for virus\n• Monitor neighboring plants closely';
    } else if (l.contains('bunchy top')) {
      return '• Mark the suspect mat and avoid taking suckers from it\n• Consult the Municipal Agriculture Office or agriculture technician\n• Follow official removal and sanitation guidance\n• Manage banana aphids using locally recommended practices\n• Use only disease-free planting materials';
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
    return {
      ...result,
      'summary': aboutCondition(label),
      'recommendations': recommendations(label),
    };
  }
}
