import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';

abstract interface class IRegionsRepository {
  /// Finds all regions.
  ///
  /// Returns a [Future] that resolves to a [Paginated] object containing a list of [Region] objects.
  /// If [totalCount] is set to `true`, the total count of regions is also returned.
  /// If [offset] is set, the list of regions starts from that index.
  /// If [limit] is set, the list of regions is limited to that number, if not set, the default limit is used, if set to `0`, the limit is removed.
  ///
  /// When requested by RegionManager, returns a list of his regions.
  Future<Paginated<Region>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
  });
}
