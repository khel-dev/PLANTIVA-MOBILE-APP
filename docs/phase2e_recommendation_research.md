# PLANTIVA Phase 2E.1 Treatment and Recommendation Research Audit

Date: 2026-09-06

## Scope and verdict

This phase audited the existing treatment, prevention, and care content for the
eight scanner-supported classes. It did not change production code, Firebase,
the scanner, the TFLite models, scan saving, or the Disease Guide UI.

**Verdict: RESEARCH READY FOR PHASE 2E.2 UI IMPLEMENTATION**

The current screen correctly explains that classification confidence is not
biological severity. However, the recommendation copy needs a controlled local
content source before it is ready for farmer-facing production use. The most
important corrections are to remove blanket chemical instructions, avoid
unsupervised plant destruction, replace the exact bleach concentration, add
citations, and keep actions specific to the classifier's actual capability.

## 1. Current recommendation architecture

The active flow is:

1. `ResultScreen` receives the accepted classifier result.
2. `ScanDiagnosisHelper.aboutCondition()` and `recommendations()` select text
   through case-insensitive label matching.
3. `ScanHistoryService.recordScan()` calls `enrichResult()` and stores the
   generated summary and recommendations with the scan record.
4. `TreatmentRecommendationScreen` receives the generated text and adds its own
   label-based prevention/care tips.
5. Recent Scans opens the same Treatment screen using the stored scan summary
   and recommendations.
6. Scan Details and PDF export display `ScanRecord.effectiveRecommendations`.

### Current fields

The treatment screen currently receives:

- label
- confidence
- summary
- recommendation
- healthy state
- image path, image URL, or image base64
- optional saved scan ID

`ScanRecord` can also read legacy `severity` and `severityAction` fields, but
the current Result and Treatment screens explicitly state that confidence is
not severity and do not use confidence to intensify treatment.

### Content ownership problem

Treatment advice currently exists in two places:

- `lib/utils/scan_diagnosis_helper.dart`
- label-based `_careTips` in `treatment_recommendation_screen.dart`

The Disease Guide has newer, sourced content, but the Treatment screen does not
read its sources. This duplication allows recommendations to drift. Saved scans
may also preserve older recommendation strings even after local guidance is
improved.

## 2. Current recommendation findings by scanner class

| Scanner class | Current direction | Audit finding |
| --- | --- | --- |
| Black Sigatoka | Remove infected leaves, improve airflow, avoid overhead irrigation, seek local advice, follow fungicide labels | Partly defensible, but "remove and destroy all infected leaves" is too broad. The guide's fixed rainy-season spray timing is not tied to scouting, a registered label, or local advice. |
| Yellow Sigatoka | Apply fungicide, remove severely infected leaves, improve drainage, monitor | Too direct. It tells the user to apply a fungicide without diagnosis, product registration, label, or resistance-management context. |
| Panama Disease | Remove/destroy infected plants, do not replant, use resistant varieties, disinfect tools | The biosecurity direction is correct, but destruction and quarantine actions must follow BPI/LGU or plant-health authority guidance. Foliar fungicide must never be presented as a cure. |
| Moko Disease | Isolate, use 10% bleach, avoid wounds, report locally | Correctly treats Moko as bacterial, but the exact bleach concentration is unsupported in the selected Philippine sources and lacks product/contact-time/safety instructions. |
| Bract Mosaic Virus | Destroy plants, control aphids with insecticide, use clean material | Correctly says the virus has no chemical cure. Direct insecticide wording is too broad and does not establish a registered banana/aphid use. Removal should be authority-guided. |
| Bunchy Top Disease | Mark suspect mat, avoid suckers, seek MAO help, follow removal guidance, manage aphids | This is the safest current disease recommendation. It should emphasize that farmers should not disturb suspected plants before local guidance because handling can spread contaminated material or vectors. |
| Insect Pest Damage | Apply insecticide, remove leaves, use sticky traps, consider biological control | Unsafe and over-specific for a broad classifier. The model does not identify a pest species, and sticky traps or leaf removal are not appropriate for every banana pest. |
| Healthy Leaf | Monitor, maintain hygiene/drainage, scan again if symptoms develop | Appropriate overall. It must continue to state that one healthy-looking leaf does not prove that the plant, mat, roots, fruit, or farm is disease-free. |

