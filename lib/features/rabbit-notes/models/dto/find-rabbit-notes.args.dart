import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';

final class VetVisitArgs extends Equatable {
  const VetVisitArgs({
    this.dateFrom,
    this.dateTo,
    this.types,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<VisitType>? types;

  @override
  List<Object?> get props => [
        dateFrom,
        dateTo,
        types,
      ];

  VetVisitArgs copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    List<VisitType>? types,
  }) {
    return VetVisitArgs(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      types: types ?? this.types,
    );
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
    this.vetVisitArgs,
  });

  final int rabbitId;
  final int? offset;
  final int? limit;
  final DateTime? createdAtFrom;
  final DateTime? createdAtTo;
  final bool? withWeight;
  final bool? isVetVisit;
  final VetVisitArgs? vetVisitArgs;

  @override
  List<Object?> get props => [
        rabbitId,
        offset,
        limit,
        createdAtFrom,
        createdAtTo,
        withWeight,
        isVetVisit,
        vetVisitArgs,
      ];

  FindRabbitNotesArgs copyWith({
    int? rabbitId,
    int? offset,
    int? limit,
    DateTime? createdAtFrom,
    DateTime? createdAtTo,
    bool? withWeight,
    bool? isVetVisit,
    VetVisitArgs? vetVisitArgs,
  }) {
    return FindRabbitNotesArgs(
      rabbitId: rabbitId ?? this.rabbitId,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      createdAtFrom: createdAtFrom ?? this.createdAtFrom,
      createdAtTo: createdAtTo ?? this.createdAtTo,
      withWeight: withWeight ?? this.withWeight,
      isVetVisit: isVetVisit ?? this.isVetVisit,
      vetVisitArgs: vetVisitArgs ?? this.vetVisitArgs,
    );
  }
}
