part of './rabbit_notes.gql.repository.dart';

abstract class GetRabbitNotesQuery {
  static const String operationName = 'GetRabbitNotes';
  static String document(bool totalCount) => '''
query $operationName(
  \$offset: Int
	\$limit: Int
	\$rabbitId: ID!
	\$createdAtFrom: DateTime
	\$createdAtTo: DateTime
	\$withWeight: Boolean
	\$isVetVisit: Boolean
	\$vetVisit: VetVisitsArgs
) {
	rabbitNotes(
    offset: \$offset
		limit: \$limit
		rabbitId: \$rabbitId
		createdAtFrom: \$createdAtFrom
		createdAtTo: \$createdAtTo
		withWeight: \$withWeight
		isVetVisit: \$isVetVisit
		vetVisit: \$vetVisit
	) {
		data {
			id
			description
			vetVisit {
				date
				visitInfo {
					visitType
				}
			}
			createdAt
		}
		${totalCount ? 'totalCount' : ''}
	}
}
''';
}

abstract class GetRabbitNoteQuery {
  static const String operationName = 'GetRabbitNote';
  static const String document = '''
query $operationName(\$id: Int!) {
	rabbitNote(id: \$id) {
		id
		rabbitId
		description
		weight
		vetVisit {
			date
			visitInfo {
				visitType
				additionalInfo
			}
		}
		createdAt
		createdBy
	}
}
''';
}