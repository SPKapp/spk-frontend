import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbit_info.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class MockRabbitCubit extends MockCubit<GetOneState<Rabbit>>
    implements RabbitCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() {
    return false;
  }
}

void main() {
  group(RabbitInfoPage, () {
    late RabbitCubit rabbitCubit;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    const rabbit = Rabbit(
      id: '1',
      name: 'rabbitName',
      admissionType: AdmissionType.found,
      gender: Gender.female,
      confirmedBirthDate: false,
      rabbitGroup:
          RabbitGroup(id: '1', rabbits: [], team: Team(id: '1', users: [])),
    );

    setUp(() {
      rabbitCubit = MockRabbitCubit();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => rabbitCubit.state)
          .thenReturn(const GetOneSuccess(data: rabbit));

      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1],
        ),
      );

      when(() => goRouter.push(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => Object());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider<AuthCubit>.value(
            value: authCubit,
            child: RabbitInfoPage(
              rabbitId: '1',
              rabbitCubit: (_) => rabbitCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('should render InitialView when RabbitInitial', (tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitInfoView), findsNothing);
    });

    testWidgets('should render FailureView when RabbitFailure', (tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitInfoView), findsNothing);
    });

    testWidgets('should refresh Rabbit when FailureView onPressed',
        (tester) async {
      when(() => rabbitCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Spróbuj ponownie'));

      verify(() => rabbitCubit.fetch()).called(1);
    });

    testWidgets('should render RabbitInfoView when RabbitSuccess - admin',
        (tester) async {
      when(() => rabbitCubit.state)
          .thenReturn(const GetOneSuccess(data: rabbit));

      await mockNetworkImages(() async => tester.pumpWidget(buildWidget()));

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitInfoView), findsOneWidget);

      expect(find.byKey(const Key('rabbit_info_popup_menu')), findsOneWidget);
      expect(find.byKey(const Key('rabbit_info_edit_button')), findsOneWidget);
    });

    testWidgets('should render RabbitInfoView when RabbitSuccess - volunteer',
        (tester) async {
      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.volunteer],
          teamId: 1,
        ),
      );

      await mockNetworkImages(() async => tester.pumpWidget(buildWidget()));

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitInfoView), findsOneWidget);

      expect(find.byKey(const Key('rabbit_info_popup_menu')), findsNothing);
      expect(find.byKey(const Key('rabbit_info_edit_button')), findsOneWidget);
    });

    testWidgets('should render RabbitInfoView when RabbitSuccess - observer',
        (tester) async {
      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          uid: '1',
          token: 'token',
          roles: const [Role.regionRabbitObserver],
          observerRegions: const [1],
        ),
      );

      await mockNetworkImages(() async => tester.pumpWidget(buildWidget()));

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitInfoView), findsOneWidget);

      expect(find.byKey(const Key('rabbit_info_popup_menu')), findsNothing);
      expect(find.byKey(const Key('rabbit_info_edit_button')), findsNothing);
    });

    testWidgets('should navigate to rabbit notes list page - vet visit',
        (WidgetTester tester) async {
      await mockNetworkImages(() async => tester.pumpWidget(buildWidget()));

      await tester.tap(find.byKey(const Key('vetVisitButton')));
      await tester.pumpAndSettle();

      verify(() => goRouter.push('/rabbit/1/notes', extra: {
            'rabbitName': rabbit.name,
            'isVetVisit': true,
          }));
    });

    testWidgets('should navigate to rabbit notes list page - notes',
        (WidgetTester tester) async {
      await mockNetworkImages(() async => tester.pumpWidget(buildWidget()));

      await tester.tap(find.byKey(const Key('notesButton')));
      await tester.pump();

      verify(() => goRouter.push('/rabbit/1/notes', extra: {
            'rabbitName': rabbit.name,
            'isVetVisit': false,
          }));
    });
  });
}
