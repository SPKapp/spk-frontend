part of 'rabbit_groups.repository.dart';

abstract class _GetRabbitGroupQuery {
  static const String operationName = 'GetRabbitGroup';
  static const String document = '''
query $operationName(\$id: ID!) {
  rabbitGroup(id: \$id) {
		id
		rabbits {
			id
			name
		}
		adoptionDescription
		adoptionDate
		status
	}
}
''';
}

abstract class _UpdateRabbitGroupMutation {
  static const String operationName = 'UpdateRabbitGroup';
  static const String document = '''
mutation $operationName(\$updateDto: UpdateRabbitGroupInput!) {
  updateRabbitGroup(updateDto: \$updateDto) {
    id
  }
}
''';
}
