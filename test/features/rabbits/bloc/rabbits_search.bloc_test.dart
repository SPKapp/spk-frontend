import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_search.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

class MockRabbitsRepository extends Mock implements IRabbitsRepository {}

void main() {
  group(RabbitsSearchBloc, () {
    late MockRabbitsRepository mockRabbitsRepository;
    late RabbitsSearchBloc rabbitsSearchBloc;

    setUp(() {
      mockRabbitsRepository = MockRabbitsRepository();
      rabbitsSearchBloc =
          RabbitsSearchBloc(rabbitsRepository: mockRabbitsRepository);
    });

    tearDown(() {
      rabbitsSearchBloc.close();
    });

    test('initial state is RabbitsSearchInitial', () {
      expect(rabbitsSearchBloc.state, equals(const RabbitsSearchInitial()));
    });

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
        'emits [RabbitsSearchSuccess] when query is changed successfully',
        setUp: () {
          when(() => mockRabbitsRepository
                  .findRabbitsByName('search query', totalCount: true))
              .thenAnswer((_) async => const Paginated(
                    data: [],
                    totalCount: 0,
                  ));
        },
        build: () => rabbitsSearchBloc,
        act: (bloc) =>
            bloc.add(const RabbitsSearchQueryChanged('search query')),
        expect: () => [
              const RabbitsSearchSuccess(
                query: 'search query',
                rabbits: [],
                hasReachedMax: true,
                totalCount: 0,
              ),
            ],
        verify: (_) {
          verify(() => mockRabbitsRepository.findRabbitsByName('search query',
              totalCount: true)).called(1);
        });

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchFailure] when query is changed and an error occurs',
      setUp: () {
        when(() => mockRabbitsRepository.findRabbitsByName('search query',
            totalCount: true)).thenThrow(Exception('Error'));
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchQueryChanged('search query')),
      expect: () => [
        const RabbitsSearchFailure(),
      ],
      verify: (_) {
        verify(() => mockRabbitsRepository.findRabbitsByName('search query',
            totalCount: true)).called(1);
      },
    );

    const result1 = [
      Rabbit(
          id: 1,
          name: 'Timon',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found),
      Rabbit(
          id: 2,
          name: 'Pumba',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found),
    ];

    const result2 = [
      Rabbit(
          id: 3,
          name: 'Timon',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found),
      Rabbit(
          id: 4,
          name: 'Pumba',
          gender: Gender.male,
          confirmedBirthDate: false,
          admissionType: AdmissionType.found),
    ];

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchSuccess] when loadMore is called successfully',
      setUp: () {
        when(() => mockRabbitsRepository.findRabbitsByName('search query',
            offset: 2)).thenAnswer((_) async => const Paginated(data: result2));
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => const RabbitsSearchSuccess(
        query: 'search query',
        rabbits: result1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      expect: () => [
        RabbitsSearchSuccess(
          query: 'search query',
          rabbits: result1 + result2,
          hasReachedMax: true,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => mockRabbitsRepository.findRabbitsByName('search query',
            offset: 2)).called(1);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchFailure] when loadMore is called and an error occurs',
      setUp: () {
        when(() => mockRabbitsRepository.findRabbitsByName('search query',
            offset: 2)).thenThrow(Exception('Error'));
      },
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => const RabbitsSearchSuccess(
        query: 'search query',
        rabbits: result1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      expect: () => [
        const RabbitsSearchFailure(
          query: 'search query',
          rabbits: result1,
          hasReachedMax: false,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => mockRabbitsRepository.findRabbitsByName('search query',
            offset: 2)).called(1);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchSuccess] when loadMore is called and hasReachedMax is true',
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchFetch()),
      seed: () => const RabbitsSearchSuccess(
        query: 'search query',
        rabbits: result1,
        hasReachedMax: true,
        totalCount: 2,
      ),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(mockRabbitsRepository);
      },
    );

    blocTest<RabbitsSearchBloc, RabbitsSearchState>(
      'emits [RabbitsSearchInitial] when clear is called',
      build: () => rabbitsSearchBloc,
      act: (bloc) => bloc.add(const RabbitsSearchClear()),
      expect: () => [
        const RabbitsSearchInitial(),
      ],
    );
  });
}
