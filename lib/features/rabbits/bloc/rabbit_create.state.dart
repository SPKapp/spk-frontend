part of 'rabbit_create.cubit.dart';

sealed class RabbitCreateState extends Equatable {
  const RabbitCreateState();

  @override
  List<Object> get props => [];
}

final class RabbitCreateInitial extends RabbitCreateState {
  const RabbitCreateInitial();
}

final class RabbitCreated extends RabbitCreateState {
  const RabbitCreated({
    required this.rabbitId,
  });

  final int rabbitId;

  @override
  List<Object> get props => [rabbitId];
}

final class RabbitCreateFailure extends RabbitCreateState {
  const RabbitCreateFailure();
}
