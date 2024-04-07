part of 'regions.repository.dart';

abstract class _FindAllRegionsQuery {
  static String name = 'GetRegionsList';
  static String document(bool totalCount) => '''
query $name(\$offset: Int, \$limit: Int) {
	regions(offset: \$offset, limit: \$limit) {
		data {
			id
			name
		}
		offset
		limit
    ${totalCount ? 'totalCount' : ''}
	}
}
''';
}
