import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/views/users_search_list.view.dart';

class MockUsersSearchBloc extends MockBloc<UsersSearchEvent, UsersSearchState>
    implements UsersSearchBloc {}

void main() {
  group(UsersSearchView, () {
    late UsersSearchBloc usersSearchBloc;

    const users = [
      User(id: '1', firstName: 'John', lastName: 'Doe'),
      User(id: '2', firstName: 'Jane', lastName: 'Smith'),
      User(id: '3', firstName: 'Thoman', lastName: 'Doe'),
      User(id: '4', firstName: 'Jake', lastName: 'Smith'),
    ];

    setUp(() {
      usersSearchBloc = MockUsersSearchBloc();
    });

    testWidgets('should display "Brak wyników." when users list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UsersSearchView(
            users: [],
            hasReachedMax: true,
          ),
        ),
      );

      expect(find.text('Brak wyników.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
        'should display CircularProgressIndicator when loading more users',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: const UsersSearchView(
              users: users,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user names when users list is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: const UsersSearchView(
              users: users,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      expect(find.text('${users[0].firstName} ${users[0].lastName}'),
          findsOneWidget);
      expect(find.text('${users[1].firstName} ${users[1].lastName}'),
          findsOneWidget);
    });

    testWidgets(
        'should call UsersSearchFetch when reaching the bottom of the list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: UsersSearchView(
              users: users + users + users,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('usersSearchListView')),
        const Offset(0, -300),
      );

      verify(() => usersSearchBloc.add(const UsersSearchFetch())).called(1);
    });
    testWidgets(
        'should not call UsersSearchFetch when page is scrollable and has reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: UsersSearchView(
              users: users + users + users,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      verifyNever(() => usersSearchBloc.add(const UsersSearchFetch()));
    });

    testWidgets(
        'should call UsersSearchFetch when page is not scrollable and has not reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: const UsersSearchView(
              users: users,
              hasReachedMax: false,
            ),
          ),
        ),
      );

      verify(() => usersSearchBloc.add(const UsersSearchFetch())).called(1);
    });

    testWidgets(
        'should not call UsersSearchFetch when page is not scrollable and has reached max',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: usersSearchBloc,
            child: const UsersSearchView(
              users: users,
              hasReachedMax: true,
            ),
          ),
        ),
      );

      verifyNever(() => usersSearchBloc.add(const UsersSearchFetch()));
    });
  });
}
