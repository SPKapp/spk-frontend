import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items/rabbit_group_card.widget.dart';

void main() {
  group(RabbitGroupCard, () {
    const rabbitGroup = RabbitsGroup(
      id: 1,
      rabbits: [
        Rabbit(
          id: 1,
          name: 'Rabbit 1',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
        Rabbit(
          id: 2,
          name: 'Rabbit 2',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        )
      ],
    );

    testWidgets('should display the correct number of rabbits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RabbitGroupCard(rabbitsGroup: rabbitGroup),
          ),
        ),
      );

      expect(find.text('Rabbit 1'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(find.text('Rabbit 2'), findsOneWidget);
    });
  });
}