## 3. Unsupported or questionable current statements

### High priority

- `Apply appropriate fungicide spray` for Yellow Sigatoka provides a chemical
  action before confirmation, label verification, or a monitoring-based plan.
- `Apply appropriate insecticide` for Insect Pest Damage is not justified
  because no pest species is identified.
- `Control aphid populations with insecticide` for Bract Mosaic does not verify
  a currently registered Philippine banana/aphid product.
- `Disinfect tools with 10% bleach solution` for Moko supplies an exact
  concentration without a preserved local protocol, product strength, contact
  time, PPE, or label.
- `Remove and destroy all infected leaves` for Black Sigatoka can cause
  excessive deleafing. Authoritative sources support targeted removal of
  diseased tissue as part of integrated management, not indiscriminate removal.
- `Remove infected plants` or `destroy infected plants completely` for Panama,
  Moko, and viral diseases should not be a stand-alone instruction. Suspected
  plants can be misdiagnosed, and containment/removal methods are locally
  regulated or technically sensitive.

### Medium priority

- `Start fungicide sprays before the rainy season peaks` is a calendar-style
  prompt without local monitoring thresholds, a current registered label, or
  resistance-management context.
- Sticky traps are presented as a general Insect Pest Damage response even
  though they do not monitor every pest that can damage banana leaves.
- `Avoid overhead irrigation` and waterlogging/drainage statements are
  reasonable general crop practices but should not be presented as sufficient
  disease treatment.
- Black and Yellow Sigatoka descriptions in `ScanDiagnosisHelper` use older
  scientific names. These are recognized synonyms, but the current names are
  `Pseudocercospora fijiensis` and `Pseudocercospora musae`.
- Moko is described as "Highly contagious." Clear spread pathways and actions
  are more useful and less fear-based than this wording.

### Presentation and traceability

- Treatment recommendations show no sources or source links.
- The screen mixes `recommendation` text with a second independent `_careTips`
  map, which can duplicate or contradict advice.
- Stored recommendation strings take precedence for old scans. A later content
  correction will not automatically correct already stored text.
- The raw model class says `Insect Pest Disease`, the category utility says
  `Insect Pest`, and the guide says `Insect Pest Damage`. Matching works today,
  but Phase 2E.2 should use one farmer-facing display name without changing the
  model label.

## 4. Chemical, product, dosage, and confidence audit

### Chemical and product claims currently present

The app mentions fungicide, insecticide, biological control, bleach, and
locally approved products. No commercial pesticide brand is currently named in
the treatment helper or Treatment screen.

### Dosages or frequencies currently present

- No agricultural pesticide application rate is present in the Treatment
  screen.
- The Moko recommendation contains `10% bleach solution`, which is an exact
  sanitation concentration and should be removed unless a complete current
  protocol is selected and cited.
- The Disease Guide contains a general pre-rainy-season spray instruction but
  no product-specific dose.

### Confidence and treatment intensity

Model confidence does **not** currently change recommendation intensity. The
screen displays confidence as classification certainty and explicitly says it
does not measure severity. Care tips are selected by disease label, not by the
confidence value. This behavior should be preserved.

## 5. Research-backed policy for each scanner class

The following is the approved research direction for Phase 2E.2. It is concise
enough for farmers but avoids turning an image classification into a confirmed
field diagnosis.

### 5.1 Black Sigatoka

**What it is:** A fungal leaf disease caused by `Pseudocercospora fijiensis`.
It reduces functional leaf area and can affect yield and fruit green life.

**Immediate actions**

- Mark the plant or block and inspect nearby leaves for similar streaks.
- Record symptoms and request confirmation when Black and Yellow Sigatoka are
  difficult to distinguish.
- Avoid moving suspect leaf material to clean areas.

**Management**

- Use targeted sanitation/deleafing, adequate spacing, drainage, and regular
  scouting as an integrated program.
- If a fungicide program is needed, use only products currently registered in
  the Philippines for banana and the target condition, follow the label, and
  obtain local technical advice.
- Resistance management requires appropriate mode-of-action alternation or
  mixtures according to the registered label and current technical guidance.

