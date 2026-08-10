import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/config/app_theme.dart';
import 'package:flutter_plantiva/screens/landing_page.dart';

void main() {
  testWidgets('Landing page loads with main actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const LandingPage(),
      ),
    );

    expect(find.text('PLANTIVA'), findsWidgets);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });
}
