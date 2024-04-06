import 'package:equatable/equatable.dart';

final class Region extends Equatable {
  const Region({
    required this.id,
    this.name,
  });

  final int id;
  final String? name;

  static Region fromJson(Map<String, dynamic> json) {
    return Region(
      id: int.parse(json['id']),
      name: json['name'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
