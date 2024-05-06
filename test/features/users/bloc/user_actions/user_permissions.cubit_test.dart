import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/users/bloc/user_actions/user_permissions.cubit.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

class MockPermissionsRepository extends Mock
    implements IPermissionsRepository {}

void main() {
  group(UserPermissionsCubit, () {
    late IPermissionsRepository mockPermissionsRepository;
    late UserPermissionsCubit userPermissionsCubit;

    setUp(() {
      mockPermissionsRepository = MockPermissionsRepository();
      userPermissionsCubit = UserPermissionsCubit(
        mockPermissionsRepository,
        '1',
      );
    });

    tearDown(() {
      userPermissionsCubit.close();
    });

    test('initial state is UserPermissionsInitial', () {
      expect(userPermissionsCubit.state, const UserPermissionsInitial());
    });

    group('addRoleToUser', () {
      blocTest<UserPermissionsCubit, UserPermissionsState>(
        'emits [UserPermissionsSuccess] when addRoleToUser is successful',
        setUp: () {
          when(() => mockPermissionsRepository.addRoleToUser(
                '1',
                Role.admin,
                teamId: null,
                regionId: null,
              )).thenAnswer((_) async {});
        },
        build: () => userPermissionsCubit,
        act: (cubit) => cubit.addRoleToUser(Role.admin),
        expect: () => [
          const UserPermissionsSuccess(),
        ],
        verify: (_) {
          verify(() => mockPermissionsRepository.addRoleToUser(
                '1',
                Role.admin,
                teamId: null,
                regionId: null,
              )).called(1);
          verifyNoMoreInteractions(mockPermissionsRepository);
        },
      );

      blocTest<UserPermissionsCubit, UserPermissionsState>(
        'emits [UserPermissionsFailure] when addRoleToUser is unsuccessful',
        setUp: () {
          when(() => mockPermissionsRepository.addRoleToUser(
                '1',
                Role.admin,
                teamId: '2',
                regionId: '3',
              )).thenThrow(Exception());
        },
        build: () => userPermissionsCubit,
        act: (cubit) =>
            cubit.addRoleToUser(Role.admin, teamId: '2', regionId: '3'),
        expect: () => [
          const UserPermissionsFailure(),
        ],
        verify: (_) {
          verify(() => mockPermissionsRepository.addRoleToUser(
                '1',
                Role.admin,
                teamId: '2',
                regionId: '3',
              )).called(1);
          verifyNoMoreInteractions(mockPermissionsRepository);
        },
      );
    });
  });
}
