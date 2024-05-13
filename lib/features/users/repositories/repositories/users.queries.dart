part of 'users.repository.dart';

abstract class _GetUsersQuery {
  static String operationName = 'GetUsers';
  static String document(bool total) => '''
query $operationName(
	\$offset: Int
	\$limit: Int
	\$regionsIds: [ID!]
	\$isActive: Boolean
	\$name: String
) {
	users(
		offset: \$offset
		limit: \$limit
		regionsIds: \$regionsIds
		isActive: \$isActive
		name: \$name
	) {
		data {
			id
			firstname
			lastname
			roles
		}
    ${total ? 'totalCount' : ''}
	}
}
''';
}

abstract class _GetUserQuery {
  static String operationName = 'GetUser';
  static String document = '''
query $operationName(\$id: ID!) {
	user(id: \$id) {
		id
		firstname
		lastname
		email
		phone
		active
		rolesWithDetails {
			role
			additionalInfo
		}
    region {
      id
			name
		}
	}
}
''';
}

abstract class _CreateUserMutation {
  static String operationName = 'CreateUser';
  static String document = '''
mutation $operationName(\$createUserInput: CreateUserInput!) {
	createUser(createUserInput: \$createUserInput) {
		id
	}
}
''';
}
