import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/adoption/views/widgets/info_actions/set_adopted_action.widget.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';

class MockUpdateRabbitGroupCubit extends MockCubit<UpdateState>
    implements UpdateRabbitGroupCubit {}

void main() {
  group(SetAdoptedAction, () {
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
            body: SetAdoptedAction(
              rabbitGroupId: '1',
              rabbitGroupUpdateCubit: (context) => updateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(
          find.text(
              'Spowoduje to zmianę statusu wszystkich królików w grupie na "Adoptowane".'),
          findsOneWidget);
      expect(find.byType(DateField), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });
  });
}
