import 'package:equatable/equatable.dart';

final class Rabbit extends Equatable {
  const Rabbit({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object> get props => [id, name];
}
