import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class FindRegionsArgs extends Equatable {
  const FindRegionsArgs({
    this.offset,
    this.limit,
    this.regionsIds,
    this.name,
  });

  final int? offset;
  final int? limit;
  final Iterable<String>? regionsIds;
  final String? name;

  @override
  List<Object?> get props => [
        offset,
        limit,
        regionsIds,
        name,
      ];

  FindRegionsArgs copyWith({
    ValueGetter<int?>? offset,
    ValueGetter<int?>? limit,
    ValueGetter<Iterable<String>?>? regionsIds,
    ValueGetter<String?>? name,
  }) {
    return FindRegionsArgs(
      offset: offset != null ? offset() : this.offset,
      limit: limit != null ? limit() : this.limit,
      regionsIds: regionsIds != null ? regionsIds() : this.regionsIds,
      name: name != null ? name() : this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (regionsIds != null) 'regionsIds': regionsIds?.toList(),
      if (name != null) 'name': name,
    };
  }
}
