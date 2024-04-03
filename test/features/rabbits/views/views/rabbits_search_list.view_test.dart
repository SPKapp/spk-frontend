import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_search_list.view.dart';

class MockRabbitsSearchBloc
    extends MockBloc<RabbitsSearchEvent, RabbitsSearchState>
    implements RabbitsSearchBloc {}

void main() {
  group(RabbitsSearchView, () {
    late RabbitsSearchBloc rabbitsSearchBloc;

    const rabbits = [
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
      Rabbit(
        id: 1,
        name: 'Simba',
        gender: Gender.male,
        admissionType: AdmissionType.found,
        confirmedBirthDate: false,
      ),
      Rabbit(
        id: 1,
        name: 'Nala',
        gender: Gender.female,
        admissionType: AdmissionType.found,
        confirmedBirthDate: false,
      ),
    ];

    setUp(() {
      rabbitsSearchBloc = MockRabbitsSearchBloc();
    });

    testWidgets('should display "Brak wyników." when rabbits list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsSearchView(
            rabbits: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak wyników.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when loading more rabbits',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: rabbitsSearchBloc,
            child: const RabbitsSearchView(
              rabbits: rabbits,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display rabbit names when rabbits list is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RabbitsSearchView(
            rabbits: rabbits,
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text(rabbits[0].name), findsOneWidget);
      expect(find.text(rabbits[1].name), findsOneWidget);
    });

    testWidgets(
        'should call RabbitsSearchFetch when reaching the bottom of the list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: rabbitsSearchBloc,
            child: RabbitsSearchView(
              rabbits: rabbits + rabbits + rabbits,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('rabbitsSearchListView')),
        const Offset(0, -300),
      );

      verify(() => rabbitsSearchBloc.add(const RabbitsSearchFetch())).called(1);
    });

    testWidgets(
        'should not call RabbitsSearchFetch when page is scrollable and has reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: rabbitsSearchBloc,
            child: const RabbitsSearchView(
              rabbits: rabbits,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      verifyNever(() => rabbitsSearchBloc.add(const RabbitsSearchFetch()));
    });

    testWidgets(
        'should call RabbitsSearchFetch when page is not scrollable and has not reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: rabbitsSearchBloc,
            child: const RabbitsSearchView(
              rabbits: rabbits,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      verify(() => rabbitsSearchBloc.add(const RabbitsSearchFetch())).called(1);
    });

    testWidgets(
        'should not call RabbitsSearchFetch when page is not scrollable and has reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: rabbitsSearchBloc,
            child: const RabbitsSearchView(
              rabbits: rabbits,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      verifyNever(() => rabbitsSearchBloc.add(const RabbitsSearchFetch()));
    });
  });
}
