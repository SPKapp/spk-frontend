import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_create.cubit.dart';

import 'rabbit_create.cubit_test.mocks.dart';

@GenerateMocks([IRabbitsRepository])
void main() {
  group(RabbitCreateCubit, () {
    final rabbitRepository = MockIRabbitsRepository();
    late RabbitCreateCubit rabbitCreateCubit;

    setUp(() {
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
        when(rabbitRepository.createRabbit(any)).thenAnswer((_) async => 1);
      },
      build: () => rabbitCreateCubit,
      act: (cubit) => cubit.createRabbit(
        RabbitCreateDto(
          name: 'name',
          rabbitGroupId: 1,
        ),
      ),
      expect: () => [
        const RabbitCreated(rabbitId: 1),
      ],
    );

    blocTest<RabbitCreateCubit, RabbitCreateState>(
      'emits [RabbitAddFailure] when addRabbit is called',
      setUp: () {
        when(rabbitRepository.createRabbit(any)).thenThrow(Exception());
      },
      build: () => rabbitCreateCubit,
      act: (cubit) => cubit.createRabbit(
        RabbitCreateDto(
          name: 'name',
          rabbitGroupId: 1,
        ),
      ),
      expect: () => [
        const RabbitCreateFailure(),
        const RabbitCreateInitial(),
      ],
    );
  });
}
