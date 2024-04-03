import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UsersSearchBloc, () {
    late UsersSearchBloc usersSearchBloc;
    late IUsersRepository mockUsersRepository;

    setUp(() {
      mockUsersRepository = MockUsersRepository();
      usersSearchBloc = UsersSearchBloc(usersRepository: mockUsersRepository);
    });

    tearDown(() {
      usersSearchBloc.close();
    });

    test('initial state is UsersSearchInitial', () {
      expect(usersSearchBloc.state, const UsersSearchInitial());
    });

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchSuccess] when query is changed successfully',
      setUp: () {
        when(() => mockUsersRepository
                .findUsersByName('search query', totalCount: true))
            .thenAnswer((_) async => const Paginated(
                  data: [],
                  totalCount: 0,
                ));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchQueryChanged('search query')),
      expect: () => [
        const UsersSearchSuccess(
          query: 'search query',
          users: [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findUsersByName('search query',
            totalCount: true)).called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchFailure] when query change fails',
      setUp: () {
        when(() => mockUsersRepository.findUsersByName('search query',
            totalCount: true)).thenThrow(Exception('Error'));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchQueryChanged('search query')),
      expect: () => [
        const UsersSearchFailure(),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findUsersByName('search query',
            totalCount: true)).called(1);
      },
    );

    const result1 = [
      User(id: 1, firstName: 'John', lastName: 'Doe'),
      User(id: 2, firstName: 'Jan', lastName: 'Smith'),
    ];

    const result2 = [
      User(id: 3, firstName: 'Thomas', lastName: 'Doe'),
      User(id: 4, firstName: 'Jacob', lastName: 'Smith'),
    ];

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchSuccess] when fetching next page successfully',
      setUp: () {
        when(() =>
                mockUsersRepository.findUsersByName('search query', offset: 2))
            .thenAnswer((_) async => const Paginated(data: result2));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchFetch()),
      seed: () => const UsersSearchSuccess(
        query: 'search query',
        users: result1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      expect: () => [
        UsersSearchSuccess(
          query: 'search query',
          users: result1 + result2,
          hasReachedMax: true,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() =>
                mockUsersRepository.findUsersByName('search query', offset: 2))
            .called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchFailure] when fetching next page fails',
      setUp: () {
        when(() =>
                mockUsersRepository.findUsersByName('search query', offset: 2))
            .thenThrow(Exception('Error'));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchFetch()),
      seed: () => const UsersSearchSuccess(
        query: 'search query',
        users: result1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      expect: () => [
        const UsersSearchFailure(),
      ],
      verify: (_) {
        verify(() =>
                mockUsersRepository.findUsersByName('search query', offset: 2))
            .called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
        'emits [UsersSearchSuccess] when loadMore is called and hasReachedMax is true',
        build: () => usersSearchBloc,
        act: (bloc) => bloc.add(const UsersSearchFetch()),
        seed: () => const UsersSearchSuccess(
              query: 'search query',
              users: result1,
              hasReachedMax: true,
              totalCount: 4,
            ),
        expect: () => [],
        verify: (_) {
          verifyZeroInteractions(mockUsersRepository);
        });

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchInitial] when clear event is added',
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchClear()),
      expect: () => [
        const UsersSearchInitial(),
      ],
    );
  });
}