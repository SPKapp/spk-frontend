import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/top_info_card.widget.dart';

void main() {
  group(TopInfoCard, () {
    Rabbit rabbit = Rabbit(
      id: '1',
      name: 'Rabbit',
      gender: Gender.unknown,
      admissionType: AdmissionType.found,
      birthDate: DateTime.now().subtract(const Duration(days: 365)),
      breed: 'Breed',
      confirmedBirthDate: false,
    );
    testWidgets('should display gender text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TopInfoCard(rabbit: rabbit)));

      expect(find.text('Płeć Nieznana'), findsOneWidget);
    });

    testWidgets('should display age text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TopInfoCard(rabbit: rabbit)));

      expect(find.text('Rok'), findsOneWidget);
    });

    testWidgets('should display breed text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TopInfoCard(rabbit: rabbit)));

      expect(find.text(rabbit.breed!), findsOneWidget);
    });

    testWidgets('should display status text correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: TopInfoCard(rabbit: rabbit)));

      expect(find.text('Nieznany status'), findsOneWidget);
    });
  });
}
