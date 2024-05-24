import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:spk_app_frontend/common/exceptions/repository.exception.dart';

import 'package:spk_app_frontend/common/services/logger.service.dart';

/// A cubit that manages the state of updating an object.
///
/// Available functions:
/// - [refresh] - restarts state to initial
///
/// Available states:
/// - [UpdateInitial] - initial state
/// - [UpdateSuccess] - the object has been updated successfully
/// - [UpdateFailure] - an error occurred while updating the object
///
abstract class IUpdateCubit extends Cubit<UpdateState> {
  IUpdateCubit() : super(const UpdateInitial());

  final logger = LoggerService();

  /// Restart state to initial.
  @nonVirtual
  void refresh() {
    emit(const UpdateInitial());
  }

  @nonVirtual
  @protected
  void error(Object e, String message) {
    logger.error(message, error: e);

    if (e is RepositoryException) {
      emit(UpdateFailure(code: e.code));
    } else {
      emit(const UpdateFailure());
    }

    emit(const UpdateInitial());
  }
}

sealed class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object> get props => [];
}

final class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

final class UpdateSuccess extends UpdateState {
  const UpdateSuccess();
}

final class UpdateFailure extends UpdateState {
  const UpdateFailure({
    this.code = 'unknown',
  });

  final String code;

  @override
  List<Object> get props => [code];
}
