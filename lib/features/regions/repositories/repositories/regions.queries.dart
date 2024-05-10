part of 'regions.repository.dart';

abstract class _FindAllRegionsQuery {
  static String name = 'GetRegionsList';
  static String document(bool totalCount) => '''
query $name(
	\$offset: Int
	\$limit: Int
	\$regionsIds: [ID!]
	\$name: String
) {
	regions(offset: \$offset, limit: \$limit, ids: \$regionsIds, name: \$name) {
		data {
			id
			name
		}
    ${totalCount ? 'totalCount' : ''}
	}
}
''';
}
