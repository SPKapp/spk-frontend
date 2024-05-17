import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_note.cubit.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';

class MockRabbitNotesRepository extends Mock
    implements IRabbitNotesRepository {}

void main() {
  group(RabbitNoteCubit, () {
    late RabbitNoteCubit rabbitNoteCubit;
    late IRabbitNotesRepository rabbitNotesRepository;

    const RabbitNote rabbitNote = RabbitNote(
      id: '1',
      description: 'Test Rabbit Note',
    );

    setUp(() {
      rabbitNotesRepository = MockRabbitNotesRepository();
      rabbitNoteCubit = RabbitNoteCubit(
        rabbitNoteId: '1',
        rabbitNotesRepository: rabbitNotesRepository,
      );
    });

    tearDown(() {
      rabbitNoteCubit.close();
    });

    test('initial state is RabbitNoteInitial', () {
      expect(rabbitNoteCubit.state, const GetOneInitial<RabbitNote>());
    });

    blocTest<RabbitNoteCubit, GetOneState>(
      'emits [RabbitNoteSuccess] when fetchRabbitNote is called',
      setUp: () {
        when(() => rabbitNotesRepository.findOne('1'))
            .thenAnswer((_) async => rabbitNote);
      },
      build: () => rabbitNoteCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        const GetOneSuccess<RabbitNote>(data: rabbitNote),
      ],
      verify: (_) {
        verify(() => rabbitNotesRepository.findOne('1')).called(1);
        verifyNoMoreInteractions(rabbitNotesRepository);
      },
    );

    blocTest<RabbitNoteCubit, GetOneState>(
      'emits [RabbitNoteFailure] when fetchRabbitNote is called',
      setUp: () {
        when(() => rabbitNotesRepository.findOne('1')).thenThrow(Exception());
      },
      build: () => rabbitNoteCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        const GetOneFailure<RabbitNote>(),
      ],
      verify: (_) {
        verify(() => rabbitNotesRepository.findOne('1')).called(1);
        verifyNoMoreInteractions(rabbitNotesRepository);
      },
    );
  });
}
