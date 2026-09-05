import 'package:flutter/material.dart';
import 'package:flutter_plantiva/widgets/healthy_scan_rate_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('healthy scan rate card fits representative phone sizes',
      (tester) async {
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
          home: Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: HealthyScanRateCard(
                healthyCount: 7,
                totalScans: 10,
                healthyRate: 70,
              ),
            ),
          ),
        ),
      );

      expect(find.text('70%'), findsOneWidget);
      expect(find.text('Healthy Scan Rate'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Failed at $size');
    }
  });

  testWidgets('empty analytics card does not show a fake zero percent',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HealthyScanRateCard(
            healthyCount: 0,
            totalScans: 0,
            healthyRate: null,
          ),
        ),
      ),
    );

    expect(find.text('-'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.textContaining('No scan data yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
