import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/features/adoption/views/views/adoption_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

void main() {
  group(AdoptionInfoView, () {
    Widget buildWidget(RabbitGroup rabbitGroup) {
      return MaterialApp(
        home: Scaffold(
          body: AdoptionInfoView(
            rabbitGroup: rabbitGroup,
          ),
        ),
      );
    }

    testWidgets('renders the correct number of rabbits',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        const RabbitGroup(
          id: '1',
          rabbits: [
            Rabbit(
              name: 'Rabbit 1',
              id: '1',
              gender: Gender.unknown,
              confirmedBirthDate: false,
              admissionType: AdmissionType.returned,
            ),
          ],
        ),
      ));

      expect(find.text('Króliki:'), findsNothing);
      expect(find.text('Królik:'), findsOneWidget);
      expect(find.text('Rabbit 1'), findsOneWidget);
      expect(find.text('Błąd pobierania opisu adopcyjnego'), findsOneWidget);
      expect(find.text('Data adopcji:'), findsNothing);
    });

    testWidgets('displays adoption description', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        const RabbitGroup(
          id: '1',
          adoptionDescription: 'This is the adoption description',
          rabbits: [],
        ),
      ));

      expect(find.text('Opis adopcyjny'), findsOneWidget);
      expect(find.text('This is the adoption description'), findsOneWidget);
    });

    testWidgets('displays adoption date if available',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
        RabbitGroup(
          id: '1',
          adoptionDate: DateTime(2024, 1, 1),
          rabbits: const [],
        ),
      ));

      expect(find.text('Data adopcji:'), findsOneWidget);
      expect(find.text('2024-01-01'), findsOneWidget);
    });
  });
}
