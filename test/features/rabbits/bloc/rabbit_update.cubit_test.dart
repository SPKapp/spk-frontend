import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_update.cubit.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitUpdateCubit, () {
    late IRabbitsRepository rabbitRepository;
    late RabbitUpdateCubit rabbitUpdateCubit;

    final dto = RabbitUpdateDto(
      id: 1,
      name: 'name',
    );

    setUp(() {
      registerFallbackValue(dto);
      rabbitRepository = MockRabbitsRepository();
      rabbitUpdateCubit = RabbitUpdateCubit(
        rabbitsRepository: rabbitRepository,
      );
    });

    test('initial state', () {
      expect(rabbitUpdateCubit.state, equals(const RabbitUpdateInitial()));
    });

    group('updateRabbit', () {
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
        verify: (_) {
          verify(() => rabbitRepository.updateRabbit(dto)).called(1);
        },
      );

      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
        'emits [RabbitUpdateFailure] when updateRabbit is called',
        setUp: () {
          when(() => rabbitRepository.updateRabbit(any()))
              .thenThrow(Exception());
        },
        build: () => rabbitUpdateCubit,
        act: (cubit) => cubit.updateRabbit(dto),
        expect: () => [
          const RabbitUpdateFailure(),
          const RabbitUpdateInitial(),
        ],
        verify: (_) {
          verify(() => rabbitRepository.updateRabbit(dto)).called(1);
        },
      );
    });

    group('changeTeam', () {
      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdated] when changeTeam is called',
          setUp: () {
            when(() => rabbitRepository.updateTeam(any(), any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeTeam('1', '1'),
          expect: () => [
                const RabbitUpdated(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateTeam('1', '1')).called(1);
          });

      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdateFailure] when changeTeam is called',
          setUp: () {
            when(() => rabbitRepository.updateTeam(any(), any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeTeam('1', '1'),
          expect: () => [
                const RabbitUpdateFailure(),
                const RabbitUpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateTeam('1', '1')).called(1);
          });
    });

    group('changeRabbitGroup', () {
      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdated] when changeRabbitGroup is called',
          setUp: () {
            when(() => rabbitRepository.updateRabbitGroup(any(), any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeRabbitGroup(1, 1),
          expect: () => [
                const RabbitUpdated(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateRabbitGroup(1, 1)).called(1);
          });

      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdateFailure] when changeRabbitGroup is called',
          setUp: () {
            when(() => rabbitRepository.updateRabbitGroup(any(), any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.changeRabbitGroup(1, 1),
          expect: () => [
                const RabbitUpdateFailure(),
                const RabbitUpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.updateRabbitGroup(1, 1)).called(1);
          });
    });

    group('removeRabbit', () {
      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdated] when removeRabbit is called',
          setUp: () {
            when(() => rabbitRepository.removeRabbit(any()))
                .thenAnswer((_) async => 1);
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.removeRabbit(1),
          expect: () => [
                const RabbitUpdated(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.removeRabbit(1)).called(1);
          });

      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
          'emits [RabbitUpdateFailure] when removeRabbit is called',
          setUp: () {
            when(() => rabbitRepository.removeRabbit(any()))
                .thenThrow(Exception());
          },
          build: () => rabbitUpdateCubit,
          act: (cubit) => cubit.removeRabbit(1),
          expect: () => [
                const RabbitUpdateFailure(),
                const RabbitUpdateInitial(),
              ],
          verify: (_) {
            verify(() => rabbitRepository.removeRabbit(1)).called(1);
          });
    });

    group('resetState', () {
      blocTest<RabbitUpdateCubit, RabbitUpdateState>(
        'emits [RabbitUpdateInitial] when resetState is called',
        build: () => rabbitUpdateCubit,
        act: (cubit) => cubit.resetState(),
        expect: () => [
          const RabbitUpdateInitial(),
        ],
      );
    });
  });
}
