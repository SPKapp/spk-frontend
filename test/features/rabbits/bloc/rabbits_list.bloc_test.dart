import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';

class MockIRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitsListBloc, () {
    late IRabbitsRepository rabbitRepository;
    late RabbitsListBloc rabbitsListBloc;

    const rabbitGroup1 = RabbitGroup(
      id: '1',
      rabbits: [
        Rabbit(
          id: '1',
          name: 'name 1',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );
    const rabbitGroup2 = RabbitGroup(
      id: '2',
      rabbits: [
        Rabbit(
          id: '2',
          name: 'name2',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );

    const paginatedResult = Paginated<RabbitGroup>(
      data: [rabbitGroup1],
    );
    const paginatedResultTotalCount = Paginated<RabbitGroup>(
      totalCount: 2,
      data: [rabbitGroup2],
    );

    tearDown(() {
      rabbitsListBloc.close();
    });

    setUp(() {
      rabbitRepository = MockIRabbitsRepository();
      rabbitsListBloc = RabbitsListBloc(
        rabbitsRepository: rabbitRepository,
        args: const FindRabbitsArgs(),
      );

      registerFallbackValue(const FindRabbitsArgs());
    });

    test('initial state', () {
      expect(rabbitsListBloc.state, equals(GetListInitial<RabbitGroup>()));
    });

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListSuccess<RabbitGroup>] when FeatchRabbits is added',
      setUp: () {
        when(
          () => rabbitRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitsListBloc,
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListSuccess<RabbitGroup>(
          data: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListFailure<RabbitGroup>] when an error occurs on initial fetch',
      setUp: () {
        when(
          () => rabbitRepository.findAll(any(), any()),
        ).thenThrow(Exception());
      },
      build: () => rabbitsListBloc,
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListFailure<RabbitGroup>(),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListFailure<RabbitGroup>] when an error occurs on next fetch',
      setUp: () {
        when(
          () => rabbitRepository.findAll(any(), any()),
        ).thenThrow(Exception());
      },
      build: () => rabbitsListBloc,
      seed: () => GetListSuccess<RabbitGroup>(
        data: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListFailure<RabbitGroup>(
          data: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListSuccess<RabbitGroup>] when FeatchRabbits event is added and hasReachedMax is false',
      setUp: () {
        when(
          () => rabbitRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResult);
      },
      build: () => rabbitsListBloc,
      seed: () => GetListSuccess<RabbitGroup>(
        data: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListSuccess<RabbitGroup>(
          data: paginatedResultTotalCount.data + paginatedResult.data,
          hasReachedMax: true,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitsListBloc, GetListState>(
        'does not emit any state when FetchRabbits event is added and hasReachedMax is true',
        build: () => rabbitsListBloc,
        seed: () => GetListSuccess<RabbitGroup>(
              data: paginatedResultTotalCount.data,
              hasReachedMax: true,
              totalCount: paginatedResultTotalCount.totalCount!,
            ),
        act: (bloc) => bloc.add(const FetchList()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => rabbitRepository.findAll(any(), any()));
          verifyNoMoreInteractions(rabbitRepository);
        });

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListInitial<RabbitGroup>] and [GetListSuccess<RabbitGroup>] when RefreshUsers event is added',
      setUp: () {
        when(() => rabbitRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitsListBloc,
      act: (bloc) => bloc.add(const RefreshList<FindRabbitsArgs>(null)),
      expect: () => [
        GetListInitial<RabbitGroup>(),
        GetListSuccess<RabbitGroup>(
          data: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );

    blocTest<RabbitsListBloc, GetListState>(
      'emits [GetListInitial<RabbitGroup>] and [GetListSuccess<RabbitGroup>] when RefreshUsers event is added with args',
      setUp: () {
        when(() => rabbitRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitsListBloc,
      act: (bloc) => bloc.add(const RefreshList(FindRabbitsArgs(name: 'name'))),
      expect: () => [
        GetListInitial<RabbitGroup>(),
        GetListSuccess<RabbitGroup>(
          data: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => rabbitRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 0)
                    .having((p) => p.name, 'name', 'name')),
            true)).called(1);
        verifyNoMoreInteractions(rabbitRepository);
      },
    );
  });
}
