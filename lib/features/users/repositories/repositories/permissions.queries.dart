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

abstract class RemoveRoleFromUserMutation {
  static const String operationName = 'RemoveRoleFromUser';
  static const String document = '''
mutation $operationName(\$userId: ID!, \$role: Role!, \$regionId: ID) {
	removeRoleFromUser(userId: \$userId, role: \$role, regionId: \$regionId)
}
''';
}

abstract class DeactivateUserMutation {
  static const String operationName = 'DeactivateUser';
  static const String document = '''
mutation $operationName(\$userId: ID!) {
	deactivateUser(userId: \$userId)
}
''';
}

abstract class ActivateUserMutation {
  static const String operationName = 'ActivateUser';
  static const String document = '''
mutation $operationName(\$userId: ID!) {
  activateUser(userId: \$userId)
}
''';
}
