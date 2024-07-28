import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'photo.model.g.dart';

/// The photo model.
/// It contains the photo data and the last update time.
@HiveType(typeId: 0)
final class Photo extends Equatable {
  const Photo({
    required this.data,
    required this.updatedAt,
    this.isDefault = false,
  });

  @HiveField(0)
  final Uint8List data;
  @HiveField(1)
  final DateTime updatedAt;
  @HiveField(2)
  final bool isDefault;

  @override
  List<Object> get props => [data, updatedAt, isDefault];

  @override
  String toString() {
    return 'Photo(updatedAt: $updatedAt, isDefault: $isDefault)';
  }

  /// Empty photo represent the error state.
  Photo.error()
      : this(
          data: Uint8List(0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
          isDefault: false,
        );

  Photo copyWith({
    Uint8List? data,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return Photo(
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
