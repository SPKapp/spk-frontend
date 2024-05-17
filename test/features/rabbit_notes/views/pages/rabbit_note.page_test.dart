import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/pages/rabbit_note.page.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note.view.dart';

class MockRabbitNoteCubit extends MockCubit<GetOneState<RabbitNote>>
    implements RabbitNoteCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group(RabbitNotePage, () {
    late RabbitNoteCubit rabbitNoteCubit;
    late AuthCubit authCubit;

    const rabbitNote = RabbitNote(id: '1');

    setUp(() {
      rabbitNoteCubit = MockRabbitNoteCubit();
      authCubit = MockAuthCubit();

      when(() => rabbitNoteCubit.state).thenReturn(
        const GetOneSuccess(data: rabbitNote),
      );

      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          id: 1,
          uid: '1',
          token: 'token',
          roles: const [Role.regionManager],
          managerRegions: const [1],
        ),
      );
    });

    Widget buildWidget({String? rabbitName}) {
      return MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: RabbitNotePage(
            id: '1',
            rabbitNoteCubit: (_) => rabbitNoteCubit,
            rabbitName: rabbitName,
          ),
        ),
      );
    }

    testWidgets('renders InitialView when state is RabbitNoteInitial',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state)
          .thenReturn(const GetOneInitial<RabbitNote>());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Notatka'), findsOneWidget);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(RabbitNoteView), findsNothing);
    });

    testWidgets('renders FailureView when state is RabbitNoteFailure',
        (WidgetTester tester) async {
      when(() => rabbitNoteCubit.state)
          .thenReturn(const GetOneFailure<RabbitNote>());

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
      when(() => authCubit.currentUser).thenAnswer(
        (_) => CurrentUser(
          id: 1,
          uid: '1',
          token: 'token',
          roles: const [],
        ),
      );

      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.byIcon(Icons.delete), findsNothing);
    });
  });
}
