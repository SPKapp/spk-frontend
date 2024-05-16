part of 'rabbit_group.cubit.dart';

sealed class RabbitGroupState extends Equatable {
  const RabbitGroupState();

  @override
  List<Object> get props => [];
}

final class RabbitGroupInitial extends RabbitGroupState {
  const RabbitGroupInitial();
}

final class RabbitGroupSuccess extends RabbitGroupState {
  const RabbitGroupSuccess({
    required this.rabbitGroup,
  });

  final RabbitGroup rabbitGroup;

  @override
  List<Object> get props => [rabbitGroup];
}

final class RabbitGroupFailure extends RabbitGroupState {
  const RabbitGroupFailure({
    this.code = 'unknown',
  });

  final String code;

  @override
  List<Object> get props => [code];
}