**Do not recommend:** A fixed spray calendar, a product from memory, removal of
all leaves, or a fungicide dose generated by the app.

**Seek help when:** Symptoms spread rapidly, identification is uncertain, or a
chemical program is being considered.

**Sources and supported claims**

- [Philippine Banana Industry Roadmap 2021-2025 - Department of Agriculture](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf): Philippine importance; removal of infected tissue, spacing, drainage, and the reality of fungicide use in commercial plantations.
- [Banana Group - Fungicide Resistance Action Committee](https://www.frac.info/frac-teams/working-groups/banana-group/): resistance-management principles for Black Sigatoka fungicides.
- [Registered Products - Philippine Fertilizer and Pesticide Authority](https://fpa.da.gov.ph/resources/reports/registered-products/): current registration and expiry must be checked before naming a product.

### 5.2 Yellow Sigatoka

**What it is:** A distinct fungal leaf spot caused by `Pseudocercospora musae`.
It is not an early stage of Black Sigatoka.

**Immediate actions**

- Inspect young and recently opened leaves and record the affected area.
- Increase monitoring in warm, wet conditions.
- Seek confirmation when lesions overlap with Black Sigatoka or other leaf
  spots.

**Management**

- Use timely, targeted deleafing and field sanitation to reduce inoculum.
- Maintain plant nutrition and drainage as supporting crop practices.
- Use chemical control only as part of an integrated, monitoring-based program
  with a currently registered product and label.

**Do not recommend:** Copying the Black Sigatoka text, automatic spraying after
one image, or an app-generated spray interval.

**Seek help when:** Leaf spot expands across the block, diagnosis is uncertain,
or fungicide resistance/product selection needs professional advice.

**Sources and supported claims**

- [Yellow Sigatoka - Australian Banana Growers' Council](https://abgc.org.au/yellow-sigatoka/): causal organism and distinguishing early yellow streaks.
- [Yellow Sigatoka management resources - Australian Banana Growers' Council](https://abgc.org.au/2019/04/18/hitting-the-right-spot-with-leaf-disease-management/): integrated monitoring and disease management.
- [Philippine Banana Production Manual - Department of Agriculture HVCDP](https://hvcdp.da.gov.ph/wp-content/uploads/2022/05/Banana-Production-Manual.pdf): Philippine Sigatoka sanitation, drainage, nutrition, and chemical-control context. The manual does not provide a sufficiently clear Black/Yellow distinction for app copy on its own.

### 5.3 Panama Disease / Fusarium Wilt

**What it is:** A soil-borne vascular wilt caused by the Fusarium wilt pathogen;
TR4 is an important Philippine banana biosecurity concern.

**Immediate actions**

- Treat the result as suspected, not confirmed.
- Mark the area, restrict unnecessary access, and avoid moving soil, water,
  footwear, tools, machinery, or planting material out of it.
- Contact the Municipal/City Agriculture Office, DA Regional Crop Protection
  Center, or BPI plant-health personnel for confirmation and instructions.

**Management**

- Use clean, certified or high-health planting material.
- Follow authority-directed containment and sanitation.
- Use locally suitable resistant or tolerant material only where supported by
  current local advice.

**Do not recommend:** Foliar fungicide as a cure, casual digging/removal,
unverified biological products, or replanting susceptible bananas without
technical assessment.

**Seek help when:** Any unexplained wilt or vascular discoloration appears. This
class warrants prompt professional confirmation because soil movement can
spread the pathogen.

**Sources and supported claims**

- [BPI Special Quarantine Administrative Order No. 01, s. 2012](https://elibrary.judiciary.gov.ph/thebookshelf/showdocs/10/50258): Philippine quarantine status and movement controls for Fusarium wilt.
- [TR4 Actions - FAO TR4 Global Network](https://www.fao.org/world-banana-forum/fusariumtr4/tr4-global-network/actions/en/): clean planting material, restricted movement, expert diagnosis, reporting, and farm biosecurity.
- [Philippine Banana Industry Roadmap 2021-2025 - Department of Agriculture](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf): importance of Fusarium wilt to Philippine production.

### 5.4 Moko Disease

**What it is:** A bacterial vascular wilt associated with the `Ralstonia`
species complex. It can spread through infected planting material and through
contaminated tools, soil, water, wounds, and some flower-visiting organisms.

**Immediate actions**

- Photograph and mark the suspect plant without cutting it unnecessarily.
- Restrict access and movement of planting material and contaminated tools.
- Request confirmation from local agriculture or plant-health personnel.

**Management**

- Use disease-free planting material and maintain strict tool hygiene.
- Follow locally directed removal, sanitation, debudding, or containment only
  after the diagnosis and protocol are confirmed.

**Do not recommend:** Fungal treatments, a generic pesticide, a stand-alone
bleach percentage, or farmer-led destruction without containment guidance.

**Seek help when:** Wilt, internal fruit/pseudostem discoloration, or bacterial
ooze is suspected, especially when nearby mats show symptoms.

**Sources and supported claims**

- [Sustainable Management of Moko and Bugtok Diseases of Banana - University of the Philippines Los Banos](https://www.ukdr.uplb.edu.ph/professorial_lectures/930/): Philippine sanitation, clean planting material, tool disinfection, monitoring, and infected-mat management research.
- [Blood and Moko Diseases of Banana - Australian Department of Agriculture](https://www.agriculture.gov.au/biosecurity-trade/pests-diseases-weeds/plant/identify/blood-and-moko-diseases-banana): symptoms, spread pathways, non-disturbance, and reporting principles.
- [Philippine Banana Industry Roadmap 2021-2025 - Department of Agriculture](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf): Moko as an economically important Philippine banana disease.

### 5.5 Banana Bract Mosaic Virus

**What it is:** A viral banana disease transmitted by aphids and spread over
longer distances through infected planting material. A pesticide cannot cure an
infected plant.

**Immediate actions**

- Mark and isolate the suspect mat.
- Do not take suckers, corms, or other planting material from it.
- Monitor neighboring plants and request diagnostic confirmation.

**Management**

- Use indexed/high-health planting material.
- Follow local guidance for infected-plant removal and sanitation.
- Manage confirmed aphid vectors through IPM and only with a registered product
  if chemical control is locally advised.

**Do not recommend:** A chemical cure for the virus or an unspecified aphid
insecticide based only on the image result.

**Seek help when:** Mosaic/streak symptoms occur across plants or before any
plant removal or vector-control program.

**Sources and supported claims**

- [Philippine Banana Industry Roadmap 2021-2025 - Department of Agriculture](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf): Philippine symptoms, aphid/planting-material spread, early detection, removal, and clean planting material.
- [Banana Bract Mosaic Virus - NSW Department of Primary Industries](https://www.dpird.nsw.gov.au/dpi/biosecurity/plant-biosecurity/insect-pests-plant-diseases/banana-bract-mosaic-virus): vectors, spread, monitoring, isolation, hygiene, and high-health propagation material.

### 5.6 Banana Bunchy Top Disease

**What it is:** A systemic viral disease caused by BBTV, spread mainly by banana
aphids and infected banana planting material. Infected plants have no curative
field treatment.

**Immediate actions**

- Mark the suspect plant and do not take suckers from the mat.
- Avoid cutting, disturbing, or moving suspect plant material until local
  guidance is received.
- Contact the Municipal/City Agriculture Office or a crop protection technician.

**Management**

- Use disease-free or indexed tissue-culture planting material.
- Follow official removal and vector-management instructions after confirmation.
- Monitor nearby plants for dot-dash streaking, stunting, and upright bunched
  leaves.

**Do not recommend:** A curative pesticide, unsupervised rogueing, or insecticide
without local IPM and current label verification.

**Seek help when:** Characteristic symptoms are seen or a suspect plant may be a
source of propagation material.

**Sources and supported claims**

- [Philippine Banana Industry Roadmap 2021-2025 - Department of Agriculture](https://www.da.gov.ph/wp-content/uploads/2023/05/Philippine-Banana-Industry-Roadmap.pdf): Philippine BBTV importance, aphid transmission, tissue-culture planting material, and infected-plant management.
- [Banana Bunchy Top Virus - Queensland Government](https://www.business.qld.gov.au/industries/farms-fishing-forestry/agriculture/biosecurity/plants/priority-pest-disease/banana-bunchy-top): no cure, symptom recognition, planting-material spread, non-disturbance, and trained-inspector action. Queensland legal requirements must not be presented as Philippine law.

### 5.7 Insect Pest Damage

The screen must begin with:

> PLANTIVA detected visual damage consistent with its broad Insect Pest Damage category.

**What it means:** The model has not identified an insect species. Similar leaf
damage can have different causes, and pest identity must be confirmed before a
targeted action is selected.

**Immediate actions**

- Inspect both leaf surfaces, the pseudostem, petioles, bunch, and nearby plants.
- Look for an actual insect, eggs, larvae, frass, webbing, tunnels, or a repeated
  damage pattern.
- Photograph the pest and affected plant parts separately if possible.

**Management**

- Use IPM: identify and monitor first, preserve beneficial organisms, improve
  sanitation, and choose a targeted control only when justified.
- If pest identity remains uncertain, bring evidence to the Municipal/City
  Agriculture Office or DA technician.
- A pesticide can be considered only after the pest and banana use are matched
  to a current FPA registration and product label.

**Do not recommend:** A pest-specific pesticide, sticky trap, leaf removal, or
biological control as a universal response to the classifier category.

**Seek help when:** The pest cannot be identified, damage spreads, the growing
point or bunch is affected, or pesticide use is being considered.

**Sources and supported claims**

- [Banana Integrated Pest Management Course - DA Agricultural Training Institute](https://ati2.da.gov.ph/ati-main/content/article/ladylyn-jose/new-e-learning-course-banana-integrated-pest-management): Philippine farmer learning pathway for banana IPM.
- [Pesticide Management in the Banana Industry - FAO World Banana Forum](https://www.fao.org/world-banana-forum/projects/good-practices/pesticide-management/en/): monitoring, non-chemical measures, IPM, legal product selection, PPE, and safe handling.
- [Registered Products - Philippine Fertilizer and Pesticide Authority](https://fpa.da.gov.ph/resources/reports/registered-products/): official current product/crop/target registration checks.

### 5.8 Healthy Leaf

**What it means:** The submitted leaf matched the Healthy Leaf class and did not
show a reliable visual pattern for the other seven supported classes. This is
not proof that the entire plant or field is disease-free.

**Immediate actions**

- Keep the scan as a visual reference and continue routine field inspection.
- Check the whole plant, including newer leaves, pseudostem, roots, fruit, and
  neighboring mats.

**Management and prevention**

- Maintain farm sanitation and clean tools.
- Use high-health planting material.
- Manage water and nutrition based on field conditions and local guidance.
- Continue monitoring, especially after stress, storms, or visible changes.

**Do not recommend:** Routine fungicide, insecticide, fertilizer, or a guarantee
that the farm is healthy.

**Seek help when:** The plant declines, wilts, produces abnormal fruit, or shows
symptoms outside the photographed leaf despite a Healthy Leaf result.

**Sources and supported claims**

- [Code of Good Agricultural Practice for Banana Production - Philippine BAFS](https://bafs.da.gov.ph/index.php/code-of-good-agricultural-practice-gap-for-banana-production/): Philippine farm, food-safety, environmental, and worker-safety framework.
- [Good Agricultural Practices for Bananas - FAO World Banana Forum](https://www.fao.org/world-banana-forum/projects/good-practices/good-agricultural-practices/en/): monitoring, clean planting material, water/soil management, IPM, and responsible crop protection.

## 6. Product recommendation feasibility

The Philippine FPA maintains lists containing product name, active ingredient,
target crop, target pest/disease, registration number, and expiry date. This
makes verified product information technically possible, but not safe as a
one-time static list:

- registrations can expire, change, be suspended, or be restricted;
- a product registered for one banana pest is not valid for the broad Insect
  Pest Damage category;
- product choice also depends on cultivar, production system, resistance
  strategy, application method, PPE, re-entry interval, and local conditions;
- a scan is not a confirmed diagnosis.

**Phase 2E.2 policy:** Do not add commercial product cards yet. Display:

> Use only products currently registered by the Philippine Fertilizer and
> Pesticide Authority for banana and the confirmed target condition. Follow the
> current product label and local agriculture guidance.

If product cards are considered in a later phase, every entry must preserve the
FPA source, registration number, crop, target, expiry date, label date, and a
content-review date. Expired or unverifiable entries must not be recommended.

## 7. Product image recommendation

Recommended order:

1. Prefer no product image in Phase 2E.2 because no product should be endorsed
   yet.
2. If verified product cards are added later, use a local asset only after image
   ownership or reuse permission is documented and the product registration is
   current.
3. Use a remote government/manufacturer image only when hotlinking permission,
   URL stability, and product identity are verified.

Do not scrape Google Images. Remote product images add copyright, availability,
tracking, and stale-label risks. Generic local illustrations for actions such as
scouting, cleaning tools, isolating an area, or consulting an expert are safer
than package photographs.

## 8. Dosage policy

- PLANTIVA must not generate, simplify, translate, or infer a pesticide rate.
- A rate may be displayed only when copied from a current authoritative product
  label that is registered for the exact crop and confirmed target, with the
  source and review date retained.
- The app must not calculate tank mixes from a scan result.
- Users should be directed to the current label, PPE, re-entry interval,
  pre-harvest interval, and trained/local guidance.
- Sanitizer concentrations should follow the same rule: include one only with a
  complete, applicable protocol and safe handling instructions. Otherwise say
  to clean and disinfect tools according to local plant-health guidance and the
  disinfectant label.

## 9. Philippine-specific sources found

- Department of Agriculture, Philippine Banana Industry Roadmap 2021-2025
- Department of Agriculture HVCDP, Banana Production Manual
- Bureau of Agriculture and Fisheries Standards, Philippine GAP for Banana
- Bureau of Plant Industry, Panama Disease quarantine order
- Fertilizer and Pesticide Authority, current registered-product reports
- Agricultural Training Institute, banana disease and IPM learning courses
- DOST-PCAARRD banana industry and Fusarium wilt programs
- University of the Philippines Los Banos, Moko/Bugtok management research

These sources provide strong Philippine context, but not every current app claim
has a sufficiently specific current Philippine protocol.

## 10. Claims not sufficiently verified for app use

- The exact `10% bleach solution` instruction for Moko.
- A universal sticky-trap recommendation for the broad insect category.
- A universal insecticide for Bract Mosaic vectors or Insect Pest Damage.
- A fixed pre-rainy-season or calendar fungicide schedule for either Sigatoka
  class in all Philippine production systems.
- A product-specific dose that can safely be shown without a current label and
  registration review.
- A universal farmer-executed destruction method for suspected Panama, Moko,
  Bunchy Top, or Bract Mosaic plants.
- A single resistant Panama cultivar recommendation suitable for all Philippine
  cultivars, regions, markets, and pathogen races.
- Any Philippine legal duty copied from Queensland, NSW, Australian, Brazilian,
  or Mexican biosecurity rules. International sources support biological and
  management principles, not Philippine legal claims.

## 11. Proposed Phase 2E.2 content structure

Use one static, versioned local guidance record per normalized scanner class:

- `displayName`
- `classificationScope`
- `immediateActions`
- `management`
- `prevention`
- `whenToSeekHelp`
- `importantNote`
- `sources` containing title, organization, direct URL, and supported claims
- `lastReviewedAt`

Display order:

1. Image-based screening notice
2. Immediate Actions
3. Management
4. Prevention and Monitoring
5. When to Seek Help
6. Important Safety Note
7. Sources

Keep paragraphs short and use action lists. Do not show High/Moderate/Low,
countdowns, or treatment urgency derived from confidence.

### Backward-compatible saved-scan policy

For a saved scan, select current guidance from the normalized disease class so
old unsafe text does not remain the primary recommendation. Preserve stored
recommendation data for backward compatibility, but do not rewrite or delete
Firestore records in Phase 2E.2. The legacy text can remain a fallback only when
no recognized local guidance record exists.

## 12. Protected-system confirmation

- Production code changed in Phase 2E.1: **NO**
- Research document added: **YES - this file only**
- Firebase Storage diff: **NONE**
- Firestore/Auth diff: **NONE**
- AI/scanner diff: **NONE**
- TFLite/model/labels diff: **NONE**
- Scan saving diff: **NONE**
- Disease Guide UI diff from Phase 2E.1: **NONE**
- Analytics diff: **NONE**

