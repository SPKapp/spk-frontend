import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/dto.dart';
import 'package:spk_app_frontend/features/rabbit-notes/models/models.dart';
import 'package:spk_app_frontend/features/rabbit-notes/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbit-notes/bloc/rabbit_notes_list.bloc.dart';

class MockRabbitNoteRepository extends Mock implements IRabbitNotesRepository {}

void main() {
  group(RabbitNotesListBloc, () {
    late IRabbitNotesRepository rabbitNoteRepository;
    late RabbitNotesListBloc rabbitNotesListBloc;

    const args1 = FindRabbitNotesArgs(rabbitId: '1');
    const args2 = FindRabbitNotesArgs(
      rabbitId: '1',
      limit: 10,
    );

    const rabbitNotes1 = [
      RabbitNote(
        id: '1',
      ),
      RabbitNote(
        id: '2',
      ),
    ];
    const rabbitNotes2 = [
      RabbitNote(
        id: '3',
      ),
      RabbitNote(
        id: '4',
      ),
    ];

    const paginatedResult = Paginated<RabbitNote>(
      data: rabbitNotes2,
    );

    const paginatedResultTotalCount = Paginated<RabbitNote>(
      data: rabbitNotes1,
      totalCount: 4,
    );

    setUpAll(() {
      registerFallbackValue(args1);
    });

    setUp(() {
      rabbitNoteRepository = MockRabbitNoteRepository();
      rabbitNotesListBloc = RabbitNotesListBloc(
        rabbitNoteRepository: rabbitNoteRepository,
        args: args1,
      );
    });

    tearDown(() {
      rabbitNotesListBloc.close();
    });

    test('initial state is GetListInitial<RabbitNote>', () {
      expect(rabbitNotesListBloc.state, equals(GetListInitial<RabbitNote>()));
    });

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListSuccess<RabbitNote>] when FetchRabbitNotes event is added',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitNotesListBloc,
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListSuccess<RabbitNote>(
          data: rabbitNotes1,
          hasReachedMax: false,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args1.rabbitId)
                  .having((p) => p.offset, 'offset', 0),
            ),
            true)).called(1);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListFailure<RabbitNote>] when FetchRabbitNotes event is added and repository throws an error',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenThrow(Exception());
      },
      build: () => rabbitNotesListBloc,
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListFailure<RabbitNote>(),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args1.rabbitId)
                  .having((p) => p.offset, 'offset', 0),
            ),
            true)).called(1);
        verifyNoMoreInteractions(rabbitNoteRepository);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListFailure<RabbitNote>] when FetchRabbitNotes event is added and repository throws an error after a successful fetch',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenThrow(Exception());
      },
      build: () => rabbitNotesListBloc,
      seed: () => GetListSuccess<RabbitNote>(
        data: rabbitNotes1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListFailure<RabbitNote>(
          data: rabbitNotes1,
          hasReachedMax: false,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args1.rabbitId)
                  .having((p) => p.offset, 'offset', 2),
            ),
            false)).called(1);
        verifyNoMoreInteractions(rabbitNoteRepository);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'no emits when FetchRabbitNotes event is added and hasReachedMax is true',
      build: () => rabbitNotesListBloc,
      seed: () => GetListSuccess<RabbitNote>(
        data: rabbitNotes1 + rabbitNotes2,
        hasReachedMax: true,
        totalCount: 4,
      ),
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [],
      verify: (_) {
        verifyZeroInteractions(rabbitNoteRepository);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListSuccess<RabbitNote>] when previous state is [GetListFailure] with data',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResult);
      },
      build: () => rabbitNotesListBloc,
      seed: () => GetListFailure<RabbitNote>(
        data: rabbitNotes1,
        hasReachedMax: false,
        totalCount: 4,
      ),
      act: (bloc) => bloc.add(const FetchList()),
      expect: () => [
        GetListSuccess<RabbitNote>(
          data: rabbitNotes1 + rabbitNotes2,
          hasReachedMax: true,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args1.rabbitId)
                  .having((p) => p.offset, 'offset', 2),
            ),
            false)).called(1);
        verifyNoMoreInteractions(rabbitNoteRepository);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListInitial<RabbitNote>] and [GetListSuccess] when RefreshRabbitNotes event is added',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitNotesListBloc,
      act: (bloc) => bloc.add(const RefreshList<FindRabbitNotesArgs>(null)),
      expect: () => [
        GetListInitial<RabbitNote>(),
        GetListSuccess<RabbitNote>(
          data: rabbitNotes1,
          hasReachedMax: false,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args1.rabbitId)
                  .having((p) => p.offset, 'offset', 0),
            ),
            true)).called(1);
      },
    );

    blocTest<RabbitNotesListBloc, GetListState>(
      'emits [GetListInitial<RabbitNote>] and [GetListSuccess] when RefreshRabbitNotes event is added with new args',
      setUp: () {
        when(() => rabbitNoteRepository.findAll(any(), any()))
            .thenAnswer((_) async => paginatedResultTotalCount);
      },
      build: () => rabbitNotesListBloc,
      act: (bloc) => bloc.add(const RefreshList(args2)),
      expect: () => [
        GetListInitial<RabbitNote>(),
        GetListSuccess(
          data: rabbitNotes1,
          hasReachedMax: false,
          totalCount: 4,
        ),
      ],
      verify: (_) {
        verify(() => rabbitNoteRepository.findAll(
            any(
              that: isA<FindRabbitNotesArgs>()
                  .having((p) => p.rabbitId, 'rabbitId', args2.rabbitId)
                  .having((p) => p.offset, 'offset', 0),
            ),
            true)).called(1);
      },
    );
  });
}
