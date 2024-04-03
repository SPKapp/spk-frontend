import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbits_list.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_search_list.view.dart';

class MockRabbitsListBloc extends MockBloc<RabbitsListEvent, RabbitsListState>
    implements RabbitsListBloc {}

class MockRabbitsSearchBloc
    extends MockBloc<RabbitsSearchEvent, RabbitsSearchState>
    implements RabbitsSearchBloc {}

void main() {
  group(RabbitsListPage, () {
    final MockRabbitsListBloc rabbitsListBloc = MockRabbitsListBloc();

    testWidgets(
        'RabbitsListPage should dispaly CircularProgressIndicator when state is RabbitsListInitial',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(
        MaterialApp(
          home: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
            drawer: const Drawer(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RabbitsListView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display "Failed to fetch rabbits" when state is RabbitsListFailure',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListFailure());
      await widgetTester.pumpWidget(
        MaterialApp(
          home: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'RabbitsListPage should display RabbitsListView when state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer(
        (_) => const RabbitsListSuccess(
          rabbitGroups: [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(
        MaterialApp(
          home: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should not rebuild when state is RabbitsListInitial and previous state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          const RabbitsListInitial(),
        ]),
        initialState: const RabbitsListSuccess(
          rabbitGroups: [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(
        MaterialApp(
          home: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
          ),
        ),
      );

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display SnackBar with error and not rebuild',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          const RabbitsListFailure(
            rabbitGroups: [RabbitGroup(id: 1, rabbits: [])],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
        initialState: const RabbitsListSuccess(
          rabbitGroups: [RabbitGroup(id: 1, rabbits: [])],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(
        MaterialApp(
          home: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
          ),
        ),
      );

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    group(SearchAction, () {
      late MockRabbitsSearchBloc rabbitsSearchBloc;

      setUp(() {
        rabbitsSearchBloc = MockRabbitsSearchBloc();
        when(() => rabbitsListBloc.state)
            .thenAnswer((_) => const RabbitsListInitial());
      });

      testWidgets(
          'SearchAction should display nothing when state is RabbitsSearchInitial',
          (WidgetTester widgetTester) async {
        when(() => rabbitsSearchBloc.state)
            .thenAnswer((_) => const RabbitsSearchInitial());

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        expect(find.byKey(const Key('search_initial')), findsOneWidget);
        expect(find.byType(RabbitsSearchView), findsNothing);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets(
          'SearchAction should display Container when state is RabbitsSearchInitial',
          (WidgetTester widgetTester) async {
        when(() => rabbitsSearchBloc.state)
            .thenAnswer((_) => const RabbitsSearchInitial());

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.byIcon(Icons.clear));
        await widgetTester.pumpAndSettle();

        expect(find.byKey(const Key('search_initial')), findsOneWidget);
        expect(find.byType(RabbitsSearchView), findsNothing);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets(
          'SearchAction should display FailureView when state is RabbitsSearchFailure',
          (WidgetTester widgetTester) async {
        when(() => rabbitsSearchBloc.state)
            .thenAnswer((_) => const RabbitsSearchFailure());

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        await widgetTester.enterText(find.byType(TextField), 'test');
        await widgetTester.pumpAndSettle();

        expect(find.byKey(const Key('search_initial')), findsNothing);
        expect(find.byType(RabbitsSearchView), findsNothing);
        expect(find.byType(FailureView), findsOneWidget);
      });

      testWidgets(
          'SearchAction should display RabbitsSearchView when state is RabbitsSearchSuccess',
          (WidgetTester widgetTester) async {
        whenListen(
          rabbitsSearchBloc,
          Stream.fromIterable([
            const RabbitsSearchSuccess(
              query: 'test',
              rabbits: [],
              hasReachedMax: true,
              totalCount: 0,
            ),
          ]),
          initialState: const RabbitsSearchInitial(),
        );

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        await widgetTester.enterText(find.byType(TextField), 'test');
        await widgetTester.pumpAndSettle();

        expect(find.byKey(const Key('search_initial')), findsNothing);
        expect(find.byType(RabbitsSearchView), findsOneWidget);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets(
          'SearchAction should add RabbitsSearchClear event when clear button is pressed',
          (WidgetTester widgetTester) async {
        when(() => rabbitsSearchBloc.state)
            .thenAnswer((_) => const RabbitsSearchInitial());

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.byIcon(Icons.clear));
        await widgetTester.pump();

        verify(() => rabbitsSearchBloc.add(const RabbitsSearchClear()))
            .called(1);
      });

      testWidgets(
          'SearchAction should add RabbitsSearchClear event when back button is pressed',
          (WidgetTester widgetTester) async {
        when(() => rabbitsSearchBloc.state)
            .thenAnswer((_) => const RabbitsSearchInitial());

        await widgetTester.pumpWidget(
          MaterialApp(
            home: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              rabbitsSearchBloc: (_) => rabbitsSearchBloc,
              drawer: const Drawer(),
            ),
          ),
        );

        await widgetTester.tap(find.byKey(const Key('search_action')));
        await widgetTester.pumpAndSettle();

        await widgetTester.tap(find.byIcon(Icons.arrow_back));
        await widgetTester.pump();

        verify(() => rabbitsSearchBloc.add(const RabbitsSearchClear()))
            .called(1);
      });
    });
  });
}
