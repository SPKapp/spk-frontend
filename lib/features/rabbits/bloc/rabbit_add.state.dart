part of 'rabbit_add.cubit.dart';

sealed class RabbitAddState extends Equatable {
  const RabbitAddState();

  @override
  List<Object> get props => [];
}

final class RabbitAddInitial extends RabbitAddState {
  const RabbitAddInitial();
}

final class RabbitCreated extends RabbitAddState {
  const RabbitCreated({
    required this.rabbitId,
  });

  final int rabbitId;

  @override
  List<Object> get props => [rabbitId];
}

final class RabbitAddFailure extends RabbitAddState {
  const RabbitAddFailure();
}
