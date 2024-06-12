part of 'storage_auth.repository.dart';

abstract class GetRabbitPhotosTokenQuery {
  static const String operationName = 'GetRabbitPhotosToken';
  static String document = '''
query $operationName(\$id: ID!) {
	rabbitPhotosToken(id: \$id) {
		token
	}
}
''';
}
