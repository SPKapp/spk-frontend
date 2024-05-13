import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbit_info.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_info.view.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

class MockRabbitCubit extends MockCubit<RabbitState> implements RabbitCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group(RabbitInfoPage, () {
    late RabbitCubit rabbitCubit;
    late AuthCubit authCubit;

    const rabbit = Rabbit(
      id: 1,
      name: 'rabbitName',
      admissionType: AdmissionType.found,
      gender: Gender.female,
      confirmedBirthDate: false,
      rabbitGroup:
          RabbitGroup(id: 1, rabbits: [], team: Team(id: '1', users: [])),
    );

    setUp(() {
      rabbitCubit = MockRabbitCubit();
      authCubit = MockAuthCubit();

      when(() => rabbitCubit.state)
          .thenReturn(const RabbitSuccess(rabbit: rabbit));

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
        home: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: RabbitInfoPage(
            rabbitId: 1,
            rabbitCubit: (_) => rabbitCubit,
          ),
        ),
      );
    }

    testWidgets('should render InitialView when RabbitInitial', (tester) async {
      when(() => rabbitCubit.state).thenReturn(const RabbitInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitInfoView), findsNothing);
    });

    testWidgets('should render FailureView when RabbitFailure', (tester) async {
      when(() => rabbitCubit.state).thenReturn(const RabbitFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitInfoView), findsNothing);
    });

    testWidgets('should refresh Rabbit when FailureView onPressed',
        (tester) async {
      when(() => rabbitCubit.state).thenReturn(const RabbitFailure());

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Spróbuj ponownie'));

      verify(() => rabbitCubit.fetchRabbit()).called(1);
    });

    testWidgets('should render RabbitInfoView when RabbitSuccess - admin',
        (tester) async {
      when(() => rabbitCubit.state)
          .thenReturn(const RabbitSuccess(rabbit: rabbit));

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
  });
}
