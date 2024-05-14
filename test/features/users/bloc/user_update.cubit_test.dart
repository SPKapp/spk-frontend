import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/features/users/bloc/user_update.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockUsersRepository extends Mock implements IUsersRepository {}

void main() {
  group(UserUpdateCubit, () {
    late UserUpdateCubit userUpdateCubit;
    late IUsersRepository mockUsersRepository;

    setUp(() {
      mockUsersRepository = MockUsersRepository();

      registerFallbackValue(const UserUpdateDto());
    });

    tearDown(() {
      userUpdateCubit.close();
    });

    group('myProfile', () {
      setUp(() {
        userUpdateCubit = UserUpdateCubit(usersRepository: mockUsersRepository);
      });

      test('initial state is UserUpdateInitial', () {
        expect(userUpdateCubit.state, equals(const UserUpdateInitial()));
      });

      blocTest<UserUpdateCubit, UserUpdateState>(
        'emits [UserUpdateInitial, UserUpdated] when updateUser is successful',
        setUp: () {
          when(() => mockUsersRepository.updateMyProfile(any()))
              .thenAnswer((_) async {});
        },
        build: () => userUpdateCubit,
        act: (cubit) =>
            cubit.updateUser(const UserUpdateDto(firstName: 'John')),
        expect: () => const <UserUpdateState>[
          UserUpdateInitial(),
          UserUpdated(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.updateMyProfile(const UserUpdateDto(
                firstName: 'John',
              ))).called(1);
        },
      );

      blocTest<UserUpdateCubit, UserUpdateState>(
        'emits [UserUpdateInitial, UserUpdateError] when updateUser is unsuccessful',
        setUp: () {
          when(() => mockUsersRepository.updateMyProfile(any()))
              .thenThrow(Exception('oops'));
        },
        build: () => userUpdateCubit,
        act: (cubit) =>
            cubit.updateUser(const UserUpdateDto(firstName: 'John')),
        expect: () => const <UserUpdateState>[
          UserUpdateInitial(),
          UserUpdateFailure(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.updateMyProfile(const UserUpdateDto(
                firstName: 'John',
              ))).called(1);
        },
      );
    });

    group('user', () {
      setUp(() {
        userUpdateCubit = UserUpdateCubit(
          userId: '1',
          usersRepository: mockUsersRepository,
        );
      });

      blocTest<UserUpdateCubit, UserUpdateState>(
        'emits [UserUpdateInitial, UserUpdated] when updateUser is successful',
        setUp: () {
          when(() => mockUsersRepository.updateUser(any(), any()))
              .thenAnswer((_) async {});
        },
        build: () => userUpdateCubit,
        act: (cubit) =>
            cubit.updateUser(const UserUpdateDto(firstName: 'John')),
        expect: () => const <UserUpdateState>[
          UserUpdateInitial(),
          UserUpdated(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.updateUser(
              '1',
              const UserUpdateDto(
                firstName: 'John',
              ))).called(1);
        },
      );

      blocTest<UserUpdateCubit, UserUpdateState>(
        'emits [UserUpdateInitial, UserUpdateError] when updateUser is unsuccessful',
        setUp: () {
          when(() => mockUsersRepository.updateUser(any(), any()))
              .thenThrow(Exception('oops'));
        },
        build: () => userUpdateCubit,
        act: (cubit) =>
            cubit.updateUser(const UserUpdateDto(firstName: 'John')),
        expect: () => const <UserUpdateState>[
          UserUpdateInitial(),
          UserUpdateFailure(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.updateUser(
              '1',
              const UserUpdateDto(
                firstName: 'John',
              ))).called(1);
        },
      );
    });
  });
}
