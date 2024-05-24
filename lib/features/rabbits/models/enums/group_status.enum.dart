enum RabbitGroupStatus {
  unknown('Unknown'),
  incoming('Incoming'),
  inTreatment('InTreatment'),
  adoptable('Adoptable'),
  adopted('Adopted'),
  deceased('Deceased');

  const RabbitGroupStatus(this.jsonValue);

  final String jsonValue;

  static RabbitGroupStatus fromJson(jsonValue) => RabbitGroupStatus.values
      .firstWhere((element) => jsonValue == element.jsonValue);

  String toJson() {
    return jsonValue;
  }

  String get displayName {
    switch (this) {
      case RabbitGroupStatus.unknown:
        return 'Nieznany status';
      case RabbitGroupStatus.incoming:
        return 'Nieodebrana';
      case RabbitGroupStatus.inTreatment:
        return 'W\u{00A0}leczeniu';
      case RabbitGroupStatus.adoptable:
        return 'Do\u{00A0}adopcji';
      case RabbitGroupStatus.adopted:
        return 'Adoptowana';
      case RabbitGroupStatus.deceased:
        return 'Zmarłe';
      default:
        return '';
    }
  }
}
