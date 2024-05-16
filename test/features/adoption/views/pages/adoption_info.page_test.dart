import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/pages/adoption_info.page.dart';
import 'package:spk_app_frontend/features/adoption/views/views/adoption_info.view.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

class MockRabbitGroupCubit extends MockCubit<GetOneState<RabbitGroup>>
    implements RabbitGroupCubit {}

void main() {
  group(AdoptionInfoPage, () {
    late RabbitGroupCubit rabbitGroupCubit;

    setUp(() {
      rabbitGroupCubit = MockRabbitGroupCubit();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: AdoptionInfoPage(
          rabbitGroupId: '1',
          rabbitGroupCubit: (_) => rabbitGroupCubit,
        ),
      );
    }

    testWidgets('renders InitialView when RabbitGroupInitial state is received',
        (WidgetTester tester) async {
      when(() => rabbitGroupCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(AdoptionInfoView), findsNothing);
    });

    testWidgets('renders FailureView when RabbitGroupFailure state is received',
        (WidgetTester tester) async {
      when(() => rabbitGroupCubit.state).thenReturn(const GetOneFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(AdoptionInfoView), findsNothing);
    });

    testWidgets(
        'renders AdoptionInfoView when RabbitGroupSuccess state is received',
        (WidgetTester tester) async {
      when(() => rabbitGroupCubit.state).thenReturn(const GetOneSuccess(
          data: RabbitGroup(
        id: '1',
        rabbits: [],
      )));

      await tester.pumpWidget(buildWidget());

      expect(find.byType(AdoptionInfoView), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });
  });
}
