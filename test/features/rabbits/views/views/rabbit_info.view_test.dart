import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitInfoView, () {
    late GoRouter goRouter;

    Rabbit rabbit = Rabbit(
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
      rabbitGroup: RabbitGroup(id: 1, rabbits: List.empty(growable: true)),
    );

    setUp(() {
      goRouter = MockGoRouter();

      when(() => goRouter.push(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => Object());
    });

    testWidgets('should render correctly - admin', (WidgetTester tester) async {
      await mockNetworkImages(() async => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RabbitInfoView(
                  rabbit: rabbit,
                  admin: true,
                ),
              ),
            ),
          ));

      expect(find.byType(TopPhotoCard), findsOneWidget);
      expect(find.byType(TopInfoCard), findsOneWidget);
      expect(find.byType(RabbitGroupCard),
          findsNothing); // rabbit.rabbitGroup!.rabbits.length <= 1
      expect(find.byType(VolunteerCard), findsOneWidget); // admin = true
      expect(find.byType(RabbitInfoButton), findsNWidgets(2));
      expect(find.byType(FullInfoCard), findsOneWidget);
    });

    testWidgets('should render correctly - not admin',
        (WidgetTester tester) async {
      rabbit.rabbitGroup!.rabbits.add(rabbit);
      rabbit.rabbitGroup!.rabbits.add(rabbit);

      await mockNetworkImages(() async => tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RabbitInfoView(
                  rabbit: rabbit,
                  admin: false,
                ),
              ),
            ),
          ));

      expect(find.byType(TopPhotoCard), findsOneWidget);
      expect(find.byType(TopInfoCard), findsOneWidget);
      expect(find.byType(RabbitGroupCard),
          findsOneWidget); // rabbit.rabbitGroup!.rabbits.length > 1
      expect(find.byType(VolunteerCard), findsNothing); // admin = fallse
      expect(find.byType(RabbitInfoButton), findsNWidgets(2));
      expect(find.byType(FullInfoCard), findsOneWidget);
    });

    testWidgets('should navigate to rabbit notes list page',
        (WidgetTester tester) async {
      await mockNetworkImages(() async => tester.pumpWidget(
            MaterialApp(
              home: InheritedGoRouter(
                goRouter: goRouter,
                child: Scaffold(
                  body: RabbitInfoView(
                    rabbit: rabbit,
                    admin: true,
                  ),
                ),
              ),
            ),
          ));

      await tester.tap(find.byKey(const Key('vet-visit-button')));
      await tester.pumpAndSettle();

      verify(() => goRouter.push('/rabbit/1/notes', extra: {
            'rabbitName': 'Rabbit',
            'isVetVisit': true,
          }));
    });

    testWidgets('should navigate to rabbit notes list page',
        (WidgetTester tester) async {
      await mockNetworkImages(() async => tester.pumpWidget(
            MaterialApp(
              home: InheritedGoRouter(
                goRouter: goRouter,
                child: Scaffold(
                  body: RabbitInfoView(
                    rabbit: rabbit,
                    admin: true,
                  ),
                ),
              ),
            ),
          ));

      await tester.tap(find.byKey(const Key('notes-button')));
      await tester.pump();

      verify(() => goRouter.push('/rabbit/1/notes', extra: {
            'rabbitName': 'Rabbit',
            'isVetVisit': false,
          }));
    });
  });
}
