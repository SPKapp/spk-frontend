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

String _rabbitQuery(bool admin) => '''
query GetRabbit(\$id: Int!) {
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
    rabbitGroup {
      id
      rabbits {
        id
        name
      }
      ${admin ? '''team {
        id
				users {
					id
					firstname
					lastname
				}
			}
      ''' : ''}
    }
  }
}
''';

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

String _rabbitsQuery(bool total) => '''
query GetRabbitGroups(\$offset: Int, \$limit: Int, \$regionId: ID) {
  rabbitGroups(offset: \$offset, limit: \$limit, regionId: \$regionId) {
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
