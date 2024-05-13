import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/views/users_list.view.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

void main() {
  group(UsersListView, () {
    late UsersListBloc usersListBloc;

    const users = [
      User(id: '1', firstName: 'John', lastName: 'Doe'),
      User(id: '2', firstName: 'Jane', lastName: 'Smith'),
    ];

    setUp(() {
      usersListBloc = MockUsersListBloc();
    });

    testWidgets('should display "Brak użytkowników." when teams list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UsersListView(
            users: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak użytkowników.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when hasReachedMax is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UsersListView(
            users: users,
            hasReachedMax: false,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user names when teams list is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UsersListView(
            users: users,
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('${users[0].firstName} ${users[0].lastName}'),
          findsOneWidget);
      expect(find.text('${users[1].firstName} ${users[1].lastName}'),
          findsOneWidget);
    });

    testWidgets('should call FetchUsers event when scroll reaches the end',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 500);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<UsersListBloc>.value(
            value: usersListBloc,
            child: const UsersListView(
              users: users,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('appListView')),
        const Offset(0, -100),
      );
      await tester.pump();

      verify(() => usersListBloc.add(const FetchUsers())).called(1);
    });

    testWidgets('should call RefreshUsers event when pull to refresh',
        (WidgetTester tester) async {
      whenListen(
        usersListBloc,
        Stream.fromIterable([
          const UsersListInitial(),
          const UsersListSuccess(
            users: [],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<UsersListBloc>.value(
            value: usersListBloc,
            child: const UsersListView(
              users: users,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      await tester.fling(
          find.text('${users[0].firstName} ${users[0].lastName}'),
          const Offset(0, 400),
          1000);
      await tester.pumpAndSettle();

      verify(() => usersListBloc.add(const RefreshUsers(null))).called(1);
    });

    testWidgets(
        'should call RefreshUsers event when RefreshIndicator is pulled and no teams are displayed',
        (WidgetTester tester) async {
      whenListen(
        usersListBloc,
        Stream.fromIterable([
          const UsersListInitial(),
          const UsersListSuccess(
            users: [],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<UsersListBloc>.value(
            value: usersListBloc,
            child: const UsersListView(
              users: [],
              hasReachedMax: true,
            ),
          ),
        ),
      );

      await tester.fling(
          find.text('Brak użytkowników.'), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      verify(() => usersListBloc.add(const RefreshUsers(null))).called(1);
    });
  });
}
