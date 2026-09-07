import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/screens/result_screen.dart';
import 'package:flutter_plantiva/screens/scan_loading_screen.dart';
import 'package:flutter_plantiva/screens/treatment_recommendation_screen.dart';
import 'package:flutter_plantiva/services/classifier_service.dart';
import 'package:flutter_plantiva/services/input_validator_service.dart';
import 'package:flutter_plantiva/services/scan_input_pipeline.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;
  late File imageFile;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('plantiva-scan-test');
    imageFile = File('${tempDirectory.path}/leaf.png');
    await imageFile.writeAsBytes(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
      ),
    );
  });

  tearDown(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  Future<void> pumpValidScan(
    WidgetTester tester,
    Future<String?> Function(
      Map<String, String>, {
      required String imagePath,
    }) persistence,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScanLoadingScreen(
          imagePath: imageFile.path,
          classifier: ClassifierService(),
          inputValidator: InputValidatorService(),
          pipelineRunner: (_) async => _validPipelineResult,
          persistenceRunner: persistence,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('result appears before one delayed save completes, then saves', (
    tester,
  ) async {
    final save = Completer<String?>();
    var persistenceCalls = 0;

    await pumpValidScan(tester, (result, {required imagePath}) {
      persistenceCalls++;
      return save.future;
    });

    expect(find.byType(ScanLoadingScreen), findsNothing);
    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('Saving scan...'), findsOneWidget);
    expect(persistenceCalls, 1);

    save.complete('scan-123');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Saved to Recent Scans'), findsOneWidget);
    expect(persistenceCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('save failure keeps result visible and reports cloud failure', (
    tester,
  ) async {
    final save = Completer<String?>();
    await pumpValidScan(
      tester,
      (result, {required imagePath}) => save.future,
    );

    save.completeError(Exception('offline'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(
      find.text(
        'Scan result available. This scan was not saved to cloud history.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('treatment opens while cloud save is still pending', (
    tester,
  ) async {
    final save = Completer<String?>();
    await pumpValidScan(
      tester,
      (result, {required imagePath}) => save.future,
    );

    final treatmentButton = find.text('View Treatment Recommendations');
    await tester.ensureVisible(treatmentButton);
    await tester.pump();
    await tester.tap(treatmentButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(TreatmentRecommendationScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    save.complete(null);
  });

  testWidgets('invalid input never starts persistence', (tester) async {
    var persistenceCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: ScanLoadingScreen(
          imagePath: imageFile.path,
          classifier: ClassifierService(),
          inputValidator: InputValidatorService(),
          pipelineRunner: (_) async => const ScanInputPipelineResult(
            passedInputGates: false,
            result: {
              'label': 'Not a Banana Leaf',
              'confidence': '0%',
              'validation_status': 'unrelatedOrUnreliable',
              'validation_message': 'Please scan a clear banana leaf.',
            },
          ),
          persistenceRunner: (result, {required imagePath}) async {
            persistenceCalls++;
            return 'unexpected';
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Please capture a banana leaf'), findsOneWidget);
    expect(persistenceCalls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing result before save completion is lifecycle safe', (
    tester,
  ) async {
    final save = Completer<String?>();
    await pumpValidScan(
      tester,
      (result, {required imagePath}) => save.future,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    save.complete('scan-after-dispose');
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

const _validPipelineResult = ScanInputPipelineResult(
  passedInputGates: true,
  result: {
    'label': 'Healthy Leaf',
    'confidence': '98.0%',
    'raw_label': 'Augmented Banana Healthy Leaf',
    'validation_status': 'validDiagnosis',
  },
);
