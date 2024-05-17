enum Role {
  admin('Admin'),
  regionManager('RegionManager'),
  regionRabbitObserver('RegionObserver'),
  volunteer('Volunteer');

  const Role(this.jsonValue);

  final dynamic jsonValue;

  static Role fromJson(jsonValue) =>
      Role.values.firstWhere((element) => jsonValue == element.jsonValue);

  String get displayName {
    switch (this) {
      case Role.admin:
        return 'Administrator';
      case Role.regionManager:
        return 'Kierownik regionu';
      case Role.regionRabbitObserver:
        return 'Obserwator regionu';
      case Role.volunteer:
        return 'Wolontariusz';
      default:
        return 'Nieznana rola';
    }
  }
}
