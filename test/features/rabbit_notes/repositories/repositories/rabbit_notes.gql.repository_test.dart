import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/repositories/rabbit_notes.gql.repository.dart';

class MockGqlService extends Mock implements GqlService {}

class MockQueryResult extends Mock implements QueryResult {}

void main() {
  group(GqlRabbitNotesRepository, () {
    late GqlRabbitNotesRepository repository;
    late GqlService gqlService;
    late QueryResult queryResult;

    setUp(() {
      gqlService = MockGqlService();
      queryResult = MockQueryResult();
      repository = GqlRabbitNotesRepository(gqlService);
    });

    group('findAll', () {
      const paginatedResult = {
        'data': [
          {
            'id': '1',
            'weight': 1.0,
          },
          {
            'id': '2',
            'weight': 2.0,
          },
        ],
        'offset': 0,
        'limit': 2,
      };
      test('should return a Paginated<RabbitNote> object', () async {
        when(() => gqlService.query(any(),
                operationName: any(named: 'operationName'),
                variables: any(named: 'variables')))
            .thenAnswer((_) async => queryResult);

        when(() => queryResult.hasException).thenReturn(false);
        when(() => queryResult.data).thenReturn({
          'rabbitNotes': paginatedResult,
        });

        expect(
          await repository.findAll(
              const FindRabbitNotesArgs(rabbitId: 1), true),
          Paginated.fromJson(paginatedResult, RabbitNote.fromJson),
        );

        verify(
          () => gqlService.query(
            any(),
            operationName: any(named: 'operationName'),
            variables: {
              'rabbitId': 1,
            },
          ),
        ).called(1);
      });

      test('should throw an exception if there is an error', () async {
        when(() => gqlService.query(any(),
                operationName: any(named: 'operationName'),
                variables: any(named: 'variables')))
            .thenAnswer((_) async => queryResult);

        when(() => queryResult.hasException).thenReturn(true);
        when(() => queryResult.exception).thenReturn(OperationException());

        expect(
          () async => await repository.findAll(
              const FindRabbitNotesArgs(rabbitId: 1), true),
          throwsA(isA<Exception>()),
        );

        verify(
          () => gqlService.query(
            any(),
            operationName: any(named: 'operationName'),
            variables: {
              'rabbitId': 1,
            },
          ),
        ).called(1);
      });
    });
  });
}
