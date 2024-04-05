import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';

import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info/volunteer_card.widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(VolunteerCard, () {
    final MockGoRouter mockGoRouter = MockGoRouter();

    const List<User> volunteers = [
      User(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
      ),
      User(
        id: 2,
        firstName: 'Jane',
        lastName: 'Smith',
      ),
    ];

    testWidgets(
      'should displays correct information',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VolunteerCard(volunteers: volunteers),
            ),
          ),
        );

        expect(find.text('Opiekunowie'), findsOneWidget);
        expect(find.text('Opiekun'), findsNothing);
        expect(find.text('Brak przypisanego Opiekuna'), findsNothing);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
      },
    );

    testWidgets(
      'should displays correct information for single volunteer',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VolunteerCard(volunteers: volunteers.sublist(0, 1)),
            ),
          ),
        );

        expect(find.text('Opiekunowie'), findsNothing);
        expect(find.text('Opiekun'), findsOneWidget);
        expect(find.text('Brak przypisanego Opiekuna'), findsNothing);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsNothing);
      },
    );

    testWidgets(
      'should displays correct information for no volunteers',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VolunteerCard(volunteers: []),
            ),
          ),
        );

        expect(find.text('Opiekunowie'), findsNothing);
        expect(find.text('Opiekun'), findsNothing);
        expect(find.text('Brak przypisanego Opiekuna'), findsOneWidget);
      },
    );

    testWidgets(
      'should navigates to user page',
      (WidgetTester tester) async {
        when(() => mockGoRouter.push(any()))
            .thenAnswer((invocation) async => Object());

        await tester.pumpWidget(
          MaterialApp(
            home: InheritedGoRouter(
              goRouter: mockGoRouter,
              child: const Scaffold(
                body: VolunteerCard(volunteers: volunteers),
              ),
            ),
          ),
        );

        await tester.tap(find.text('John Doe'));
        await tester.pumpAndSettle();

        verify(() => mockGoRouter.push('/user/1')).called(1);
      },
    );
  });
}
