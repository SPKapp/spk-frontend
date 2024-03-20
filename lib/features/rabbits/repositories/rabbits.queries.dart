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

const String _rabbitQuery = '''
query Rabbit(\$id: Int!) {
  rabbit(id: \$id) {
    id
    name
    admissionType
    color
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
