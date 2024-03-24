import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

void main() {
  group(RabbitsListView, () {
    const rabbitGroups = [
      RabbitsGroup(id: 1, rabbits: []),
      RabbitsGroup(id: 2, rabbits: []),
      RabbitsGroup(id: 3, rabbits: []),
    ];

    testWidgets('should display "Brak królików." when rabbitsGroups is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitsGroups: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak królików.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
        'should display RabbitGroupCard widgets when rabbitsGroups is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitsGroups: rabbitGroups,
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.byType(RabbitGroupCard), findsNWidgets(rabbitGroups.length));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'should display RabbitGroupCard widgets and CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitsGroups: rabbitGroups,
            hasReachedMax: false,
          ),
        ),
      );

      expect(find.byType(RabbitGroupCard), findsNWidgets(rabbitGroups.length));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
