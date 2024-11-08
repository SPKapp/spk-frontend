import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/models/visit_info.model.dart';

final class VetVisit extends Equatable {
  const VetVisit({
    this.date,
    this.visitInfo = const [],
  });

  final DateTime? date;
  final List<VisitInfo> visitInfo;

  @override
  List<Object?> get props => [date, visitInfo];

  factory VetVisit.fromJson(Map<String, dynamic> json) {
    return VetVisit(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      visitInfo: (json['visitInfo'] as List)
          .map((e) => VisitInfo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': date?.toIso8601String(),
        if (visitInfo.isNotEmpty)
          'visitInfo': visitInfo.map((info) => info.toJson()).toList(),
      };
}
