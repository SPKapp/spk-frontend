import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_note.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note.view.dart';

class MockRabbitNoteCubit extends MockCubit<RabbitNoteState>
    implements RabbitNoteCubit {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  group(RabbitNotePage, () {
    late RabbitNoteCubit rabbitNoteCubit;
    late AppBloc appBloc;

    const rabbitNote = RabbitNote(id: 1);

    setUp(() {
      rabbitNoteCubit = MockRabbitNoteCubit();
      appBloc = MockAppBloc();

      when(() => rabbitNoteCubit.state).thenReturn(
        const RabbitNoteSuccess(rabbitNote: rabbitNote),
      );

      when(() => appBloc.state).thenAnswer(
        (_) => const AppState.authenticated(
          CurrentUser(
            id: 1,
            uid: '1',
            token: 'token',
            roles: [Role.regionManager],
            regions: [1],
          ),
        ),
      );
    });

    Widget buildWidget({String? rabbitName}) {
      return MaterialApp(
        home: BlocProvider.value(
          value: appBloc,
          child: RabbitNotePage(
            id: 1,
            rabbitNoteCubit: (_) => rabbitNoteCubit,
            rabbitName: rabbitName,
          ),
        ),
      );
    }

    testWidgets('renders InitialView when state is RabbitNoteInitial',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state).thenReturn(const RabbitNoteInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Notatka'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteView), findsNothing);
    });

    testWidgets('renders FailureView when state is RabbitNoteFailure',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state).thenReturn(const RabbitNoteFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Notatka'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
      expect(find.byType(RabbitNoteView), findsNothing);
    });

    testWidgets('renders RabbitNoteView when state is RabbitNoteSuccess',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(rabbitName: 'Królik'));

      expect(find.text('Notatka'), findsOneWidget);
      expect(find.text('Królik'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteView), findsOneWidget);
    });

    testWidgets('renders edit button when user can edit rabbit note',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('does not render edit button when cannot edit rabbit note',
        (WidgetTester tester) async {
      when(() => appBloc.state).thenAnswer(
        (_) => const AppState.authenticated(
          CurrentUser(
            id: 1,
            uid: '1',
            token: 'token',
            roles: [],
            regions: [1],
          ),
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
