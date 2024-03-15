import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:spk_app_frontend/config/config.dart';

final GraphQLClient graphQLClient = GraphQLClient(
  link: HttpLink(AppConfig.apiUrl),
  cache: GraphQLCache(),
);
