import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/bloc/user_actions/regions_and_teams.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockTeamsRepository extends Mock implements ITeamsRepository {}

void main() {
  group(RegionsAndTeamsCubit, () {
    late ITeamsRepository teamsRepository;
    late RegionsAndTeamsCubit cubit;

    setUp(() {
      teamsRepository = MockTeamsRepository();
      cubit = RegionsAndTeamsCubit(teamsRepository: teamsRepository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is RegionsAndTeamsInitial', () {
      expect(cubit.state, const RegionsAndTeamsInitial());
    });

    blocTest<RegionsAndTeamsCubit, RegionsAndTeamsState>(
      'emits [RegionsAndTeamsSuccess] when fetch is successful',
      setUp: () {
        when(() => teamsRepository.fetchRegionsAndTeams(any())).thenAnswer(
          (_) async => (List<Region>.empty(), List<Team>.empty()),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.fetch(null),
      expect: () => [
        const RegionsAndTeamsSuccess(regions: [], teams: []),
      ],
      verify: (_) {
        verify(() => teamsRepository.fetchRegionsAndTeams(null)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<RegionsAndTeamsCubit, RegionsAndTeamsState>(
      'emits [RegionsAndTeamsFailure] when fetch is unsuccessful',
      setUp: () {
        when(() => teamsRepository.fetchRegionsAndTeams(any())).thenThrow(
          Exception(),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.fetch(null),
      expect: () => [
        const RegionsAndTeamsFailure(),
      ],
      verify: (_) {
        verify(() => teamsRepository.fetchRegionsAndTeams(null)).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );

    blocTest<RegionsAndTeamsCubit, RegionsAndTeamsState>(
      'emits [RegionsAndTeamsSuccess] when fetch is successful with regionsIds',
      setUp: () {
        when(() => teamsRepository.fetchRegionsAndTeams(any())).thenAnswer(
          (_) async => (List<Region>.empty(), List<Team>.empty()),
        );
      },
      build: () => cubit,
      act: (cubit) => cubit.fetch(['1']),
      expect: () => [
        const RegionsAndTeamsSuccess(regions: [], teams: []),
      ],
      verify: (_) {
        verify(() => teamsRepository.fetchRegionsAndTeams(['1'])).called(1);
        verifyNoMoreInteractions(teamsRepository);
      },
    );
  });
}
