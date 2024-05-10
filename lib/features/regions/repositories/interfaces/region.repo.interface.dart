import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';

abstract interface class IRegionsRepository {
  /// Finds all regions.
  ///
  /// The [args] parameter specifies the criteria for filtering the [Region] objects. The [totalCount] parameter specifies whether the total number of objects should be included in the result, otherwise it will be null.
  Future<Paginated<Region>> findAll(FindRegionsArgs args, bool totalCount);
}
