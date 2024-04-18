enum VisitType {
  control('Control'),
  caccination('Vaccination'),
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
      case VisitType.caccination:
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
}
