import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_plantiva/utils/disease_labels.dart';

void main() {
  group('DiseaseLabels BBTD support', () {
    test('normalizes BBTD label variants to Bunchy Top Disease', () {
      const variants = [
        'Bunchy Top Disease',
        'Banana Bunchy Top Disease',
        'Augmented Banana Bunchy Top Disease',
        'BBTD',
        'Banana Bunchy Top Virus',
      ];

      for (final label in variants) {
        expect(DiseaseLabels.normalize(label), 'Bunchy Top Disease');
      }
    });

    test('includes BBTD in official analytics categories', () {
      expect(DiseaseLabels.categories, contains('Bunchy Top Disease'));
    });

    test('provides BBTD display metadata', () {
      expect(
        DiseaseLabels.displaySubtitle('Bunchy Top Disease'),
        'Banana Bunchy Top Virus (BBTV)',
      );
      expect(
        DiseaseLabels.colorFor('Bunchy Top Disease'),
        isNot(DiseaseLabels.colorFor('Unknown')),
      );
      expect(
        DiseaseLabels.iconFor('Bunchy Top Disease'),
        Icons.local_florist_outlined,
      );
    });
  });
}
