import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/search.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/list_actions/rabbits_search_action.widget.dart';

class MockRabbitsSearchBloc
    extends MockBloc<SearchEvent, SearchState<RabbitGroup>>
    implements RabbitsSearchBloc {}

void main() {
  group(RabbitsSearchAction, () {
    late RabbitsSearchBloc rabbitsSearchBloc;

    setUp(() {
      rabbitsSearchBloc = MockRabbitsSearchBloc();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: RabbitsSearchAction(
            args: () => const FindRabbitsArgs(),
            rabbitsSearchBloc: (context) => rabbitsSearchBloc,
          ),
        ),
      );
    }

    testWidgets('renders SearchAction widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(SimpleSearchAction), findsOneWidget);
    });

    testWidgets('should display nothing when initial state',
        (WidgetTester tester) async {
      when(() => rabbitsSearchBloc.state).thenReturn(SearchInitial());

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SimpleSearchAction));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchInitial')), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(AppListView<Rabbit>), findsNothing);
    });

    testWidgets('should display FailureView when failure state',
        (WidgetTester tester) async {
      when(() => rabbitsSearchBloc.state).thenReturn(SearchFailure());

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SimpleSearchAction));
      await tester.pumpAndSettle();

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byKey(const Key('searchInitial')), findsNothing);
      expect(find.byType(AppListView<Rabbit>), findsNothing);
    });

    testWidgets('should display AppListView<Rabbit> when success state',
        (WidgetTester tester) async {
      when(() => rabbitsSearchBloc.state).thenReturn(SearchSuccess(
        query: 'query',
        data: const [],
        totalCount: 0,
        hasReachedMax: false,
      ));

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SimpleSearchAction));
      await tester.pumpAndSettle();

      expect(find.text('Brak wyników.'), findsOneWidget);
      expect(find.byKey(const Key('searchInitial')), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });
  });
}
