import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models/team.model.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces/teams.repo.interface.dart';

part 'teams.queries.dart';

final class TeamsReposiotry implements ITeamsRepository {
  TeamsReposiotry(this._gqlService);

  final GqlService _gqlService;

  @override
  Future<Paginated<Team>> findAll(
    FindTeamsArgs args,
    bool totalCount,
  ) async {
    final result = await _gqlService.query(_GetTeamQuery.document(totalCount),
        operationName: _GetTeamQuery.operationName, variables: args.toJson());

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return Paginated.fromJson<Team>(
      result.data!['teams'],
      Team.fromJson,
    );
  }

  @override
  Future<(Iterable<Region>, Iterable<Team>)> fetchRegionsAndTeams(
    Iterable<String>? regionsIds,
  ) async {
    final result = await _gqlService.query(
      _GetRegionsAndTeamsQuery.document,
      operationName: _GetRegionsAndTeamsQuery.operationName,
      variables: {
        if (regionsIds != null) 'regionsIds': List.unmodifiable(regionsIds),
        'limit': 0,
        'isActive': true,
      },
    );

    if (result.hasException) {
      throw Exception(result.exception);
    }

    final regions = (result.data!['regions']['data'] as Iterable)
        .map((json) => Region.fromJson(json));
    final teams = (result.data!['teams']['data'] as Iterable)
        .map((json) => Team.fromJson(json));

    return (regions, teams);
  }
}
