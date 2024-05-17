import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_note_update.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note_modify.view.dart';

class MockRabbitNoteCubit extends MockCubit<GetOneState<RabbitNote>>
    implements RabbitNoteCubit {}

class MockRabbitNoteUpdateCubit extends MockCubit<RabbitNoteUpdateState>
    implements RabbitNoteUpdateCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() {
    return false;
  }
}

void main() {
  group(RabbitNoteUpdatePage, () {
    late RabbitNoteCubit rabbitNoteCubit;
    late RabbitNoteUpdateCubit rabbitNoteUpdateCubit;
    late GoRouter goRouter;

    setUp(() {
      rabbitNoteCubit = MockRabbitNoteCubit();
      rabbitNoteUpdateCubit = MockRabbitNoteUpdateCubit();
      goRouter = MockGoRouter();

      when(() => rabbitNoteCubit.state).thenReturn(
        const GetOneSuccess<RabbitNote>(
            data: RabbitNote(id: '1', description: 'Test')),
      );

      when(() => rabbitNoteUpdateCubit.state).thenReturn(
        const RabbitNoteUpdateInitial(),
      );

      registerFallbackValue(
        const RabbitNoteUpdateDto(id: '1'),
      );
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: RabbitNoteUpdatePage(
            rabbitNoteId: '1',
            rabbitNoteCubit: (context) => rabbitNoteCubit,
            rabbitNoteUpdateCubit: (context) => rabbitNoteUpdateCubit,
          ),
        ),
      );
    }

    testWidgets('should render correctly - initialView',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state)
          .thenReturn(const GetOneInitial<RabbitNote>());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteModifyView), findsNothing);
    });

    testWidgets('should render correctly - failureView',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state)
          .thenReturn(const GetOneFailure<RabbitNote>());

      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitNoteModifyView), findsNothing);
    });

    testWidgets('should render correctly - rabbitNoteModifyView',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteModifyView), findsOneWidget);
    });

    testWidgets('should show success snackbar', (WidgetTester tester) async {
      whenListen(
        rabbitNoteUpdateCubit,
        Stream.fromIterable([
          const RabbitNoteUpdated(),
        ]),
        initialState: const RabbitNoteUpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('descriptionField')), 'Test description');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      verify(() => rabbitNoteUpdateCubit.updateRabbitNote(
            const RabbitNoteUpdateDto(
              id: '1',
              description: 'Test description',
              weight: 0.0,
              vetVisit: null,
            ),
          )).called(1);
      verify(() => goRouter.pop(true)).called(1);
    });

    testWidgets('should show error snackbar', (WidgetTester tester) async {
      whenListen(
        rabbitNoteUpdateCubit,
        Stream.fromIterable([
          const RabbitNoteUpdateFailure(),
        ]),
        initialState: const RabbitNoteUpdateInitial(),
      );

      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byKey(const Key('descriptionField')), 'Test description');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      expect(find.byKey(const Key('errorSnackBar')), findsOneWidget);
      verify(() => rabbitNoteUpdateCubit.updateRabbitNote(
            const RabbitNoteUpdateDto(
              id: '1',
              description: 'Test description',
              weight: 0.0,
              vetVisit: null,
            ),
          )).called(1);
      verifyNever(() => goRouter.pop(any()));
    });

    testWidgets('should not send request when form is invalid',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(find.byKey(const Key('descriptionField')), '');
      await tester.tap(find.byKey(const Key('saveButton')));
      await tester.pump();

      expect(find.text('Pole nie może być puste'), findsOneWidget);
      verifyNever(() => rabbitNoteUpdateCubit.updateRabbitNote(any()));
      verifyNever(() => goRouter.pop(any()));
    });
  });
}
