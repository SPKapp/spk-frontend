import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/list_items/rabbit_list_item.widget.dart';

import 'rabbit_list_item.widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GoRouter>()])
void main() {
  group(RabbitListItem, () {
    const int rabbitId = 1;
    const String rabbitName = 'Rabbit';
    late MockGoRouter mockGoRouter;

    setUp(() {
      mockGoRouter = MockGoRouter();
    });

    testWidgets('RabbitListItem should display correct name',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RabbitListItem(
              id: rabbitId,
              name: rabbitName,
            ),
          ),
        ),
      );

      expect(find.text(rabbitName), findsOneWidget);
    });

    testWidgets('RabbitListItem onTap should push correct route',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: const Scaffold(
              body: RabbitListItem(
                id: rabbitId,
                name: rabbitName,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      verify(mockGoRouter.push('/rabbit/$rabbitId')).called(1);
    });
  });
}
