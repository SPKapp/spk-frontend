part of 'rabbits.repository.dart';

const String _myRabbitsQuery = '''
query MyRabbits {
  myProfile {
    team {
      rabbitGroups {
        id
        rabbits {
          id
          name
        }
      }
    }
  }
}
''';

abstract class GetRabbitQuery {
  static const String operationName = 'GetRabbit';
  static String document = '''
query $operationName(\$id: Int!) {
  rabbit(id: \$id) {
    id
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
mutation $operationName(\$rabbitGroupId: Int!, \$teamId: Int!) {
	updateRabbitGroupTeam(rabbitGroupId: \$rabbitGroupId, teamId: \$teamId) {
		id
	}
}
''';
}

abstract class UpdateRabbitGroupMutation {
  static const String operationName = 'UpdateRabbitRabbitGroup';
  static String document = '''
mutation $operationName(\$rabbitId: Int!, \$rabbitGroupId: Int) {
	updateRabbitRabbitGroup(rabbitId: \$rabbitId, rabbitGroupId: \$rabbitGroupId) {
		id
	}
}
''';
}

abstract class RemoveRabbitMutation {
  static const String operationName = 'RemoveRabbit';
  static String document = '''
mutation $operationName(\$id: Int!) {
	removeRabbit(id: \$id) {
		id
	}
}
''';
}

String _getRabbitsListQuery(bool total) => '''
query GetRabbitGroups(\$offset: Int, \$limit: Int, \$regionsIds: [ID!]) {
  rabbitGroups(offset: \$offset, limit: \$limit, regionsIds: \$regionsIds) {
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
