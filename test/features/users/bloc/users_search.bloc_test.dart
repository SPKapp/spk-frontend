import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/bloc/users_search.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UsersSearchBloc, () {
    late UsersSearchBloc usersSearchBloc;
    late IUsersRepository mockUsersRepository;

    setUp(() {
      mockUsersRepository = MockUsersRepository();
      usersSearchBloc = UsersSearchBloc(
        usersRepository: mockUsersRepository,
        args: const FindUsersArgs(
          name: 'search query',
        ),
      );
    });

    tearDown(() {
      usersSearchBloc.close();
    });

    test('initial state is UsersSearchInitial', () {
      expect(usersSearchBloc.state, UsersSearchInitial());
    });

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchSuccess] when query is changed successfully',
      setUp: () {
        when(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 0,
            ),
            true)).thenAnswer((_) async => const Paginated(
              data: [],
              totalCount: 0,
            ));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchRefresh('search query')),
      expect: () => [
        UsersSearchInitial(),
        UsersSearchSuccess(
          query: 'search query',
          teams: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 0,
            ),
            true)).called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchFailure] when query change fails',
      setUp: () {
        when(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 0,
            ),
            true)).thenThrow(Exception('Error'));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchRefresh('search query')),
      expect: () => [
        UsersSearchInitial(),
        UsersSearchFailure(),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 0,
            ),
            true)).called(1);
      },
    );

    const result1 = [
      Team(id: 1, users: [
        User(id: 1, firstName: 'John', lastName: 'Doe'),
        User(id: 2, firstName: 'Jan', lastName: 'Smith'),
      ])
    ];

    const result2 = [
      Team(id: 2, users: [
        User(id: 3, firstName: 'Thomas', lastName: 'Doe'),
        User(id: 4, firstName: 'Jacob', lastName: 'Smith'),
      ])
    ];

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchSuccess] when fetching next page successfully',
      setUp: () {
        when(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 1,
            ),
            false)).thenAnswer((_) async => const Paginated(data: result2));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchFetch()),
      seed: () => UsersSearchSuccess(
        query: 'search query',
        teams: result1,
        hasReachedMax: false,
        totalCount: 2,
      ),
      expect: () => [
        UsersSearchSuccess(
          query: 'search query',
          teams: result1 + result2,
          hasReachedMax: true,
          totalCount: 2,
        ),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 1,
            ),
            false)).called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
      'emits [UsersSearchFailure] when fetching next page fails',
      setUp: () {
        when(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 1,
            ),
            false)).thenThrow(Exception('Error'));
      },
      build: () => usersSearchBloc,
      act: (bloc) => bloc.add(const UsersSearchFetch()),
      seed: () => UsersSearchSuccess(
        query: 'search query',
        teams: result1,
        hasReachedMax: false,
        totalCount: 2,
      ),
      expect: () => [
        UsersSearchFailure(
          query: 'search query',
          teams: result1,
          hasReachedMax: false,
          totalCount: 2,
        ),
      ],
      verify: (_) {
        verify(() => mockUsersRepository.findAll(
            const FindUsersArgs(
              name: 'search query',
              offset: 1,
            ),
            false)).called(1);
      },
    );

    blocTest<UsersSearchBloc, UsersSearchState>(
        'emits [UsersSearchSuccess] when loadMore is called and hasReachedMax is true',
        build: () => usersSearchBloc,
        act: (bloc) => bloc.add(const UsersSearchFetch()),
        seed: () => UsersSearchSuccess(
              query: 'search query',
              teams: result1,
              hasReachedMax: true,
              totalCount: 1,
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
        UsersSearchInitial(),
      ],
    );
  });
}
