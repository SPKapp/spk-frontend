import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models/user.model.dart';
import 'package:spk_app_frontend/features/users/views/pages/users_list.page.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

void main() {
  group(UsersListPage, () {
    late UsersListBloc usersListBloc;

    setUp(() {
      usersListBloc = MockUsersListBloc();

      when(() => usersListBloc.args).thenReturn(const FindUsersArgs());
    });

    testWidgets(
        'UsersListPage should display CircularProgressIndicator when state is UsersListInitial',
        (WidgetTester tester) async {
      when(() => usersListBloc.state)
          .thenAnswer((_) => const UsersListInitial());

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
      when(() => usersListBloc.state)
          .thenAnswer((_) => const UsersListFailure());
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
        (_) => const UsersListSuccess(
          users: [],
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
          const UsersListInitial(),
        ]),
        initialState: const UsersListSuccess(
          users: [],
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
          const UsersListFailure(
            users: [
              User(
                id: 1,
                firstName: 'John',
                lastName: 'Foe',
              )
            ],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
        initialState: const UsersListSuccess(
          users: [
            User(
              id: 1,
              firstName: 'John',
              lastName: 'Foe',
            )
          ],
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
  });
}
