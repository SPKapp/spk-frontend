part of 'rabbit_update.cubit.dart';

sealed class RabbitUpdateState extends Equatable {
  const RabbitUpdateState();

  @override
  List<Object> get props => [];
}

final class RabbitUpdateInitial extends RabbitUpdateState {
  const RabbitUpdateInitial();
}

final class RabbitUpdated extends RabbitUpdateState {
  const RabbitUpdated();
}

final class RabbitUpdateFailure extends RabbitUpdateState {
  const RabbitUpdateFailure();
}
