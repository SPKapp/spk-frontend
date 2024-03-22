import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';

import 'rabbit_update.cubit_test.mocks.dart';

@GenerateMocks([IRabbitsRepository])
void main() {
  group(RabbitUpdateCubit, () {
    final rabbitRepository = MockIRabbitsRepository();
    late RabbitUpdateCubit rabbitUpdateCubit;

    setUp(() {
      rabbitUpdateCubit = RabbitUpdateCubit(
        rabbitsRepository: rabbitRepository,
      );
    });

    test('initial state', () {
      expect(rabbitUpdateCubit.state, equals(const RabbitUpdateInitial()));
    });

    blocTest<RabbitUpdateCubit, RabbitUpdateState>(
      'emits [RabbitUpdated] when updateRabbit is called',
      setUp: () {
        when(rabbitRepository.updateRabbit(any)).thenAnswer((_) async => 1);
      },
      build: () => rabbitUpdateCubit,
      act: (cubit) => cubit.updateRabbit(
        RabbitUpdateDto(
          id: 1,
          name: 'name',
          rabbitGroupId: 1,
        ),
      ),
      expect: () => [
        const RabbitUpdated(),
      ],
    );

    blocTest<RabbitUpdateCubit, RabbitUpdateState>(
      'emits [RabbitUpdateFailure] when updateRabbit is called',
      setUp: () {
        when(rabbitRepository.updateRabbit(any)).thenThrow(Exception());
      },
      build: () => rabbitUpdateCubit,
      act: (cubit) => cubit.updateRabbit(
        RabbitUpdateDto(
          id: 1,
          name: 'name',
          rabbitGroupId: 1,
        ),
      ),
      expect: () => [
        const RabbitUpdateFailure(),
        const RabbitUpdateInitial(),
      ],
    );
  });
}
