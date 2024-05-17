import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/pages/update_adoption_info.page.dart';
import 'package:spk_app_frontend/features/adoption/views/views/update_adoption_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class MockUpdateRabbitGroupCubit extends MockCubit<UpdateRabbitGroupState>
    implements UpdateRabbitGroupCubit {}

class MockRabbitGroupCubit extends MockCubit<GetOneState<RabbitGroup>>
    implements RabbitGroupCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() {
    return false;
  }
}

void main() {
  group(UpdateAdoptionInfoPage, () {
    late UpdateRabbitGroupCubit updateCubit;
    late RabbitGroupCubit rabbitGroupCubit;
    late GoRouter goRouter;

    setUp(() {
      updateCubit = MockUpdateRabbitGroupCubit();
      rabbitGroupCubit = MockRabbitGroupCubit();
      goRouter = MockGoRouter();

      when(() => rabbitGroupCubit.state).thenReturn(const GetOneSuccess(
        data: RabbitGroup(id: '1', rabbits: []),
      ));

      when(() => updateCubit.state)
          .thenReturn(const UpdateRabbitGroupInitial());

      registerFallbackValue(RabbitGroupUpdateDto(
        id: '1',
      ));
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: UpdateAdoptionInfoPage(
            rabbitGroupId: '1',
            updateCubit: (_) => updateCubit,
            rabbitGroupCubit: (_) => rabbitGroupCubit,
          ),
        ),
      );
    }

    testWidgets(
        'renders InitialView when RabbitGroupState is RabbitGroupInitial',
        (WidgetTester tester) async {
      when(() => rabbitGroupCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
    });

    testWidgets(
        'renders FailureView when RabbitGroupState is RabbitGroupFailure',
        (WidgetTester tester) async {
      when(() => rabbitGroupCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'renders UpdateAdoptionInfoView when RabbitGroupState is RabbitGroupSuccess',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(UpdateAdoptionInfoView), findsOneWidget);
    });

    testWidgets(
        'calls UpdateRabbitGroupCubit update method when save button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byKey(const Key('saveButton')));
      verify(() => updateCubit.update(any())).called(1);
    });

    testWidgets(
        'shows success snackbar and pops when UpdatedRabbitGroup state is emitted',
        (WidgetTester tester) async {
      whenListen(
        updateCubit,
        Stream.fromIterable([
          const UpdatedRabbitGroup(),
        ]),
      );

      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('successSnackBar')), findsOneWidget);
      verify(() => goRouter.pop(true)).called(1);
    });

    testWidgets(
        'shows failure snackbar when UpdateRabbitGroupFailure state is emitted',
        (WidgetTester tester) async {
      whenListen(
        updateCubit,
        Stream.fromIterable([
          const UpdateRabbitGroupFailure(),
        ]),
      );

      await tester.pumpWidget(buildWidget());

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('failureSnackBar')), findsOneWidget);
    });
  });
}
