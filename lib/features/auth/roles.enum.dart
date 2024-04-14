enum Role {
  admin('admin'),
  regionManager('region_manager'),
  regionRabbitObserver('region_observer'),
  volunteer('volunteer');

  const Role(this.jsonValue);

  final dynamic jsonValue;

  static Role fromJson(jsonValue) =>
      Role.values.firstWhere((element) => jsonValue == element.jsonValue);
}
