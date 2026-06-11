import 'package:flutter/material.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';

/// Educational disease content aligned with PLANTIVA's TFLite model classes.
/// Images: Wikimedia Commons (educational, publicly licensed).
class DiseaseGuideData {
  static const _fallback = 'assets/images/banana_landing.jpg';

  static const all = <DiseaseGuideItem>[
  blackSigatoka,
  bractMosaic,
  healthyLeaf,
  insectPest,
  moko,
  panama,
  yellowSigatoka,
];

  static DiseaseGuideItem? byId(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  static const blackSigatoka = DiseaseGuideItem(
    id: 'black_sigatoka',
    name: 'Banana Black Sigatoka Disease',
    shortName: 'Black Sigatoka',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.high,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/9/9a/Banana_leaf_showing_symptoms_of_Black_sigatoka_disease.jpg',
    fallbackAsset: _fallback,
    summary:
        'A destructive fungal leaf spot disease that reduces photosynthesis and can cut banana yields by 50% or more.',
    overview:
        'Black Sigatoka (also called black leaf streak) is caused by the fungus Mycosphaerella fijiensis. It is one of the most economically important banana diseases worldwide, especially in humid tropical regions.',
    whyDangerous:
        'Infected leaves lose green tissue quickly, weakening the plant and reducing bunch size. Without control, entire plantations can become unproductive within seasons.',
    symptoms: [
      DiseaseSymptom(
        title: 'Dark streaks',
        description: 'Thin dark lines on the underside of leaves that widen over time.',
        icon: Icons.texture_outlined,
      ),
      DiseaseSymptom(
        title: 'Black spots',
        description: 'Irregular black lesions surrounded by yellow halos on leaf blades.',
        icon: Icons.circle_outlined,
      ),
      DiseaseSymptom(
        title: 'Premature leaf death',
        description: 'Older leaves die early, reducing the plant\'s energy for fruit development.',
        icon: Icons.eco_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Fungal spores',
        description: 'Spread by wind and rain splash between plants.',
        icon: Icons.air_outlined,
      ),
      DiseaseCause(
        title: 'Humid conditions',
        description: 'Warm, wet weather accelerates infection and lesion growth.',
        icon: Icons.water_drop_outlined,
      ),
      DiseaseCause(
        title: 'Dense planting',
        description: 'Poor airflow keeps leaves wet longer, favoring the fungus.',
        icon: Icons.forest_outlined,
      ),
    ],
    prevention: [
      'Remove and destroy infected leaves promptly',
      'Maintain spacing for good air circulation',
      'Use disease-free planting material',
      'Apply preventive fungicide on a regular schedule',
      'Monitor fields weekly during rainy season',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Immediate actions',
        steps: [
          'Identify and flag heavily infected mats',
          'Remove the worst-affected leaves and burn or bury them',
          'Begin fungicide program within 48 hours',
        ],
      ),
      DiseaseTreatment(
        title: 'Ongoing management',
        steps: [
          'Alternate systemic and contact fungicides as recommended locally',
          'Improve drainage in waterlogged areas',
          'Track lesion counts on indicator plants',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Black Sigatoka Identification & Control',
        channel: 'Agricultural Extension',
        duration: 'Varies',
        searchQuery: 'black sigatoka banana disease management FAO',
      ),
      DiseaseVideo(
        title: 'Banana Leaf Spot Diseases Explained',
        channel: 'Plant Pathology',
        duration: 'Varies',
        searchQuery: 'banana sigatoka disease farmer education',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Wind & rain'),
      DiseaseQuickFact(label: 'Risk Level', value: 'High'),
      DiseaseQuickFact(label: 'Detectability', value: 'Moderate'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Severe'),
    ],
    farmerTips: [
      'Inspect the underside of leaves early in the morning when dew reveals streaks.',
      'Always disinfect cutting tools between plants.',
      'Start fungicide sprays before the rainy season peaks.',
    ],
    relatedIds: ['yellow_sigatoka', 'healthy_leaf'],
    searchKeywords: [
      'black sigatoka',
      'streaks',
      'spots',
      'fungal',
      'mycosphaerella',
      'leaf spot',
    ],
  );

  static const yellowSigatoka = DiseaseGuideItem(
    id: 'yellow_sigatoka',
    name: 'Banana Yellow Sigatoka Disease',
    shortName: 'Yellow Sigatoka',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.moderate,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Yellow_Sigatoka.jpg/640px-Yellow_Sigatoka.jpg',
    fallbackAsset: _fallback,
    summary:
        'An early-stage fungal leaf disease with yellow streaks that often precedes Black Sigatoka in the field.',
    overview:
        'Yellow Sigatoka is caused by Mycosphaerella musicola. It is less aggressive than Black Sigatoka but still reduces leaf area and weakens plants if left unmanaged.',
    whyDangerous:
        'Yellow Sigatoka opens the door for more severe infections and weakens plants during critical growth stages, lowering yield and fruit quality.',
    symptoms: [
      DiseaseSymptom(
        title: 'Yellow streaks',
        description: 'Fine yellow lines running parallel to leaf veins.',
        icon: Icons.linear_scale,
      ),
      DiseaseSymptom(
        title: 'Brown aging spots',
        description: 'Streaks turn brown as lesions age and expand.',
        icon: Icons.change_history_outlined,
      ),
      DiseaseSymptom(
        title: 'Reduced leaf area',
        description: 'Extensive streaking reduces effective photosynthesis.',
        icon: Icons.crop_portrait_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Fungal infection',
        description: 'M. musicola spores land on wet leaf surfaces.',
        icon: Icons.coronavirus_outlined,
      ),
      DiseaseCause(
        title: 'Rainy climate',
        description: 'Frequent rainfall keeps leaves moist for spore germination.',
        icon: Icons.thunderstorm_outlined,
      ),
    ],
    prevention: [
      'Scout young leaves every 7–10 days',
      'Remove infected leaf tissue early',
      'Avoid overhead irrigation where possible',
      'Maintain balanced plant nutrition',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Field response',
        steps: [
          'Apply recommended fungicide at first sign of streaks',
          'Increase scouting frequency in humid weeks',
          'Remove severely affected leaves',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Yellow vs Black Sigatoka Identification',
        channel: 'Banana Research Network',
        duration: 'Varies',
        searchQuery: 'yellow sigatoka banana leaf disease',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Wind & rain'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'Detectability', value: 'Easy early'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Moderate'),
    ],
    farmerTips: [
      'Yellow Sigatoka often appears on younger leaves first — check those carefully.',
      'Controlling Yellow Sigatoka early helps prevent Black Sigatoka outbreaks.',
    ],
    relatedIds: ['black_sigatoka', 'healthy_leaf'],
    searchKeywords: ['yellow sigatoka', 'streaks', 'yellow', 'fungal', 'musicola'],
  );

  static const panama = DiseaseGuideItem(
    id: 'panama',
    name: 'Banana Panama Disease',
    shortName: 'Panama Disease',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.high,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Panama_disease_in_banana.jpg/640px-Panama_disease_in_banana.jpg',
    fallbackAsset: _fallback,
    summary:
        'Fusarium wilt — a soil-borne fungal disease with no chemical cure that can wipe out entire banana fields.',
    overview:
        'Panama disease is caused by Fusarium oxysporum f. sp. cubense. It blocks water movement inside the plant, causing wilting and death. Tropical Race 4 (TR4) is especially devastating.',
    whyDangerous:
        'The fungus persists in soil for years. Infected fields may become unsuitable for susceptible banana varieties for decades.',
    symptoms: [
      DiseaseSymptom(
        title: 'Leaf yellowing',
        description: 'Older leaves yellow and collapse along the leaf margin.',
        icon: Icons.wb_sunny_outlined,
      ),
      DiseaseSymptom(
        title: 'Wilting',
        description: 'Plant wilts even when soil moisture is adequate.',
        icon: Icons.water_drop_outlined,
      ),
      DiseaseSymptom(
        title: 'Split pseudostem',
        description: 'Brown vascular staining visible when stem is cut.',
        icon: Icons.content_cut_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Soil-borne fungus',
        description: 'Fusarium survives in soil and infects roots.',
        icon: Icons.landscape_outlined,
      ),
      DiseaseCause(
        title: 'Contaminated tools',
        description: 'Machetes and footwear can move infested soil between blocks.',
        icon: Icons.build_outlined,
      ),
      DiseaseCause(
        title: 'Infected suckers',
        description: 'Planting material from infected mats spreads the disease.',
        icon: Icons.grass_outlined,
      ),
    ],
    prevention: [
      'Use certified disease-free planting material',
      'Plant resistant varieties where available',
      'Disinfect tools and footwear between fields',
      'Avoid moving soil from infected areas',
      'Establish field entry biosecurity protocols',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Isolation procedures',
        steps: [
          'Rogue and destroy infected plants immediately',
          'Quarantine the affected zone — no movement of plant material',
          'Do not replant susceptible varieties in the same soil',
        ],
      ),
      DiseaseTreatment(
        title: 'Long-term management',
        steps: [
          'Switch to resistant cultivars approved for your region',
          'Consult local agriculture office for TR4 protocols',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Panama Disease (Fusarium Wilt) Explained',
        channel: 'FAO Plant Health',
        duration: 'Varies',
        searchQuery: 'panama disease fusarium wilt banana TR4',
      ),
      DiseaseVideo(
        title: 'Protecting Banana Farms from Fusarium',
        channel: 'University Extension',
        duration: 'Varies',
        searchQuery: 'banana fusarium wilt prevention farmer',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal wilt'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Soil & tools'),
      DiseaseQuickFact(label: 'Risk Level', value: 'High'),
      DiseaseQuickFact(label: 'Detectability', value: 'Moderate'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Catastrophic'),
    ],
    farmerTips: [
      'Never plant suckers from a field with unexplained wilting.',
      'Boot disinfection stations at field entrances save entire farms.',
    ],
    relatedIds: ['moko', 'healthy_leaf'],
    searchKeywords: ['panama', 'fusarium', 'wilt', 'tr4', 'yellowing', 'vascular'],
  );

  static const moko = DiseaseGuideItem(
    id: 'moko',
    name: 'Banana Moko Disease',
    shortName: 'Moko Disease',
    category: DiseaseCategory.bacterial,
    risk: DiseaseRisk.high,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Bacterial_wilt_of_banana.jpg/640px-Bacterial_wilt_of_banana.jpg',
    fallbackAsset: _fallback,
    summary:
        'A highly contagious bacterial wilt that causes rapid collapse of banana plants.',
    overview:
        'Moko disease is caused by Ralstonia solanacearum. It spreads through insects, tools, and infected planting material, causing internal browning and sudden wilt.',
    whyDangerous:
        'Bacteria multiply quickly inside the plant. A single infected mat can spread to neighbors within weeks if not destroyed immediately.',
    symptoms: [
      DiseaseSymptom(
        title: 'Sudden wilting',
        description: 'Young leaves wilt and die while still green.',
        icon: Icons.sick_outlined,
      ),
      DiseaseSymptom(
        title: 'Internal browning',
        description: 'Brown discoloration of vascular tissue inside the pseudostem.',
        icon: Icons.circle,
      ),
      DiseaseSymptom(
        title: 'Bacterial ooze',
        description: 'Milky bacterial exudate may appear when stem is cut.',
        icon: Icons.water_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Bacterial pathogen',
        description: 'Ralstonia solanacearum infects through root wounds.',
        icon: Icons.biotech_outlined,
      ),
      DiseaseCause(
        title: 'Insect vectors',
        description: 'Beetles and other insects can carry bacteria between plants.',
        icon: Icons.bug_report_outlined,
      ),
      DiseaseCause(
        title: 'Contaminated tools',
        description: 'Cutting tools spread bacteria sap from plant to plant.',
        icon: Icons.content_cut,
      ),
    ],
    prevention: [
      'Use only certified disease-free suckers',
      'Disinfect tools with bleach solution between plants',
      'Control insect vectors in the plantation',
      'Avoid wounding plants during field work',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Emergency response',
        steps: [
          'Destroy infected mats immediately — do not compost',
          'Quarantine a buffer zone around the outbreak',
          'Report to local plant quarantine authorities',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Moko Disease: Recognition and Response',
        channel: 'Plant Quarantine Service',
        duration: 'Varies',
        searchQuery: 'banana moko disease bacterial wilt',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Bacterial'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Tools & insects'),
      DiseaseQuickFact(label: 'Risk Level', value: 'High'),
      DiseaseQuickFact(label: 'Detectability', value: 'Moderate'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Severe'),
    ],
    farmerTips: [
      'Separate infected plants immediately — do not wait for confirmation.',
      'Keep a dedicated disinfectant bucket at every field entrance.',
    ],
    relatedIds: ['panama', 'insect_pest'],
    searchKeywords: ['moko', 'bacterial', 'wilt', 'ralstonia', 'ooze', 'collapse'],
  );

  static const bractMosaic = DiseaseGuideItem(
    id: 'bract_mosaic',
    name: 'Banana Bract Mosaic Virus Disease',
    shortName: 'Bract Mosaic Virus',
    category: DiseaseCategory.viral,
    risk: DiseaseRisk.moderate,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Mosaic_virus_on_plant.jpg/640px-Mosaic_virus_on_plant.jpg',
    fallbackAsset: _fallback,
    summary:
        'A virus disease causing mosaic patterns on bracts and leaves, spread primarily by aphids.',
    overview:
        'Banana Bract Mosaic Virus (BBrMV) affects both ornamental and fruiting bananas. Once a plant is infected, there is no cure — management focuses on prevention and vector control.',
    whyDangerous:
        'Virus-infected plants remain carriers for life, serving as reservoirs that aphids spread to healthy plants across the farm.',
    symptoms: [
      DiseaseSymptom(
        title: 'Mosaic patterns',
        description: 'Irregular light and dark green patches on leaves and bracts.',
        icon: Icons.grid_on_outlined,
      ),
      DiseaseSymptom(
        title: 'Bract streaking',
        description: 'Discolored streaks on flower bracts during bunch development.',
        icon: Icons.deck_outlined,
      ),
      DiseaseSymptom(
        title: 'Stunted growth',
        description: 'Infected plants may show reduced vigor over time.',
        icon: Icons.trending_down,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Viral pathogen',
        description: 'BBrMV infects through sap and grafting wounds.',
        icon: Icons.coronavirus,
      ),
      DiseaseCause(
        title: 'Aphid vectors',
        description: 'Aphids transmit the virus while feeding on plant sap.',
        icon: Icons.pest_control,
      ),
    ],
    prevention: [
      'Use virus-indexed planting material',
      'Control aphid populations early',
      'Rogue infected plants as soon as identified',
      'Avoid sharing tools between infected and clean blocks',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Management (no cure)',
        steps: [
          'Remove and destroy infected plants',
          'Apply aphid management per local guidelines',
          'Monitor neighboring plants for 4–6 weeks',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Virus Diseases and Aphid Control',
        channel: 'Crop Protection Network',
        duration: 'Varies',
        searchQuery: 'banana bract mosaic virus aphid control',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Viral'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Aphids'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'Detectability', value: 'Moderate'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Moderate'),
    ],
    farmerTips: [
      'Mosaic patterns are easiest to spot in partial shade — inspect then.',
      'Plant virus-free tissue culture plants when replanting.',
    ],
    relatedIds: ['insect_pest', 'healthy_leaf'],
    searchKeywords: ['mosaic', 'virus', 'bract', 'aphid', 'bbmv', 'pattern'],
  );

  static const insectPest = DiseaseGuideItem(
    id: 'insect_pest',
    name: 'Banana Insect Pest Disease',
    shortName: 'Insect Pest Damage',
    category: DiseaseCategory.pest,
    risk: DiseaseRisk.moderate,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Aphids_on_leaves.jpg/640px-Aphids_on_leaves.jpg',
    fallbackAsset: _fallback,
    summary:
        'Physical damage from insects such as thrips, aphids, and weevils that weakens leaves and opens entry points for pathogens.',
    overview:
        'Insect pest damage is not a single disease but a category of injury caused by feeding insects. Damaged tissue stresses plants and can worsen disease outbreaks.',
    whyDangerous:
        'Pest wounds create entry points for fungi and bacteria. Some insects also vector deadly viruses like Bract Mosaic.',
    symptoms: [
      DiseaseSymptom(
        title: 'Chewing damage',
        description: 'Irregular holes and torn leaf margins from feeding.',
        icon: Icons.pest_control_outlined,
      ),
      DiseaseSymptom(
        title: 'Stippling & silvering',
        description: 'Thrips cause silvery patches on leaf surfaces.',
        icon: Icons.grain,
      ),
      DiseaseSymptom(
        title: 'Pest presence',
        description: 'Visible insects, eggs, or frass on leaf undersides.',
        icon: Icons.bug_report,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Insect feeding',
        description: 'Thrips, aphids, weevils, and beetles damage leaf tissue.',
        icon: Icons.bug_report_outlined,
      ),
      DiseaseCause(
        title: 'Weed hosts',
        description: 'Weeds near fields harbor pest populations.',
        icon: Icons.grass,
      ),
      DiseaseCause(
        title: 'Monoculture',
        description: 'Large banana blocks provide uninterrupted pest habitat.',
        icon: Icons.crop_square,
      ),
    ],
    prevention: [
      'Monitor with yellow sticky traps',
      'Maintain field sanitation and weed control',
      'Encourage natural predators where possible',
      'Inspect new plantings weekly for early pest signs',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Integrated pest management',
        steps: [
          'Identify the pest species before treatment',
          'Use targeted biological or chemical controls per label',
          'Remove heavily infested leaves to reduce populations',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Insect Pests: ID and Management',
        channel: 'Integrated Pest Management',
        duration: 'Varies',
        searchQuery: 'banana insect pest thrips aphid management',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Pest damage'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Insect movement'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'Detectability', value: 'Easy'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Variable'),
    ],
    farmerTips: [
      'Check leaf undersides — most banana pests hide there.',
      'Healthy plants tolerate minor pest damage better than stressed ones.',
    ],
    relatedIds: ['bract_mosaic', 'healthy_leaf'],
    searchKeywords: ['insect', 'pest', 'thrips', 'aphid', 'weevil', 'chewing', 'holes'],
  );

  static const healthyLeaf = DiseaseGuideItem(
    id: 'healthy_leaf',
    name: 'Banana Healthy Leaf',
    shortName: 'Healthy Leaf',
    category: DiseaseCategory.healthy,
    risk: DiseaseRisk.low,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Banana_leaf_1.jpg/640px-Banana_leaf_1.jpg',
    fallbackAsset: _fallback,
    summary:
        'The baseline for PLANTIVA scans — vibrant green leaves without disease symptoms or pest damage.',
    overview:
        'A healthy banana leaf shows uniform green coloration, intact margins, and no streaks, spots, or wilting. This is what farmers should aim to maintain across the plantation.',
    whyDangerous:
        'Healthy leaves are not dangerous — they represent your target outcome. Maintaining plant health protects yield and reduces management costs.',
    symptoms: [
      DiseaseSymptom(
        title: 'Vibrant green color',
        description: 'Even green tone across the leaf blade without yellowing.',
        icon: Icons.eco_rounded,
      ),
      DiseaseSymptom(
        title: 'Intact leaf margins',
        description: 'No tears, necrosis, or irregular edges.',
        icon: Icons.check_circle_outline,
      ),
      DiseaseSymptom(
        title: 'No lesions',
        description: 'Absence of spots, streaks, or mosaic patterns.',
        icon: Icons.verified_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Good nutrition',
        description: 'Balanced fertilization supports strong leaf development.',
        icon: Icons.spa_outlined,
      ),
      DiseaseCause(
        title: 'Proper water management',
        description: 'Adequate but not excessive soil moisture.',
        icon: Icons.water,
      ),
      DiseaseCause(
        title: 'Preventive care',
        description: 'Regular scouting and early disease intervention.',
        icon: Icons.shield_outlined,
      ),
    ],
    prevention: [
      'Continue weekly PLANTIVA leaf scanning',
      'Maintain field sanitation',
      'Apply balanced fertilizer program',
      'Monitor for early disease signs on border plants',
      'Keep tools clean between plants',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Maintaining health',
        steps: [
          'Document healthy scans as your field baseline',
          'Compare new scans against healthy reference photos',
          'Reinforce good practices when health rate is high',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Best Practices for Healthy Banana Fields',
        channel: 'Sustainable Agriculture',
        duration: 'Varies',
        searchQuery: 'healthy banana plantation best practices farmer',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Healthy reference'),
      DiseaseQuickFact(label: 'Spread Method', value: 'N/A'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Low'),
      DiseaseQuickFact(label: 'Detectability', value: 'Easy'),
      DiseaseQuickFact(label: 'Economic Impact', value: 'Positive'),
    ],
    farmerTips: [
      'Use healthy leaves as your comparison standard when scouting.',
      'High healthy scan rates mean your management program is working.',
      'Scan the same blocks regularly to catch changes early.',
    ],
    relatedIds: ['black_sigatoka', 'yellow_sigatoka'],
    searchKeywords: ['healthy', 'green', 'normal', 'baseline', 'no disease'],
  );
}
