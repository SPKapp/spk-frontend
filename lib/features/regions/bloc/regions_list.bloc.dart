import 'package:meta/meta.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/regions/models/dto.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';

/// A bloc that manages the state of a list with regions.
///
/// This bloc is responsible for fetching the regions from the repository.
class RegionsListBloc extends IGetListBloc<Region, FindRegionsArgs> {
  RegionsListBloc({
    required IRegionsRepository regionsRepository,
    required super.args,
  }) : _regionsRepository = regionsRepository;

  final IRegionsRepository _regionsRepository;

  @override
  @visibleForOverriding
  Future<Paginated<Region>> fetchData() async {
    return await _regionsRepository.findAll(
      args.copyWith(offset: () => state.data.length),
      state.totalCount == 0,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error while fetching regions', error: error);
    return null;
  }
}
