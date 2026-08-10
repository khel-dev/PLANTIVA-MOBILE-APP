import 'package:flutter/material.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';

/// Educational disease content aligned with PLANTIVA's TFLite model classes.
/// Educational disease content aligned with PLANTIVA's local image assets.
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
    bunchyTop,
    anthracnose,
    bananaFreckle,
    crownRot,
    weevilBorer,
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
    imageUrl: 'assets/images/black_sigatoka.jpg',
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
        description:
            'Thin dark lines on the underside of leaves that widen over time.',
        icon: Icons.texture_outlined,
      ),
      DiseaseSymptom(
        title: 'Black spots',
        description:
            'Irregular black lesions surrounded by yellow halos on leaf blades.',
        icon: Icons.circle_outlined,
      ),
      DiseaseSymptom(
        title: 'Premature leaf death',
        description:
            'Older leaves die early, reducing the plant\'s energy for fruit development.',
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
        description:
            'Warm, wet weather accelerates infection and lesion growth.',
        icon: Icons.water_drop_outlined,
      ),
      DiseaseCause(
        title: 'Dense planting',
        description:
            'Poor airflow keeps leaves wet longer, favoring the fungus.',
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
    imageUrl: 'assets/images/yellow_sigatoka.jpg',
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
        description:
            'Frequent rainfall keeps leaves moist for spore germination.',
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
    searchKeywords: [
      'yellow sigatoka',
      'streaks',
      'yellow',
      'fungal',
      'musicola'
    ],
  );

  static const panama = DiseaseGuideItem(
    id: 'panama',
    name: 'Banana Panama Disease',
    shortName: 'Panama Disease',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.high,
    imageUrl: 'assets/images/panama_disease.jpg',
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
        description:
            'Machetes and footwear can move infested soil between blocks.',
        icon: Icons.build_outlined,
      ),
      DiseaseCause(
        title: 'Infected suckers',
        description:
            'Planting material from infected mats spreads the disease.',
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
    searchKeywords: [
      'panama',
      'fusarium',
      'wilt',
      'tr4',
      'yellowing',
      'vascular'
    ],
  );

  static const moko = DiseaseGuideItem(
    id: 'moko',
    name: 'Banana Moko Disease',
    shortName: 'Moko Disease',
    category: DiseaseCategory.bacterial,
    risk: DiseaseRisk.high,
    imageUrl: 'assets/images/moko_disease.jpg',
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
        description:
            'Brown discoloration of vascular tissue inside the pseudostem.',
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
        description:
            'Beetles and other insects can carry bacteria between plants.',
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
    searchKeywords: [
      'moko',
      'bacterial',
      'wilt',
      'ralstonia',
      'ooze',
      'collapse'
    ],
  );

  static const bractMosaic = DiseaseGuideItem(
    id: 'bract_mosaic',
    name: 'Banana Bract Mosaic Virus Disease',
    shortName: 'Bract Mosaic Virus',
    category: DiseaseCategory.viral,
    risk: DiseaseRisk.moderate,
    imageUrl: 'assets/images/bract_mosaic_virus.jpg',
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
        description:
            'Irregular light and dark green patches on leaves and bracts.',
        icon: Icons.grid_on_outlined,
      ),
      DiseaseSymptom(
        title: 'Bract streaking',
        description:
            'Discolored streaks on flower bracts during bunch development.',
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
    imageUrl: 'assets/images/insect_pest_damage.jpg',
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
    searchKeywords: [
      'insect',
      'pest',
      'thrips',
      'aphid',
      'weevil',
      'chewing',
      'holes'
    ],
  );

  static const healthyLeaf = DiseaseGuideItem(
    id: 'healthy_leaf',
    name: 'Banana Healthy Leaf',
    shortName: 'Healthy Leaf',
    category: DiseaseCategory.healthy,
    risk: DiseaseRisk.low,
    imageUrl: 'assets/images/healthy_banana_leaf.jpg',
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

  static const bunchyTop = DiseaseGuideItem(
    id: 'bunchy_top',
    name: 'Banana Bunchy Top Disease',
    shortName: 'Bunchy Top',
    category: DiseaseCategory.viral,
    risk: DiseaseRisk.high,
    imageUrl: 'assets/images/banana_bunchy_top.jpg',
    fallbackAsset: _fallback,
    scientificName: 'Banana bunchy top virus (BBTV)',
    isAiDetectable: true,
    modelLabel: 'Augmented Banana Bunchy Top Disease',
    summary:
        'A highly destructive banana virus disease that can severely stunt plants and make infected mats unproductive.',
    overview:
        'Banana Bunchy Top Disease is caused by Banana bunchy top virus (BBTV). It is spread mainly by the banana aphid, Pentalonia nigronervosa, and by infected planting material such as suckers from diseased mats.',
    whyDangerous:
        'Infected plants can develop a tight bunching or rosette appearance, become severely stunted, and fail to produce normally. There is no curative field treatment for BBTV, so prevention, reporting, and removal under agricultural guidance are critical.',
    symptoms: [
      DiseaseSymptom(
        title: 'Dot-dash streaks',
        description:
            'Dark green dot-dash or Morse code-like streaks may appear on leaf veins, midribs, and petioles.',
        icon: Icons.short_text_outlined,
      ),
      DiseaseSymptom(
        title: 'Bunched leaves',
        description:
            'Advanced plants develop narrow, upright, progressively shorter leaves that form a rosette.',
        icon: Icons.local_florist_outlined,
      ),
      DiseaseSymptom(
        title: 'Stunted growth',
        description:
            'Infected plants may become brittle, severely stunted, and nonproductive.',
        icon: Icons.trending_down,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Banana aphid vector',
        description:
            'Pentalonia nigronervosa transmits BBTV while feeding on banana plants.',
        icon: Icons.bug_report_outlined,
      ),
      DiseaseCause(
        title: 'Infected planting material',
        description:
            'Suckers or planting materials from infected mats can spread the virus to new areas.',
        icon: Icons.grass_outlined,
      ),
    ],
    prevention: [
      'Use disease-free planting materials from reliable sources',
      'Monitor fields for aphids and early bunchy top symptoms',
      'Remove infected plants only according to local agricultural guidance',
      'Avoid moving planting materials from suspect fields',
      'Keep new planting materials separated from suspect or infected farm areas',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Field response',
        steps: [
          'Mark suspect plants and avoid collecting suckers from the area',
          'Consult the Municipal Agriculture Office or crop protection staff',
          'Follow official removal and sanitation guidance for infected mats',
        ],
      ),
      DiseaseTreatment(
        title: 'Vector management',
        steps: [
          'Monitor and manage banana aphid populations',
          'Remove volunteer banana plants that may harbor aphids or disease',
          'Use only locally recommended control practices',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Bunchy Top Disease Philippines',
        channel: 'Search result',
        duration: 'Varies',
        searchQuery: 'banana bunchy top disease Philippines',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Viral'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'BBTV'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Banana aphid'),
      DiseaseQuickFact(label: 'Planting Risk', value: 'Infected suckers'),
      DiseaseQuickFact(label: 'Risk Level', value: 'High'),
      DiseaseQuickFact(label: 'AI Status', value: 'AI detectable'),
    ],
    farmerTips: [
      'Do not use suckers from plants with bunching or severe stunting.',
      'Report suspicious bunchy top symptoms early for proper field guidance.',
      'Managing aphids is part of prevention, but infected plants still require official guidance.',
    ],
    relatedIds: ['bract_mosaic', 'moko', 'panama'],
    searchKeywords: [
      'banana bunchy top',
      'bunchy top',
      'bbtv',
      'banana bunchy top virus',
      'banana aphid',
      'rosette banana',
    ],
    sources: [
      'Business Queensland - Banana bunchy top',
      'CGIAR / Bioversity International - Guide to Banana Bunchy Top Disease',
      'Plant Disease / PMC - Banana bunchy top virus research in the Philippines',
    ],
  );

  static const anthracnose = DiseaseGuideItem(
    id: 'anthracnose',
    name: 'Banana Anthracnose',
    shortName: 'Anthracnose',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.moderate,
    imageUrl: 'assets/images/banana_anthracnose.jpg',
    fallbackAsset: _fallback,
    scientificName: 'Colletotrichum musae and related Colletotrichum species',
    isAiDetectable: false,
    modelLabel: null,
    summary:
        'A banana disease commonly seen on fruit as dark sunken lesions, especially under humid and postharvest conditions.',
    overview:
        'Banana Anthracnose is a fungal fruit disease associated with Colletotrichum species. Symptoms are often noticed during ripening or after harvest, especially when fruit has wounds or is kept under humid conditions.',
    whyDangerous:
        'Anthracnose reduces fruit quality and market value. It can remain unnoticed at harvest and become more visible as fruit ripens, so careful handling and clean postharvest practices are important.',
    symptoms: [
      DiseaseSymptom(
        title: 'Sunken fruit spots',
        description:
            'Black or brown depressed lesions may appear on banana fruit.',
        icon: Icons.circle_outlined,
      ),
      DiseaseSymptom(
        title: 'Expanding lesions',
        description:
            'Spots can enlarge and merge, damaging more of the fruit surface.',
        icon: Icons.blur_circular_outlined,
      ),
      DiseaseSymptom(
        title: 'Salmon spore masses',
        description:
            'Under humid conditions, lesions may develop salmon-colored fungal structures or spore masses.',
        icon: Icons.grain,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Fungal infection',
        description:
            'Colletotrichum fungi can infect banana fruit and develop into visible lesions during ripening.',
        icon: Icons.biotech_outlined,
      ),
      DiseaseCause(
        title: 'Humid conditions',
        description:
            'Moist environments can favor fungal growth and postharvest disease development.',
        icon: Icons.water_drop_outlined,
      ),
      DiseaseCause(
        title: 'Fruit handling stress',
        description:
            'Bruising and poor postharvest handling can worsen fruit disease problems.',
        icon: Icons.inventory_2_outlined,
      ),
    ],
    prevention: [
      'Handle harvested fruit carefully to reduce wounds and bruising',
      'Keep packing and storage areas clean',
      'Remove affected fruit and plant residues properly',
      'Follow recommended postharvest sanitation practices',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Postharvest management',
        steps: [
          'Separate visibly affected fruit from healthy fruit',
          'Improve sanitation in handling, washing, and packing areas',
          'Follow local postharvest guidance instead of relying on a single chemical solution',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Anthracnose Philippines',
        channel: 'Search result',
        duration: 'Varies',
        searchQuery: 'banana anthracnose Philippines',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'Colletotrichum spp.'),
      DiseaseQuickFact(label: 'Common Site', value: 'Fruit'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'AI Status', value: 'Guide only'),
    ],
    farmerTips: [
      'Protect fruit from bruising during harvest and transport.',
      'Good sanitation after harvest helps reduce fruit rot problems.',
    ],
    relatedIds: ['black_sigatoka', 'yellow_sigatoka'],
    searchKeywords: [
      'banana anthracnose',
      'anthracnose banana',
      'banana fruit spots',
      'banana black spots',
    ],
    sources: [
      'TNAU Agritech Portal - Banana postharvest anthracnose',
      'Plantwise Knowledge Bank - Anthracnose on banana',
      'Philippine Center for Postharvest Development and Mechanization - banana postharvest disease information',
    ],
  );

  static const bananaFreckle = DiseaseGuideItem(
    id: 'banana_freckle',
    name: 'Banana Freckle',
    shortName: 'Banana Freckle',
    category: DiseaseCategory.fungal,
    risk: DiseaseRisk.moderate,
    imageUrl: 'assets/images/banana_freckle.jpg',
    fallbackAsset: _fallback,
    scientificName: 'Phyllosticta spp. including Phyllosticta cavendishii',
    isAiDetectable: false,
    modelLabel: null,
    summary:
        'A fungal banana disease associated with small raised freckle-like spots on leaves and fruit.',
    overview:
        'Banana Freckle is associated with Phyllosticta fungi and can affect leaves and fruit. DOST-PCAARRD has documented banana freckles affecting Lakatan and Cardaba in Region XII, including areas in North Cotabato, Sultan Kudarat, and Maguindanao.',
    whyDangerous:
        'Freckle symptoms can reduce fruit appearance and crop quality. When spots increase across a block, farmers need stronger monitoring, sanitation, and good agricultural practices.',
    symptoms: [
      DiseaseSymptom(
        title: 'Raised dark spots',
        description:
            'Small dark raised spots can appear on leaves or fruit and may feel rough like sandpaper.',
        icon: Icons.scatter_plot_outlined,
      ),
      DiseaseSymptom(
        title: 'Fruit spotting',
        description:
            'On fruit, freckles may reduce visual quality even when the fruit is still usable.',
        icon: Icons.spa_outlined,
      ),
      DiseaseSymptom(
        title: 'Variety concern',
        description:
            'Philippine reports include affected Lakatan and Cardaba bananas.',
        icon: Icons.eco_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Fungal disease pressure',
        description:
            'Phyllosticta fungi can produce spotting symptoms when conditions favor disease development.',
        icon: Icons.agriculture_outlined,
      ),
      DiseaseCause(
        title: 'Poor sanitation',
        description:
            'Unmanaged field residues and weak field hygiene can contribute to pest and disease pressure.',
        icon: Icons.cleaning_services_outlined,
      ),
    ],
    prevention: [
      'Inspect Lakatan and Cardaba plants regularly for freckle-like spots',
      'Maintain field sanitation and remove problematic plant residues',
      'Use good agricultural practices recommended by local experts',
      'Monitor disease trends across affected blocks',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Good agricultural practices',
        steps: [
          'Improve sanitation and regular field monitoring',
          'Avoid moving suspect plant material between farms',
          'Consult local agriculture technicians for crop management guidance',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Freckle Philippines',
        channel: 'Search result',
        duration: 'Varies',
        searchQuery: 'banana freckle Philippines',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'Phyllosticta spp.'),
      DiseaseQuickFact(label: 'Common Sites', value: 'Leaves and fruit'),
      DiseaseQuickFact(label: 'Reported Varieties', value: 'Lakatan, Cardaba'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'AI Status', value: 'Guide only'),
    ],
    farmerTips: [
      'Record where freckle-like symptoms appear so recurring blocks can be monitored.',
      'Use local GAP guidance before applying any treatment program.',
    ],
    relatedIds: ['black_sigatoka', 'yellow_sigatoka'],
    searchKeywords: [
      'banana freckle',
      'banana freckles',
      'banana leaf spots',
      'lakatan freckle',
      'cardaba freckle',
    ],
    sources: [
      'DOST-PCAARRD - Good agricultural practices reduces pests and diseases of Lakatan and Cardaba',
      'Business Queensland - Freckle disease of banana',
      'International Plant Protection Convention - Phyllosticta cavendishii banana freckle pest report',
    ],
  );

  static const crownRot = DiseaseGuideItem(
    id: 'crown_rot',
    name: 'Banana Crown Rot',
    shortName: 'Crown Rot',
    category: DiseaseCategory.postharvest,
    risk: DiseaseRisk.moderate,
    imageUrl: 'assets/images/banana_crown_rot.jpg',
    fallbackAsset: _fallback,
    scientificName: 'Complex of postharvest fungal pathogens',
    isAiDetectable: false,
    modelLabel: null,
    summary:
        'A postharvest rot problem affecting the crown area of banana hands after harvest.',
    overview:
        'Banana Crown Rot is associated with postharvest deterioration and can involve a complex of fungal pathogens rather than one single cause. Philippine research has studied crown rot management in Cavendish bananas in Davao City and Bungulan bananas in Dumaguete.',
    whyDangerous:
        'Crown rot affects market quality after harvest. Poor sanitation, harvesting, handling, and storage practices can increase losses before fruit reaches buyers.',
    symptoms: [
      DiseaseSymptom(
        title: 'Crown discoloration',
        description:
            'The cut crown area of banana hands may darken and show rot development.',
        icon: Icons.change_history_outlined,
      ),
      DiseaseSymptom(
        title: 'Postharvest decay',
        description:
            'Rot may progress after harvest during handling, transport, or storage.',
        icon: Icons.inventory_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Pathogen complex',
        description:
            'Crown rot can involve multiple fungal pathogens rather than one single organism.',
        icon: Icons.biotech_outlined,
      ),
      DiseaseCause(
        title: 'Handling conditions',
        description:
            'Poor sanitation and rough handling can support postharvest deterioration.',
        icon: Icons.local_shipping_outlined,
      ),
    ],
    prevention: [
      'Harvest carefully and avoid unnecessary wounds',
      'Keep knives, trays, and packing areas clean',
      'Handle banana hands gently during transport and packing',
      'Follow recommended postharvest management practices',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Postharvest response',
        steps: [
          'Separate affected banana hands from clean produce',
          'Improve sanitation in harvest and packing operations',
          'Consult postharvest or agriculture specialists for locally approved management options',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Crown Rot Postharvest',
        channel: 'Search result',
        duration: 'Varies',
        searchQuery: 'banana crown rot banana postharvest',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Postharvest fungal rot'),
      DiseaseQuickFact(label: 'Common Site', value: 'Crown of banana hands'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'AI Status', value: 'Guide only'),
    ],
    farmerTips: [
      'Crown rot is mainly a postharvest issue, so field diagnosis alone is not enough.',
      'Cleaner harvest tools and gentler handling can reduce losses.',
    ],
    relatedIds: ['anthracnose', 'healthy_leaf'],
    searchKeywords: [
      'banana crown rot',
      'crown rot banana',
      'banana postharvest rot',
      'banana hand rot',
    ],
    sources: [
      'Philippine Center for Postharvest Development and Mechanization (PhilMech) - banana postharvest disease information',
      'ITFNet / PhilMech report - organic solution research for banana crown rot',
      'Plant Pathology - crown rot disease complex in banana',
    ],
  );

  static const weevilBorer = DiseaseGuideItem(
    id: 'weevil_borer',
    name: 'Banana Weevil Borer',
    shortName: 'Weevil Borer',
    category: DiseaseCategory.pest,
    risk: DiseaseRisk.moderate,
    imageUrl: 'assets/images/banana_weevil_borer.jpg',
    fallbackAsset: _fallback,
    scientificName: 'Cosmopolites sordidus',
    isAiDetectable: false,
    modelLabel: null,
    summary:
        'A banana insect pest whose larvae bore into the corm and lower pseudostem, weakening the plant.',
    overview:
        'Banana Weevil Borer, commonly associated with Cosmopolites sordidus, is included as a guide-only pest entry. The pest damages banana mainly through larval tunneling in the corm and lower pseudostem.',
    whyDangerous:
        'Weevil damage can weaken plant anchorage, reduce plant vigor, and contribute to smaller bunches or plant loss when infestations are not monitored and managed.',
    symptoms: [
      DiseaseSymptom(
        title: 'Weak plant growth',
        description:
            'Infested plants may show reduced vigor, yellowing leaves, poor sucker growth, or smaller bunches.',
        icon: Icons.trending_down,
      ),
      DiseaseSymptom(
        title: 'Corm tunneling',
        description:
            'Larvae can tunnel inside the corm and lower pseudostem, making damage hard to see from the outside.',
        icon: Icons.pest_control_outlined,
      ),
    ],
    causes: [
      DiseaseCause(
        title: 'Banana weevil infestation',
        description:
            'Adult weevils lay eggs near the plant base; larvae cause the main damage by boring into plant tissue.',
        icon: Icons.bug_report_outlined,
      ),
      DiseaseCause(
        title: 'Unmanaged farm residues',
        description:
            'Poor sanitation and heavily infested material can support pest buildup.',
        icon: Icons.delete_sweep_outlined,
      ),
    ],
    prevention: [
      'Monitor banana mats regularly for pest activity',
      'Maintain field sanitation and remove heavily infested material as advised',
      'Avoid moving infested planting material to clean areas',
      'Use good farm management and IPM practices',
      'Consult local agriculture technicians before using pest control products',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Integrated pest management',
        steps: [
          'Confirm the pest problem before treatment',
          'Remove or manage heavily infested material following local guidance',
          'Use locally recommended control practices and follow product label instructions when applicable',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana Weevil Borer Philippines',
        channel: 'Search result',
        duration: 'Varies',
        searchQuery: 'banana weevil borer Philippines',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Problem Type', value: 'Insect pest'),
      DiseaseQuickFact(label: 'Pest Name', value: 'Cosmopolites sordidus'),
      DiseaseQuickFact(label: 'Main Damage', value: 'Corm tunneling'),
      DiseaseQuickFact(label: 'Risk Level', value: 'Moderate'),
      DiseaseQuickFact(label: 'Management', value: 'IPM and sanitation'),
      DiseaseQuickFact(label: 'AI Status', value: 'Guide only'),
    ],
    farmerTips: [
      'This entry is pest-specific and should be used alongside the general Insect Pest guide.',
      'Avoid applying pesticides without confirming the pest and reading the product label.',
    ],
    relatedIds: ['insect_pest', 'bract_mosaic'],
    searchKeywords: [
      'banana weevil',
      'banana weevil borer',
      'weevil damage banana',
      'banana pest',
      'corm weevil',
    ],
    sources: [
      'DA Agricultural Training Institute banana IPM material',
      'Business Queensland - Banana weevil borer',
      'Plantwise Knowledge Bank - Banana Weevil: Cosmopolites sordidus',
    ],
  );
}
