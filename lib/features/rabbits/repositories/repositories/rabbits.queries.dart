part of 'rabbits.repository.dart';

abstract class GetRabbitsListQuery {
  static const String operationName = 'GetRabbitGroups';
  static String document(bool total) => '''
query $operationName(
	\$offset: Int
	\$limit: Int
	\$regionsIds: [ID!]
	\$teamsIds: [ID!]
	\$name: String
	\$rabbitStatus: [RabbitStatus!]
) {
	rabbitGroups(
		offset: \$offset
		limit: \$limit
		regionsIds: \$regionsIds
		teamIds: \$teamsIds
		name: \$name
		rabbitStatus: \$rabbitStatus
	) {
    data {
      id
      rabbits {
          id
          name
        }
    }
    offset
    limit
    ${total ? 'totalCount' : ''}
  }
}
''';
}

abstract class GetRabbitQuery {
  static const String operationName = 'GetRabbit';
  static String document = '''
query $operationName(\$id: ID!) {
  rabbit(id: \$id) {
    id
    status
    name
    color
    breed
    gender
    birthDate
    confirmedBirthDate
    admissionDate
    admissionType
    fillingDate
    weight
		chipNumber
		castrationDate
		dewormingDate
		vaccinationDate
    rabbitGroup {
			id
			rabbits {
				id
				name
			}
			team {
				id
				users {
					id
					firstname
					lastname
				}
			}
			region {
				id
			}
		}
	}
}
''';
}

abstract class CreateRabbitMutation {
  static const String operationName = 'CreateRabbit';
  static String document = '''
mutation $operationName(\$createRabbitInput: CreateRabbitInput!) {
  createRabbit(createRabbitInput: \$createRabbitInput) {
    id
  }
}
''';
}

abstract class UpdateRabbitMutation {
  static const String operationName = 'UpdateRabbit';
  static String document = '''
mutation $operationName(\$updateRabbitInput: UpdateRabbitInput!) {
  updateRabbit(updateRabbitInput: \$updateRabbitInput) {
    id
  }
}
''';
}

abstract class UpdateTeamMutation {
  static const String operationName = 'UpdateTeam';
  static String document = '''
mutation $operationName(\$rabbitGroupId: ID!, \$teamId: ID) {
	updateRabbitGroupTeam(rabbitGroupId: \$rabbitGroupId, teamId: \$teamId) {
		id
	}
}
''';
}

abstract class UpdateRabbitGroupMutation {
  static const String operationName = 'UpdateRabbitRabbitGroup';
  static String document = '''
mutation $operationName(\$rabbitId: ID!, \$rabbitGroupId: ID) {
	updateRabbitRabbitGroup(rabbitId: \$rabbitId, rabbitGroupId: \$rabbitGroupId) {
		id
	}
}
''';
}

abstract class RemoveRabbitMutation {
  static const String operationName = 'RemoveRabbit';
  static String document = '''
mutation $operationName(\$id: ID!) {
	removeRabbit(id: \$id) {
		id
	}
}
''';
}

abstract class ChangeRabbitStatusMutation {
  static const String operationName = 'ChangeRabbitStatus';
  static String document = '''
mutation $operationName(\$rabbitId: ID!, \$status: RabbitStatus) {
	updateRabbit(updateRabbitInput: {
		id: \$rabbitId
		status: \$status
	}) {
		id
	}
}
''';
}
