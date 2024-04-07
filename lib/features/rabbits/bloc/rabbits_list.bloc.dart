import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits_list.state.dart';
part 'rabbits_list.event.dart';

enum RabbitsQueryType { my, all }

/// A bloc that manages the state of a list with rabbitGroups.
///
/// The bloc can be configured with [queryType]
/// to fetch the rabbits of the volunteer [RabbitsQueryType.my]
/// or all rabbits [RabbitsQueryType.all].
/// If [perPage] is not provided, the default value is defined by backend, if set to 0 the backend will return all rabbits.
/// if [regionsIds] is provided, the backend will return only rabbits from these regions.
///
/// The bloc provides [FetchRabbits] event to fetch next page of rabbits and [RefreshRabbits] event to restart fetching rabbits.
/// It emits [RabbitsListInitial] state when the bloc is created, [RabbitsListSuccess] state when the rabbits are fetched successfully
/// and [RabbitsListFailure] state when an error occurs while fetching rabbits, this state also contains previous successful fetched rabbits.
class RabbitsListBloc extends Bloc<RabbitsListEvent, RabbitsListState> {
  RabbitsListBloc({
    required IRabbitsRepository rabbitsRepository,
    required RabbitsQueryType queryType,
    int? perPage,
    List<int>? regionsIds,
  })  : _rabbitsRepository = rabbitsRepository,
        _queryType = queryType,
        _perPage = perPage,
        _regionsIds = regionsIds,
        super(const RabbitsListInitial()) {
    on<FetchRabbits>(
      _onFetchRabbits,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshRabbits>(_onRefreshRabbits);
  }

  final IRabbitsRepository _rabbitsRepository;
  final RabbitsQueryType _queryType;
  final int? _perPage;
  final List<int>? _regionsIds;

  void _onFetchRabbits(
      FetchRabbits event, Emitter<RabbitsListState> emit) async {
    switch (_queryType) {
      case RabbitsQueryType.my:
        await _onFetchMyRabbits(emit);
      case RabbitsQueryType.all:
        await _onFetchAllRabbits(emit);
    }
  }

  Future<void> _onFetchMyRabbits(Emitter<RabbitsListState> emit) async {
    try {
      // TODO: To analyze
      switch (state) {
        case RabbitsListInitial():
        case RabbitsListFailure():
          final rabbits = await _rabbitsRepository.myRabbits();
          emit(RabbitsListSuccess(
            rabbitGroups: rabbits,
            hasReachedMax: true,
            totalCount: rabbits.length,
          ));
        case RabbitsListSuccess():
          emit(state);
      }
    } catch (e) {
      emit(
        const RabbitsListFailure(),
      );
    }
  }

  Future<void> _onFetchAllRabbits(Emitter<RabbitsListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _rabbitsRepository.findAll(
        offset: state.rabbitGroups.length,
        limit: _perPage,
        regionsIds: _regionsIds,
        totalCount: state is RabbitsListInitial,
      );

      final rabbitGroups = paginatedResult.data;
      final totalCount = (state is RabbitsListInitial)
          ? paginatedResult.totalCount!
          : state.totalCount;

      emit(RabbitsListSuccess(
        rabbitGroups: state.rabbitGroups + rabbitGroups,
        hasReachedMax:
            state.rabbitGroups.length + rabbitGroups.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      emit(
        RabbitsListFailure(
          rabbitGroups: state.rabbitGroups,
          hasReachedMax: state.hasReachedMax,
          totalCount: state.totalCount,
        ),
      );
    }
  }

  void _onRefreshRabbits(
      RefreshRabbits event, Emitter<RabbitsListState> emit) async {
    emit(const RabbitsListInitial());
    add(const FetchRabbits());
  }
}
