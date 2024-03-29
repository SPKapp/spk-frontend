import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitCubit, () {
    final rabbitRepository = MockRabbitsRepository();
    late RabbitCubit rabbitCubit;

    const Rabbit rabbit = Rabbit(
      id: 1,
      name: 'name',
      gender: Gender.male,
      confirmedBirthDate: false,
      admissionType: AdmissionType.found,
    );

    setUp(() {
      registerFallbackValue(rabbit);
      rabbitCubit = RabbitCubit(
        rabbitsRepository: rabbitRepository,
        rabbitId: rabbit.id,
      );
    });

    test('initial state', () {
      expect(rabbitCubit.state, equals(const RabbitInitial()));
    });

    blocTest<RabbitCubit, RabbitState>(
      'emits [RabbitSuccess] when fetchRabbit is called',
      setUp: () {
        when(() => rabbitRepository.rabbit(rabbit.id))
            .thenAnswer((_) async => rabbit);
      },
      build: () => rabbitCubit,
      act: (cubit) => cubit.fetchRabbit(),
      expect: () => [
        const RabbitSuccess(rabbit: rabbit),
      ],
      verify: (_) {
        verify(() => rabbitRepository.rabbit(rabbit.id)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitCubit, RabbitState>(
      'emits [RabbitFailure] when fetchRabbit is called',
      setUp: () {
        when(() => rabbitRepository.rabbit(rabbit.id)).thenThrow(Exception());
      },
      build: () => rabbitCubit,
      act: (cubit) => cubit.fetchRabbit(),
      expect: () => [
        const RabbitFailure(),
      ],
      verify: (_) {
        verify(() => rabbitRepository.rabbit(rabbit.id)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );
  });
}
