import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models/user.model.dart';
import 'package:spk_app_frontend/features/users/views/pages/users_list.page.dart';

class MockUsersListBloc extends MockBloc<GetListEvent, GetListState<User>>
    implements UsersListBloc {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() => false;
}

void main() {
  group(UsersListPage, () {
    late UsersListBloc usersListBloc;
    late GoRouter goRouter;

    setUp(() {
      usersListBloc = MockUsersListBloc();
      goRouter = MockGoRouter();

      when(() => usersListBloc.args).thenReturn(const FindUsersArgs());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: UsersListPage(
            usersListBloc: (_) => usersListBloc,
          ),
        ),
      );
    }

    testWidgets(
        'UsersListPage should display CircularProgressIndicator when state is UsersListInitial',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer((_) => GetListInitial<User>());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'UsersListPage should display "Failed to fetch users" when state is UsersListFailure',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer((_) => GetListFailure<User>());
      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListTile), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'should display ListTile with user name when state is UsersListSuccess and data is not empty',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer(
        (_) => GetListSuccess<User>(
          data: const [
            User(
              id: '1',
              firstName: 'John',
              lastName: 'Foe',
            )
          ],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('John Foe'), findsOneWidget);
      expect(find.byKey(const Key('usersListFailureText')), findsNothing);
    });

    testWidgets(
        'should display "Brak użytkowników." when state is UsersListSuccess and data is empty',
        (WidgetTester tester) async {
      when(() => usersListBloc.state).thenAnswer(
        (_) => GetListSuccess<User>(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Brak użytkowników.'), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });
  });
}
