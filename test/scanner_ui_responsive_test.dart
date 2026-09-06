import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/screens/scan_loading_screen.dart';
import 'package:flutter_plantiva/screens/scanner_screen.dart';
import 'package:flutter_plantiva/services/classifier_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scanner remains usable at representative phone sizes',
      (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in const [
      Size(320, 568),
      Size(375, 667),
      Size(411, 891),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Scan Banana Leaf'), findsOneWidget);
      expect(find.text('Capture Leaf'), findsOneWidget);
      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Failed at $size');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('supported conditions sheet lists all eight classes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.tap(find.byTooltip('Supported conditions'));
    await tester.pump(const Duration(milliseconds: 400));

    for (final condition in const [
      'Black Sigatoka',
      'Bract Mosaic Virus',
      'Bunchy Top Disease',
      'Healthy Leaf',
      'Insect Pest Damage',
      'Moko Disease',
      'Panama Disease',
      'Yellow Sigatoka',
    ]) {
      expect(find.text(condition), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('loading presentation fits a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ScanLoadingScreen(
          imagePath: 'missing-scan-image.jpg',
          classifier: ClassifierService(),
          inputValidator: InputValidatorService(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Checking your image'), findsOneWidget);
    expect(find.text('Analyzing leaf...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
