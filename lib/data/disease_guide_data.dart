import 'package:flutter/material.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';

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
    imageUrl: 'assets/images/black_sigatoka.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Black Sigatoka Disease',
    summary:
        'A serious fungal leaf spot disease that damages green leaf area and can substantially reduce banana yield and fruit quality.',
    overview:
        'Black Sigatoka, also called black leaf streak, is caused by Pseudocercospora fijiensis (formerly Mycosphaerella fijiensis). It is distinct from Yellow Sigatoka and is favored by wet, humid conditions.',
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
      'Remove heavily affected leaf tissue using locally recommended sanitation practices',
      'Maintain spacing for good air circulation',
      'Use disease-free planting material',
      'Monitor fields regularly, especially during wet weather',
      'Use fungicides only when locally recommended and follow the product label',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Initial management steps',
        steps: [
          'Identify and flag heavily infected mats',
          'Remove the worst-affected leaf tissue using safe field sanitation',
          'Ask an agriculture technician to confirm the disease before starting a spray program',
        ],
      ),
      DiseaseTreatment(
        title: 'Ongoing management',
        steps: [
          'Improve drainage in waterlogged areas',
          'Keep records of new lesions and affected blocks',
          'If fungicide is advised, rotate modes of action and follow local labels',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Black Sigatoka identification and field information',
        channel: 'Queensland Government',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/black-sigatoka-banana',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Wind & rain'),
      DiseaseQuickFact(label: 'Main Site', value: 'Leaves'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Inspect the underside of leaves early in the morning when dew reveals streaks.',
      'Always disinfect cutting tools between plants.',
      'Use scouting records and local technical advice before starting any spray program.',
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
    sources: [
      DiseaseSource(
        name: 'Queensland Government - Black sigatoka of banana',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/black-sigatoka-banana',
      ),
      DiseaseSource(
        name: 'ProMusa - Black leaf streak',
        url: 'https://www.promusa.org/Black%2Bleaf%2Bstreak',
      ),
    ],
  );

  static const yellowSigatoka = DiseaseGuideItem(
    id: 'yellow_sigatoka',
    name: 'Banana Yellow Sigatoka Disease',
    shortName: 'Yellow Sigatoka',
    category: DiseaseCategory.fungal,
    imageUrl: 'assets/images/yellow_sigatoka.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Yellow Sigatoka Disease',
    summary:
        'A fungal leaf spot disease that begins with yellow-green streaks and is distinct from Black Sigatoka.',
    overview:
        'Yellow Sigatoka is caused by Pseudocercospora musae (formerly Mycosphaerella musicola). Its early yellow-green streaks are usually more visible on the upper leaf surface, while laboratory testing may be needed to distinguish mature lesions from related leaf spots.',
    whyDangerous:
        'When many lesions develop, usable green leaf area declines and fruit filling and quality can be affected. It should not be treated as an early stage of Black Sigatoka.',
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
      'Inspect young and recently opened leaves regularly',
      'Remove infected leaf tissue early',
      'Avoid overhead irrigation where possible',
      'Maintain balanced plant nutrition',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Field response',
        steps: [
          'Record where yellow-green streaks and mature lesions occur',
          'Increase scouting during humid or rainy periods',
          'Seek local diagnosis before applying a disease-control product',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Yellow Sigatoka field guide',
        channel: 'Australian Banana Growers\' Council',
        url: 'https://abgc.org.au/yellow-sigatoka/',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Wind & rain'),
      DiseaseQuickFact(label: 'Main Site', value: 'Leaves'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Check the upper surface of younger leaves for early yellow-green streaks.',
      'Do not assume every mature Sigatoka-like lesion can be identified by appearance alone.',
    ],
    relatedIds: ['black_sigatoka', 'healthy_leaf'],
    searchKeywords: [
      'yellow sigatoka',
      'streaks',
      'yellow',
      'fungal',
      'musicola'
    ],
    sources: [
      DiseaseSource(
        name: 'Australian Banana Growers\' Council - Yellow Sigatoka',
        url: 'https://abgc.org.au/yellow-sigatoka/',
      ),
      DiseaseSource(
        name: 'CIRAD - The Sigatoka leaf disease complex in banana',
        url: 'https://publications.cirad.fr/une_notice.php?dk=609616',
      ),
    ],
  );

  static const panama = DiseaseGuideItem(
    id: 'panama',
    name: 'Banana Panama Disease',
    shortName: 'Panama Disease',
    category: DiseaseCategory.fungal,
    imageUrl: 'assets/images/panama_disease.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Panama Disease',
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
          'Consult local plant-health authorities before removing suspected plants',
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
        title: 'Fusarium TR4 basics and farm protection',
        channel: 'Food and Agriculture Organization',
        url: 'https://www.fao.org/tr4gn/tr4-basics/en/',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal wilt'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Soil & tools'),
      DiseaseQuickFact(label: 'Main Site', value: 'Vascular tissue'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
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
    sources: [
      DiseaseSource(
        name: 'FAO TR4 Global Network - TR4 basics',
        url: 'https://www.fao.org/tr4gn/tr4-basics/en/',
      ),
      DiseaseSource(
        name: 'Queensland Government - Panama disease tropical race 4',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/panama-disease',
      ),
    ],
  );

  static const moko = DiseaseGuideItem(
    id: 'moko',
    name: 'Banana Moko Disease',
    shortName: 'Moko Disease',
    category: DiseaseCategory.bacterial,
    imageUrl: 'assets/images/moko_disease.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Moko Disease',
    summary:
        'A highly contagious bacterial wilt that causes rapid collapse of banana plants.',
    overview:
        'Moko disease is caused by Ralstonia solanacearum. It spreads through insects, tools, and infected planting material, causing internal browning and sudden wilt.',
    whyDangerous:
        'Bacteria multiply quickly inside the plant, and an infected mat can spread the disease to neighboring plants without appropriate control.',
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
        description:
            'Ralstonia bacteria invade vascular tissue and may enter through wounds or roots.',
        icon: Icons.biotech_outlined,
      ),
      DiseaseCause(
        title: 'Short-distance spread',
        description:
            'Flower-visiting insects, contaminated tools, soil, and water can move bacteria between plants.',
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
      'Clean and disinfect cutting tools between plants',
      'Reduce avoidable wounds and follow local sanitation guidance',
      'Avoid wounding plants during field work',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Response guidance',
        steps: [
          'Follow local plant-health authority guidance for confirmed infected mats and do not compost suspect material',
          'Quarantine a buffer zone around the outbreak',
          'Report to local plant quarantine authorities',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Blood and Moko diseases of banana',
        channel: 'Australian Department of Agriculture',
        url:
            'https://www.agriculture.gov.au/biosecurity-trade/pests-diseases-weeds/plant/identify/blood-and-moko-diseases-banana',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Bacterial'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Tools & insects'),
      DiseaseQuickFact(label: 'Main Site', value: 'Vascular tissue'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Mark and isolate suspected plants while requesting professional confirmation.',
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
    sources: [
      DiseaseSource(
        name: 'Australian Department of Agriculture - Blood and Moko diseases',
        url:
            'https://www.agriculture.gov.au/biosecurity-trade/pests-diseases-weeds/plant/identify/blood-and-moko-diseases-banana',
      ),
      DiseaseSource(
        name: 'SENASICA - Moko disease of banana',
        url: 'https://www.gob.mx/senasica/documentos/moko-del-platano',
      ),
    ],
  );

  static const bractMosaic = DiseaseGuideItem(
    id: 'bract_mosaic',
    name: 'Banana Bract Mosaic Virus Disease',
    shortName: 'Bract Mosaic Virus',
    category: DiseaseCategory.viral,
    imageUrl: 'assets/images/bract_mosaic_virus.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Bract Mosaic Virus Disease',
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
          'Continue monitoring neighboring plants for symptoms',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Banana bract mosaic virus identification',
        channel: 'NSW Department of Primary Industries',
        url:
            'https://www.dpird.nsw.gov.au/dpi/biosecurity/plant-biosecurity/insect-pests-plant-diseases/banana-bract-mosaic-virus',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Viral'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Aphids'),
      DiseaseQuickFact(label: 'Field Cure', value: 'None'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Mosaic patterns are easiest to spot in partial shade — inspect then.',
      'Plant virus-free tissue culture plants when replanting.',
    ],
    relatedIds: ['insect_pest', 'healthy_leaf'],
    searchKeywords: ['mosaic', 'virus', 'bract', 'aphid', 'bbmv', 'pattern'],
    sources: [
      DiseaseSource(
        name:
            'NSW Department of Primary Industries - Banana bract mosaic virus',
        url:
            'https://www.dpird.nsw.gov.au/dpi/biosecurity/plant-biosecurity/insect-pests-plant-diseases/banana-bract-mosaic-virus',
      ),
      DiseaseSource(
        name: 'DOST-PCAARRD - Banana bract mosaic disease R&D program',
        url:
            'https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/dost-pcaarrd-launches-r-d-program-against-banana-bract-mosaic-disease',
      ),
    ],
  );

  static const insectPest = DiseaseGuideItem(
    id: 'insect_pest',
    name: 'Banana Insect Pest Damage',
    shortName: 'Insect Pest Damage',
    category: DiseaseCategory.pest,
    imageUrl: 'assets/images/insect_pest_damage.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Insect Pest Disease',
    summary:
        'A broad scan category for visible banana-leaf damage that may be consistent with insect feeding.',
    overview:
        'PLANTIVA detects visual damage consistent with its broad Insect Pest Damage category. It does not identify a specific insect species. Closer inspection of the plant, pest, and affected area may be needed before choosing management.',
    whyDangerous:
        'Heavy feeding can reduce useful leaf area or plant vigor, while some banana pests can also spread plant pathogens. The likely pest must be confirmed before treatment.',
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
        title: 'Possible insect feeding',
        description:
            'Chewing, scraping, or sap-feeding insects are examples, but the scan result alone cannot name the pest.',
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
        title: 'Banana Integrated Pest Management learning course',
        channel: 'DA Agricultural Training Institute',
        url:
            'https://ati2.da.gov.ph/ati-main/content/article/ladylyn-jose/new-e-learning-course-banana-integrated-pest-management',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Category Type', value: 'Broad pest damage'),
      DiseaseQuickFact(label: 'Species Result', value: 'Not identified'),
      DiseaseQuickFact(label: 'Next Step', value: 'Inspect the plant'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Check leaf undersides — most banana pests hide there.',
      'Photograph any insect, eggs, or tunneling separately for an agriculture technician.',
      'Do not select a pesticide based only on the PLANTIVA category.',
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
    sources: [
      DiseaseSource(
        name:
            'DA Agricultural Training Institute - Banana Integrated Pest Management',
        url:
            'https://ati2.da.gov.ph/ati-main/content/article/ladylyn-jose/new-e-learning-course-banana-integrated-pest-management',
      ),
      DiseaseSource(
        name: 'FAO World Banana Forum - Pesticide management and IPM',
        url:
            'https://www.fao.org/world-banana-forum/projects/good-practices/pesticide-management/en/',
      ),
    ],
  );

  static const healthyLeaf = DiseaseGuideItem(
    id: 'healthy_leaf',
    name: 'Healthy Banana Leaf',
    shortName: 'Healthy Leaf',
    category: DiseaseCategory.healthy,
    imageUrl: 'assets/images/healthy_banana_leaf.jpg',
    fallbackAsset: _fallback,
    modelLabel: 'Augmented Banana Healthy Leaf',
    summary:
        'A banana leaf with no obvious visual pattern from the seven disease or damage classes supported by the scanner.',
    overview:
        'A healthy-looking banana leaf is generally green and functional without obvious disease lesions, strong mosaic patterns, or serious pest damage. A single image cannot confirm the health of roots, fruit, soil, or the whole mat, so routine field monitoring remains important.',
    whyDangerous:
        'Healthy Leaf is not a disease diagnosis. It means the image did not show a reliable visual pattern for the disease and damage classes recognized by PLANTIVA.',
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
        title: 'Regular monitoring',
        description:
            'Field observation helps farmers notice changes that one leaf image may not show.',
        icon: Icons.shield_outlined,
      ),
    ],
    prevention: [
      'Continue regular whole-plant and field inspection',
      'Maintain field sanitation',
      'Base fertilizer decisions on local recommendations and soil needs',
      'Monitor for early disease signs on border plants',
      'Keep tools clean between plants',
    ],
    treatments: [
      DiseaseTreatment(
        title: 'Maintaining health',
        steps: [
          'Use healthy-looking scans as one observation in your field records',
          'Compare changes over time while also checking the whole plant',
          'Consult an agriculture technician if plants decline despite healthy-looking leaves',
        ],
      ),
    ],
    videos: [
      DiseaseVideo(
        title: 'Good agricultural practices for bananas',
        channel: 'FAO World Banana Forum',
        url:
            'https://www.fao.org/world-banana-forum/projects/good-practices/good-agricultural-practices/en/',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Category Type', value: 'Healthy reference'),
      DiseaseQuickFact(label: 'Disease', value: 'No'),
      DiseaseQuickFact(label: 'Scope', value: 'Visible leaf only'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
    ],
    farmerTips: [
      'Use healthy leaves as your comparison standard when scouting.',
      'Do not spray fungicide only because a scan was classified as Healthy Leaf.',
      'Check roots, pseudostem, fruit, and nearby plants when assessing crop health.',
    ],
    relatedIds: ['black_sigatoka', 'yellow_sigatoka'],
    searchKeywords: ['healthy', 'green', 'normal', 'baseline', 'no disease'],
    sources: [
      DiseaseSource(
        name:
            'FAO World Banana Forum - Good agricultural practices for bananas',
        url:
            'https://www.fao.org/world-banana-forum/projects/good-practices/good-agricultural-practices/en/',
      ),
      DiseaseSource(
        name: 'Philippine Bureau of Plant Industry - Banana Production Guide',
        url: 'https://buplant.da.gov.ph/production-guide/',
      ),
    ],
  );

  static const bunchyTop = DiseaseGuideItem(
    id: 'bunchy_top',
    name: 'Banana Bunchy Top Disease',
    shortName: 'Bunchy Top',
    category: DiseaseCategory.viral,
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
        icon: Icons.eco_outlined,
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
        title: 'Banana bunchy top identification and spread',
        channel: 'Queensland Government',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-bunchy-top',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Viral'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'BBTV'),
      DiseaseQuickFact(label: 'Spread Method', value: 'Banana aphid'),
      DiseaseQuickFact(label: 'Planting Risk', value: 'Infected suckers'),
      DiseaseQuickFact(label: 'AI Status', value: 'Scan supported'),
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
      DiseaseSource(
        name: 'Queensland Government - Banana bunchy top virus',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-bunchy-top',
      ),
      DiseaseSource(
        name: 'DOST-PCAARRD - GAP for Lakatan and Cardaba',
        url:
            'https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/good-agricultural-practices-gap-reduces-pests-and-diseases-of-lakatan-and-cardaba',
      ),
    ],
  );

  static const anthracnose = DiseaseGuideItem(
    id: 'anthracnose',
    name: 'Banana Anthracnose',
    shortName: 'Anthracnose',
    category: DiseaseCategory.fungal,
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
        title: 'Banana anthracnose symptoms and postharvest information',
        channel: 'Tamil Nadu Agricultural University',
        url:
            'https://agritech.tnau.ac.in/crop_protection/crop_diseases_postharvest_banana_1.html',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'Colletotrichum spp.'),
      DiseaseQuickFact(label: 'Common Site', value: 'Fruit'),
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
      DiseaseSource(
        name: 'TNAU Agritech Portal - Banana postharvest anthracnose',
        url:
            'https://agritech.tnau.ac.in/crop_protection/crop_diseases_postharvest_banana_1.html',
      ),
      DiseaseSource(
        name: 'UC Davis Postharvest Center - Banana produce facts',
        url: 'https://postharvest.ucdavis.edu/produce-facts-sheets/banana',
      ),
    ],
  );

  static const bananaFreckle = DiseaseGuideItem(
    id: 'banana_freckle',
    name: 'Banana Freckle',
    shortName: 'Banana Freckle',
    category: DiseaseCategory.fungal,
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
        title: 'Banana freckle identification and biosecurity',
        channel: 'Queensland Government',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-freckle',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Fungal'),
      DiseaseQuickFact(label: 'Causal Agent', value: 'Phyllosticta spp.'),
      DiseaseQuickFact(label: 'Common Sites', value: 'Leaves and fruit'),
      DiseaseQuickFact(label: 'Reported Varieties', value: 'Lakatan, Cardaba'),
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
      DiseaseSource(
        name: 'DOST-PCAARRD - GAP for Lakatan and Cardaba',
        url:
            'https://www.pcaarrd.dost.gov.ph/index.php/quick-information-dispatch-qid-articles/good-agricultural-practices-gap-reduces-pests-and-diseases-of-lakatan-and-cardaba',
      ),
      DiseaseSource(
        name: 'Queensland Government - Freckle disease of banana',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-freckle',
      ),
    ],
  );

  static const crownRot = DiseaseGuideItem(
    id: 'crown_rot',
    name: 'Banana Crown Rot',
    shortName: 'Crown Rot',
    category: DiseaseCategory.postharvest,
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
        title: 'Banana postharvest disorders and crown rot',
        channel: 'UC Davis Postharvest Center',
        url: 'https://postharvest.ucdavis.edu/produce-facts-sheets/banana',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Disease Type', value: 'Postharvest fungal rot'),
      DiseaseQuickFact(label: 'Common Site', value: 'Crown of banana hands'),
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
      DiseaseSource(
        name: 'UC Davis Postharvest Center - Banana produce facts',
        url: 'https://postharvest.ucdavis.edu/produce-facts-sheets/banana',
      ),
      DiseaseSource(
        name: 'TNAU Agritech Portal - Banana crown rot',
        url:
            'https://agritech.tnau.ac.in/crop_protection/crop_diseases_postharvest_banana_3.html',
      ),
    ],
  );

  static const weevilBorer = DiseaseGuideItem(
    id: 'weevil_borer',
    name: 'Banana Weevil Borer',
    shortName: 'Weevil Borer',
    category: DiseaseCategory.pest,
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
        title: 'Banana weevil borer identification and management',
        channel: 'Queensland Government',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/insects/horticultural/banana-weevil-borer',
      ),
    ],
    quickFacts: [
      DiseaseQuickFact(label: 'Problem Type', value: 'Insect pest'),
      DiseaseQuickFact(label: 'Pest Name', value: 'Cosmopolites sordidus'),
      DiseaseQuickFact(label: 'Main Damage', value: 'Corm tunneling'),
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
      DiseaseSource(
        name: 'Queensland Government - Banana weevil borer',
        url:
            'https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/insects/horticultural/banana-weevil-borer',
      ),
      DiseaseSource(
        name:
            'DA Agricultural Training Institute - Banana Integrated Pest Management',
        url:
            'https://ati2.da.gov.ph/ati-main/content/article/ladylyn-jose/new-e-learning-course-banana-integrated-pest-management',
      ),
    ],
  );
}
