import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UsersListBloc, () {
    late IUsersRepository usersRepository;
    late UsersListBloc usersListBloc;

    const user1 = User(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'email@example.com',
      phone: '123456789',
    );

    const user2 = User(
      id: '2',
      firstName: 'Tom',
      lastName: 'Smith',
      email: 'email2@example.com',
      phone: '223456789',
    );

    const paginatedResult = Paginated<User>(
      data: [user1],
    );
    const paginatedResultTotalCount = Paginated<User>(
      totalCount: 2,
      data: [user2],
    );

    setUp(() {
      usersRepository = MockUsersRepository();
      usersListBloc = UsersListBloc(
        usersRepository: usersRepository,
        args: const FindUsersArgs(),
      );

      registerFallbackValue(const FindUsersArgs());
    });

    tearDown(() {
      usersListBloc.close();
    });

    test('initial state is UsersListInitial', () {
      expect(usersListBloc.state, const UsersListInitial());
    });

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when FetchUsers event is added',
      setUp: () {
        when(() => usersRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListSuccess(
          users: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => usersRepository.findAll(
            any(
                that:
                    isA<FindUsersArgs>().having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(usersRepository);
      },
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListFailure] when an error occurs on initial fetch',
      setUp: () {
        when(() => usersRepository.findAll(any(), any()))
            .thenThrow(Exception('An error occurred'));
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        const UsersListFailure(),
      ],
      verify: (_) {
        verify(() => usersRepository.findAll(
            any(
                that:
                    isA<FindUsersArgs>().having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(usersRepository);
      },
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListFailure] when an error occurs on next fetch',
      setUp: () {
        when(() => usersRepository.findAll(any(), any()))
            .thenThrow(Exception('An error occurred'));
      },
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        users: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListFailure(
          users: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => usersRepository.findAll(
            any(
                that:
                    isA<FindUsersArgs>().having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(usersRepository);
      },
    );

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when FetchUsers event is added and hasReachedMax is false',
      setUp: () {
        when(() => usersRepository.findAll(any(), any()))
            .thenAnswer((invocation) async => paginatedResult);
      },
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        users: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchUsers()),
      expect: () => [
        UsersListSuccess(
          users: paginatedResultTotalCount.data + paginatedResult.data,
          hasReachedMax: true,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => usersRepository.findAll(
            any(
                that:
                    isA<FindUsersArgs>().having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(usersRepository);
      },
    );

    blocTest<UsersListBloc, UsersListState>(
      'does not emit any state when FetchUsers event is added and hasReachedMax is true',
      build: () => usersListBloc,
      seed: () => UsersListSuccess(
        users: paginatedResultTotalCount.data,
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
          when(() => usersRepository.findAll(any(), any()))
              .thenAnswer((invocation) async => paginatedResultTotalCount);
        },
        build: () => usersListBloc,
        act: (bloc) => bloc.add(const RefreshUsers(null)),
        expect: () => [
              const UsersListInitial(),
              UsersListSuccess(
                users: paginatedResultTotalCount.data,
                hasReachedMax: false,
                totalCount: paginatedResultTotalCount.totalCount!,
              ),
            ],
        verify: (_) {
          verify(() => usersRepository.findAll(
              any(
                  that: isA<FindUsersArgs>()
                      .having((p) => p.offset, 'offset', 0)),
              true)).called(1);
          verifyNoMoreInteractions(usersRepository);
        });

    blocTest<UsersListBloc, UsersListState>(
      'emits [UsersListSuccess] when RefreshUsers event is added with args',
      setUp: () {
        when(() => usersRepository.findAll(any(), any()))
            .thenAnswer((invocation) async => paginatedResultTotalCount);
      },
      build: () => usersListBloc,
      act: (bloc) => bloc.add(const RefreshUsers(FindUsersArgs(name: 'name'))),
      expect: () => [
        const UsersListInitial(),
        UsersListSuccess(
          users: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => usersRepository.findAll(
            any(
              that: isA<FindUsersArgs>()
                  .having((p) => p.offset, 'offset', 0)
                  .having((p) => p.name, 'name', 'name'),
            ),
            true)).called(1);
        verifyNoMoreInteractions(usersRepository);
      },
    );
  });
}
