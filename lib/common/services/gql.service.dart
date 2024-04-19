import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:spk_app_frontend/config/config.dart';

class GqlService {
  GqlService(String Function() authTokenFn) {
    final HttpLink httpLink = HttpLink(AppConfig.apiUrl);
    final AuthLink authLink =
        AuthLink(getToken: () async => 'Bearer ${authTokenFn()}');

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    );
  }

  late GraphQLClient _client;

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
