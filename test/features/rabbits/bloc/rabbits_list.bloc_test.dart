import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';

class MockIRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitsListBloc, () {
    final rabbitRepository = MockIRabbitsRepository();
    late RabbitsListBloc rabbitsListBloc;

    const rabbitGroup1 = RabbitsGroup(
      id: 1,
      rabbits: [
        Rabbit(
          id: 1,
          name: 'name 1',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );
    const rabbitGroup2 = RabbitsGroup(
      id: 2,
      rabbits: [
        Rabbit(
          id: 2,
          name: 'name2',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );

    const paginatedResult = Paginated<RabbitsGroup>(
      data: [rabbitGroup1],
    );
    const paginatedResultTotalCount = Paginated<RabbitsGroup>(
      totalCount: 2,
      data: [rabbitGroup2],
    );

    tearDown(() {
      rabbitsListBloc.close();
    });

    group(RabbitsQueryType.my, () {
      setUp(() {
        rabbitsListBloc = RabbitsListBloc(
          rabbitsRepository: rabbitRepository,
          queryType: RabbitsQueryType.my,
        );
      });

      test('initial state', () {
        expect(rabbitsListBloc.state, equals(const RabbitsListInitial()));
      });

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListSuccess] when [FeatchRabbits] is added',
        setUp: () {
          when(() => rabbitRepository.myRabbits())
              .thenAnswer((_) async => [rabbitGroup1]);
        },
        build: () => rabbitsListBloc,
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          const RabbitsListSuccess(
            rabbitsGroups: [rabbitGroup1],
            hasReachedMax: true,
            totalCount: 1,
          ),
        ],
        verify: (_) {
          verify(() => rabbitRepository.myRabbits()).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListFailure] when an error occurs on initial fetch',
        setUp: () {
          when(() => rabbitRepository.myRabbits()).thenThrow(Exception());
        },
        build: () => rabbitsListBloc,
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          const RabbitsListFailure(),
        ],
        verify: (_) {
          verify(() => rabbitRepository.myRabbits()).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
        'do not emit new state when state is RabbitsListSuccess',
        build: () => rabbitsListBloc,
        seed: () => const RabbitsListSuccess(
          rabbitsGroups: [rabbitGroup1],
          hasReachedMax: true,
          totalCount: 1,
        ),
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => rabbitRepository.myRabbits());
        },
      );
    });

    group(RabbitsQueryType.all, () {
      setUp(() {
        rabbitsListBloc = RabbitsListBloc(
          rabbitsRepository: rabbitRepository,
          queryType: RabbitsQueryType.all,
        );
      });

      test('initial state', () {
        expect(rabbitsListBloc.state, equals(const RabbitsListInitial()));
      });

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListSuccess] when FeatchRabbits is added',
        setUp: () {
          when(
            () => rabbitRepository.findAll(
              offset: 0,
              totalCount: true,
            ),
          ).thenAnswer((_) async => paginatedResultTotalCount);
        },
        build: () => rabbitsListBloc,
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          RabbitsListSuccess(
            rabbitsGroups: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => rabbitRepository.findAll(
                offset: 0,
                totalCount: true,
              )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListFailure] when an error occurs on initial fetch',
        setUp: () {
          when(
            () => rabbitRepository.findAll(
              offset: 0,
              totalCount: true,
            ),
          ).thenThrow(Exception());
        },
        build: () => rabbitsListBloc,
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          const RabbitsListFailure(),
        ],
        verify: (_) {
          verify(() => rabbitRepository.findAll(
                offset: 0,
                totalCount: true,
              )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListFailure] when an error occurs on next fetch',
        setUp: () {
          when(
            () => rabbitRepository.findAll(
              offset: 1,
              totalCount: false,
            ),
          ).thenThrow(Exception());
        },
        build: () => rabbitsListBloc,
        seed: () => RabbitsListSuccess(
          rabbitsGroups: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          RabbitsListFailure(
            rabbitsGroups: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => rabbitRepository.findAll(
                offset: 1,
                totalCount: false,
              )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [RabbitsListSuccess] when FeatchRabbits event is added and hasReachedMax is false',
        setUp: () {
          when(
            () => rabbitRepository.findAll(
              offset: 1,
              totalCount: false,
            ),
          ).thenAnswer((_) async => paginatedResult);
        },
        build: () => rabbitsListBloc,
        seed: () => RabbitsListSuccess(
          rabbitsGroups: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
        act: (bloc) => bloc.add(const FetchRabbits()),
        expect: () => [
          RabbitsListSuccess(
            rabbitsGroups:
                paginatedResultTotalCount.data + paginatedResult.data,
            hasReachedMax: true,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => rabbitRepository.findAll(
                offset: 1,
                totalCount: false,
              )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsListBloc, RabbitsListState>(
          'does not emit any state when FetchRabbits event is added and hasReachedMax is true',
          build: () => rabbitsListBloc,
          seed: () => RabbitsListSuccess(
                rabbitsGroups: paginatedResultTotalCount.data,
                hasReachedMax: true,
                totalCount: paginatedResultTotalCount.totalCount!,
              ),
          act: (bloc) => bloc.add(const FetchRabbits()),
          expect: () => [],
          verify: (_) {
            verifyNever(() => rabbitRepository.findAll(
                  offset: 1,
                  totalCount: false,
                ));
            verifyNoMoreInteractions(rabbitRepository);
          });

      blocTest<RabbitsListBloc, RabbitsListState>(
        'emits [UsersListSuccess] when RefreshUsers event is added',
        setUp: () {
          when(() => rabbitRepository.findAll(offset: 0, totalCount: true))
              .thenAnswer((_) async => paginatedResultTotalCount);
        },
        build: () => rabbitsListBloc,
        act: (bloc) => bloc.add(const RefreshRabbits()),
        expect: () => [
          const RabbitsListInitial(),
          RabbitsListSuccess(
            rabbitsGroups: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => rabbitRepository.findAll(offset: 0, totalCount: true))
              .called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );
    });
  });
}
