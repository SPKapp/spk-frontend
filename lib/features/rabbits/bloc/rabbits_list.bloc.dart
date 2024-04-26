import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';

part 'rabbits_list.state.dart';
part 'rabbits_list.event.dart';

enum RabbitsQueryType { my, all }

/// A bloc that manages the state of a list with rabbitGroups.
///
/// Available functions:
/// - [FetchRabbits] - fetches the next page of rabbits
/// it uses the previous arguments to fetch the next page
/// - [RefreshRabbits] - restarts fetching the rabbits with the given arguments
///  if no arguments are provided it will use the previous arguments otherwise new arguments will be used
///
/// Available states:
/// - [RabbitsListInitial] - initial state
/// - [RabbitsListSuccess] - the rabbits have been fetched successfully
/// - [RabbitsListFailure] - an error occurred while fetching the rabbits
///
class RabbitsListBloc extends Bloc<RabbitsListEvent, RabbitsListState> {
  RabbitsListBloc({
    required IRabbitsRepository rabbitsRepository,
    required FindRabbitsArgs args,
  })  : _rabbitsRepository = rabbitsRepository,
        _args = args,
        super(const RabbitsListInitial()) {
    on<FetchRabbits>(
      _onFetch,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshRabbits>(_onRefreshRabbits);
  }

  final IRabbitsRepository _rabbitsRepository;
  FindRabbitsArgs _args;

  FindRabbitsArgs get args => _args;

  Future<void> _onFetch(
      FetchRabbits event, Emitter<RabbitsListState> emit) async {
    if (state.hasReachedMax) return;

    try {
      final paginatedResult = await _rabbitsRepository.findAll(
        _args.copyWith(offset: () => state.rabbitGroups.length),
        state.totalCount == 0,
      );

      final totalCount = paginatedResult.totalCount ?? state.totalCount;
      final newData = state.rabbitGroups + paginatedResult.data;

      emit(RabbitsListSuccess(
        rabbitGroups: newData,
        hasReachedMax: newData.length >= totalCount,
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
    _args = event.args ?? _args;
    emit(const RabbitsListInitial());
    add(const FetchRabbits());
  }
}
