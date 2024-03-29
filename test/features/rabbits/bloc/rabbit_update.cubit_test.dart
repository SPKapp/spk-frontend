import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitUpdateCubit, () {
    final rabbitRepository = MockRabbitsRepository();
    late RabbitUpdateCubit rabbitUpdateCubit;

    final dto = RabbitUpdateDto(
      id: 1,
      name: 'name',
      rabbitGroupId: 1,
    );

    setUp(() {
      registerFallbackValue(dto);
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
        when(() => rabbitRepository.updateRabbit(any()))
            .thenAnswer((_) async => 1);
      },
      build: () => rabbitUpdateCubit,
      act: (cubit) => cubit.updateRabbit(dto),
      expect: () => [
        const RabbitUpdated(),
      ],
    );

    blocTest<RabbitUpdateCubit, RabbitUpdateState>(
      'emits [RabbitUpdateFailure] when updateRabbit is called',
      setUp: () {
        when(() => rabbitRepository.updateRabbit(any())).thenThrow(Exception());
      },
      build: () => rabbitUpdateCubit,
      act: (cubit) => cubit.updateRabbit(dto),
      expect: () => [
        const RabbitUpdateFailure(),
        const RabbitUpdateInitial(),
      ],
    );
  });
}
