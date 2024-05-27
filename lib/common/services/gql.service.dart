import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:spk_app_frontend/config/config.dart';

class GqlService {
  GqlService();

  late GraphQLClient _client;

  void setAuthToken(String Function() authTokenFn) {
    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer ${authTokenFn()}');

    _client = GraphQLClient(
      link: authLink.concat(HttpLink(AppConfig.apiUrl)),
      cache: GraphQLCache(),
    );
  }

  Future<QueryResult> query(
    String query, {
    Map<String, dynamic> variables = const {},
    String? operationName,
  }) {
    return _client.query(QueryOptions(
      operationName: operationName,
      fetchPolicy: FetchPolicy.noCache,
      document: gql(query),
      variables: variables,
    ));
  }

  Future<QueryResult> mutate(
    String mutation, {
    Map<String, dynamic> variables = const {},
    String? operationName,
  }) {
    return _client.mutate(MutationOptions(
      operationName: operationName,
      document: gql(mutation),
      variables: variables,
    ));
  }
}
