import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';

import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UserCubit, () {
    late UserCubit userCubit;
    late IUsersRepository mockUsersRepository;

    const User user = User(id: '1', firstName: 'John', lastName: 'Doe');

    setUp(() {
      mockUsersRepository = MockUsersRepository();
    });

    tearDown(() {
      userCubit.close();
    });

    group('Find by ID', () {
      setUp(() {
        userCubit = UserCubit(
          userId: '1',
          usersRepository: mockUsersRepository,
        );
      });

      test('initial state is UserInitial', () {
        expect(userCubit.state, equals(const GetOneInitial<User>()));
      });

      blocTest<UserCubit, GetOneState>(
        'emits [UserSuccess] when fetchUser is called successfully',
        setUp: () {
          when(() => mockUsersRepository.findOne(user.id))
              .thenAnswer((_) async => user);
        },
        build: () => userCubit,
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const GetOneSuccess<User>(data: user),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.findOne(user.id)).called(1);
          verifyNoMoreInteractions(mockUsersRepository);
        },
      );

      blocTest<UserCubit, GetOneState>(
        'emits [UserFailure] when fetchUser throws an error',
        setUp: () {
          when(() => mockUsersRepository.findOne(user.id))
              .thenThrow(Exception());
        },
        build: () => userCubit,
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const GetOneFailure<User>(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.findOne(user.id)).called(1);
          verifyNoMoreInteractions(mockUsersRepository);
        },
      );

      blocTest<UserCubit, GetOneState>(
        'emits [UserInitial, UserSuccess] when refreshUser is called',
        setUp: () {
          when(() => mockUsersRepository.findOne(user.id))
              .thenAnswer((_) async => user);
        },
        build: () => userCubit,
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const GetOneInitial<User>(),
          const GetOneSuccess<User>(data: user),
        ],
      );
    });

    group('Find my profile', () {
      setUp(() {
        userCubit = UserCubit(
          usersRepository: mockUsersRepository,
        );
      });

      test('initial state is UserInitial', () {
        expect(userCubit.state, equals(const GetOneInitial<User>()));
      });

      blocTest<UserCubit, GetOneState>(
        'emits [UserSuccess] when fetchMyProfile is called successfully',
        setUp: () {
          when(() => mockUsersRepository.findMyProfile())
              .thenAnswer((_) async => user);
        },
        build: () => userCubit,
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const GetOneSuccess<User>(data: user),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.findMyProfile()).called(1);
          verifyNoMoreInteractions(mockUsersRepository);
        },
      );

      blocTest<UserCubit, GetOneState>(
        'emits [UserFailure] when fetchMyProfile throws an error',
        setUp: () {
          when(() => mockUsersRepository.findMyProfile())
              .thenThrow(Exception());
        },
        build: () => userCubit,
        act: (cubit) => cubit.fetch(),
        expect: () => [
          const GetOneFailure<User>(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.findMyProfile()).called(1);
          verifyNoMoreInteractions(mockUsersRepository);
        },
      );

      blocTest<UserCubit, GetOneState>(
        'emits [UserInitial, UserSuccess] when refreshMyProfile is called',
        setUp: () {
          when(() => mockUsersRepository.findMyProfile())
              .thenAnswer((_) async => user);
        },
        build: () => userCubit,
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const GetOneInitial<User>(),
          const GetOneSuccess<User>(data: user),
        ],
      );
    });
  });
}
