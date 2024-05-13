import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';

abstract interface class ITeamsRepository {
  /// Retrieves a list of [Team] objects based on the provided arguments.
  ///
  /// The [args] parameter specifies the criteria for filtering the [Team] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<Team>> findAll(FindTeamsArgs args, bool totalCount);

  /// Retrieves a list of [Region] objects and [Team] objects based on the provided [regionsIds].
  Future<(Iterable<Region>, Iterable<Team>)> fetchRegionsAndTeams(
    Iterable<String>? regionsIds,
  );
}
