import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/rabbit_group_card.widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitGroupCard, () {
    final MockGoRouter mockGoRouter = MockGoRouter();

    const rabbits = [
      Rabbit(
        id: '1',
        name: 'Rabbit 1',
        gender: Gender.male,
        admissionType: AdmissionType.found,
        confirmedBirthDate: false,
      ),
      Rabbit(
        id: '2',
        name: 'Rabbit 2',
        gender: Gender.male,
        admissionType: AdmissionType.found,
        confirmedBirthDate: false,
      ),
    ];
    testWidgets('should displays correct information',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RabbitGroupCard(rabbits: rabbits),
          ),
        ),
      );

      expect(find.text('Zaprzyjaźnione Króliki:'), findsOneWidget);
      expect(find.text('Zaprzyjaźniony Królik:'), findsNothing);
      expect(find.text('Rabbit 1'), findsOneWidget);
      expect(find.text('Rabbit 2'), findsOneWidget);
    });

    testWidgets('should dispalys correct information for single rabbit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitGroupCard(rabbits: rabbits.sublist(0, 1)),
          ),
        ),
      );

      expect(find.text('Zaprzyjaźnione Króliki:'), findsNothing);
      expect(find.text('Zaprzyjaźniony Królik:'), findsOneWidget);
      expect(find.text('Rabbit 1'), findsOneWidget);
      expect(find.text('Rabbit 2'), findsNothing);
    });

    testWidgets('should navigate to rabbit details on tap',
        (WidgetTester tester) async {
      when(() => mockGoRouter.push(any()))
          .thenAnswer((invocation) async => Object());

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: const Scaffold(
              body: RabbitGroupCard(rabbits: rabbits),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Rabbit 1'));
      await tester.pumpAndSettle();

      verify(() => mockGoRouter.push('/rabbit/1')).called(1);
    });
  });
}
