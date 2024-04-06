part of 'users.repository.dart';

String _getTeamListQuery(bool total) => '''
query GetTeamList(\$offset: Int, \$limit: Int, \$regionsIds: [ID!]) {
	teams(offset: \$offset, limit: \$limit, regionsIds: \$regionsIds) {
		data {
			id
			users {
				id
				firstname
				lastname
			}
		}
		offset
		limit
    ${total ? 'totalCount' : ''}
  }
}
''';
