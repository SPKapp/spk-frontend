part of 'update_rabbit_group.cubit.dart';

sealed class UpdateRabbitGroupState extends Equatable {
  const UpdateRabbitGroupState();

  @override
  List<Object> get props => [];
}

final class UpdateRabbitGroupInitial extends UpdateRabbitGroupState {
  const UpdateRabbitGroupInitial();
}

final class UpdatedRabbitGroup extends UpdateRabbitGroupState {
  const UpdatedRabbitGroup();
}

final class UpdateRabbitGroupFailure extends UpdateRabbitGroupState {
  const UpdateRabbitGroupFailure({
    this.code = 'unknown',
  });

  final String code;

  @override
  List<Object> get props => [code];
}
