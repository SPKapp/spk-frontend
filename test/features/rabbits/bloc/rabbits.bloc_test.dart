import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/repositories/interfaces.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits.bloc.dart';

import 'rabbit.cubit_test.mocks.dart';

@GenerateMocks([IRabbitsRepository])
void main() {
  group(RabbitsBloc, () {
    final rabbitRepository = MockIRabbitsRepository();
    late RabbitsBloc rabbitsBloc;

    const rabbit1 = Rabbit(
      id: 1,
      name: 'name 1',
      gender: Gender.male,
      confirmedBirthDate: false,
      admissionType: AdmissionType.found,
    );
    const rabbit2 = Rabbit(
      id: 2,
      name: 'name2',
      gender: Gender.male,
      confirmedBirthDate: false,
      admissionType: AdmissionType.found,
    );

    const rabbitGroup1 = RabbitsGroup(
      id: 1,
      rabbits: [rabbit1],
    );
    const rabbitGroup2 = RabbitsGroup(
      id: 2,
      rabbits: [rabbit2],
    );

    group(RabbitsQueryType.my, () {
      setUp(() {
        // provideDummy(rabbitsGroup);
        rabbitsBloc = RabbitsBloc(
          rabbitsRepository: rabbitRepository,
          queryType: RabbitsQueryType.my,
        );
      });

      test('initial state', () {
        expect(rabbitsBloc.state, equals(RabbitsInitial()));
      });

      blocTest<RabbitsBloc, RabbitsState>(
        'emits [RabbitsSuccess] when [FeatchRabbits] is added',
        setUp: () {
          when(rabbitRepository.myRabbits())
              .thenAnswer((_) async => [rabbitGroup1]);
        },
        wait: const Duration(milliseconds: 500),
        build: () => rabbitsBloc,
        act: (bloc) => bloc.add(const FeatchRabbits()),
        expect: () => [
          RabbitsSuccess(
            rabbitsGroups: const [rabbitGroup1],
            hasReachedMax: true,
            totalCount: 1,
          ),
        ],
        verify: (_) {
          verify(rabbitRepository.myRabbits()).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsBloc, RabbitsState>(
        'emits [RabbitsFailure] when [FeatchRabbits] is added and repository throws an error',
        setUp: () {
          when(rabbitRepository.myRabbits()).thenThrow(Exception());
        },
        wait: const Duration(milliseconds: 500),
        build: () => rabbitsBloc,
        act: (bloc) => bloc.add(const FeatchRabbits()),
        expect: () => [
          RabbitsFailure(),
        ],
        verify: (_) {
          verify(rabbitRepository.myRabbits()).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );
    });

    group(RabbitsQueryType.all, () {
      const result1 = Paginated(
        data: [rabbitGroup1],
        totalCount: 2,
      );
      const result2 = Paginated(
        data: [rabbitGroup2],
      );

      setUp(() {
        provideDummy(result1);
        provideDummy(result2);
        rabbitsBloc = RabbitsBloc(
          rabbitsRepository: rabbitRepository,
          queryType: RabbitsQueryType.all,
        );
      });

      test('initial state', () {
        expect(rabbitsBloc.state, equals(RabbitsInitial()));
      });

      blocTest<RabbitsBloc, RabbitsState>(
        'emits [RabbitsSuccess] when [FeatchRabbits] is added',
        setUp: () {
          when(
            rabbitRepository.findAll(
              totalCount: argThat(isTrue, named: 'totalCount'),
            ),
          ).thenAnswer((_) async => result1);
        },
        wait: const Duration(milliseconds: 500),
        build: () => rabbitsBloc,
        act: (bloc) => bloc.add(const FeatchRabbits()),
        expect: () => [
          RabbitsSuccess(
            rabbitsGroups: result1.data,
            hasReachedMax: false,
            totalCount: 2,
          ),
        ],
        verify: (_) {
          verify(rabbitRepository.findAll(
            totalCount: argThat(isTrue, named: 'totalCount'),
          )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsBloc, RabbitsState>(
        'emits [RabbitsSuccess] when [FeatchRabbits] is added and hasReachedMax is true',
        setUp: () {
          when(
            rabbitRepository.findAll(
              offset: argThat(equals(1), named: 'offset'),
            ),
          ).thenAnswer((_) async => result2);
        },
        wait: const Duration(milliseconds: 500),
        build: () => rabbitsBloc,
        act: (bloc) => bloc.add(const FeatchRabbits()),
        seed: () => RabbitsSuccess(
          rabbitsGroups: result1.data,
          hasReachedMax: false,
          totalCount: 2,
        ),
        expect: () => [
          RabbitsSuccess(
            rabbitsGroups: [...result1.data, ...result2.data],
            hasReachedMax: true,
            totalCount: 2,
          ),
        ],
        verify: (_) {
          verify(rabbitRepository.findAll(
            offset: argThat(equals(1), named: 'offset'),
          )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );

      blocTest<RabbitsBloc, RabbitsState>(
        'emits [RabbitsFailure] when [FeatchRabbits] is added and repository throws an error',
        setUp: () {
          when(
            rabbitRepository.findAll(
              totalCount: argThat(isTrue, named: 'totalCount'),
            ),
          ).thenThrow(Exception());
        },
        wait: const Duration(milliseconds: 500),
        build: () => rabbitsBloc,
        act: (bloc) => bloc.add(const FeatchRabbits()),
        expect: () => [
          RabbitsFailure(),
        ],
        verify: (_) {
          verify(rabbitRepository.findAll(
            totalCount: argThat(isTrue, named: 'totalCount'),
          )).called(1);
          verifyNoMoreInteractions(rabbitRepository);
        },
      );
    });
  });
}
