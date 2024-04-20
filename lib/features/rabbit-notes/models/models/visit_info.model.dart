import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/rabbit-notes/models/enums/visit-type.enum.dart';

final class VisitInfo extends Equatable implements Comparable<VisitInfo> {
  const VisitInfo({
    required this.visitType,
    this.additionalInfo,
  });

  final VisitType visitType;
  final String? additionalInfo;

  @override
  List<Object?> get props => [visitType, additionalInfo];

  factory VisitInfo.fromJson(Map<String, dynamic> json) {
    return VisitInfo(
      visitType: VisitType.fromJson(json['visitType']),
      additionalInfo: json['additionalInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'visitType': visitType.toJson(),
        if (additionalInfo != null) 'additionalInfo': additionalInfo,
      };

  @override
  int compareTo(VisitInfo other) {
    return visitType.compareTo(other.visitType);
  }
}
