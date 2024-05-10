import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class FindUsersArgs extends Equatable {
  const FindUsersArgs({
    this.offset,
    this.limit,
    this.regionsIds,
    this.isActive = true,
    this.name,
  });

  final int? offset;
  final int? limit;
  final List<String>? regionsIds;
  final bool? isActive;
  final String? name;

  @override
  List<Object?> get props => [
        offset,
        limit,
        regionsIds,
        isActive,
        name,
      ];

  FindUsersArgs copyWith({
    ValueGetter<int?>? offset,
    ValueGetter<int?>? limit,
    ValueGetter<List<String>?>? regionsIds,
    ValueGetter<bool?>? isActive,
    ValueGetter<String?>? name,
  }) {
    return FindUsersArgs(
      offset: offset != null ? offset() : this.offset,
      limit: limit != null ? limit() : this.limit,
      regionsIds: regionsIds != null ? regionsIds() : this.regionsIds,
      isActive: isActive != null ? isActive() : this.isActive,
      name: name != null ? name() : this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (regionsIds != null) 'regionsIds': regionsIds,
      'isActive': isActive,
      if (name != null) 'name': name,
    };
  }
}
