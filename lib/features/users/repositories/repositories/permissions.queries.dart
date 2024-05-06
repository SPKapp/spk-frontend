part of './permissions.repository.dart';

abstract class AddRoleToUserMutation {
  static const String operationName = 'AddRoleToUser';
  static const String document = '''
mutation $operationName(\$userId: ID!, \$role: Role!, \$regionId: ID, \$teamId: ID) {
	addRoleToUser(
		userId: \$userId
		role: \$role
		regionId: \$regionId
		teamId: \$teamId
	)
}
''';
}
