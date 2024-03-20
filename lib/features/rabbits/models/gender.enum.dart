enum Gender {
  male('Male'),
  female('Female'),
  unknown('Unknown');

  const Gender(this.jsonValue);

  final String jsonValue;

  static Gender fromJson(jsonValue) =>
      Gender.values.firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }
}
