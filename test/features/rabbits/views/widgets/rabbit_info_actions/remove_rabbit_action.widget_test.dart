import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions.dart';

class MockRabbitUpdateCubit extends MockCubit<RabbitUpdateState>
    implements RabbitUpdateCubit {}

void main() {
  group(RemoveRabbitAction, () {
    late RabbitUpdateCubit rabbitUpdateCubit;
    late MockNavigator navigator;

    setUp(() {
      rabbitUpdateCubit = MockRabbitUpdateCubit();
      navigator = MockNavigator();

      when(() => rabbitUpdateCubit.state).thenReturn(
        const RabbitUpdateInitial(),
      );

      when(() => navigator.canPop()).thenReturn(true);
    });

    Widget buildWidget() {
      return MaterialApp(
        home: MockNavigatorProvider(
          navigator: navigator,
          child: Scaffold(
            body: RemoveRabbitAction(
              rabbitId: '1',
              rabbitUpdateCubit: (context) => rabbitUpdateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('should show confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Czy na pewno chcesz usunąć królika?'), findsOneWidget);
      expect(
          find.text(
              'Spowoduje to usunięcie królika z bazy danych, wraz z powiązanymi notatkami, zdjęciami i innymi danymi.'),
          findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Usuń'), findsOneWidget);
    });

    testWidgets('should call removeRabbit when delete button is pressed',
        (WidgetTester tester) async {
      whenListen(
        rabbitUpdateCubit,
        Stream.fromIterable([const RabbitUpdated()]),
        initialState: const RabbitUpdateInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Usuń'));
      await tester.pump();

      verify(() => rabbitUpdateCubit.removeRabbit('1')).called(1);
      verify(() => navigator.pop(true)).called(1);
    });

    testWidgets('should show snackbar on failure', (WidgetTester tester) async {
      whenListen(
        rabbitUpdateCubit,
        Stream.fromIterable([const RabbitUpdateFailure()]),
        initialState: const RabbitUpdateInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Usuń'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);

      verify(() => navigator.pop(false)).called(1);
    });

    testWidgets('should close dialog on cancel', (WidgetTester tester) async {
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Anuluj'));
      await tester.pump();

      verify(() => navigator.pop(false)).called(1);
    });
  });
}
