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

const String _createRabbitMutation = '''
mutation CreateRabbit(\$createRabbitInput: CreateRabbitInput!) {
  createRabbit(createRabbitInput: \$createRabbitInput) {
    id
  }
}
''';

const String _updateRabbitMutation = r'''
mutation updateRabbit($updateRabbitInput: UpdateRabbitInput!) {
  updateRabbit(updateRabbitInput: $updateRabbitInput) {
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
    rabbitGroup {
      id
      rabbits {
        id
        name
      }
    }
  }
}
''';

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

String _updateTeamMutation = r'''
mutation UpdateTeam($rabbitGroupId: Int!, $teamId: Int!) {
	updateRabbitGroupTeam(rabbitGroupId: $rabbitGroupId, teamId: $teamId) {
		id
	}
}
''';

String _updateRabbitGroupMutation = r'''
mutation UpdateRabbitRabbitGroup($rabbitId: Int!, $rabbitGroupId: Int) {
	updateRabbitRabbitGroup(rabbitId: $rabbitId, rabbitGroupId: $rabbitGroupId) {
		id
	}
}
''';
