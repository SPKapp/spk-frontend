part of 'fcm_tokens.repository.dart';

abstract class UpdateFcmTokenMutation {
  static String operationName = 'UpdateFcmToken';
  static String document = '''
mutation $operationName(\$token: String!) {
	updateFcmToken(token: \$token) 
}
''';
}

abstract class DeleteFcmTokenMutation {
  static String operationName = 'DeleteFcmToken';
  static String document = '''
mutation $operationName(\$token: String!) {
  deleteFcmToken(token: \$token) 
}
''';
}
