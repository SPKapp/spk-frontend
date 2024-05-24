import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/common/exceptions/repository.exception.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitUpdateCubit, () {
    late IRabbitsRepository rabbitRepository;
    late RabbitUpdateCubit rabbitUpdateCubit;

    final dto = RabbitUpdateDto(
      id: '1',
      name: 'name',
    );

    setUp(() {
      registerFallbackValue(dto);
      rabbitRepository = MockRabbitsRepository();
      rabbitUpdateCubit = RabbitUpdateCubit(
        rabbitsRepository: rabbitRepository,
      );
      registerFallbackValue(RabbitStatus.incoming);
    });

    test('initial state', () {
      expect(rabbitUpdateCubit.state, equals(const UpdateInitial()));
    });

    group('updateRabbit', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
        'emits [RabbitUpdated] when updateRabbit is called',
        setUp: () {
          when(() => rabbitRepository.updateRabbit(any()))
              .thenAnswer((_) async => 1);
        },
        build: () => rabbitUpdateCubit,
        act: (cubit) => cubit.updateRabbit(dto),
        expect: () => [
          const UpdateSuccess(),
        ],
        verify: (_) {
          verify(() => rabbitRepository.updateRabbit(dto)).called(1);
        },
      );

      blocTest<RabbitUpdateCubit, UpdateState>(
        'emits [RabbitUpdateFailure] when updateRabbit is called',
        setUp: () {
          when(() => rabbitRepository.updateRabbit(any()))
              .thenThrow(Exception());
        },
        build: () => rabbitUpdateCubit,
        act: (cubit) => cubit.updateRabbit(dto),
        expect: () => [
          const UpdateFailure(),
          const UpdateInitial(),
        ],
        verify: (_) {
          verify(() => rabbitRepository.updateRabbit(dto)).called(1);
        },
      );
    });

    group('changeTeam', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdated] when changeTeam is called',
          setUp: () {
            when(() => rabbitRepository.updateTeam(any(), any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeTeam('1', '1'),
          expect: () => [
                const UpdateSuccess(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateTeam('1', '1')).called(1);
          });

      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdateFailure] when changeTeam is called',
          setUp: () {
            when(() => rabbitRepository.updateTeam(any(), any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeTeam('1', '1'),
          expect: () => [
                const UpdateFailure(),
                const UpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateTeam('1', '1')).called(1);
          });
    });

    group('changeRabbitGroup', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdated] when changeRabbitGroup is called',
          setUp: () {
            when(() => rabbitRepository.updateRabbitGroup(any(), any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeRabbitGroup('1', '1'),
          expect: () => [
                const UpdateSuccess(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateRabbitGroup('1', '1'))
                .called(1);
          });

      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdateFailure] when changeRabbitGroup is called',
          setUp: () {
            when(() => rabbitRepository.updateRabbitGroup(any(), any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeRabbitGroup('1', '1'),
          expect: () => [
                const UpdateFailure(),
                const UpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateRabbitGroup('1', '1'))
                .called(1);
          });
    });

    group('removeRabbit', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdated] when removeRabbit is called',
          setUp: () {
            when(() => rabbitRepository.removeRabbit(any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.removeRabbit('1'),
          expect: () => [
                const UpdateSuccess(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.removeRabbit('1')).called(1);
          });

      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdateFailure] when removeRabbit is called',
          setUp: () {
            when(() => rabbitRepository.removeRabbit(any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.removeRabbit('1'),
          expect: () => [
                const UpdateFailure(),
                const UpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.removeRabbit('1')).called(1);
          });
    });

    group('changeRabbitStatus', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdated] when changeRabbitStatus is called',
          setUp: () {
            when(() => rabbitRepository.changeRabbitStatus(any(), any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) =>
              cubit.changeRabbitStatus('1', RabbitStatus.inTreatment),
          expect: () => [
                const UpdateSuccess(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.changeRabbitStatus(
                '1', RabbitStatus.inTreatment)).called(1);
          });

      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [RabbitUpdateFailure] when changeRabbitStatus is called',
          setUp: () {
            when(() => rabbitRepository.changeRabbitStatus(any(), any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) =>
              cubit.changeRabbitStatus('1', RabbitStatus.inTreatment),
          expect: () => [
                const UpdateFailure(),
                const UpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.changeRabbitStatus(
                '1', RabbitStatus.inTreatment)).called(1);
          });

      blocTest<RabbitUpdateCubit, UpdateState>(
          'emits [UpdateFailure] when changeRabbitStatus is called - RepositoryException',
          setUp: () {
            when(() => rabbitRepository.changeRabbitStatus(any(), any()))
                .thenThrow(const RepositoryException(code: 'error'));
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) =>
              cubit.changeRabbitStatus('1', RabbitStatus.inTreatment),
          expect: () => [
                const UpdateFailure(code: 'error'),
                const UpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.changeRabbitStatus(
                '1', RabbitStatus.inTreatment)).called(1);
          });
    });

    group('resetState', () {
      blocTest<RabbitUpdateCubit, UpdateState>(
        'emits [RabbitUpdateInitial] when resetState is called',
        build: () => rabbitUpdateCubit,
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const UpdateInitial(),
        ],
      );
    });
  });
}
