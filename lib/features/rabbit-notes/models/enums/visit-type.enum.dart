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
}
