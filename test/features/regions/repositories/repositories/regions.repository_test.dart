import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/repositories/repositories/regions.repository.dart';

class MockGqlService extends Mock implements GqlService {}

class MockQueryResult extends Mock implements QueryResult {}

void main() {
  group(RegionsRepository, () {
    late RegionsRepository repository;
    late GqlService gqlService;
    late QueryResult queryResult;

    setUp(() {
      gqlService = MockGqlService();
      queryResult = MockQueryResult();
      repository = RegionsRepository(gqlService);
    });

    group('findAll', () {
      const paginatedResult = {
        'data': [
          {'id': '1', 'name': 'Region 1'},
          {'id': '2', 'name': 'Region 2'},
        ],
        'offset': 0,
        'limit': 2,
      };

      test('should send a query to find all regions', () async {
        when(() => gqlService.query(any(),
                operationName: any(named: 'operationName'),
                variables: any(named: 'variables')))
            .thenAnswer((_) async => queryResult);

        when(() => queryResult.hasException).thenReturn(false);
        when(() => queryResult.data).thenReturn({
          'regions': paginatedResult,
        });

        expect(
          await repository.findAll(limit: 1, offset: 0),
          Paginated.fromJson(paginatedResult, (json) => Region.fromJson(json)),
        );

        verify(
          () => gqlService.query(
            any(),
            operationName: any(named: 'operationName'),
            variables: {
              'offset': 0,
              'limit': 1,
            },
          ),
        ).called(1);
      });
    });
  });
}
