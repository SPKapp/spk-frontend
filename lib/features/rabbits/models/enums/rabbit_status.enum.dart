enum RabbitStatus {
  unknown('Unknown'),
  incoming('Incoming'),
  inTreatment('InTreatment'),
  adoptable('Adoptable'),
  adopted('Adopted'),
  deceased('Deceased');

  const RabbitStatus(this.jsonValue);

  final String jsonValue;

  static RabbitStatus fromJson(jsonValue) => RabbitStatus.values
      .firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }

  String get displayName {
    switch (this) {
      case RabbitStatus.unknown:
        return 'Nieznany status';
      case RabbitStatus.incoming:
        return 'Nieodebrany';
      case RabbitStatus.inTreatment:
        return 'W\u{00A0}leczeniu';
      case RabbitStatus.adoptable:
        return 'Do\u{00A0}adopcji';
      case RabbitStatus.adopted:
        return 'Adoptowany';
      case RabbitStatus.deceased:
        return 'Zmarły';
      default:
        return '';
    }
  }
}
