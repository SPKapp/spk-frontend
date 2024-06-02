import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/users/bloc/user_update.cubit.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_actions/remove_user_action.widget.dart';

class MockUserUpdateCubit extends MockCubit<UpdateState>
    implements UserUpdateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RemoveUserAction, () {
    late UserUpdateCubit userUpdateCubit;
    late GoRouter goRouter;

    setUp(() {
      userUpdateCubit = MockUserUpdateCubit();
      goRouter = MockGoRouter();

      when(() => userUpdateCubit.state).thenReturn(const UpdateInitial());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: RemoveUserAction(
              userId: 'user123',
              userUpdateCubit: (_) => userUpdateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
          find.text('Czy na pewno chcesz usunąć użytkownika?'), findsOneWidget);
      expect(
          find.text(
              'Spowoduje to usunięcie wszystkich danych użytkownika, w tym jego uprawnień. Operacji tej nie można cofnąć.'),
          findsOneWidget);
      expect(find.text('Usuń'), findsOneWidget);
    });

    testWidgets(
        'shows success snackbar and pops when user is successfully removed',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateSuccess(),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Usuń'));
      await tester.pump();

      verify(() => userUpdateCubit.removeUser()).called(1);

      expect(find.text('Użytkownik został usunięty.'), findsOneWidget);
    });

    testWidgets(
        'shows failure snackbar and does not pop when user is not found',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateFailure(code: 'user-not-found'),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Użytkownik został usunięty.'), findsNothing);
      expect(find.text('Nie znaleziono użytkownika.'), findsOneWidget);
      expect(
          find.text('Nie można usunąć aktywnego użytkownika.'), findsNothing);
    });

    testWidgets('shows failure snackbar and does not pop when user is active',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateFailure(code: 'user-active'),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Użytkownik został usunięty.'), findsNothing);
      expect(find.text('Nie znaleziono użytkownika.'), findsNothing);
      expect(
          find.text('Nie można usunąć aktywnego użytkownika.'), findsOneWidget);
    });

    testWidgets('shows failure snackbar and does not pop when unknown error',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateFailure(),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Użytkownik został usunięty.'), findsNothing);
      expect(find.text('Nie znaleziono użytkownika.'), findsNothing);
      expect(
          find.text('Nie można usunąć aktywnego użytkownika.'), findsNothing);
      expect(find.text('Wystąpił błąd podczas usuwania użytkownika.'),
          findsOneWidget);
    });
  });
}
