enum RabbitStatus {
  forCastration('ForCastration');

  const RabbitStatus(this.jsonValue);

  final String jsonValue;

  static RabbitStatus fromJson(jsonValue) => RabbitStatus.values
      .firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }
}
