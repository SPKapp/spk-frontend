part of 'rabbit.cubit.dart';

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

final class RabbitFailure extends RabbitState {
  const RabbitFailure();
}
