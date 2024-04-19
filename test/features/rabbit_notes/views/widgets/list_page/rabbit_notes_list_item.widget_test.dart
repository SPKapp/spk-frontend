import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/views/widgets/list_page/rabbit_notes_list_item.widget.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitNoteListItem, () {
    late GoRouter goRouter;

    setUp(() {
      goRouter = MockGoRouter();
    });

    testWidgets('should display vet visit information correctly',
        (WidgetTester tester) async {
      final rabbitNote = RabbitNote(
        id: 1,
        vetVisit: VetVisit(
          visitInfo: const [
            VisitInfo(visitType: VisitType.control),
            VisitInfo(visitType: VisitType.chip),
          ],
          date: DateTime(2024, 1, 1),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RabbitNoteListItem(
              rabbitNote: rabbitNote,
            ),
          ),
        ),
      );

      expect(find.text('Wizyta Weterynaryjna'), findsOneWidget);
      expect(find.text('Notatka'), findsNothing);

      expect(
          find.text(
              '${rabbitNote.vetVisit!.visitInfo[0].visitType.displayName}, ${rabbitNote.vetVisit!.visitInfo[1].visitType.displayName}'),
          findsOneWidget);
      expect(find.text('2024-01-01\n00:00'), findsOneWidget);
    });

    testWidgets('should navigate to note details when tapped',
        (WidgetTester tester) async {
      const rabbitNote = RabbitNote(
        id: 1,
      );

      when(() => goRouter.push(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => Object());

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: goRouter,
            child: const Scaffold(
              body: RabbitNoteListItem(
                rabbitNote: rabbitNote,
                rabbitName: 'Fluffy',
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      verify(() => goRouter.push('/note/1', extra: {'rabbitName': 'Fluffy'}));
    });
  });
}
