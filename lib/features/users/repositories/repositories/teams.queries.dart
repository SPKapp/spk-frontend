part of './teams.repository.dart';

abstract class _GetTeamQuery {
  static String operationName = 'GetTeam';
  static String document(bool total) => '''
query $operationName(\$offset: Int, \$limit: Int, \$regionsIds: [ID!], \$isActive: Boolean) {
	teams(offset: \$offset, limit: \$limit, regionsIds: \$regionsIds, isActive: \$isActive) {
		data {
			id
			users {
				id
				firstname
				lastname
			}
		}
    ${total ? 'totalCount' : ''}
	}
}
''';
}

abstract class _GetRegionsAndTeamsQuery {
  static const String operationName = 'GetRegionsAndTeams';
  static const String document = '''
query $operationName(\$limit: Int, \$regionsIds: [ID!], \$isActive: Boolean) {
	teams(limit: \$limit, regionsIds: \$regionsIds, isActive: \$isActive) {
		data {
			id
			users {
				id
				firstname
				lastname
				roles
			}
		}
	}
	regions(limit: \$limit, ids: \$regionsIds) {
		data {
			id
			name
		}
	}
}

  ''';
}
