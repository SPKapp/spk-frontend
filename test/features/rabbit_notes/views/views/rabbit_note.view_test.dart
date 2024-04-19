import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/extensions/date_time.extension.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/views/rabbit_note.view.dart';

class MockRabbitNoteCubit extends MockCubit<RabbitNoteState>
    implements RabbitNoteCubit {}

void main() {
  group(RabbitNoteView, () {
    late RabbitNoteCubit rabbitNoteCubit;

    setUp(() {
      rabbitNoteCubit = MockRabbitNoteCubit();
    });

    Widget buildWidget({required RabbitNote rabbitNote}) {
      return MaterialApp(
        home: BlocProvider.value(
          value: rabbitNoteCubit,
          child: Scaffold(
            body: RabbitNoteView(
              rabbitNote: rabbitNote,
            ),
          ),
        ),
      );
    }

    group('Note', () {
      testWidgets('should display correct information',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            rabbitNote: RabbitNote(
              id: 1,
              createdAt: DateTime(2024, 1, 1),
              description: 'Description',
              weight: 1.0,
            ),
          ),
        );

        expect(find.text('Notatka'), findsOneWidget);
        expect(find.text('Data Utworzenia:'), findsOneWidget);
        expect(
          find.text(DateTime(2024, 1, 1).toDateTimeString()),
          findsOneWidget,
        );
        expect(find.text('Opis:'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Waga:'), findsOneWidget);
        expect(find.text('1.0 kg'), findsOneWidget);

        expect(find.text('Wizyta weterynaryjna'), findsNothing);
        expect(find.text('Data Wizyty:'), findsNothing);
        expect(find.text('Typ Wizyty:'), findsNothing);
      });

      testWidgets('should display minimal info', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            rabbitNote: const RabbitNote(
              id: 1,
            ),
          ),
        );

        expect(find.text('Notatka'), findsOneWidget);
        expect(find.text('Data Utworzenia:'), findsOneWidget);
        expect(find.text('Opis:'), findsNothing);
        expect(find.text('Waga:'), findsNothing);

        expect(find.text('Nieznana'), findsOneWidget);
      });
    });

    group('Vet Visit', () {
      testWidgets('should display correct information',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            rabbitNote: RabbitNote(
              id: 1,
              description: 'Description',
              weight: 1.0,
              vetVisit: VetVisit(
                date: DateTime(2024, 1, 1),
                visitInfo: List.of([
                  const VisitInfo(
                    visitType: VisitType.control,
                    additionalInfo: 'Additional Info',
                  ),
                ]),
              ),
            ),
          ),
        );

        expect(find.text('Wizyta weterynaryjna'), findsOneWidget);
        expect(find.text('Data Wizyty:'), findsOneWidget);
        expect(
          find.text(DateTime(2024, 1, 1).toDateTimeString()),
          findsOneWidget,
        );
        expect(find.text('Opis:'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Waga:'), findsOneWidget);
        expect(find.text('1.0 kg'), findsOneWidget);
        expect(find.text('Typ Wizyty:'), findsOneWidget);

        expect(find.text('Notatka'), findsNothing);
        expect(find.text('Data Utworzenia:'), findsNothing);
      });

      testWidgets('should display minimal info', (WidgetTester tester) async {
        await tester.pumpWidget(
          buildWidget(
            rabbitNote: RabbitNote(
              id: 1,
              vetVisit: VetVisit(visitInfo: List.empty(growable: true)),
            ),
          ),
        );

        expect(find.text('Wizyta weterynaryjna'), findsOneWidget);
        expect(find.text('Data Wizyty:'), findsOneWidget);
        expect(find.text('Typ Wizyty:'), findsOneWidget);
        expect(find.text('Opis:'), findsNothing);
        expect(find.text('Waga:'), findsNothing);

        expect(find.text('Nieznana'), findsOneWidget);
      });
    });

    testWidgets('should call refreshRabbitNote when refreshing',
        (WidgetTester tester) async {
      whenListen(
        rabbitNoteCubit,
        Stream.fromIterable(
          [
            const RabbitNoteInitial(),
            const RabbitNoteSuccess(rabbitNote: RabbitNote(id: 1)),
          ],
        ),
      );

      await tester.pumpWidget(
        buildWidget(rabbitNote: const RabbitNote(id: 1)),
      );

      await tester.fling(
        find.byType(RabbitNoteView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      verify(() => rabbitNoteCubit.refreshRabbitNote()).called(1);
    });
  });
}
