import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/full_info_card.widget.dart';

void main() {
  group(FullInfoCard, () {
    final rabbit = Rabbit(
      id: 1,
      name: 'Rabbit',
      gender: Gender.female,
      weight: 5.0,
      color: 'White',
      birthDate: DateTime(2024, 1, 1),
      confirmedBirthDate: true,
      castrationDate: DateTime(2024, 2, 1),
      vaccinationDate: DateTime(2024, 3, 1),
      chipNumber: '1234567890',
      admissionDate: DateTime(2024, 5, 1),
      admissionType: AdmissionType.found,
      fillingDate: DateTime(2024, 6, 1),
    );
    testWidgets('FullInfoCard displays correct information',
        (WidgetTester tester) async {
      // Build the FullInfoCard widget with the Rabbit object
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullInfoCard(rabbit: rabbit),
            ),
          ),
        ),
      );

      expect(find.text('Waga:'), findsOneWidget);
      expect(find.text('5.0 kg'), findsOneWidget);
      expect(find.text('Kolor:'), findsOneWidget);
      expect(find.text('White'), findsOneWidget);
      expect(find.text('Data Urodzenia:'), findsOneWidget);
      expect(find.text('2024-01-01'), findsOneWidget);
      expect(find.text('Data Kastracji:'), findsOneWidget);
      expect(find.text('2024-02-01'), findsOneWidget);
      expect(find.text('Data Szczepienia:'), findsOneWidget);
      expect(find.text('2024-03-01'), findsOneWidget);
      expect(find.text('Data Odrobaczania:'), findsOneWidget);
      expect(find.text('Brak danych'), findsOneWidget);
      expect(find.text('Numer Chipa:'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('Data Przekazania:'), findsOneWidget);
      expect(find.text('2024-05-01'), findsOneWidget);
      expect(find.text('Typ Przekazania:'), findsOneWidget);
      expect(find.text('Znaleziony'), findsOneWidget);
      expect(find.text('Data Zgłoszenia:'), findsOneWidget);
      expect(find.text('2024-06-01'), findsOneWidget);
    });

    testWidgets('should weight be clickable', (WidgetTester tester) async {
      bool weightClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FullInfoCard(
                rabbit: rabbit,
                weightClick: () {
                  weightClicked = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('5.0 kg'));
      await tester.pumpAndSettle();

      expect(weightClicked, true);
    });
  });
}
