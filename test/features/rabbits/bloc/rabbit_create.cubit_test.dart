import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_create.cubit.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitCreateCubit, () {
    final rabbitRepository = MockRabbitsRepository();
    late RabbitCreateCubit rabbitCreateCubit;

    final dto = RabbitCreateDto(
      name: 'name',
      rabbitGroupId: 1,
    );

    setUp(() {
      registerFallbackValue(dto);
      rabbitCreateCubit = RabbitCreateCubit(
        rabbitsRepository: rabbitRepository,
      );
    });

    test('initial state', () {
      expect(rabbitCreateCubit.state, equals(const RabbitCreateInitial()));
    });

    blocTest<RabbitCreateCubit, RabbitCreateState>(
        'emits [RabbitCreated] when addRabbit is called',
        setUp: () {
          when(() => rabbitRepository.createRabbit(any()))
              .thenAnswer((_) async => 1);
        },
        build: () => rabbitCreateCubit,
        act: (cubit) => cubit.createRabbit(dto),
        expect: () => [
              const RabbitCreated(rabbitId: 1),
            ],
        verify: (_) {
          verify(() => rabbitRepository.createRabbit(any())).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        });

    blocTest<RabbitCreateCubit, RabbitCreateState>(
      'emits [RabbitAddFailure] when addRabbit is called',
      setUp: () {
        when(() => rabbitRepository.createRabbit(any())).thenThrow(Exception());
      },
      build: () => rabbitCreateCubit,
      act: (cubit) => cubit.createRabbit(dto),
      expect: () => [
        const RabbitCreateFailure(),
        const RabbitCreateInitial(),
      ],
      verify: (_) {
        verify(() => rabbitRepository.createRabbit(any())).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );
  });
}
