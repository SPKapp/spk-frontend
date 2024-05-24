import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/form_fields.dart';
import 'package:spk_app_frontend/features/rabbits/views/widgets/rabbit_info_actions/change_status_action.widget.dart';

class MockRabbitUpdateCubit extends MockCubit<UpdateState>
    implements RabbitUpdateCubit {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(ChangeStatus, () {
    late RabbitUpdateCubit rabbitUpdateCubit;
    late GoRouter goRouter;

    const rabbitWithoutStatus = Rabbit(
      id: '1',
      name: 'Rabbit',
      gender: Gender.female,
      admissionType: AdmissionType.found,
      confirmedBirthDate: false,
    );
    const rabbit = Rabbit(
      id: '1',
      name: 'Rabbit',
      gender: Gender.female,
      admissionType: AdmissionType.found,
      confirmedBirthDate: false,
      status: RabbitStatus.adoptable,
    );

    setUp(() {
      rabbitUpdateCubit = MockRabbitUpdateCubit();
      goRouter = MockGoRouter();

      when(() => rabbitUpdateCubit.state).thenAnswer(
        (_) => const UpdateInitial(),
      );
    });

    Widget buildWidget({Rabbit rabbit = rabbitWithoutStatus}) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: Scaffold(
            body: ChangeStatus(
              rabbit: rabbit,
              rabbitUpdateCubit: (_) => rabbitUpdateCubit,
            ),
          ),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(RabbitStatusDropdown), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows snackbar when no status is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Nie wybrano statusu'), findsOneWidget);
    });

    testWidgets('shows snackbar when status is not changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(rabbit: rabbit));

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(find.text('Nie zmieniono statusu'), findsOneWidget);
    });

    testWidgets('calls changeRabbitStatus when status is changed',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(RabbitStatusDropdown));
      await tester.pumpAndSettle();
      await tester.tap(find.text(RabbitStatus.adopted.displayName).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      verify(() => rabbitUpdateCubit.changeRabbitStatus(
            rabbitWithoutStatus.id,
            RabbitStatus.adopted,
          )).called(1);
    });

    testWidgets('shows snackbar when status change fails',
        (WidgetTester tester) async {
      whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const UpdateInitial(),
            const UpdateFailure(),
          ]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nie udało się zmienić statusu królika.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when status change fails - not-all-deceased',
        (WidgetTester tester) async {
      whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const UpdateInitial(),
            const UpdateFailure(code: 'not-all-deceased'),
          ]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Aby zmienić status królika na "${RabbitStatus.deceased.displayName}" wszystkie króliki z grupy muszą mieć ten status. Użyj opcji zmień grupę i dodaj nową grupę dla zmarłego królika.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when status change fails - not-all-adopted',
        (WidgetTester tester) async {
      whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const UpdateInitial(),
            const UpdateFailure(code: 'not-all-adopted'),
          ]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Aby zmienić status królika na "${RabbitStatus.adopted.displayName}" wszystkie króliki z grupy muszą mieć ten status. Użyj menu adopcji aby zmienić status dla wszystkich królików w grupie.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'shows snackbar when status change fails - unavailable-group-status',
        (WidgetTester tester) async {
      whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const UpdateInitial(),
            const UpdateFailure(code: 'unavailable-group-status'),
          ]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Nie można ustalić statusu grupy królików. Prawdopodobnie żadne króliki nie mają statusu "${RabbitStatus.inTreatment.displayName}".',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows snackbar when status change succeeds',
        (WidgetTester tester) async {
      whenListen(
          rabbitUpdateCubit,
          Stream.fromIterable([
            const UpdateInitial(),
            const UpdateSuccess(),
          ]));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Zapisano zmiany'),
        findsOneWidget,
      );
    });
  });
}
