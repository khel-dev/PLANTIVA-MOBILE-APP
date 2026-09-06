import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/screens/profile.dart';
import 'package:flutter_plantiva/screens/profile/about_plantiva_screen.dart';
import 'package:flutter_plantiva/screens/profile/help_center_screen.dart';
import 'package:flutter_plantiva/services/profile_service.dart';

void main() {
  test('support email actions use the approved recipient and content', () {
    final contact = contactSupportEmailUri();
    final report = reportProblemEmailUri();

    expect(plantivaSupportEmail, 'queljayverdelossantos@gmail.com');
    expect(contact.path, plantivaSupportEmail);
    expect(contact.queryParameters['subject'], 'PLANTIVA Support Request');
    expect(
      contact.queryParameters['body'],
      contains('[Please describe your concern here.]'),
    );
    expect(report.path, plantivaSupportEmail);
    expect(report.queryParameters['subject'], 'PLANTIVA App Problem Report');
    expect(report.queryParameters['body'], contains('Steps before the issue'));
  });

  test('about content and profile photo contract remain exact', () {
    expect(plantivaWebsiteUrl, 'https://plantiva-capstone.netlify.app/');
    expect(
      plantivaTeamMembers,
      const [
        'Queljayver D. Bustamante',
        'Earl John Bio',
        'James Ray Ancog',
        'Niel John Elio',
      ],
    );
    expect(
      profilePhotoMenuLabels,
      const [
        'Take Photo',
        'Choose from Gallery',
        'Remove Photo',
        'Cancel',
      ],
    );
    expect(
      profilePhotoStoragePath('test-user'),
      'users/test-user/profile.jpg',
    );
  });

  testWidgets('Help Center opens the responsive About PLANTIVA screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MaterialApp(home: HelpCenterScreen()));
    expect(tester.takeException(), isNull, reason: 'Help Center overflowed');
    await tester.scrollUntilVisible(
      find.text('About PLANTIVA'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull, reason: 'Help actions overflowed');
    await tester.tap(find.text('About PLANTIVA'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutPlantivaScreen), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'About header overflowed');
    await tester.scrollUntilVisible(
      find.text('Meet the Team'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    final teamException = tester.takeException();
    expect(
      teamException,
      isNull,
      reason: teamException is FlutterError
          ? teamException.toStringDeep()
          : 'Team heading overflowed',
    );
    expect(find.text('Meet the Team'), findsOneWidget);
    for (final name in plantivaTeamMembers) {
      await tester.scrollUntilVisible(
        find.text(name),
        120,
        scrollable: find.byType(Scrollable).last,
      );
      expect(tester.takeException(), isNull, reason: '$name overflowed');
      expect(find.text(name), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('Visit PLANTIVA Website'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull, reason: 'Website button overflowed');
    expect(find.text('Visit PLANTIVA Website'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
