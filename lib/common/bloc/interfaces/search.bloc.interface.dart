import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/debounce.transformer.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

abstract class ISearchBloc<T extends Object>
    extends Bloc<SearchEvent, SearchState<T>> {
  ISearchBloc() : super(SearchInitial<T>()) {
    on<FetchSearch>(
      _onFetchList,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );
    on<RefreshSearch>(
      _onRefreshList,
      transformer: debounceTransformer(const Duration(milliseconds: 500)),
    );

    on<ClearSearch>(_onClearSearch);
  }

  final logger = LoggerService();

  void _onFetchList(FetchSearch event, Emitter<SearchState<T>> emit) async {
    if (state.hasReachedMax) return;

    if (state.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    try {
      final paginatedResult = await fetchData(state.totalCount == 0);

      final totalCount = paginatedResult.totalCount ?? state.totalCount;

      final newData = state.data + paginatedResult.data;

      emit(SearchSuccess(
        query: state.query,
        data: newData,
        hasReachedMax: newData.length >= totalCount,
        totalCount: totalCount,
      ));
    } catch (e) {
      final code = createErrorCode(e);
      if (code != null) {
        emit(SearchFailure(
          code: code,
          query: state.query,
          data: state.data,
          hasReachedMax: state.hasReachedMax,
          totalCount: state.totalCount,
        ));
      } else {
        emit(SearchFailure(
          query: state.query,
          data: state.data,
          hasReachedMax: state.hasReachedMax,
          totalCount: state.totalCount,
        ));
      }
    }
  }

  /// Fetches the data from the server.
  @visibleForOverriding
  Future<Paginated<T>> fetchData(bool getTotalCount);

  /// Creates an error code from the given error.
  ///
  /// In this function you also should log the error.
  @visibleForOverriding
  String? createErrorCode(Object error);

  void _onRefreshList(RefreshSearch event, Emitter<SearchState<T>> emit) {
    emit(SearchInitial<T>(query: event.query));
    add(const FetchSearch());
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState<T>> emit) {
    emit(SearchInitial<T>());
  }
}

// ***************************
// ********** Event **********
// ***************************

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class FetchSearch extends SearchEvent {
  const FetchSearch();
}

final class RefreshSearch extends SearchEvent {
  const RefreshSearch(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

final class ClearSearch extends SearchEvent {
  const ClearSearch();
}

// ***************************
// ********** State **********
// ***************************

sealed class SearchState<T extends Object> extends Equatable {
  SearchState({
    this.query = '',
    List<T>? data,
    this.hasReachedMax = false,
    this.totalCount = 0,
  }) : data = data ?? <T>[];

  final String query;
  final List<T> data;
  final bool hasReachedMax;
  final int totalCount;

  @override
  List<Object> get props => [query, data, hasReachedMax, totalCount];
}

final class SearchInitial<T extends Object> extends SearchState<T> {
  SearchInitial({super.query});
}

final class SearchSuccess<T extends Object> extends SearchState<T> {
  SearchSuccess({
    required super.query,
    required super.data,
    required super.hasReachedMax,
    required super.totalCount,
  });
}

final class SearchFailure<T extends Object> extends SearchState<T> {
  factory SearchFailure({
    String code = 'unknown',
    String? query,
    List<T>? data,
    bool? hasReachedMax,
    int? totalCount,
  }) {
    assert(
      (query != null &&
              data != null &&
              hasReachedMax != null &&
              totalCount != null) ||
          (data == null && hasReachedMax == null && totalCount == null),
      'query, data, hasReachedMax, and totalCount must be provided together',
    );

    if (query == null) {
      return SearchFailure._empty(code: code);
    }

    return SearchFailure._withData(
      code: code,
      query: query,
      data: data,
      hasReachedMax: hasReachedMax ?? false,
      totalCount: totalCount ?? 0,
    );
  }

  SearchFailure._empty({
    required this.code,
  });

  SearchFailure._withData({
    required this.code,
    required super.query,
    required super.data,
    required super.hasReachedMax,
    required super.totalCount,
  });

  final String code;
}
