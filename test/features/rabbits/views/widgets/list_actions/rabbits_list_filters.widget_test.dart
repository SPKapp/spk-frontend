import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_actions/rabbits_list_filters.widget.dart';

void main() {
  group(RabbitsListFilters, () {
    testWidgets('RabbitsListFilters should render correctly',
        (WidgetTester widgetTester) async {
      await widgetTester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitsListFilters(
              args: const FindRabbitsArgs(),
              onFilter: (args) => args,
            ),
          ),
        ),
      );

      expect(find.text('Filtruj króliki'), findsOneWidget);
      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('Filtruj'), findsOneWidget);
    });
  });
}
