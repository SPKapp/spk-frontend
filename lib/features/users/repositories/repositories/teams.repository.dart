import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models/team.model.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces/teams.repo.interface.dart';

part 'teams.queries.dart';

final class TeamsReposiotry implements ITeamsRepository {
  TeamsReposiotry(this._gqlService);

  final GqlService _gqlService;

  @override
  Future<(Iterable<Region>, Iterable<Team>)> fetchRegionsAndTeams(
    Iterable<String>? regionsIds,
  ) async {
    final result = await _gqlService.query(
      GetRegionsAndTeamsQuery.document,
      operationName: GetRegionsAndTeamsQuery.operationName,
      variables: {
        if (regionsIds != null) 'regionsIds': regionsIds,
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
