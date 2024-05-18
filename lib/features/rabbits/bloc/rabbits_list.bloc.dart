import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

/// A bloc that manages the state of a list with rabbits.
///
/// This bloc is used to fetch the list of rabbits.
class RabbitsListBloc extends IGetListBloc<RabbitGroup, FindRabbitsArgs> {
  RabbitsListBloc({
    required IRabbitsRepository rabbitsRepository,
    required super.args,
  }) : _rabbitsRepository = rabbitsRepository;

  final IRabbitsRepository _rabbitsRepository;

  @override
  @visibleForOverriding
  Future<Paginated<RabbitGroup>> fetchData() {
    return _rabbitsRepository.findAll(
      args.copyWith(offset: () => state.data.length),
      state.totalCount == 0,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error fetching rabbits', error: error);
    return null;
  }
}
