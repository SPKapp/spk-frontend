import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

/// A bloc that manages the state of a list with objects.
///
/// Available functions:
/// - [FetchList] - fetches the next page of objects - this function is debounced
/// - [RefreshList] - restarts fetching the objects with the given arguments
///
/// Available states:
/// - [GetListInitial] - initial state
/// - [GetListSuccess] - the objects have been fetched successfully
/// - [GetListFailure] - an error occurred while fetching the objects
///
abstract class IGetListBloc<T extends Object, Args extends Object>
    extends Bloc<GetListEvent, GetListState<T>> {
  IGetListBloc({
    required Args args,
    required this.fetchError,
  })  : _args = args,
        super(GetListInitial<T>()) {
    on<FetchList>(
      _onFetchList,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshList<Args>>(_onRefreshList);
  }

  final logger = LoggerService();
  String fetchError;

  Args _args;
  Args get args => _args;

  /// Fetches the next page of data.
  void _onFetchList(FetchList event, Emitter<GetListState<T>> emit) async {
    if (state.hasReachedMax) return;

    try {
      logger.info('Fetching list of $T objects');
      final paginatedResult =
          await fetchData(state.data.length, state.totalCount == 0);
      logger.info('Fetched list of ${paginatedResult.data.length} $T objects');

      final totalCount = paginatedResult.totalCount ?? state.totalCount;

      logger.info(
          'Type of paginatedResult.data: ${paginatedResult.data.runtimeType}');
      logger.info('Type of state.data: ${state.data.runtimeType}');

      final newData = state.data + paginatedResult.data;

      logger.info('Total count of $T objects: $totalCount');

      emit(GetListSuccess(
        data: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      final code = createErrorCode(e);
      if (code != null) {
        emit(GetListFailure(
          code: code,
          data: state.data,
          hasReachedMax: state.hasReachedMax,
          totalCount: state.totalCount,
        ));
      } else {
        emit(GetListFailure(
          data: state.data,
          hasReachedMax: state.hasReachedMax,
          totalCount: state.totalCount,
        ));
      }
    }
  }

  /// Fetches the data from the server.
  @protected
  Future<Paginated<T>> fetchData(int offset, bool getTotalCount);

  /// Creates an error code from the given error.
  ///
  /// In this function you also should log the error.
  @visibleForOverriding
  String? createErrorCode(Object error);

  /// Restarts fetching the data.
  /// if new arguments are not provided it will use the previous arguments
  void _onRefreshList(RefreshList<Args> event, Emitter<GetListState<T>> emit) {
    _args = event.args ?? _args;
    emit(GetListInitial<T>());
    add(const FetchList());
  }
}
// ***************************
// ********** Event **********
// ***************************

sealed class GetListEvent extends Equatable {
  const GetListEvent();

  @override
  List<Object?> get props => [];
}

final class FetchList extends GetListEvent {
  const FetchList();
}

final class RefreshList<T> extends GetListEvent {
  const RefreshList(this.args);

  final T? args;

  @override
  List<Object?> get props => [args];
}

// ***************************
// ********** State **********
// ***************************

sealed class GetListState<T extends Object> extends Equatable {
  GetListState({
    List<T>? data,
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : data = data ?? <T>[];

  final List<T> data;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [data, hasReachedMax, totalCount];
}

final class GetListInitial<T extends Object> extends GetListState<T> {
  GetListInitial();
}

final class GetListSuccess<T extends Object> extends GetListState<T> {
  GetListSuccess({
    required super.data,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class GetListFailure<T extends Object> extends GetListState<T> {
  factory GetListFailure({
    String code = 'unknown',
    List<T>? data,
    bool? hasReachedMax,
    int? totalCount,
  }) {
    assert(
      (data != null && hasReachedMax != null && totalCount != null) ||
          (data == null && hasReachedMax == null && totalCount == null),
      'data, hasReachedMax and totalCount must be provided together',
    );

    if (data != null) {
      return GetListFailure._withData(
        code: code,
        data: data,
        hasReachedMax: hasReachedMax!,
        totalCount: totalCount!,
      );
    }

    return GetListFailure._empty(code: code);
  }

  GetListFailure._empty({
    required this.code,
  }) : super();

  GetListFailure._withData({
    required this.code,
    required super.data,
    required super.hasReachedMax,
    required super.totalCount,
  });

  final String code;
}
