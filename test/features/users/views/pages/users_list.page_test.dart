import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/views/pages/users_list.page.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

void main() {
  group(UsersListPage, () {
    final MockUsersListBloc usersListBloc = MockUsersListBloc();

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
      expect(find.byKey(const Key('usersListFailureText')), findsNothing);
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
      expect(find.byKey(const Key('usersListFailureText')), findsOneWidget);
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
      expect(find.byKey(const Key('usersListFailureText')), findsNothing);
    });
  });
}

// TODO: Add search functionality
// TODO: Add filter functionality