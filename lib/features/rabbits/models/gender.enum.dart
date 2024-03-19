enum Gender {
  male('male'),
  female('female'),
  unknown('unknown');

  const Gender(this.jsonValue);

  final dynamic jsonValue;

  static Gender fromJson(jsonValue) =>
      Gender.values.firstWhere((element) => jsonValue == element.jsonValue);
}
