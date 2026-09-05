import 'package:flutter/material.dart';
import 'package:flutter_plantiva/screens/profile/help_center_screen.dart';
import 'package:flutter_plantiva/widgets/plantiva_decorated_background.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('decorated background is responsive and does not block input',
      (tester) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var taps = 0;
    for (final size in const [
      Size(320, 568),
      Size(375, 667),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlantivaDecoratedBackground(
              child: Center(
                child: FilledButton(
                  onPressed: () => taps++,
                  child: const Text('Test Action'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsNWidgets(2));
      await tester.tap(find.text('Test Action'));
      expect(tester.takeException(), isNull, reason: 'Failed at $size');
    }

    expect(taps, 3);
  });

  testWidgets('a representative decorated sub-page fits small phones',
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
      await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));
      await tester.pump();

      expect(find.text('Help Center'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Failed at $size');
    }
  });
}
