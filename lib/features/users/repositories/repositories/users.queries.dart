part of 'users.repository.dart';

String _getTeamListQuery(bool total) => '''
query GetTeamListQuery(\$offset: Int, \$limit: Int,) {
  teams(offset: \$offset, limit: \$limit) {
    data {
      id
      users  {
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
