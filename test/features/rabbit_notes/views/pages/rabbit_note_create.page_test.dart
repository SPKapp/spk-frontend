import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_note_create.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note_modify.view.dart';

class MockRabbitNoteCreateCubit extends MockCubit<RabbitNoteCreateState>
    implements RabbitNoteCreateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitNoteCreatePage, () {
    late RabbitNoteCreateCubit createCubit;
    late GoRouter goRouter;

    setUp(() {
      createCubit = MockRabbitNoteCreateCubit();
      goRouter = MockGoRouter();

      when(() => createCubit.state).thenReturn(
        const RabbitNoteCreateInitial(),
      );

      when(() => goRouter.pushReplacement(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => Object());

      registerFallbackValue(
        const RabbitNoteCreateDto(rabbitId: 1, description: 'Test description'),
      );
    });

    Widget buildWidget({
      String? rabbitName,
      bool? isVetVisitInitial,
    }) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: RabbitNoteCreatePage(
            rabbitId: 1,
            rabbitName: rabbitName,
            isVetVisitInitial: isVetVisitInitial,
            rabbitNoteCreateCubit: (context) => createCubit,
          ),
        ),
      );
    }

    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(),
      );

      expect(find.byType(RabbitNoteModifyView), findsOneWidget);
      expect(find.byKey(const Key('successSnackBar')), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);
    });

    testWidgets('should show success snackbar', (WidgetTester tester) async {
      whenListen(
        createCubit,
        Stream.fromIterable([
          const RabbitNoteCreated(1),
        ]),
        initialState: const RabbitNoteCreateInitial(),
      );

      await tester.pumpWidget(
        buildWidget(rabbitName: 'Test Rabbit'),
      );

      await tester.enterText(
          find.byKey(const Key('descriptionField')), 'Test description');

      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsNothing);
      expect(find.byKey(const Key('successSnackBar')), findsOneWidget);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);

      verify(() => createCubit.createRabbitNote(
            const RabbitNoteCreateDto(
                rabbitId: 1, description: 'Test description'),
          )).called(1);
      verify(() => goRouter.pushReplacement(
            '/note/1',
            extra: {'rabbitName': 'Test Rabbit'},
          )).called(1);
    });

    testWidgets('should show error snackbar', (WidgetTester tester) async {
      whenListen(
        createCubit,
        Stream.fromIterable([
          const RabbitNoteCreateFailure(),
        ]),
        initialState: const RabbitNoteCreateInitial(),
      );

      await tester.pumpWidget(
        buildWidget(rabbitName: 'Test Rabbit'),
      );

      await tester.enterText(
          find.byKey(const Key('descriptionField')), 'Test description');
      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsNothing);
      expect(find.byKey(const Key('successSnackBar')), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsOneWidget);

      verify(() => createCubit.createRabbitNote(
            const RabbitNoteCreateDto(
                rabbitId: 1, description: 'Test description'),
          )).called(1);
      verifyNever(() => goRouter.pushReplacement(
            any(),
            extra: any(named: 'extra'),
          ));
    });

    testWidgets('should show error when description is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(rabbitName: 'Test Rabbit'),
      );

      await tester.tap(find.byKey(const Key('submitButton')));
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsOneWidget);
      expect(find.byKey(const Key('successSnackBar')), findsNothing);
      expect(find.byKey(const Key('errorSnackBar')), findsNothing);

      verifyNever(() => createCubit.createRabbitNote(any()));
      verifyNever(() => goRouter.pushReplacement(
            any(),
            extra: any(named: 'extra'),
          ));
    });
  });
}
