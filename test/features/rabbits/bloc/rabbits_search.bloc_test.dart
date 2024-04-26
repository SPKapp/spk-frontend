import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto/find_rabbits.args.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitsSearchBloc, () {
    late MockRabbitsRepository rabbitsRepository;
    late RabbitsSearchBloc rabbitsSearchBloc;

    setUp(() {
      rabbitsRepository = MockRabbitsRepository();
      rabbitsSearchBloc = RabbitsSearchBloc(
          rabbitsRepository: rabbitsRepository,
          args: const FindRabbitsArgs(name: 'search query'));

      registerFallbackValue(const FindRabbitsArgs());
    });

    tearDown(() {
      rabbitsSearchBloc.close();
    });

    test('initial state is RabbitsSearchInitial', () {
      expect(rabbitsSearchBloc.state, equals(RabbitsSearchInitial()));
    });

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
        'emits [RabbitsSearchSuccess] when query is changed successfully',
        setUp: () {
          when(() => rabbitsRepository.findAll(any(), any()))
              .thenAnswer((_) async => const Paginated(
                    data: [],
                    totalCount: 0,
                  ));
        },
        build: () => rabbitsSearchBloc,
        act: (bloc) => bloc.add(const RabbitsSearchRefresh('search query')),
        expect: () => [
              RabbitsSearchInitial(),
              RabbitsSearchSuccess(
                query: 'search query',
                rabbitGroups: const [],
                hasReachedMax: true,
                totalCount: 0,
              ),
            ],
        verify: (_) {
          verify(() => rabbitsRepository.findAll(any(), true)).called(1);
        });

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchFailure] when query is changed and an error occurs',
      setUp: () {
        when(
          () => rabbitsRepository.findAll(any(), any()),
        ).thenThrow(Exception());
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchRefresh('search query')),
      expect: () => [
        RabbitsSearchInitial(),
        RabbitsSearchFailure(),
      ],
      verify: (_) {
        verify(() => rabbitsRepository.findAll(any(), true)).called(1);
      },
    );

    const rabbitGroup1 = RabbitGroup(
      id: 1,
      rabbits: [
        Rabbit(
          id: 1,
          name: 'Timon',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
        Rabbit(
          id: 2,
          name: 'Pumba',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );
    const rabbitGroup2 = RabbitGroup(
      id: 2,
      rabbits: [
        Rabbit(
          id: 3,
          name: 'Timon',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
        Rabbit(
          id: 4,
          name: 'Pumba',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found,
        ),
      ],
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchSuccess] when loadMore is called successfully',
      setUp: () {
        when(() => rabbitsRepository.findAll(any(), any()))
            .thenAnswer((_) async => const Paginated(data: [rabbitGroup2]));
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => RabbitsSearchSuccess(
        query: 'search query',
        rabbitGroups: const [rabbitGroup1],
        hasReachedMax: false,
        totalCount: 2,
      ),
      expect: () => [
        RabbitsSearchSuccess(
          query: 'search query',
          rabbitGroups: const [rabbitGroup1, rabbitGroup2],
          hasReachedMax: true,
          totalCount: 2,
        ),
      ],
      verify: (_) {
        verify(() => rabbitsRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 1)),
            false)).called(1);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchFailure] when loadMore is called and an error occurs',
      setUp: () {
        when(() => rabbitsRepository.findAll(any(), any()))
            .thenThrow(Exception('Error'));
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => RabbitsSearchSuccess(
        query: 'search query',
        rabbitGroups: const [rabbitGroup1],
        hasReachedMax: false,
        totalCount: 2,
      ),
      expect: () => [
        RabbitsSearchFailure(
          query: 'search query',
          rabbitGroups: const [rabbitGroup1],
          hasReachedMax: false,
          totalCount: 2,
        ),
      ],
      verify: (_) {
        verify(() => rabbitsRepository.findAll(
            any(
                that: isA<FindRabbitsArgs>()
                    .having((p) => p.offset, 'offset', 1)),
            false)).called(1);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchSuccess] when loadMore is called and hasReachedMax is true',
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => RabbitsSearchSuccess(
        query: 'search query',
        rabbitGroups: const [rabbitGroup1],
        hasReachedMax: true,
        totalCount: 2,
      ),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(rabbitsRepository);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchInitial] when clear is called',
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchClear()),
      expect: () => [
        RabbitsSearchInitial(),
      ],
    );
  });
}
