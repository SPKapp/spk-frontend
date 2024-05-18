import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/search.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

/// A bloc that manages the state of a list with rabbitGroups.
///
/// It uses the [IRabbitsRepository] to fetch the rabbitGroups.
class RabbitsSearchBloc extends ISearchBloc<RabbitGroup> {
  RabbitsSearchBloc({
    required IRabbitsRepository rabbitsRepository,
    required FindRabbitsArgs args,
  })  : _rabbitsRepository = rabbitsRepository,
        _args = args;

  final IRabbitsRepository _rabbitsRepository;
  final FindRabbitsArgs _args;

  @override
  @visibleForOverriding
  Future<Paginated<RabbitGroup>> fetchData() async {
    return await _rabbitsRepository.findAll(
      _args.copyWith(
        offset: () => state.data.length,
        name: () => state.query,
      ),
      state.totalCount == 0,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error while fetching rabbits', error: error);
    return null;
  }
}
