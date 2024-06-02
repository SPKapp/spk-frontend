import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/bloc/user_update.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/pages/user_update.page.dart';
import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

class MockUserUpdateCubit extends MockCubit<UpdateState>
    implements UserUpdateCubit {}

class MockUserCubit extends MockCubit<GetOneState<User>> implements UserCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() {
    return false;
  }
}

void main() {
  group(UserUpdatePage, () {
    late UserUpdateCubit userUpdateCubit;
    late UserCubit userCubit;
    late GoRouter goRouter;

    setUp(() {
      userUpdateCubit = MockUserUpdateCubit();
      userCubit = MockUserCubit();
      goRouter = MockGoRouter();

      when(() => userUpdateCubit.state).thenReturn(const UpdateInitial());
      when(() => userCubit.state).thenReturn(
        const GetOneSuccess(
          data: User(
            id: '1',
            firstName: 'Jake',
            lastName: 'Doe',
            email: 'old@example.com',
            phone: '+48123456789',
          ),
        ),
      );

      registerFallbackValue(const UserUpdateDto());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: UserUpdatePage(
            updateCubit: (_) => userUpdateCubit,
            userCubit: (_) => userCubit,
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(UserModifyView), findsOneWidget);
    });

    testWidgets('displays initial view when UserState is UserInitial',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
    });

    testWidgets('displays failure view when UserState is UserFailure',
        (WidgetTester tester) async {
      when(() => userCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets('calls updateUser when form is submitted',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateInitial(),
          const UpdateSuccess(),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('firstnameTextField')), 'John');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      verify(() => userUpdateCubit
          .updateUser(const UserUpdateDto(firstName: 'John'))).called(1);

      expect(find.text('Użytkownik został zaktualizowany'), findsOneWidget);
      verify(() => goRouter.pop(true)).called(1);
    });

    testWidgets('displays failure message when update fails',
        (WidgetTester tester) async {
      whenListen(
        userUpdateCubit,
        Stream.fromIterable([
          const UpdateInitial(),
          const UpdateFailure(),
        ]),
        initialState: const UpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('firstnameTextField')), 'John');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      expect(
          find.text('Nie udało się zaktualizować użytkownika'), findsOneWidget);
    });

    testWidgets('displays no changes', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      verifyNever(() => userUpdateCubit.updateUser(any()));
    });

    testWidgets('displays email change notification',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('emailTextField')), 'email@example.com');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });
}
