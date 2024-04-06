import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:spk_app_frontend/common/services/gql.service.dart';

import 'package:spk_app_frontend/features/rabbits/repositories/repositories/rabbits.repository.dart';

class MockGqlService extends Mock implements GqlService {}

class MockQueryResult extends Mock implements QueryResult {}

void main() {
  group(RabbitsRepository, () {
    late RabbitsRepository repository;
    late GqlService gqlService;
    late QueryResult queryResult;

    setUp(() {
      gqlService = MockGqlService();
      queryResult = MockQueryResult();
      repository = RabbitsRepository(gqlService);
    });

    group('updateTeam', () {
      test('should send a mutation to update a team', () async {
        when(() => gqlService.mutate(any(), variables: any(named: 'variables')))
            .thenAnswer((_) async => queryResult);
        when(() => queryResult.hasException).thenReturn(false);

        await repository.updateTeam(1, 1);

        verify(() => gqlService.mutate(any(), variables: {
              'rabbitGroupId': 1,
              'teamId': 1,
            })).called(1);
      });
    });
  });
}
