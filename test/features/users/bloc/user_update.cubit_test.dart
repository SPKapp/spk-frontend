import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';

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

    group('updateUser', () {
      group('myProfile', () {
        setUp(() {
          userUpdateCubit =
              UserUpdateCubit(usersRepository: mockUsersRepository);
        });

        test('initial state is UpdateInitial', () {
          expect(userUpdateCubit.state, equals(const UpdateInitial()));
        });

        blocTest<UserUpdateCubit, UpdateState>(
          'emits [UpdateSuccess] when updateUser is successful',
          setUp: () {
            when(() => mockUsersRepository.updateMyProfile(any()))
                .thenAnswer((_) async {});
          },
          build: () => userUpdateCubit,
          act: (cubit) =>
              cubit.updateUser(const UserUpdateDto(firstName: 'John')),
          expect: () => const <UpdateState>[
            UpdateSuccess(),
          ],
          verify: (_) {
            verify(
                () => mockUsersRepository.updateMyProfile(const UserUpdateDto(
                      firstName: 'John',
                    ))).called(1);
          },
        );

        blocTest<UserUpdateCubit, UpdateState>(
          'emits [UpdateFailure, UpdateInitial] when updateUser is unsuccessful',
          setUp: () {
            when(() => mockUsersRepository.updateMyProfile(any()))
                .thenThrow(Exception('oops'));
          },
          build: () => userUpdateCubit,
          act: (cubit) =>
              cubit.updateUser(const UserUpdateDto(firstName: 'John')),
          expect: () => const <UpdateState>[
            UpdateFailure(),
            UpdateInitial(),
          ],
          verify: (_) {
            verify(
                () => mockUsersRepository.updateMyProfile(const UserUpdateDto(
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

        blocTest<UserUpdateCubit, UpdateState>(
          'emits [UpdateSuccess] when updateUser is successful',
          setUp: () {
            when(() => mockUsersRepository.updateUser(any(), any()))
                .thenAnswer((_) async {});
          },
          build: () => userUpdateCubit,
          act: (cubit) =>
              cubit.updateUser(const UserUpdateDto(firstName: 'John')),
          expect: () => const <UpdateState>[
            UpdateSuccess(),
          ],
          verify: (_) {
            verify(() => mockUsersRepository.updateUser(
                '1',
                const UserUpdateDto(
                  firstName: 'John',
                ))).called(1);
          },
        );

        blocTest<UserUpdateCubit, UpdateState>(
          'emits [UpdateFailure, UpdateInitial] when updateUser is unsuccessful',
          setUp: () {
            when(() => mockUsersRepository.updateUser(any(), any()))
                .thenThrow(Exception('oops'));
          },
          build: () => userUpdateCubit,
          act: (cubit) =>
              cubit.updateUser(const UserUpdateDto(firstName: 'John')),
          expect: () => const <UpdateState>[
            UpdateFailure(),
            UpdateInitial(),
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

    group('removeUser', () {
      setUp(() {
        userUpdateCubit = UserUpdateCubit(
          userId: '1',
          usersRepository: mockUsersRepository,
        );
      });

      blocTest<UserUpdateCubit, UpdateState>(
        'emits [UpdateSuccess] when removeUser is successful',
        setUp: () {
          when(() => mockUsersRepository.removeUser(any()))
              .thenAnswer((_) async {});
        },
        build: () => userUpdateCubit,
        act: (cubit) => cubit.removeUser(),
        expect: () => const <UpdateState>[
          UpdateSuccess(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.removeUser('1')).called(1);
        },
      );

      blocTest<UserUpdateCubit, UpdateState>(
        'emits [UpdateFailure, UpdateInitial] when removeUser is unsuccessful',
        setUp: () {
          when(() => mockUsersRepository.removeUser(any()))
              .thenThrow(Exception('oops'));
        },
        build: () => userUpdateCubit,
        act: (cubit) => cubit.removeUser(),
        expect: () => const <UpdateState>[
          UpdateFailure(),
          UpdateInitial(),
        ],
        verify: (_) {
          verify(() => mockUsersRepository.removeUser('1')).called(1);
        },
      );
    });
  });
}
