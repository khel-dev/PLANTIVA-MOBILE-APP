import 'package:flutter/material.dart';
import 'package:flutter_plantiva/widgets/disease_distribution_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all eight distribution labels have an explicit icon mapping', () {
    const expected = {
      'Black Sigatoka': DiseaseDistributionIconKind.blackSigatoka,
      'Bract Mosaic Virus': DiseaseDistributionIconKind.bractMosaic,
      'Bunchy Top Disease': DiseaseDistributionIconKind.bunchyTop,
      'Healthy Leaf': DiseaseDistributionIconKind.healthyLeaf,
      'Insect Pest Damage': DiseaseDistributionIconKind.insectPest,
      'Moko Disease': DiseaseDistributionIconKind.moko,
      'Panama Disease': DiseaseDistributionIconKind.panamaWilt,
      'Yellow Sigatoka': DiseaseDistributionIconKind.yellowSigatoka,
    };

    for (final entry in expected.entries) {
      expect(
        DiseaseDistributionIcon.kindFor(entry.key),
        entry.value,
        reason: 'Incorrect icon mapping for ${entry.key}',
      );
    }
  });

  testWidgets('all disease icons paint at the compact distribution size',
      (tester) async {
    const categories = [
      'Black Sigatoka',
      'Bract Mosaic Virus',
      'Bunchy Top Disease',
      'Healthy Leaf',
      'Insect Pest Damage',
      'Moko Disease',
      'Panama Disease',
      'Yellow Sigatoka',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final category in categories)
                DiseaseDistributionIcon(
                  category: category,
                  color: Colors.green,
                ),
            ],
          ),
        ),
      ),
    );

    final icons = find.byType(DiseaseDistributionIcon);
    expect(icons, findsNWidgets(8));
    for (var index = 0; index < 8; index++) {
      expect(tester.getSize(icons.at(index)), const Size.square(18));
    }
    expect(tester.takeException(), isNull);
  });
}
