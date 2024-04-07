import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/interfaces.dart';

part 'regions_list.event.dart';
part 'regions_list.state.dart';

/// A bloc that manages the state of a list with regions.
///
/// If [perPage] is not provided, the default value is defined by backend, if set to 0 the backend will return all regions.
///
/// The bloc provides [FetchRegions] event to fetch next page of regions and [RefreshRegions] event to restart fetching regions.
/// It emits [RegionsListInitial] state when the bloc is created, [RegionsListSuccess] state when the regions are fetched successfully
/// and [RegionsListFailure] state when an error occurs while fetching regions, this state also contains previous successful fetched regions.
class RegionsListBloc extends Bloc<RegionsListEvent, RegionsListState> {
  RegionsListBloc({
    required IRegionsRepository regionsRepository,
    int? perPage,
  })  : _regionsRepository = regionsRepository,
        _perPage = perPage,
        super(const RegionsListInitial()) {
    on<FetchRegions>(
      _onFetchRegions,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshRegions>(_onRefreshRegions);
  }

  final IRegionsRepository _regionsRepository;
  final int? _perPage;

  void _onFetchRegions(
      FetchRegions event, Emitter<RegionsListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _regionsRepository.findAll(
        offset: state.regions.length,
        limit: _perPage,
        totalCount: state is RegionsListInitial,
      );

      final regions = paginatedResult.data;
      final totalCount = (state is RegionsListInitial)
          ? paginatedResult.totalCount!
          : state.totalCount;

      emit(RegionsListSuccess(
        regions: state.regions + regions,
        hasReachedMax: state.regions.length + regions.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      emit(RegionsListFailure(
        regions: state.regions,
        hasReachedMax: state.hasReachedMax,
        totalCount: state.totalCount,
      ));
    }
  }

  void _onRefreshRegions(
      RefreshRegions event, Emitter<RegionsListState> emit) async {
    emit(const RegionsListInitial());
    add(const FetchRegions());
  }
}
