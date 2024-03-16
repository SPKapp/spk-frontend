import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

part 'rabbits.queries.dart';

class RabbitsRepository {
  RabbitsRepository(this.gqlService);

  final GqlService gqlService;

  Future<List<RabbitsGroup>> myRabbits() async {
    final result = await gqlService.query(_myRabbitsQuery);

    if (result.hasException) {
      throw Exception(result.exception);
    }

    return (result.data?['myProfile']['team']['rabbitGroups'] as List)
        .map((json) => RabbitsGroup.fromJson(json))
        .toList();
  }
}
