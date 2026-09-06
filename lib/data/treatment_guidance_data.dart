import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/models/treatment_guidance.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';

/// Reviewed farmer guidance used by live and saved scan results.
class TreatmentGuidanceData {
  const TreatmentGuidanceData._();

  static const version = '2026.09.1';

  static const _daRoadmap = DiseaseSource(
    name: 'Department of Agriculture - Philippine Banana Industry Roadmap',
    url:
        'https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf',
  );
  static const _fpa = DiseaseSource(
    name: 'Fertilizer and Pesticide Authority - Registered Products',
    url: 'https://fpa.da.gov.ph/resources/reports/registered-products/',
  );

  static const all = <TreatmentGuidance>[
    TreatmentGuidance(
      id: 'black_sigatoka',
      version: version,
      normalizedClass: 'Black Sigatoka',
      title: 'Black Sigatoka Guidance',
      summary:
          'Black Sigatoka is a fungal leaf disease that reduces healthy leaf area and can affect yield and fruit quality.',
      immediateActions: [
        'Mark the plant or block and inspect nearby leaves for similar dark streaks or spots.',
        'Record the symptoms and seek confirmation if Black and Yellow Sigatoka are difficult to distinguish.',
        'Avoid moving suspect leaf material into clean areas.',
      ],
      management: [
        'Use targeted sanitation and deleafing, adequate spacing, drainage, and regular scouting as one integrated program.',
        'If chemical control is advised, use only a currently registered product for banana and the confirmed condition, and follow its label.',
      ],
      prevention: [
        'Maintain airflow and drainage so foliage dries efficiently after rain.',
        'Review any fungicide program with a local technician and follow resistance-management guidance.',
      ],
      whenToSeekHelp: [
        'Symptoms spread quickly or identification remains uncertain.',
        'A chemical-control program is being considered.',
      ],
      importantNote:
          'Do not remove every leaf or begin a fixed spray schedule from one image result.',
      sources: [
        _daRoadmap,
        DiseaseSource(
          name: 'Fungicide Resistance Action Committee - Banana Group',
          url: 'https://www.frac.info/frac-teams/working-groups/banana-group/',
        ),
        _fpa,
      ],
    ),
    TreatmentGuidance(
      id: 'bract_mosaic_virus',
      version: version,
      normalizedClass: 'Bract Mosaic Virus',
      title: 'Bract Mosaic Virus Guidance',
      summary:
          'Banana Bract Mosaic is a viral disease spread by infected planting material and aphid vectors.',
      immediateActions: [
        'Mark and isolate the suspect mat.',
        'Do not take suckers, corms, or other planting material from it.',
        'Monitor neighboring plants and request diagnostic confirmation.',
      ],
      management: [
        'Use indexed or high-health planting material.',
        'Follow local guidance for infected-plant management and sanitation.',
        'Manage confirmed aphid vectors through integrated pest management.',
      ],
      prevention: [
        'Inspect new planting material and monitor nearby mats for streaking or mosaic patterns.',
        'Use a registered product only when chemical vector control is locally advised, and follow its label.',
      ],
      whenToSeekHelp: [
        'Mosaic or streak symptoms occur across several plants.',
        'Before plant removal or a vector-control program is started.',
      ],
      importantNote:
          'There is no chemical cure for the virus. An image result should be confirmed before field action.',
      sources: [
        _daRoadmap,
        DiseaseSource(
          name: 'NSW DPI - Banana Bract Mosaic Virus',
          url:
              'https://www.dpird.nsw.gov.au/dpi/biosecurity/plant-biosecurity/insect-pests-plant-diseases/banana-bract-mosaic-virus',
        ),
      ],
    ),
    TreatmentGuidance(
      id: 'bunchy_top',
      version: version,
      normalizedClass: 'Bunchy Top Disease',
      title: 'Bunchy Top Disease Guidance',
      summary:
          'Banana Bunchy Top is a systemic viral disease spread mainly by banana aphids and infected planting material.',
      immediateActions: [
        'Mark the suspect plant and do not take suckers from the mat.',
        'Avoid cutting, disturbing, or moving suspect plant material until local guidance is received.',
        'Contact the Municipal or City Agriculture Office or a crop-protection technician.',
      ],
      management: [
        'Use disease-free or indexed tissue-culture planting material.',
        'Follow official removal and vector-management instructions after confirmation.',
      ],
      prevention: [
        'Monitor nearby plants for dot-dash streaking, stunting, and upright bunched leaves.',
        'Use local integrated pest-management guidance for banana aphids.',
      ],
      whenToSeekHelp: [
        'Characteristic symptoms appear.',
        'A suspect plant may be used as propagation material.',
      ],
      importantNote:
          'There is no curative field treatment for an infected plant. Do not rogue or spray based only on this image result.',
      sources: [
        _daRoadmap,
        DiseaseSource(
          name: 'Queensland Government - Banana Bunchy Top Virus',
          url:
              'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-bunchy-top',
        ),
      ],
    ),
    TreatmentGuidance(
      id: 'healthy_leaf',
      version: version,
      normalizedClass: 'Healthy Leaf',
      title: 'Healthy Leaf Care Guidance',
      summary:
          'The submitted leaf matched the Healthy Leaf class and did not show a reliable visual pattern for the other supported classes.',
      immediateActions: [
        'Keep this scan as a visual reference and continue routine field inspection.',
        'Check newer leaves, the pseudostem, roots, fruit, and neighboring mats.',
      ],
      management: [
        'Maintain farm sanitation and clean tools.',
        'Use high-health planting material and manage water and nutrition for local field conditions.',
      ],
      prevention: [
        'Continue monitoring after stress, storms, or visible plant changes.',
        'Use good agricultural practices and seek local advice when crop conditions change.',
      ],
      whenToSeekHelp: [
        'The plant declines, wilts, produces abnormal fruit, or shows symptoms outside the photographed leaf.',
      ],
      importantNote:
          'This result describes only the scanned leaf. It does not confirm that the entire plant, mat, or farm is disease-free.',
      sources: [
        DiseaseSource(
          name: 'Philippine BAFS - Good Agricultural Practice for Banana',
          url:
              'https://bafs.da.gov.ph/index.php/code-of-good-agricultural-practice-gap-for-banana-production/',
        ),
        DiseaseSource(
          name: 'FAO World Banana Forum - Good Agricultural Practices',
          url:
              'https://www.fao.org/world-banana-forum/projects/good-practices/good-agricultural-practices/en/',
        ),
      ],
      isHealthy: true,
    ),
    TreatmentGuidance(
      id: 'insect_pest_damage',
      version: version,
      normalizedClass: 'Insect Pest Damage',
      title: 'Insect Pest Damage Guidance',
      summary:
          'PLANTIVA detected visual damage consistent with its broad Insect Pest Damage category. The exact insect cannot be identified by this model.',
      immediateActions: [
        'Inspect both leaf surfaces, the pseudostem, petioles, bunch, and nearby plants.',
        'Look for insects, eggs, larvae, frass, webbing, tunnels, or a repeated damage pattern.',
        'Photograph the pest and affected plant parts separately if possible.',
      ],
      management: [
        'Use integrated pest management: identify and monitor first, preserve beneficial organisms, and choose a targeted response only when justified.',
        'Bring clear evidence to the Municipal or City Agriculture Office if the pest remains uncertain.',
      ],
      prevention: [
        'Maintain field sanitation and inspect plants regularly for new damage.',
        'Consider a pesticide only after the pest and banana use match a current FPA registration and product label.',
      ],
      whenToSeekHelp: [
        'The pest cannot be identified or damage continues to spread.',
        'The growing point or bunch is affected, or pesticide use is being considered.',
      ],
      importantNote:
          'This is a broad damage category, not a pest identification. Do not select a pest-specific control from this scan alone.',
      sources: [
        DiseaseSource(
          name: 'DA Agricultural Training Institute - Banana IPM Course',
          url:
              'https://ati2.da.gov.ph/ati-main/content/article/ladylyn-jose/new-e-learning-course-banana-integrated-pest-management',
        ),
        DiseaseSource(
          name: 'FAO World Banana Forum - Pesticide Management',
          url:
              'https://www.fao.org/world-banana-forum/projects/good-practices/pesticide-management/en/',
        ),
        _fpa,
      ],
      isBroadCategory: true,
    ),
    TreatmentGuidance(
      id: 'moko_disease',
      version: version,
      normalizedClass: 'Moko Disease',
      title: 'Moko Disease Guidance',
      summary:
          'Moko is a bacterial vascular wilt that can spread through infected planting material and contaminated tools, soil, water, and wounds.',
      immediateActions: [
        'Photograph and mark the suspect plant without cutting it unnecessarily.',
        'Restrict access and movement of planting material and contaminated tools.',
        'Request confirmation from local agriculture or plant-health personnel.',
      ],
      management: [
        'Use disease-free planting material and maintain strict tool hygiene.',
        'Follow locally directed removal, sanitation, debudding, or containment only after confirmation.',
      ],
      prevention: [
        'Avoid unnecessary wounds and movement between suspect and clean areas.',
        'Clean and disinfect tools according to local plant-health guidance and the disinfectant label.',
      ],
      whenToSeekHelp: [
        'Wilt, internal fruit or pseudostem discoloration, or bacterial ooze is suspected.',
        'Nearby mats begin showing similar symptoms.',
      ],
      importantNote:
          'Do not use fungal treatments, generic pesticides, or an improvised disinfectant concentration.',
      sources: [
        DiseaseSource(
          name: 'UPLB - Sustainable Management of Moko and Bugtok Diseases',
          url: 'https://www.ukdr.uplb.edu.ph/professorial_lectures/930/',
        ),
        DiseaseSource(
          name:
              'Australian Department of Agriculture - Blood and Moko Diseases',
          url:
              'https://www.agriculture.gov.au/biosecurity-trade/pests-diseases-weeds/plant/identify/blood-and-moko-diseases-banana',
        ),
        _daRoadmap,
      ],
    ),
    TreatmentGuidance(
      id: 'panama_disease',
      version: version,
      normalizedClass: 'Panama Disease',
      title: 'Panama Disease Guidance',
      summary:
          'Panama Disease is a soil-borne vascular wilt. Suspected cases require careful biosecurity and professional confirmation.',
      immediateActions: [
        'Treat the result as suspected, mark the area, and restrict unnecessary access.',
        'Avoid moving soil, water, footwear, tools, machinery, or planting material out of the area.',
        'Contact local agriculture or BPI plant-health personnel for confirmation and instructions.',
      ],
      management: [
        'Use clean, certified or high-health planting material.',
        'Follow authority-directed containment and sanitation.',
        'Use locally suitable resistant or tolerant material only with current local advice.',
      ],
      prevention: [
        'Keep soil and water from suspect areas away from clean blocks.',
        'Maintain farm biosecurity for people, tools, machinery, and planting material.',
      ],
      whenToSeekHelp: [
        'Any unexplained wilt or vascular discoloration appears.',
        'Before digging, removing, or replanting in a suspect area.',
      ],
      importantNote:
          'Foliar fungicide is not a cure. Do not casually dig up or move a suspected plant because contaminated soil can spread the pathogen.',
      sources: [
        DiseaseSource(
          name: 'Bureau of Plant Industry - Special Quarantine Order No. 01',
          url:
              'https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/10/50258',
        ),
        DiseaseSource(
          name: 'FAO TR4 Global Network - Recommended Actions',
          url:
              'https://www.fao.org/world-banana-forum/fusariumtr4/tr4-global-network/actions/en/',
        ),
        _daRoadmap,
      ],
    ),
    TreatmentGuidance(
      id: 'yellow_sigatoka',
      version: version,
      normalizedClass: 'Yellow Sigatoka',
      title: 'Yellow Sigatoka Guidance',
      summary:
          'Yellow Sigatoka is a distinct fungal leaf spot that produces yellow streaks and reduces functional leaf area.',
      immediateActions: [
        'Inspect young and recently opened leaves and record the affected area.',
        'Increase monitoring during warm, wet conditions.',
        'Seek confirmation when lesions overlap with Black Sigatoka or other leaf spots.',
      ],
      management: [
        'Use timely, targeted deleafing and field sanitation to reduce affected tissue.',
        'Maintain plant nutrition and drainage as supporting crop practices.',
      ],
      prevention: [
        'Use regular scouting to guide management rather than spraying from one image result.',
        'Use chemical control only in an integrated program with a currently registered product and its label.',
      ],
      whenToSeekHelp: [
        'Leaf spot expands across the block or diagnosis is uncertain.',
        'Product selection or resistance management needs professional advice.',
      ],
      importantNote:
          'Yellow Sigatoka is not an early stage of Black Sigatoka. Do not begin an automatic or fixed spray interval from this scan.',
      sources: [
        DiseaseSource(
          name: 'Australian Banana Growers Council - Yellow Sigatoka',
          url: 'https://abgc.org.au/yellow-sigatoka/',
        ),
        DiseaseSource(
          name: 'Australian Banana Growers Council - Leaf Disease Management',
          url:
              'https://abgc.org.au/2019/04/18/hitting-the-right-spot-with-leaf-disease-management/',
        ),
        DiseaseSource(
          name: 'Department of Agriculture - Banana Production Manual',
          url:
              'https://hvcdp.da.gov.ph/wp-content/uploads/2022/05/Banana-Production-Manual.pdf',
        ),
      ],
    ),
  ];

  static TreatmentGuidance? find(String? label) {
    final normalized = DiseaseLabels.normalize(label);
    final canonical =
        normalized == 'Insect Pest' ? 'Insect Pest Damage' : normalized;
    for (final guidance in all) {
      if (guidance.normalizedClass == canonical) return guidance;
    }
    return null;
  }

  static TreatmentGuidance resolve(String? label) {
    return find(label) ??
        const TreatmentGuidance(
          id: 'unrecognized',
          version: version,
          normalizedClass: 'Unrecognized Result',
          title: 'General Scan Guidance',
          summary:
              'This image result does not match a supported PLANTIVA guidance category.',
          immediateActions: [
            'Keep a photo and record the visible symptoms.',
            'Inspect the whole plant and nearby banana mats.',
          ],
          management: [
            'Avoid choosing a chemical or destructive action from an unrecognized image result.',
          ],
          prevention: [
            'Maintain clean tools and avoid moving suspect planting material.',
          ],
          whenToSeekHelp: [
            'Ask the Municipal or City Agriculture Office or an agriculture technician for identification.',
          ],
          importantNote:
              'Scan again with a clear banana-leaf image. This result is not a confirmed diagnosis.',
          sources: [],
        );
  }
}
