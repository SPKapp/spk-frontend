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
      RabbitsGroup(id: 1, rabbits: [
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
      RabbitsGroup(id: 2, rabbits: [
        Rabbit(
          id: 1,
          name: 'Simba',
          gender: Gender.male,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ]),
      RabbitsGroup(id: 3, rabbits: [
        Rabbit(
          id: 1,
          name: 'Nala',
          gender: Gender.female,
          admissionType: AdmissionType.found,
          confirmedBirthDate: false,
        ),
      ]),
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
        'should display CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitsGroups: rabbitGroups,
            hasReachedMax: false,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display rabbit names when rabbitsGroups is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsListView(
            rabbitsGroups: rabbitGroups,
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
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: RabbitsListView(
              rabbitsGroups: rabbitGroups + rabbitGroups,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('rabbitsListView')),
        const Offset(0, -300),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump();

      verify(() => rabbitsListBloc.add(const FetchRabbits())).called(1);
    });

    testWidgets('should call RefreshRabbits event when pull to refresh',
        (WidgetTester tester) async {
      when(() => rabbitsListBloc.stream)
          .thenAnswer((_) => Stream.fromIterable([RabbitsListInitial()]));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: const RabbitsListView(
              rabbitsGroups: rabbitGroups,
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
          .thenAnswer((_) => Stream.fromIterable([RabbitsListInitial()]));
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<RabbitsListBloc>.value(
            value: rabbitsListBloc,
            child: const RabbitsListView(
              rabbitsGroups: [],
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
