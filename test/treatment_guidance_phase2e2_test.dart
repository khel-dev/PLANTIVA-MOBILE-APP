import 'package:flutter/material.dart';
import 'package:flutter_plantiva/data/treatment_guidance_data.dart';
import 'package:flutter_plantiva/models/scan_record.dart';
import 'package:flutter_plantiva/screens/treatment_recommendation_screen.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expectedClasses = {
    'Black Sigatoka',
    'Bract Mosaic Virus',
    'Bunchy Top Disease',
    'Healthy Leaf',
    'Insect Pest Damage',
    'Moko Disease',
    'Panama Disease',
    'Yellow Sigatoka',
  };

  test('contains exactly eight complete and uniquely keyed guidance records',
      () {
    expect(TreatmentGuidanceData.all, hasLength(8));
    expect(
      TreatmentGuidanceData.all.map((item) => item.normalizedClass).toSet(),
      expectedClasses,
    );
    expect(
      TreatmentGuidanceData.all.map((item) => item.id).toSet(),
      hasLength(8),
    );

    for (final item in TreatmentGuidanceData.all) {
      expect(item.immediateActions, isNotEmpty, reason: item.normalizedClass);
      expect(item.management, isNotEmpty, reason: item.normalizedClass);
      expect(item.prevention, isNotEmpty, reason: item.normalizedClass);
      expect(item.whenToSeekHelp, isNotEmpty, reason: item.normalizedClass);
      expect(item.sources, isNotEmpty, reason: item.normalizedClass);
      expect(item.sources.every((source) => source.uri != null), isTrue);
    }
  });

  test('healthy and broad-category guidance use safe scope statements', () {
    final healthy = TreatmentGuidanceData.resolve('Banana Healthy Leaf');
    final insect = TreatmentGuidanceData.resolve(
      'Augmented Banana Insect Pest Disease',
    );

    expect(healthy.isHealthy, isTrue);
    expect(healthy.title.toLowerCase(), isNot(contains('treatment')));
    expect(healthy.plainText.toLowerCase(), isNot(contains('fungicide')));
    expect(healthy.importantNote, contains('scanned leaf'));
    expect(insect.isBroadCategory, isTrue);
    expect(insect.summary, contains('exact insect cannot be identified'));
    expect(insect.importantNote.toLowerCase(),
        contains('not a pest identification'));
  });

  test('guidance excludes unsafe fixed directions and fake severity', () {
    final prohibited = RegExp(
      r'\b(?:high|moderate|low) severity\b|10% bleach|apply appropriate (?:fungicide|insecticide)|sticky traps',
      caseSensitive: false,
    );

    for (final item in TreatmentGuidanceData.all) {
      final copy = [
        item.title,
        item.summary,
        ...item.immediateActions,
        ...item.management,
        ...item.prevention,
        ...item.whenToSeekHelp,
        item.importantNote,
      ].join(' ');
      expect(prohibited.hasMatch(copy), isFalse, reason: item.normalizedClass);
    }
  });

  test('viral and Panama records do not claim a chemical cure', () {
    for (final label in [
      'Bract Mosaic Virus',
      'Bunchy Top Disease',
      'Panama Disease',
    ]) {
      final copy = TreatmentGuidanceData.resolve(label).plainText.toLowerCase();
      expect(copy, isNot(contains('apply fungicide')), reason: label);
      expect(copy, isNot(contains('apply insecticide')), reason: label);
    }
    expect(
      TreatmentGuidanceData.resolve('Panama Disease').importantNote,
      contains('not a cure'),
    );
  });

  test('aliases resolve without confidence-dependent guidance', () {
    expect(
      TreatmentGuidanceData.resolve('BBTD').normalizedClass,
      'Bunchy Top Disease',
    );
    expect(
      TreatmentGuidanceData.resolve('Banana Bunchy Top Virus').id,
      TreatmentGuidanceData.resolve('Bunchy Top Disease').id,
    );
  });

  test('saved scans prefer current guidance without rewriting legacy data', () {
    const stale = ScanRecord(
      id: 'legacy-scan',
      label: 'Banana Yellow Sigatoka Disease',
      category: 'Yellow Sigatoka',
      confidence: '91%',
      createdAt: null,
      summary: 'STALE SUMMARY',
      recommendations: 'Apply appropriate fungicide spray',
    );

    expect(stale.effectiveSummary, isNot('STALE SUMMARY'));
    expect(
      stale.effectiveRecommendations,
      isNot(contains('Apply appropriate fungicide spray')),
    );

    const unknown = ScanRecord(
      id: 'unknown-legacy-scan',
      label: 'Legacy Unsupported Label',
      category: 'Other',
      confidence: '88%',
      createdAt: null,
      recommendations: 'STALE UNSUPPORTED ADVICE',
    );
    expect(unknown.effectiveRecommendations, isNot(contains('STALE')));
    expect(
      unknown.effectiveRecommendations,
      contains('not a confirmed diagnosis'),
    );
  });

  testWidgets('source names are tappable without exposing raw URLs',
      (tester) async {
    Uri? opened;
    final launcher = DiseaseGuideResourceLauncher(
      launch: (uri) async {
        opened = uri;
        return true;
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TreatmentRecommendationScreen(
          label: 'Healthy Leaf',
          confidence: '98%',
          summary: 'legacy',
          recommendation: 'legacy',
          isHealthy: true,
          resourceLauncher: launcher,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Philippine BAFS - Good Agricultural Practice for Banana'),
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.text('Philippine BAFS - Good Agricultural Practice for Banana'),
    );
    await tester.pump();

    expect(opened, isNotNull);
    expect(find.textContaining('https://'), findsNothing);
  });

  for (final size in const [
    Size(320, 568),
    Size(375, 667),
    Size(430, 932),
  ]) {
    testWidgets(
        'treatment screen is responsive at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: TreatmentRecommendationScreen(
            label: 'Banana Bract Mosaic Virus Disease',
            confidence: '83.1%',
            summary: 'legacy',
            recommendation: 'legacy',
            isHealthy: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Open Disease Guide'),
        500,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Open Disease Guide'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
