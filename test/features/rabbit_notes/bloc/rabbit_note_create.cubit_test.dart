import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

class MockRabbitNotesRepository extends Mock
    implements IRabbitNotesRepository {}

void main() {
  group(RabbitNoteCreateCubit, () {
    late RabbitNoteCreateCubit cubit;
    late IRabbitNotesRepository mockRabbitNotesRepository;

    setUp(() {
      mockRabbitNotesRepository = MockRabbitNotesRepository();
      cubit = RabbitNoteCreateCubit(
        rabbitNotesRepository: mockRabbitNotesRepository,
      );

      registerFallbackValue(
        const RabbitNoteCreateDto(
          rabbitId: 1,
          description: 'description',
        ),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is RabbitNoteCreateInitial', () {
      expect(cubit.state, const RabbitNoteCreateInitial());
    });

    blocTest<RabbitNoteCreateCubit, RabbitNoteCreateState>(
      'emits [RabbitNoteCreated] when createRabbitNote is called',
      setUp: () {
        when(() => mockRabbitNotesRepository.create(any()))
            .thenAnswer((_) async => 1);
      },
      build: () => cubit,
      act: (cubit) => cubit.createRabbitNote(const RabbitNoteCreateDto(
        rabbitId: 1,
        description: 'description',
      )),
      expect: () => [
        const RabbitNoteCreated(1),
      ],
      verify: (_) {
        verify(() => mockRabbitNotesRepository.create(any())).called(1);
        verifyNoMoreInteractions(mockRabbitNotesRepository);
      },
    );

    blocTest<RabbitNoteCreateCubit, RabbitNoteCreateState>(
      'emits [RabbitNoteCreateFailure] when createRabbitNote is called',
      setUp: () {
        when(() => mockRabbitNotesRepository.create(any()))
            .thenThrow(Exception());
      },
      build: () => cubit,
      act: (cubit) => cubit.createRabbitNote(const RabbitNoteCreateDto(
        rabbitId: 1,
        description: 'description',
      )),
      expect: () => [
        const RabbitNoteCreateFailure(),
      ],
      verify: (_) {
        verify(() => mockRabbitNotesRepository.create(any())).called(1);
        verifyNoMoreInteractions(mockRabbitNotesRepository);
      },
    );
  });
}
