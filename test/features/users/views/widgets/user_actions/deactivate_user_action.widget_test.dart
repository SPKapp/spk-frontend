import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_actions/deactivate_user_action.widget.dart';

class MockUserPermissionsCubit extends MockCubit<UserPermissionsState>
    implements UserPermissionsCubit {}

void main() {
  group('DeactivateUserAction', () {
    late MockUserPermissionsCubit mockUserPermissionsCubit;
    late MockNavigator navigator;

    setUp(() {
      mockUserPermissionsCubit = MockUserPermissionsCubit();
      navigator = MockNavigator();

      when(() => mockUserPermissionsCubit.state).thenReturn(
        const UserPermissionsInitial(),
      );

      when(() => navigator.canPop()).thenReturn(true);
    });

    Widget buildWidget(bool isActive) {
      return MaterialApp(
        home: MockNavigatorProvider(
          navigator: navigator,
          child: Scaffold(
            body: DeactivateUserAction(
              userId: '1',
              isActive: isActive,
              userPermissionsCubit: (_) => mockUserPermissionsCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('should show the correct dialog content',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(true));

      expect(find.text('Czy na pewno chcesz dezaktywować użytkownika?'),
          findsOneWidget);
      expect(
          find.text(
              'Spowoduje to dezaktywację użytkownika, co uniemożliwi mu logowanie do aplikacji.'),
          findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Dezaktywuj'), findsOneWidget);
    });

    testWidgets('should show the correct dialog content when isActive is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(false));

      expect(find.text('Czy na pewno chcesz aktywować użytkownika?'),
          findsOneWidget);
      expect(
          find.text(
              'Spowoduje to aktywację użytkownika, co umożliwi mu logowanie do aplikacji.'),
          findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Aktywuj'), findsOneWidget);
    });

    testWidgets('should call deactivateUser when Dezaktywuj button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(true));

      await tester.tap(find.text('Dezaktywuj'));
      await tester.pump();

      verify(() => mockUserPermissionsCubit.deactivateUser()).called(1);
    });

    testWidgets('should call activateUser when Aktywuj button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(false),
      );

      await tester.tap(find.text('Aktywuj'));
      verify(() => mockUserPermissionsCubit.activateUser()).called(1);
    });

    testWidgets('should show snackbar on success', (WidgetTester tester) async {
      whenListen(
        mockUserPermissionsCubit,
        Stream.fromIterable([const UserPermissionsSuccess()]),
        initialState: const UserPermissionsInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget(true));

      await tester.tap(find.text('Dezaktywuj'));
      await tester.pump();

      expect(find.text('Użytkownik został dezaktywowany'), findsOneWidget);

      verify(() => navigator.pop(true)).called(1);
    });

    testWidgets('should show snackbar on success - isActive false',
        (WidgetTester tester) async {
      whenListen(
        mockUserPermissionsCubit,
        Stream.fromIterable([const UserPermissionsSuccess()]),
        initialState: const UserPermissionsInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget(false));

      await tester.tap(find.text('Aktywuj'));
      await tester.pump();

      expect(find.text('Użytkownik został aktywowany'), findsOneWidget);

      verify(() => navigator.pop(true)).called(1);
    });

    testWidgets('should show snackbar on failure', (WidgetTester tester) async {
      whenListen(
        mockUserPermissionsCubit,
        Stream.fromIterable([const UserPermissionsFailure()]),
        initialState: const UserPermissionsInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget(true));

      await tester.tap(find.text('Dezaktywuj'));
      await tester.pump();

      expect(
          find.text('Nie udało się dezaktywować użytkownika'), findsOneWidget);

      verify(() => navigator.pop(false)).called(1);
    });
    testWidgets('should show snackbar on failure - isActive false',
        (WidgetTester tester) async {
      whenListen(
        mockUserPermissionsCubit,
        Stream.fromIterable([const UserPermissionsFailure()]),
        initialState: const UserPermissionsInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget(false));

      await tester.tap(find.text('Aktywuj'));
      await tester.pump();

      expect(find.text('Nie udało się aktywować użytkownika'), findsOneWidget);

      verify(() => navigator.pop(false)).called(1);
    });

    testWidgets('should close dialog on cancel', (WidgetTester tester) async {
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget(true));

      await tester.tap(find.text('Anuluj'));
      await tester.pump();

      verify(() => navigator.pop(false)).called(1);
    });
  });
}
