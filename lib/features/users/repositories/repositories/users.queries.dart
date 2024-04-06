part of 'users.repository.dart';

String _getTeamListQuery(bool total) => '''
query GetTeamList(\$offset: Int, \$limit: Int, \$regionIds: [ID!]) {
	teams(offset: \$offset, limit: \$limit, regionIds: \$regionIds) {
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
