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
