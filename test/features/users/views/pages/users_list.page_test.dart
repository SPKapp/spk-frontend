import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/pages/users_list.page.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';
import 'package:spk_app_frontend/features/users/views/views/users_search_list.view.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

class MockUsersSearchBloc extends MockBloc<UsersSearchEvent, UsersSearchState>
    implements UsersSearchBloc {}

void main() {
  group(UsersListPage, () {
    final UsersListBloc usersListBloc = MockUsersListBloc();

    testWidgets(
        'UsersListPage should display CircularProgressIndicator when state is UsersListInitial',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer((_) => UsersListInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: UsersListPage(
            usersListBloc: (_) => usersListBloc,
            drawer: const Drawer(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(UsersListView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'UsersListPage should display "Failed to fetch users" when state is UsersListFailure',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer((_) => UsersListFailure());
      await tester.pumpWidget(
        MaterialApp(
          home: UsersListPage(
            usersListBloc: (_) => usersListBloc,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(UsersListView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'UsersListPage should display UsersListView when state is UsersListSuccess',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer(
        (_) => UsersListSuccess(
          teams: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UsersListPage(
            usersListBloc: (_) => usersListBloc,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(UsersListView), findsOneWidget);
      expect(find.byKey(const Key('usersListFailureText')), findsNothing);
    });

    testWidgets(
        'UsersListPage should not rebuild when state is UsersListInitial and previous state is UsersListSuccess',
        (WidgetTester tester) async {
      whenListen(
        usersListBloc,
        Stream.fromIterable([
          UsersListInitial(),
        ]),
        initialState: UsersListSuccess(
          teams: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UsersListPage(
            usersListBloc: (_) => usersListBloc,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(UsersListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'UsersListPage should display Snackbar with error and not rebuild',
        (WidgetTester tester) async {
      whenListen(
        usersListBloc,
        Stream.fromIterable([
          UsersListFailure(
            teams: const [Team(id: 1, users: [])],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
        initialState: UsersListSuccess(
          teams: const [Team(id: 1, users: [])],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: UsersListPage(
            usersListBloc: (_) => usersListBloc,
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(UsersListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    group(SearchAction, () {
      late UsersSearchBloc usersSearchBloc;

      setUp(() {
        usersSearchBloc = MockUsersSearchBloc();
        when(() => usersListBloc.state).thenAnswer((_) => UsersListInitial());
      });

      testWidgets('should display nothing when state is UsersSearchInitial',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state)
            .thenReturn(const UsersSearchInitial());

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('searchInitial')), findsOneWidget);
        expect(find.byType(UsersSearchView), findsNothing);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets('should display Container when state is UsersSearchInitial',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state)
            .thenReturn(const UsersSearchInitial());

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('searchInitial')), findsOneWidget);
        expect(find.byType(UsersSearchView), findsNothing);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets('should display FailureView when state is UsersSearchFailure',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state)
            .thenAnswer((_) => const UsersSearchFailure());

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('searchInitial')), findsNothing);
        expect(find.byType(UsersSearchView), findsNothing);
        expect(find.byType(FailureView), findsOneWidget);
      });

      testWidgets(
          'should display UsersSearchView when state is UsersSearchSuccess',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state).thenAnswer(
          (_) => const UsersSearchSuccess(
            query: 'text',
            users: [],
            hasReachedMax: true,
            totalCount: 0,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('searchInitial')), findsNothing);
        expect(find.byType(UsersSearchView), findsOneWidget);
        expect(find.byType(FailureView), findsNothing);
      });

      testWidgets(
          'should add UsersSearchClear event when clear button is pressed',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state)
            .thenReturn(const UsersSearchInitial());

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        verify(() => usersSearchBloc.add(const UsersSearchClear())).called(1);
      });

      testWidgets(
          'should add UsersSearchClear event when back button is pressed',
          (WidgetTester tester) async {
        when(() => usersSearchBloc.state)
            .thenReturn(const UsersSearchInitial());

        await tester.pumpWidget(
          MaterialApp(
            home: UsersListPage(
              usersListBloc: (_) => usersListBloc,
              usersSearchBloc: (_) => usersSearchBloc,
            ),
          ),
        );

        await tester.tap(find.byKey(const Key('searchAction')));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        verify(() => usersSearchBloc.add(const UsersSearchClear())).called(1);
      });
    });
  });
}
