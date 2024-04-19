import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/item_page/rabbit_note_remove.widget.dart';

class MockRabbitNoteUpdateCubit extends MockCubit<RabbitNoteUpdateState>
    implements RabbitNoteUpdateCubit {}

void main() {
  group(RabbitNoteRemoveAction, () {
    late RabbitNoteUpdateCubit rabbitNoteUpdateCubit;
    late MockNavigator navigator;

    setUp(() {
      rabbitNoteUpdateCubit = MockRabbitNoteUpdateCubit();
      navigator = MockNavigator();

      when(() => rabbitNoteUpdateCubit.state).thenReturn(
        const RabbitNoteUpdateInitial(),
      );

      when(() => navigator.canPop()).thenReturn(true);
    });

    Widget buildWidget() {
      return MaterialApp(
        home: MockNavigatorProvider(
          navigator: navigator,
          child: Scaffold(
            body: RabbitNoteRemoveAction(
              rabbitNoteId: 1,
              rabbitNoteUpdateCubit: (context) => rabbitNoteUpdateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('should show confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Usuwanie notatki'), findsOneWidget);
      expect(find.text('Czy na pewno chcesz usunąć notatkę?'), findsOneWidget);
      expect(find.text('Anuluj'), findsOneWidget);
      expect(find.text('Usuń'), findsOneWidget);
    });

    testWidgets('should call removeRabbitNote when delete button is pressed',
        (WidgetTester tester) async {
      whenListen(
        rabbitNoteUpdateCubit,
        Stream.fromIterable([const RabbitNoteUpdated()]),
        initialState: const RabbitNoteUpdateInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Usuń'));
      await tester.pump();

      verify(() => rabbitNoteUpdateCubit.removeRabbitNote()).called(1);
      verify(() => navigator.pop(true)).called(1);
    });

    testWidgets('should show snackbar when note update fails',
        (WidgetTester tester) async {
      whenListen(
        rabbitNoteUpdateCubit,
        Stream.fromIterable([const RabbitNoteUpdateFailure()]),
        initialState: const RabbitNoteUpdateInitial(),
      );
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Usuń'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nie udało się usunąć notatki'), findsOneWidget);

      verify(() => navigator.pop(false)).called(1);
    });

    testWidgets('should close dialog when cancel button is pressed',
        (WidgetTester tester) async {
      when(() => navigator.pop(any())).thenAnswer((_) async => false);

      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('Anuluj'));
      await tester.pump();

      verify(() => navigator.pop(false)).called(1);
    });
  });
}
