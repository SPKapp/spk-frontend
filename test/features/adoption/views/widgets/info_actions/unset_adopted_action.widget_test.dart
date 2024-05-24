import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/widgets/info_actions/unset_adopted_action.widget.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';

class MockUpdateRabbitGroupCubit extends MockCubit<UpdateState>
    implements UpdateRabbitGroupCubit {}

void main() {
  group(UnsetAdoptedAction, () {
    late UpdateRabbitGroupCubit updateCubit;
    late MockNavigator navigator;

    setUp(() {
      updateCubit = MockUpdateRabbitGroupCubit();
      navigator = MockNavigator();

      when(() => updateCubit.state).thenReturn(const UpdateInitial());
      when(() => navigator.canPop()).thenReturn(true);

      registerFallbackValue(RabbitGroupUpdateDto(
        id: '1',
      ));
    });

    Widget buildWidget() {
      return MaterialApp(
        home: MockNavigatorProvider(
          navigator: navigator,
          child: Scaffold(
            body: UnsetAdoptedAction(
              rabbitGroupId: '1',
              rabbitGroupUpdateCubit: (context) => updateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders AlertDialog with correct title and content',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Czy na pewno chcesz cofnąć adopcję?'), findsOneWidget);
    });

    testWidgets('calls Navigator.pop when cancel button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Anuluj'));

      verifyNever(() => updateCubit.update(any()));
      verify(() => navigator.pop(false)).called(1);
    });

    testWidgets(
        'calls UpdateRabbitGroupCubit.update with RabbitGroupUpdateDto when confirm button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Cofnij adopcję'));

      verify(() => updateCubit.update(any())).called(1);
      verifyNever(() => navigator.pop(false));
    });
  });
}
