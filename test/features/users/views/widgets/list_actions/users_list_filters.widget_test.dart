import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/views/widgets/list_actions/users_list_filters.widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(UsersListFilters, () {
    late GoRouter goRouter;

    setUp(() {
      goRouter = MockGoRouter();
    });

    Widget buildWidget(UsersListFilters child) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          UsersListFilters(
            args: const FindUsersArgs(),
            onFilter: (args) {},
          ),
        ),
      );

      expect(find.text('Filtruj użytkowników'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.text('Filtruj'), findsOneWidget);
    });

    testWidgets('should send new args when saved', (WidgetTester tester) async {
      bool onFilterCalled = false;

      await tester.pumpWidget(
        buildWidget(
          UsersListFilters(
            args: const FindUsersArgs(),
            onFilter: (args) {
              onFilterCalled = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(ChoiceChip).last);
      await tester.tap(find.text('Filtruj'));
      await tester.pumpAndSettle();

      expect(onFilterCalled, isTrue);
      verify(() => goRouter.pop()).called(1);
    });
  });
}
