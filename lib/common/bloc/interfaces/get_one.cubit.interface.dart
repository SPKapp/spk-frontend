import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:spk_app_frontend/common/services/logger.service.dart';

/// A cubit that manages the state of a single object.
///
/// Available functions:
/// - [fetch] - fetches the data
/// - [refresh] - restarts fetching the data
///
/// Available states:
/// - [GetOneInitial] - initial state
/// - [GetOneSuccess] - the data has been fetched successfully
/// - [GetOneFailure] - an error occurred while fetching the data
///
abstract class IGetOneCubit<T extends Object> extends Cubit<GetOneState<T>> {
  IGetOneCubit() : super(GetOneInitial<T>());

  final logger = LoggerService();

  /// Fetches the data.
  /// Emits new state only if data was changed.
  void fetch();

  /// Restarts fetching the data.
  /// Always emits new state.
  @nonVirtual
  void refresh() {
    emit(GetOneInitial<T>());
    fetch();
  }
}

sealed class GetOneState<T extends Object> extends Equatable {
  const GetOneState();

  @override
  List<Object> get props => [];
}

final class GetOneInitial<T extends Object> extends GetOneState<T> {
  const GetOneInitial();
}

final class GetOneSuccess<T extends Object> extends GetOneState<T> {
  const GetOneSuccess({
    required this.data,
  });

  final T data;

  @override
  List<Object> get props => [data];
}

final class GetOneFailure<T extends Object> extends GetOneState<T> {
  const GetOneFailure({
    this.code = 'unknown',
  });

  final String code;

  @override
  List<Object> get props => [code];
}
