import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user_permissions.state.dart';

class UserPermissionsCubit extends Cubit<UserPermissionsState> {
  UserPermissionsCubit(
    this._permissionsRepository,
    this.userId,
  ) : super(const UserPermissionsInitial());

  final IPermissionsRepository _permissionsRepository;
  final String userId;

  Future<void> addRoleToUser(
    Role role, {
    String? teamId,
    String? regionId,
  }) async {
    try {
      await _permissionsRepository.addRoleToUser(
        userId,
        role,
        teamId: teamId,
        regionId: regionId,
      );
      emit(const UserPermissionsSuccess());
    } catch (e) {
      emit(const UserPermissionsFailure());
    }
  }
}
