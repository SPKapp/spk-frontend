import 'package:firebase_auth/firebase_auth.dart';
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
    bool refreshAuthToken = true,
  }) async {
    final result = await _client.query(QueryOptions(
      operationName: operationName,
      fetchPolicy: FetchPolicy.noCache,
      document: gql(query),
      variables: variables,
    ));

    if (refreshAuthToken && result.hasException) {
      // Handle unauthorized error and try to refresh the token
      if (result.exception!.graphqlErrors.isNotEmpty) {
        if (result.exception!.graphqlErrors[0].message == 'Unauthorized') {
          await FirebaseAuth.instance.currentUser?.reload();

          return this.query(
            query,
            variables: variables,
            operationName: operationName,
            refreshAuthToken: false,
          );
        }
      }
    }

    return result;
  }

  Future<QueryResult> mutate(
    String mutation, {
    Map<String, dynamic> variables = const {},
    String? operationName,
    bool refreshAuthToken = true,
  }) async {
    final result = await _client.mutate(MutationOptions(
      operationName: operationName,
      document: gql(mutation),
      variables: variables,
    ));

    if (refreshAuthToken && result.hasException) {
      // Handle unauthorized error and try to refresh the token
      if (result.exception!.graphqlErrors.isNotEmpty) {
        if (result.exception!.graphqlErrors[0].message == 'Unauthorized') {
          await FirebaseAuth.instance.currentUser?.reload();

          return mutate(
            mutation,
            variables: variables,
            operationName: operationName,
            refreshAuthToken: false,
          );
        }
      }
    }

    return result;
  }
}
