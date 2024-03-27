import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UsersListBloc, () {
    final IUsersRepository usersRepository = MockUsersRepository();
    late UsersListBloc usersListBloc;

    const team1 = Team(
      id: 1,
      users: [
        User(
          id: 1,
          firstName: 'John',
          lastName: 'Doe',
          email: 'email@example.com',
          phone: '123456789',
        ),
      ],
    );

    const paginatedResult1 = Paginated<Team>(
      totalCount: 1,
      data: [team1],
    );
    const paginatedResult2 = Paginated<Team>(
      totalCount: 2,
      data: [team1],
    );

    setUp(() {
      usersListBloc = UsersListBloc(usersRepository: usersRepository);
    });

    tearDown(() {
      usersListBloc.close();
    });

    test('initial state is UsersListInitial', () {
      expect(usersListBloc.state, UsersListInitial());
    });

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when FetchUsers event is added',
      setUp: () {
        when(() => usersRepository.fetchTeams(
              offset: 0,
              totalCount: true,
            )).thenAnswer((invocation) async => paginatedResult1);
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListSuccess(
          teams: paginatedResult1.data,
          hasReachedMax: true,
          totalCount: paginatedResult1.totalCount!,
        ),
      ],
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListFailure] when an error occurs on initial fetch',
      setUp: () {
        when(() => usersRepository.fetchTeams(
              offset: 0,
              totalCount: true,
            )).thenThrow(Exception('An error occurred'));
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListFailure(),
      ],
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListFailure] when an error occurs on next fetch',
      setUp: () {
        when(() => usersRepository.fetchTeams(
              offset: 1,
              totalCount: false,
            )).thenThrow(Exception('An error occurred'));
      },
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        teams: paginatedResult1.data,
        hasReachedMax: false,
        totalCount: paginatedResult1.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListFailure(
          teams: paginatedResult1.data,
          hasReachedMax: false,
          totalCount: paginatedResult1.totalCount!,
        ),
      ],
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when FetchUsers event is added and hasReachedMax is false',
      setUp: () {
        when(() => usersRepository.fetchTeams(offset: 1, totalCount: false))
            .thenAnswer((invocation) async => paginatedResult1);
      },
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        teams: paginatedResult2.data,
        hasReachedMax: false,
        totalCount: paginatedResult2.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListSuccess(
          teams: paginatedResult2.data + paginatedResult1.data,
          hasReachedMax: true,
          totalCount: paginatedResult2.totalCount!,
        ),
      ],
    );

    blocTest<UsersListBloc, UsersListState>(
      'does not emit any state when FetchUsers event is added and hasReachedMax is true',
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        teams: paginatedResult2.data,
        hasReachedMax: true,
        totalCount: 1,
      ),
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [],
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when RefreshUsers event is added',
      setUp: () {
        when(() => usersRepository.fetchTeams(
              offset: 0,
              totalCount: true,
            )).thenAnswer((invocation) async => paginatedResult1);
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const RefreshUsers()),
      expect: () => [
        UsersListInitial(),
        UsersListSuccess(
          teams: paginatedResult1.data,
          hasReachedMax: true,
          totalCount: paginatedResult1.totalCount!,
        ),
      ],
    );
  });
}
