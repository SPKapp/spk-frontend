import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

final class VetVisitArgs extends Equatable {
  const VetVisitArgs({
    this.dateFrom,
    this.dateTo,
    this.visitTypes,
  });

  static const VetVisitArgs empty = VetVisitArgs();

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<VisitType>? visitTypes;

  @override
  List<Object?> get props => [
        dateFrom,
        dateTo,
        visitTypes,
      ];

  VetVisitArgs? copyWith({
    ValueGetter<DateTime?>? dateFrom,
    ValueGetter<DateTime?>? dateTo,
    ValueGetter<List<VisitType>?>? visitTypes,
  }) {
    return VetVisitArgs(
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      visitTypes: visitTypes != null
          ? (visitTypes()?.isEmpty == false ? visitTypes() : null)
          : this.visitTypes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
      if (visitTypes != null)
        'visitTypes': visitTypes?.map((e) => e.toJson()).toList(),
    };
  }
}

final class FindRabbitNotesArgs extends Equatable {
  const FindRabbitNotesArgs({
    required this.rabbitId,
    this.offset,
    this.limit,
    this.createdAtFrom,
    this.createdAtTo,
    this.withWeight,
    this.isVetVisit,
    this.vetVisit,
  });

  final String rabbitId;
  final int? offset;
  final int? limit;
  final DateTime? createdAtFrom;
  final DateTime? createdAtTo;
  final bool? withWeight;
  final bool? isVetVisit;
  final VetVisitArgs? vetVisit;

  @override
  List<Object?> get props => [
        rabbitId,
        offset,
        limit,
        createdAtFrom,
        createdAtTo,
        withWeight,
        isVetVisit,
        vetVisit,
      ];

  FindRabbitNotesArgs copyWith({
    ValueGetter<int?>? offset,
    ValueGetter<int?>? limit,
    ValueGetter<DateTime?>? createdAtFrom,
    ValueGetter<DateTime?>? createdAtTo,
    ValueGetter<bool?>? withWeight,
    ValueGetter<bool?>? isVetVisit,
    ValueGetter<VetVisitArgs?>? vetVisit,
  }) {
    return FindRabbitNotesArgs(
      rabbitId: rabbitId,
      offset: offset != null ? offset() : this.offset,
      limit: limit != null ? limit() : this.limit,
      createdAtFrom:
          createdAtFrom != null ? createdAtFrom() : this.createdAtFrom,
      createdAtTo: createdAtTo != null ? createdAtTo() : this.createdAtTo,
      withWeight: withWeight != null ? withWeight() : this.withWeight,
      isVetVisit: isVetVisit != null ? isVetVisit() : this.isVetVisit,
      vetVisit: vetVisit != null
          ? (vetVisit() != VetVisitArgs.empty ? vetVisit() : null)
          : this.vetVisit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rabbitId': rabbitId,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (createdAtFrom != null)
        'createdAtFrom': createdAtFrom!.toIso8601String(),
      if (createdAtTo != null) 'createdAtTo': createdAtTo!.toIso8601String(),
      if (withWeight != null) 'withWeight': withWeight,
      if (isVetVisit != null) 'isVetVisit': isVetVisit,
      if (vetVisit != null) 'vetVisit': vetVisit?.toJson(),
    };
  }
}
