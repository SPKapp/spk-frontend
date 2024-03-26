import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:spk_app_frontend/features/users/bloc/user_create.cubit.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

import 'user_create.cubit_test.mocks.dart';

@GenerateMocks([IUsersRepository])
void main() {
  group(UserCreateCubit, () {
    final usersRepository = MockIUsersRepository();
    late UserCreateCubit userCreateCubit;

    final dto = UserCreateDto(
      firstname: 'John',
      lastname: 'Doe',
      email: 'email@example.com',
      phone: '123456789',
    );

    setUp(() {
      userCreateCubit = UserCreateCubit(usersRepository: usersRepository);
    });

    tearDown(() {
      userCreateCubit.close();
    });

    test('initial state is UserCreateInitial', () {
      expect(userCreateCubit.state, equals(const UserCreateInitial()));
    });

    blocTest<UserCreateCubit, UserCreateState>(
      'emits [UserCreated] when createUser is called',
      setUp: () {
        when(usersRepository.createUser(any)).thenAnswer((_) async => 1);
      },
      build: () => userCreateCubit,
      act: (cubit) => cubit.createUser(dto),
      expect: () => [
        const UserCreated(userId: 1),
      ],
    );

    blocTest<UserCreateCubit, UserCreateState>(
      'emits [UserCreateFailure] when createUser is called',
      setUp: () {
        when(usersRepository.createUser(any)).thenThrow(Exception());
      },
      build: () => userCreateCubit,
      act: (cubit) => cubit.createUser(dto),
      expect: () => [
        const UserCreateFailure(),
        const UserCreateInitial(),
      ],
    );
  });
}
