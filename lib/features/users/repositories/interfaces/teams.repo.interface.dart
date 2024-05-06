import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

abstract interface class ITeamsRepository {
  Future<(Iterable<Region>, Iterable<Team>)> fetchRegionsAndTeams(
    Iterable<String>? regionsIds,
  );
}
