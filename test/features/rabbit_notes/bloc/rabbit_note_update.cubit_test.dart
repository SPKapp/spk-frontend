import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_update.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

class MockRabbitNotesRepository extends Mock
    implements IRabbitNotesRepository {}

void main() {
  group(RabbitNoteUpdateCubit, () {
    late RabbitNoteUpdateCubit cubit;
    late IRabbitNotesRepository mockRepository;

    setUp(() {
      mockRepository = MockRabbitNotesRepository();
      cubit = RabbitNoteUpdateCubit(
        rabbitNoteId: 1,
        rabbitNotesRepository: mockRepository,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is RabbitNoteUpdateInitial', () {
      expect(cubit.state, const RabbitNoteUpdateInitial());
    });

    group('update', () {
      const dto = RabbitNoteUpdateDto(id: 1, description: 'test');
      blocTest<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        'emits [RabbitNoteUpdated] when updateRabbitNote is called',
        setUp: () {
          when(() => mockRepository.update(dto)).thenAnswer((_) async {});
        },
        build: () => cubit,
        act: (cubit) => cubit.updateRabbitNote(dto),
        expect: () => [
          const RabbitNoteUpdated(),
        ],
        verify: (_) {
          verify(() => mockRepository.update(dto)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      blocTest<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        'emits [RabbitNoteUpdateFailure] when updateRabbitNote is called',
        setUp: () {
          when(() => mockRepository.update(dto)).thenThrow(Exception());
        },
        build: () => cubit,
        act: (cubit) => cubit.updateRabbitNote(dto),
        expect: () => [
          const RabbitNoteUpdateFailure(),
        ],
        verify: (_) {
          verify(() => mockRepository.update(dto)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );
    });

    group('remove', () {
      blocTest<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        'emits [RabbitNoteUpdated] when removeRabbitNote is called',
        setUp: () {
          when(() => mockRepository.remove(1)).thenAnswer((_) async {});
        },
        build: () => cubit,
        act: (cubit) => cubit.removeRabbitNote(),
        expect: () => [
          const RabbitNoteUpdated(),
        ],
        verify: (_) {
          verify(() => mockRepository.remove(1)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      blocTest<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        'emits [RabbitNoteUpdateFailure] when removeRabbitNote is called',
        setUp: () {
          when(() => mockRepository.remove(1)).thenThrow(Exception());
        },
        build: () => cubit,
        act: (cubit) => cubit.removeRabbitNote(),
        expect: () => [
          const RabbitNoteUpdateFailure(),
        ],
        verify: (_) {
          verify(() => mockRepository.remove(1)).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );
    });

    blocTest<RabbitNoteUpdateCubit, RabbitNoteUpdateState>(
        'emits [RabbitNoteUpdateInitial] when reset is called',
        build: () => cubit,
        act: (cubit) => cubit.resetState(),
        expect: () => [
              const RabbitNoteUpdateInitial(),
            ],
        verify: (_) {
          verifyZeroInteractions(mockRepository);
        });
  });
}
