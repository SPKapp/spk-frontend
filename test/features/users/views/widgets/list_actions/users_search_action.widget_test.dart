import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/widgets/list_actions.dart';

class MockUsersSearchBloc extends MockBloc<UsersSearchEvent, UsersSearchState>
    implements UsersSearchBloc {}

void main() {
  group(UsersSearchAction, () {
    late UsersSearchBloc usersSearchBloc;

    setUp(() {
      usersSearchBloc = MockUsersSearchBloc();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: UsersSearchAction(
            args: const FindUsersArgs(),
            usersSearchBloc: (context) => usersSearchBloc,
          ),
        ),
      );
    }

    testWidgets('renders SearchAction widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(SearchAction), findsOneWidget);
    });

    testWidgets('should display nothing when initial state',
        (WidgetTester tester) async {
      when(() => usersSearchBloc.state).thenReturn(UsersSearchInitial());

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SearchAction));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchInitial')), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(AppListView<User>), findsNothing);
    });

    testWidgets('should display FailureView when failure state',
        (WidgetTester tester) async {
      when(() => usersSearchBloc.state).thenReturn(UsersSearchFailure());

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SearchAction));
      await tester.pumpAndSettle();

      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets('should display AppListView when success state',
        (WidgetTester tester) async {
      when(() => usersSearchBloc.state).thenReturn(UsersSearchSuccess(
        query: 'query',
        teams: const [],
        totalCount: 0,
        hasReachedMax: false,
      ));

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(SearchAction));
      await tester.pumpAndSettle();

      expect(find.byType(AppListView<User>), findsOneWidget);
    });
  });
}
