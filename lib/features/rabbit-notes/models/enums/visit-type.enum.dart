import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum VisitType implements Comparable<VisitType> {
  control('Control'),
  vaccination('Vaccination'),
  deworming('Deworming'),
  treatment('Treatment'),
  operation('Operation'),
  castration('Castration'),
  chip('Chip');

  const VisitType(this.jsonValue);

  final String jsonValue;

  static VisitType fromJson(jsonValue) =>
      VisitType.values.firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }

  String get displayName {
    switch (this) {
      case VisitType.control:
        return 'Kontrola';
      case VisitType.vaccination:
        return 'Szczepienie';
      case VisitType.deworming:
        return 'Odrobaczanie';
      case VisitType.treatment:
        return 'Leczenie';
      case VisitType.operation:
        return 'Operacja';
      case VisitType.castration:
        return 'Kastracja';
      case VisitType.chip:
        return 'Chipowanie';
    }
  }

  IconData get icon {
    switch (this) {
      case VisitType.control:
        return FontAwesomeIcons.fileMedical;
      case VisitType.vaccination:
        return FontAwesomeIcons.syringe;
      case VisitType.deworming:
        return FontAwesomeIcons.bugSlash;
      case VisitType.treatment:
        return FontAwesomeIcons.briefcaseMedical;
      case VisitType.operation:
        return FontAwesomeIcons.fileWaveform;
      case VisitType.castration:
        return FontAwesomeIcons.circleXmark;
      case VisitType.chip:
        return FontAwesomeIcons.microchip;
    }
  }

  @override
  int compareTo(VisitType other) {
    return index.compareTo(other.index);
  }
}
