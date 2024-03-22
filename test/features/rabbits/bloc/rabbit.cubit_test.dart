import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit.cubit.dart';

import 'rabbit.cubit_test.mocks.dart';

@GenerateMocks([IRabbitsRepository])
void main() {
  group(RabbitCubit, () {
    final rabbitRepository = MockIRabbitsRepository();
    late RabbitCubit rabbitCubit;

    const Rabbit rabbit = Rabbit(
      id: 1,
      name: 'name',
      gender: Gender.male,
      confirmedBirthDate: false,
      admissionType: AdmissionType.found,
    );

    setUp(() {
      provideDummy(rabbit);
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
        when(rabbitRepository.rabbit(rabbit.id))
            .thenAnswer((_) async => rabbit);
      },
      build: () => rabbitCubit,
      act: (cubit) => cubit.fetchRabbit(),
      expect: () => [
        const RabbitSuccess(rabbit: rabbit),
      ],
    );

    blocTest<RabbitCubit, RabbitState>(
      'emits [RabbitFailure] when fetchRabbit is called',
      setUp: () {
        when(rabbitRepository.rabbit(rabbit.id)).thenThrow(Exception());
      },
      build: () => rabbitCubit,
      act: (cubit) => cubit.fetchRabbit(),
      expect: () => [
        const RabbitFailure(),
      ],
    );
  });
}
