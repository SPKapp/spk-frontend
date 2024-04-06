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
    const team2 = Team(
      id: 2,
      users: [
        User(
          id: 2,
          firstName: 'Tom',
          lastName: 'Smith',
          email: 'email2@example.com',
          phone: '223456789',
        ),
      ],
    );

    group('default', () {
      const paginatedResult = Paginated<Team>(
        data: [team1],
      );
      const paginatedResultTotalCount = Paginated<Team>(
        totalCount: 2,
        data: [team2],
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
              )).thenAnswer((invocation) async => paginatedResultTotalCount);
        },
        build: () => usersListBloc,
        act: (bloc) => bloc.add(const FetchUsers()),
        expect: () => [
          UsersListSuccess(
            teams: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => usersRepository.fetchTeams(
                offset: 0,
                totalCount: true,
              )).called(1);
          verifyNoMoreInteractions(usersRepository);
        },
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
        verify: (_) {
          verify(() => usersRepository.fetchTeams(
                offset: 0,
                totalCount: true,
              )).called(1);
          verifyNoMoreInteractions(usersRepository);
        },
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
          teams: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
        act: (bloc) => bloc.add(const FetchUsers()),
        expect: () => [
          UsersListFailure(
            teams: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => usersRepository.fetchTeams(
                offset: 1,
                totalCount: false,
              )).called(1);
          verifyNoMoreInteractions(usersRepository);
        },
      );

      blocTest<UsersListBloc, UsersListState>(
        'emits [UsersListSuccess] when FetchUsers event is added and hasReachedMax is false',
        setUp: () {
          when(() => usersRepository.fetchTeams(
                offset: 1,
                totalCount: false,
              )).thenAnswer((invocation) async => paginatedResult);
        },
        build: () => usersListBloc,
        seed: () => UsersListSuccess(
          teams: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
        act: (bloc) => bloc.add(const FetchUsers()),
        expect: () => [
          UsersListSuccess(
            teams: paginatedResultTotalCount.data + paginatedResult.data,
            hasReachedMax: true,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => usersRepository.fetchTeams(
                offset: 1,
                totalCount: false,
              )).called(1);
          verifyNoMoreInteractions(usersRepository);
        },
      );

      blocTest<UsersListBloc, UsersListState>(
        'does not emit any state when FetchUsers event is added and hasReachedMax is true',
        build: () => usersListBloc,
        seed: () => UsersListSuccess(
          teams: paginatedResultTotalCount.data,
          hasReachedMax: true,
          totalCount: 1,
        ),
        act: (bloc) => bloc.add(const FetchUsers()),
        expect: () => [],
        verify: (_) {
          verifyNoMoreInteractions(usersRepository);
        },
      );

      blocTest<UsersListBloc, UsersListState>(
        'emits [UsersListSuccess] when RefreshUsers event is added',
        setUp: () {
          when(() => usersRepository.fetchTeams(
                offset: 0,
                totalCount: true,
              )).thenAnswer((invocation) async => paginatedResultTotalCount);
        },
        build: () => usersListBloc,
        act: (bloc) => bloc.add(const RefreshUsers()),
        expect: () => [
          UsersListInitial(),
          UsersListSuccess(
            teams: paginatedResultTotalCount.data,
            hasReachedMax: false,
            totalCount: paginatedResultTotalCount.totalCount!,
          ),
        ],
        verify: (_) {
          verify(() => usersRepository.fetchTeams(
                offset: 0,
                totalCount: true,
              )).called(1);
          verifyNoMoreInteractions(usersRepository);
        },
      );
    });
    group('perPage', () {
      const paginatedResultTotalCountFull = Paginated<Team>(
        totalCount: 2,
        data: [team1, team2],
      );

      setUp(() {
        usersListBloc = UsersListBloc(
          usersRepository: usersRepository,
          perPage: 10,
        );
      });

      blocTest(
          'emits [UsersListSuccess] when FetchUsers event is added, and perPage is set',
          setUp: () {
            when(() => usersRepository.fetchTeams(
                      offset: 0,
                      limit: 10,
                      totalCount: true,
                    ))
                .thenAnswer(
                    (invocation) async => paginatedResultTotalCountFull);
          },
          build: () => usersListBloc,
          act: (bloc) => bloc.add(const FetchUsers()),
          expect: () => [
                UsersListSuccess(
                  teams: paginatedResultTotalCountFull.data,
                  hasReachedMax: true,
                  totalCount: paginatedResultTotalCountFull.totalCount!,
                ),
              ],
          verify: (_) {
            verify(() => usersRepository.fetchTeams(
                  offset: 0,
                  limit: 10,
                  totalCount: true,
                )).called(1);
            verifyNoMoreInteractions(usersRepository);
          });
    });

    group('regionsIds', () {
      const paginatedResultTotalCountFull = Paginated<Team>(
        totalCount: 2,
        data: [team1, team2],
      );

      setUp(() {
        usersListBloc = UsersListBloc(
          usersRepository: usersRepository,
          regionsIds: [1],
        );
      });

      blocTest(
          'emits [UsersListSuccess] when FetchUsers event is added, and regionsIds is set',
          setUp: () {
            when(() => usersRepository.fetchTeams(
                      offset: 0,
                      totalCount: true,
                      regionsIds: [1],
                    ))
                .thenAnswer(
                    (invocation) async => paginatedResultTotalCountFull);
          },
          build: () => usersListBloc,
          act: (bloc) => bloc.add(const FetchUsers()),
          expect: () => [
                UsersListSuccess(
                  teams: paginatedResultTotalCountFull.data,
                  hasReachedMax: true,
                  totalCount: paginatedResultTotalCountFull.totalCount!,
                ),
              ],
          verify: (_) {
            verify(() => usersRepository.fetchTeams(
                  offset: 0,
                  totalCount: true,
                  regionsIds: [1],
                )).called(1);
            verifyNoMoreInteractions(usersRepository);
          });
    });
  });
}
