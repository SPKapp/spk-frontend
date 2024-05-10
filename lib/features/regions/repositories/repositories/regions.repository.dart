import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';

import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces/region.repo.interface.dart';

part 'regions.queries.dart';

final class RegionsRepository implements IRegionsRepository {
  RegionsRepository(this.gqlService);

  final GqlService gqlService;

  @override
  Future<Paginated<Region>> findAll(
    FindRegionsArgs args,
    bool totalCount,
  ) async {
    final result = await gqlService.query(
      _FindAllRegionsQuery.document(totalCount),
      operationName: _FindAllRegionsQuery.name,
      variables: args.toJson(),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return Paginated.fromJson(
      result.data!['regions'],
      (json) => Region.fromJson(json),
    );
  }
}
