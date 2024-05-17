import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/rabbit_update.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbit_update.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

class MockRabbitCubit extends MockCubit<GetOneState<Rabbit>>
    implements RabbitCubit {}

class MockRabbitUpdateCubit extends MockCubit<RabbitUpdateState>
    implements RabbitUpdateCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitUpdatePage, () {
    late RabbitCubit rabbitCubit;
    late RabbitUpdateCubit rabbitUpdateCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    const rabbit = Rabbit(
      id: '1',
      name: 'rabbitName',
      admissionType: AdmissionType.found,
      gender: Gender.female,
      confirmedBirthDate: false,
    );

    setUpAll(() {
      registerFallbackValue(RabbitUpdateDto(id: '1', name: 'rabbitName'));
    });

    setUp(() {
      rabbitCubit = MockRabbitCubit();
      rabbitUpdateCubit = MockRabbitUpdateCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => rabbitCubit.state)
          .thenReturn(const GetOneSuccess(data: rabbit));

      when(() => rabbitUpdateCubit.state)
          .thenAnswer((_) => const RabbitUpdateInitial());

      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1],
        ),
      );
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: RabbitUpdatePage(
              rabbitId: '1',
              rabbitCubit: (_) => rabbitCubit,
              rabbitUpdateCubit: (_) => rabbitUpdateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('should renders correctly - privileged',
        (WidgetTester tester) async {
      when(() => rabbitCubit.state)
          .thenReturn(const GetOneSuccess(data: rabbit));

      await tester.pumpWidget(buildWidget());

      expect(find.text(rabbit.name), findsWidgets);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(RabbitModifyView), findsOneWidget);
      expect(find.byKey(const Key('regionDropdown')), findsNothing);
      expect(find.byKey(const Key('nameTextField')), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should renders correctly - unprivileged',
        (WidgetTester tester) async {
      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.volunteer],
          teamId: 1,
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.text(rabbit.name), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(RabbitModifyView), findsOneWidget);
      expect(find.byKey(const Key('regionDropdown')), findsNothing);
      expect(find.byKey(const Key('nameTextField')), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should display InitialView when loading',
        (WidgetTester tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
    });

    testWidgets('should display FailureView when RabbitFailure',
        (WidgetTester tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets('should call fetchRabbit when FailureView onPressed',
        (WidgetTester tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Spróbuj ponownie'));

      verify(() => rabbitCubit.fetch()).called(1);
    });

    testWidgets(
        'should call RabbitUpdateCubit.updateRabbit when form is submitted',
        (WidgetTester tester) async {
      whenListen(
        rabbitUpdateCubit,
        Stream.fromIterable([const RabbitUpdated()]),
        initialState: const RabbitUpdateInitial(),
      );

      when(() => goRouter.pop(any())).thenAnswer((_) async => Object());

      final editControlers = FieldControlers();
      addTearDown(() => editControlers.dispose());
      editControlers.nameControler.text = 'rabbitName';

      await tester.pumpWidget(buildWidget());

      final sendButton = find.byIcon(Icons.save);
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Królik został zaktualizowany'), findsOneWidget);

      verify(
        () => rabbitUpdateCubit.updateRabbit(any()),
      ).called(1);
      verify(() => goRouter.pop(true)).called(1);
    });

    testWidgets('should show error message when rabbit update fails',
        (WidgetTester tester) async {
      whenListen(
        rabbitUpdateCubit,
        Stream.fromIterable([const RabbitUpdateFailure()]),
        initialState: const RabbitUpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());

      final sendButton = find.byIcon(Icons.save);
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Nie udało się zaktualizować królika'), findsOneWidget);
    });
  });
}
