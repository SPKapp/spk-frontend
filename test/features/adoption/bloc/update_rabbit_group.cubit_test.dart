import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

import 'package:spk_app_frontend/features/adoption/bloc/update_rabbit_group.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class MockRabbitGroupsRepository extends Mock
    implements IRabbitGroupsRepository {}

void main() {
  group(UpdateRabbitGroupCubit, () {
    late UpdateRabbitGroupCubit cubit;
    late IRabbitGroupsRepository mockRepository;

    setUp(() {
      mockRepository = MockRabbitGroupsRepository();
      cubit = UpdateRabbitGroupCubit(
        rabbitgroupId: 'rabbitgroupId',
        rabbitGroupsRepository: mockRepository,
      );

      registerFallbackValue(RabbitGroupUpdateDto(
        id: 'id',
      ));
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is UpdateRabbitGroupInitial', () {
      expect(cubit.state, equals(const UpdateInitial()));
    });

    blocTest<UpdateRabbitGroupCubit, UpdateState>(
      'emits [UpdatedRabbitGroup] when update is successful',
      setUp: () {
        when(() => mockRepository.update(any(), any()))
            .thenAnswer((_) async {});
      },
      build: () => cubit,
      act: (cubit) => cubit.update(RabbitGroupUpdateDto(
        id: 'id',
      )),
      expect: () => [const UpdateSuccess()],
    );

    blocTest<UpdateRabbitGroupCubit, UpdateState>(
      'emits [UpdateRabbitGroupFailure] when update fails',
      setUp: () {
        when(() => mockRepository.update(any(), any())).thenThrow(Exception());
      },
      build: () => cubit,
      act: (cubit) => cubit.update(RabbitGroupUpdateDto(
        id: 'id',
      )),
      expect: () => [const UpdateFailure(), const UpdateInitial()],
    );
  });
}
