enum AdmissionType {
  handedOver('HandedOver'),
  found('Found'),
  returned('Returned');

  const AdmissionType(this.jsonValue);

  final String jsonValue;

  static AdmissionType fromJson(jsonValue) => AdmissionType.values
      .firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }
}
