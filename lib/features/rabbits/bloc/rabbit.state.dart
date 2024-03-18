part of 'rabbit.cubit.dart';

enum RabbitStatus { initial, success, failure }

sealed class RabbitState extends Equatable {
  const RabbitState();

  @override
  List<Object?> get props => [];
}

final class RabbitInitial extends RabbitState {
  const RabbitInitial();
}

final class RabbitSuccess extends RabbitState {
  const RabbitSuccess({
    required this.rabbit,
  });

  final Rabbit rabbit;

  @override
  List<Object?> get props => [rabbit];
}

final class RabbitUpdated extends RabbitSuccess {
  const RabbitUpdated({
    required super.rabbit,
  });
}

final class RabbitFailure extends RabbitState {
  const RabbitFailure();
}

final class RabbitUpdateFailure extends RabbitFailure {
  const RabbitUpdateFailure();
}
