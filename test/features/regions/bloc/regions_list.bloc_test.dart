import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';

class MockRegionsRepository extends Mock implements IRegionsRepository {}

void main() {
  group(RegionsListBloc, () {
    late IRegionsRepository regionsRepository;
    late RegionsListBloc regionsListBloc;

    const region1 = Region(id: '1', name: 'Region 1');
    const region2 = Region(id: '2', name: 'Region 2');

    const paginatedResult = Paginated<Region>(
      data: [region1],
    );

    const paginatedResultTotalCount = Paginated<Region>(
      data: [region2],
      totalCount: 2,
    );

    setUp(() {
      regionsRepository = MockRegionsRepository();
      regionsListBloc = RegionsListBloc(
        regionsRepository: regionsRepository,
        args: const FindRegionsArgs(),
      );

      registerFallbackValue(const FindRegionsArgs());
    });

    tearDown(() {
      regionsListBloc.close();
    });

    test('initial state is RegionsListInitial', () {
      expect(regionsListBloc.state, equals(const RegionsListInitial()));
    });

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListSuccess] when FetchRegions event is added',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => regionsListBloc,
      act: (bloc) => bloc.add(const FetchRegions()),
      expect: () => [
        RegionsListSuccess(
          regions: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => regionsRepository.findAll(
              any(
                  that: isA<FindRegionsArgs>()
                      .having((p) => p.offset, 'offset', 0)),
              true,
            )).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListFailure] when an error occurs on initial fetch',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenThrow(Exception());
      },
      build: () => regionsListBloc,
      act: (bloc) => bloc.add(const FetchRegions()),
      expect: () => [
        const RegionsListFailure(),
      ],
      verify: (_) {
        verify(() => regionsRepository.findAll(
              any(
                  that: isA<FindRegionsArgs>()
                      .having((p) => p.offset, 'offset', 0)),
              true,
            )).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListFailure] when an error occurs on next fetch',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenThrow(Exception());
      },
      build: () => regionsListBloc,
      seed: () => RegionsListSuccess(
        regions: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchRegions()),
      expect: () => [
        RegionsListFailure(
          regions: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => regionsRepository.findAll(
              any(
                  that: isA<FindRegionsArgs>()
                      .having((p) => p.offset, 'offset', 1)),
              false,
            )).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListSuccess] when FetchRegions event is added and hasReachedMax is false',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResult);
      },
      build: () => regionsListBloc,
      seed: () => RegionsListSuccess(
        regions: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchRegions()),
      expect: () => [
        RegionsListSuccess(
          regions: paginatedResultTotalCount.data + paginatedResult.data,
          hasReachedMax: true,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => regionsRepository.findAll(
              any(
                  that: isA<FindRegionsArgs>()
                      .having((p) => p.offset, 'offset', 1)),
              false,
            )).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListSuccess] when FetchRegions event is added and hasReachedMax is true',
      build: () => regionsListBloc,
      seed: () => RegionsListSuccess(
        regions: paginatedResultTotalCount.data,
        hasReachedMax: true,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchRegions()),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'eemits [RegionsListSuccess] when RefreshUsers event is added',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => regionsListBloc,
      act: (bloc) => bloc.add(const RefreshRegions(null)),
      expect: () => [
        const RegionsListInitial(),
        RegionsListSuccess(
          regions: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(
          () => regionsRepository.findAll(
            any(
                that: isA<FindRegionsArgs>()
                    .having((p) => p.offset, 'offset', 0)),
            true,
          ),
        ).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );

    blocTest<RegionsListBloc, RegionsListState>(
      'emits [RegionsListSuccess] when RefreshUsers event is added with args',
      setUp: () {
        when(
          () => regionsRepository.findAll(any(), any()),
        ).thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => regionsListBloc,
      act: (bloc) =>
          bloc.add(const RefreshRegions(FindRegionsArgs(name: 'name'))),
      expect: () => [
        const RegionsListInitial(),
        RegionsListSuccess(
          regions: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(
          () => regionsRepository.findAll(
            any(
              that: isA<FindRegionsArgs>()
                  .having((p) => p.offset, 'offset', 0)
                  .having((p) => p.name, 'name', 'name'),
            ),
            true,
          ),
        ).called(1);
        verifyNoMoreInteractions(regionsRepository);
      },
    );
  });
}
