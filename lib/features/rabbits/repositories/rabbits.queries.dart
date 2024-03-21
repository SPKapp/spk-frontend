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

const String _rabbitQuery = r'''
query GetRabbit($id: Int!) {
  rabbit(id: $id) {
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

const String _createRabbitMutation = '''
mutation CreateRabbit(\$createRabbitInput: CreateRabbitInput!) {
  createRabbit(createRabbitInput: \$createRabbitInput) {
    id
    rabbitGroup {
      id
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
