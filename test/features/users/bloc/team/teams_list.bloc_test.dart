import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/users/bloc/team/teams_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockTeamsRepository extends Mock implements ITeamsRepository {}

void main() {
  group(TeamsListBloc, () {
    late ITeamsRepository teamsRepository;
    late TeamsListBloc teamsListBloc;

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

    const paginatedResult = Paginated<Team>(
      data: [team1],
    );
    const paginatedResultTotalCount = Paginated<Team>(
      totalCount: 2,
      data: [team2],
    );

    setUp(() {
      teamsRepository = MockTeamsRepository();
      teamsListBloc = TeamsListBloc(
        teamsRepository: teamsRepository,
        args: const FindTeamsArgs(),
      );

      registerFallbackValue(const FindTeamsArgs());
    });

    tearDown(() {
      teamsListBloc.close();
    });

    test('initial state is TeamsListInitial', () {
      expect(teamsListBloc.state, TeamsListInitial());
    });

    blocTest<TeamsListBloc, TeamsListState>(
      'emits [TeamsListSuccess] when FetchTeams event is added',
      setUp: () {
        when(() => teamsRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => teamsListBloc,
      act: (bloc) => bloc.add(const FetchTeams()),
      expect: () => [
        TeamsListSuccess(
          teams: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => teamsRepository.findAll(
            any(
                that:
                    isA<FindTeamsArgs>().having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<TeamsListBloc, TeamsListState>(
      'emits [TeamsListFailure] when an error occurs on initial fetch',
      setUp: () {
        when(() => teamsRepository.findAll(any(), any()))
            .thenThrow(Exception('An error occurred'));
      },
      build: () => teamsListBloc,
      act: (bloc) => bloc.add(const FetchTeams()),
      expect: () => [
        TeamsListFailure(),
      ],
      verify: (_) {
        verify(() => teamsRepository.findAll(
            any(
                that:
                    isA<FindTeamsArgs>().having((p) => p.offset, 'offset', 0)),
            true)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<TeamsListBloc, TeamsListState>(
      'emits [TeamsListFailure] when an error occurs on next fetch',
      setUp: () {
        when(() => teamsRepository.findAll(any(), any()))
            .thenThrow(Exception('An error occurred'));
      },
      build: () => teamsListBloc,
      seed: () => TeamsListSuccess(
        teams: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchTeams()),
      expect: () => [
        TeamsListFailure(
          teams: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => teamsRepository.findAll(
            any(
                that:
                    isA<FindTeamsArgs>().having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<TeamsListBloc, TeamsListState>(
      'emits [TeamsListSuccess] when FetchTeams event is added and hasReachedMax is false',
      setUp: () {
        when(() => teamsRepository.findAll(any(), any()))
            .thenAnswer((invocation) async => paginatedResult);
      },
      build: () => teamsListBloc,
      seed: () => TeamsListSuccess(
        teams: paginatedResultTotalCount.data,
        hasReachedMax: false,
        totalCount: paginatedResultTotalCount.totalCount!,
      ),
      act: (bloc) => bloc.add(const FetchTeams()),
      expect: () => [
        TeamsListSuccess(
          teams: paginatedResultTotalCount.data + paginatedResult.data,
          hasReachedMax: true,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => teamsRepository.findAll(
            any(
                that:
                    isA<FindTeamsArgs>().having((p) => p.offset, 'offset', 1)),
            false)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<TeamsListBloc, TeamsListState>(
      'does not emit any state when FetchTeams event is added and hasReachedMax is true',
      build: () => teamsListBloc,
      seed: () => TeamsListSuccess(
        teams: paginatedResultTotalCount.data,
        hasReachedMax: true,
        totalCount: 1,
      ),
      act: (bloc) => bloc.add(const FetchTeams()),
      expect: () => [],
      verify: (_) {
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<TeamsListBloc, TeamsListState>(
        'emits [TeamsListSuccess] when RefreshTeams event is added',
        setUp: () {
          when(() => teamsRepository.findAll(any(), any()))
              .thenAnswer((invocation) async => paginatedResultTotalCount);
        },
        build: () => teamsListBloc,
        act: (bloc) => bloc.add(const RefreshTeams(null)),
        expect: () => [
              TeamsListInitial(),
              TeamsListSuccess(
                teams: paginatedResultTotalCount.data,
                hasReachedMax: false,
                totalCount: paginatedResultTotalCount.totalCount!,
              ),
            ],
        verify: (_) {
          verify(() => teamsRepository.findAll(
              any(
                  that: isA<FindTeamsArgs>()
                      .having((p) => p.offset, 'offset', 0)),
              true)).called(1);
          verifyNoMoreInteractions(teamsRepository);
        });

    blocTest<TeamsListBloc, TeamsListState>(
      'emits [TeamsListSuccess] when RefreshTeams event is added with args',
      setUp: () {
        when(() => teamsRepository.findAll(any(), any()))
            .thenAnswer((invocation) async => paginatedResultTotalCount);
      },
      build: () => teamsListBloc,
      act: (bloc) =>
          bloc.add(const RefreshTeams(FindTeamsArgs(isActive: true))),
      expect: () => [
        TeamsListInitial(),
        TeamsListSuccess(
          teams: paginatedResultTotalCount.data,
          hasReachedMax: false,
          totalCount: paginatedResultTotalCount.totalCount!,
        ),
      ],
      verify: (_) {
        verify(() => teamsRepository.findAll(
            any(
              that: isA<FindTeamsArgs>()
                  .having((p) => p.offset, 'offset', 0)
                  .having((p) => p.isActive, 'isActive', true),
            ),
            true)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );
  });
}
