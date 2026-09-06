import 'package:flutter/material.dart';
import 'package:flutter_plantiva/data/disease_guide_data.dart';
import 'package:flutter_plantiva/models/disease_guide.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_detail_screen.dart';
import 'package:flutter_plantiva/screens/disease_guide/disease_guide_screen.dart';
import 'package:flutter_plantiva/services/disease_guide_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const supportedNames = {
    'Black Sigatoka',
    'Bract Mosaic Virus',
    'Bunchy Top',
    'Healthy Leaf',
    'Insect Pest Damage',
    'Moko Disease',
    'Panama Disease',
    'Yellow Sigatoka',
  };

  const educationalNames = {
    'Anthracnose',
    'Banana Freckle',
    'Crown Rot',
    'Weevil Borer',
  };

  test('guide has exactly eight scan-supported and four educational entries',
      () {
    expect(DiseaseGuideData.all, hasLength(12));

    final supported = DiseaseGuideData.all
        .where((item) => item.isAiDetectable)
        .map((item) => item.shortName)
        .toSet();
    final educational = DiseaseGuideData.all
        .where((item) => !item.isAiDetectable)
        .map((item) => item.shortName)
        .toSet();

    expect(supported, supportedNames);
    expect(educational, educationalNames);
    expect(
      DiseaseGuideData.all
          .where((item) => item.isAiDetectable)
          .every((item) => item.modelLabel?.isNotEmpty ?? false),
      isTrue,
    );
  });

  test('Bunchy Top is present and mapped as scan supported', () {
    final bunchyTop = DiseaseGuideData.byId('bunchy_top');

    expect(bunchyTop, isNotNull);
    expect(bunchyTop!.isAiDetectable, isTrue);
    expect(bunchyTop.modelLabel, 'Augmented Banana Bunchy Top Disease');
  });

  test('Healthy Leaf is presented as healthy and not as a disease', () {
    final healthy = DiseaseGuideData.byId('healthy_leaf')!;
    final copy =
        '${healthy.summary} ${healthy.overview} ${healthy.whyDangerous}'
            .toLowerCase();

    expect(healthy.category, DiseaseCategory.healthy);
    expect(healthy.name, 'Healthy Banana Leaf');
    expect(copy, contains('not a disease'));
    expect(copy, contains('single image cannot confirm'));
  });

  test('Insect Pest Damage remains a broad category', () {
    final insect = DiseaseGuideData.byId('insect_pest')!;
    final copy = '${insect.summary} ${insect.overview} ${insect.whyDangerous}'
        .toLowerCase();

    expect(insect.shortName, 'Insect Pest Damage');
    expect(copy, contains('broad'));
    expect(copy, contains('does not identify a specific insect species'));
    expect(copy, contains('confirmed before treatment'));
  });

  test('supported entries have valid direct source metadata', () {
    final supported = DiseaseGuideData.all.where((item) => item.isAiDetectable);

    for (final item in supported) {
      expect(item.sources, isNotEmpty, reason: item.shortName);
      expect(
        item.sources.every((source) => source.uri != null),
        isTrue,
        reason: item.shortName,
      );
    }
  });

  test('supported content has no fake severity or urgency labels', () {
    final prohibited = RegExp(
      r'\b(?:risk level|severity|24[ -]?hour|48[ -]?hour|countdown)\b',
      caseSensitive: false,
    );

    for (final item
        in DiseaseGuideData.all.where((item) => item.isAiDetectable)) {
      final content = [
        item.summary,
        item.overview,
        item.whyDangerous,
        ...item.prevention,
        ...item.farmerTips,
        ...item.quickFacts.expand((fact) => [fact.label, fact.value]),
        ...item.treatments.expand(
          (treatment) => [treatment.title, ...treatment.steps],
        ),
      ].join(' ');

      expect(prohibited.hasMatch(content), isFalse, reason: item.shortName);
    }
  });

  test('learning resources use valid direct URLs instead of search pages', () {
    for (final item in DiseaseGuideData.all) {
      expect(item.videos, isNotEmpty, reason: item.shortName);
      for (final resource in item.videos) {
        expect(resource.uri, isNotNull, reason: resource.title);
        expect(
          resource.url.contains('/results?search_query='),
          isFalse,
          reason: resource.title,
        );
      }
    }
  });

  test('external resource launcher handles invalid URLs and launch failures',
      () async {
    final launcher = DiseaseGuideResourceLauncher(
      launch: (_) async => throw StateError('No external activity'),
    );

    expect(await launcher.open(null), isFalse);
    expect(await launcher.open(Uri.parse('file:///private/resource')), isFalse);
    expect(await launcher.open(Uri.parse('https://example.com')), isFalse);
  });

  testWidgets('detail header remains readable on representative phone sizes',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in const [
      Size(320, 568),
      Size(375, 667),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        const MaterialApp(
          home: DiseaseDetailScreen(disease: DiseaseGuideData.bunchyTop),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byKey(
        const ValueKey('disease_detail_back_button'),
      );
      final bookmarkButton = find.byKey(
        const ValueKey('disease_detail_bookmark_button'),
      );

      expect(backButton, findsOneWidget);
      expect(bookmarkButton, findsOneWidget);
      expect(
        tester
            .widget<Icon>(find.descendant(
              of: backButton,
              matching: find.byType(Icon),
            ))
            .color,
        Colors.white,
      );
      expect(
        tester
            .widget<Icon>(find.descendant(
              of: bookmarkButton,
              matching: find.byType(Icon),
            ))
            .color,
        Colors.white,
      );
      expect(tester.takeException(), isNull, reason: 'Failed at $size');

      for (var step = 0; step < 9; step++) {
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -320),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Content overflow at $size, scroll step $step',
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
      'guide landing and support filters fit representative phone sizes',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in const [
      Size(320, 568),
      Size(375, 667),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DiseaseGuideScreen())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Disease Guide'), findsOneWidget);
      expect(find.text('Guides viewed'), findsOneWidget);
      expect(find.text('Scanner Supported'), findsOneWidget);
      expect(find.text('Educational'), findsWidgets);
      expect(tester.takeException(), isNull, reason: 'Failed at $size');

      await tester.tap(find.text('Scanner Supported'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Filter failed at $size');

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
