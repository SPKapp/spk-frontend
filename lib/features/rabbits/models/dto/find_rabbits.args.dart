import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

final class FindRabbitsArgs extends Equatable {
  const FindRabbitsArgs({
    this.offset,
    this.limit,
    this.regionsIds,
    this.teamsIds,
    this.name,
    this.rabbitStatus,
  });

  final int? offset;
  final int? limit;
  final List<String>? regionsIds;
  final List<String>? teamsIds;
  final String? name;
  final List<RabbitStatus>? rabbitStatus;

  @override
  List<Object?> get props => [
        offset,
        limit,
        regionsIds,
        teamsIds,
        name,
      ];

  FindRabbitsArgs copyWith({
    ValueGetter<int?>? offset,
    ValueGetter<int?>? limit,
    ValueGetter<List<String>?>? regionsIds,
    ValueGetter<List<String>?>? teamsIds,
    ValueGetter<String?>? name,
    ValueGetter<List<RabbitStatus>?>? rabbitStatus,
  }) {
    return FindRabbitsArgs(
      offset: offset != null ? offset() : this.offset,
      limit: limit != null ? limit() : this.limit,
      regionsIds: regionsIds != null ? regionsIds() : this.regionsIds,
      teamsIds: teamsIds != null ? teamsIds() : this.teamsIds,
      name: name != null ? name() : this.name,
      rabbitStatus: rabbitStatus != null ? rabbitStatus() : this.rabbitStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (regionsIds != null) 'regionsIds': regionsIds,
      if (teamsIds != null) 'teamsIds': teamsIds,
      if (name != null) 'name': name,
      if (rabbitStatus != null) 'rabbitStatus': rabbitStatus,
    };
  }
}
