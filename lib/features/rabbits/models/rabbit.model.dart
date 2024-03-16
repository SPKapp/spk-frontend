import 'package:equatable/equatable.dart';

final class Rabbit extends Equatable {
  const Rabbit({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  static Rabbit fromJson(Map<String, dynamic> json) {
    return Rabbit(
      id: int.parse(json['id']),
      name: json['name'] as String,
    );
  }

  @override
  List<Object> get props => [id, name];
}
