import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class MockRabbitsListBloc extends MockBloc<RabbitsListEvent, RabbitsListState>
    implements RabbitsListBloc {}

void main() {
  group(RabbitsListView, () {
    final MockRabbitsListBloc rabbitsListBloc = MockRabbitsListBloc();
    const rabbitGroups = [
      RabbitGroup(id: 1, rabbits: [
        Rabbit(
          id: 1,
          name: 'Timon',
          gender: Gender.male,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
        Rabbit(
          id: 2,
          name: 'Pumba',
          gender: Gender.male,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ]),
      RabbitGroup(id: 2, rabbits: [
        Rabbit(
          id: 1,
          name: 'Simba',
          gender: Gender.male,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ]),
      RabbitGroup(id: 3, rabbits: [
        Rabbit(
          id: 1,
          name: 'Nala',
          gender: Gender.female,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ]),
    ];

    testWidgets('should display "Brak królików." when rabbitGroups is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitGroups: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak królików.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitGroups: rabbitGroups,
            hasReachedMax: false,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display rabbit names when rabbitGroups is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitGroups: rabbitGroups,
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text(rabbitGroups[0].rabbits[0].name), findsOneWidget);
      expect(find.text(rabbitGroups[0].rabbits[1].name), findsOneWidget);
      expect(find.text(rabbitGroups[1].rabbits[0].name), findsOneWidget);
      expect(find.text(rabbitGroups[2].rabbits[0].name), findsOneWidget);
    });

    testWidgets('should call FetchRabbits event when scroll reaches the end',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 500);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: const RabbitsListView(
              rabbitGroups: rabbitGroups,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('appListView')),
        const Offset(0, -200),
      );

      verify(() => rabbitsListBloc.add(const FetchRabbits())).called(1);
    });

    testWidgets('should call RefreshRabbits event when pull to refresh',
        (WidgetTester tester) async {
      when(() => rabbitsListBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([const RabbitsListInitial()]));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: const RabbitsListView(
              rabbitGroups: rabbitGroups,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      await tester.fling(
          find.text(
            rabbitGroups[0].rabbits[0].name,
          ),
          const Offset(0, 400),
          1000);
      await tester.pumpAndSettle();

      verify(() => rabbitsListBloc.add(const RefreshRabbits())).called(1);
    });

    testWidgets(
        'should call RefreshRabbits event when pull to refresh and no data',
        (WidgetTester tester) async {
      when(() => rabbitsListBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([const RabbitsListInitial()]));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: const RabbitsListView(
              rabbitGroups: [],
              hasReachedMax: true,
            ),
          ),
        ),
      );

      await tester.fling(
          find.text('Brak królików.'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      verify(() => rabbitsListBloc.add(const RefreshRabbits())).called(1);
    });
  });
}
