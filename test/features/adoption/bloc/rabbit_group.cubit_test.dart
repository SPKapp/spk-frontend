import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/adoption/bloc/rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class MockRabbitGroupsRepository extends Mock
    implements IRabbitGroupsRepository {}

void main() {
  group(RabbitGroupCubit, () {
    late RabbitGroupCubit rabbitGroupCubit;
    late IRabbitGroupsRepository mockRabbitGroupsRepository;

    setUp(() {
      mockRabbitGroupsRepository = MockRabbitGroupsRepository();
      rabbitGroupCubit = RabbitGroupCubit(
        rabbitGroupId: '1',
        rabbitGroupsRepository: mockRabbitGroupsRepository,
      );
    });

    tearDown(() {
      rabbitGroupCubit.close();
    });

    test('initial state is RabbitGroupInitial', () {
      expect(rabbitGroupCubit.state, equals(const RabbitGroupInitial()));
    });

    blocTest<RabbitGroupCubit, RabbitGroupState>(
      'emits [RabbitGroupSuccess] when fetch is successful',
      setUp: () {
        when(() => mockRabbitGroupsRepository.findOne('1'))
            .thenAnswer((_) async => const RabbitGroup(
                  id: '1',
                  rabbits: [],
                ));
      },
      build: () => rabbitGroupCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        const RabbitGroupSuccess(rabbitGroup: RabbitGroup(id: '1', rabbits: []))
      ],
    );

    blocTest<RabbitGroupCubit, RabbitGroupState>(
      'emits [RabbitGroupFailure] when fetch is unsuccessful',
      setUp: () {
        when(() => mockRabbitGroupsRepository.findOne('1'))
            .thenThrow(Exception());
      },
      build: () => rabbitGroupCubit,
      act: (cubit) => cubit.fetch(),
      expect: () => [
        const RabbitGroupFailure(),
      ],
    );

    blocTest<RabbitGroupCubit, RabbitGroupState>(
      'emits [RabbitGroupInitial, RabbitGroupSuccess] when refresh is called',
      setUp: () {
        when(() => mockRabbitGroupsRepository.findOne('1'))
            .thenAnswer((_) async => const RabbitGroup(
                  id: '1',
                  rabbits: [],
                ));
      },
      build: () => rabbitGroupCubit,
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const RabbitGroupInitial(),
        const RabbitGroupSuccess(rabbitGroup: RabbitGroup(id: '1', rabbits: []))
      ],
    );
  });
}
