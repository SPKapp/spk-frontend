part of 'users.repository.dart';

abstract class GetTeamQuery {
  static String operationName = 'GetTeam';
  static String document(bool total) => '''
query $operationName(\$offset: Int, \$limit: Int, \$regionsIds: [ID!], \$isActive: Boolean, \$name: String) {
	teams(offset: \$offset, limit: \$limit, regionsIds: \$regionsIds, isActive: \$isActive, name: \$name) {
		data {
			id
			users {
				id
				firstname
				lastname
        roles
			}
		}
		offset
		limit
    ${total ? 'totalCount' : ''}
	}
}
''';
}

abstract class CreateUserMutation {
  static String operationName = 'CreateUser';
  static String document = '''
mutation $operationName(\$createUserInput: CreateUserInput!) {
	createUser(createUserInput: \$createUserInput) {
		id
	}
}
''';
}
