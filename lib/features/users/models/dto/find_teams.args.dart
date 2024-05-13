import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class FindTeamsArgs extends Equatable {
  const FindTeamsArgs({
    this.offset,
    this.limit,
    this.regionsIds,
    this.isActive = true,
  });

  final int? offset;
  final int? limit;
  final List<String>? regionsIds;
  final bool? isActive;

  @override
  List<Object?> get props => [
        offset,
        limit,
        regionsIds,
        isActive,
      ];

  FindTeamsArgs copyWith({
    ValueGetter<int?>? offset,
    ValueGetter<int?>? limit,
    ValueGetter<List<String>?>? regionsIds,
    ValueGetter<bool?>? isActive,
  }) {
    return FindTeamsArgs(
      offset: offset != null ? offset() : this.offset,
      limit: limit != null ? limit() : this.limit,
      regionsIds: regionsIds != null ? regionsIds() : this.regionsIds,
      isActive: isActive != null ? isActive() : this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (regionsIds != null) 'regionsIds': regionsIds,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
