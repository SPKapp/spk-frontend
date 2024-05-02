import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/views/widgets/list_actions/users_list_filters.widget.dart';

class MockUsersListBloc extends MockBloc<UsersListEvent, UsersListState>
    implements UsersListBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(UsersListFilters, () {
    late UsersListBloc usersListBloc;
    late GoRouter goRouter;

    setUp(() {
      usersListBloc = MockUsersListBloc();
      goRouter = MockGoRouter();
    });

    Widget buildWidget(FindUsersArgs args) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider(
            create: (context) => usersListBloc,
            child: Scaffold(
              body: UsersListFilters(
                args: args,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(const FindUsersArgs()),
      );

      expect(find.text('Filtruj użytkowników'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should send new args when saved', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(const FindUsersArgs()),
      );

      await tester.tap(find.byType(ChoiceChip).last);
      await tester.tap(find.text('Filtruj'));
      await tester.pumpAndSettle();

      verify(
        () => usersListBloc.add(
          const RefreshUsers(FindUsersArgs(isActive: false)),
        ),
      ).called(1);
      verify(() => goRouter.pop()).called(1);
    });
  });
}
