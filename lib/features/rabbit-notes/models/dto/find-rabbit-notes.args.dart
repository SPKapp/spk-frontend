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
}

final class FindRabbitNotesArgs extends Equatable {
  const FindRabbitNotesArgs({
    required this.rabbitId,
    this.createdAtFrom,
    this.createdAtTo,
    this.withWeight,
    this.isVetVisit,
    this.vetVisitArgs,
  });

  final int rabbitId;
  final DateTime? createdAtFrom;
  final DateTime? createdAtTo;
  final bool? withWeight;
  final bool? isVetVisit;
  final VetVisitArgs? vetVisitArgs;

  @override
  List<Object?> get props => [
        rabbitId,
        createdAtFrom,
        createdAtTo,
        withWeight,
        isVetVisit,
        vetVisitArgs,
      ];
}
