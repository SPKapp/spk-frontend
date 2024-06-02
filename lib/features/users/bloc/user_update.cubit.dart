import 'package:spk_app_frontend/common/bloc/interfaces/update.cubit.interface.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// Cubit for updating user
///
/// This cubit is used to update user data.
///
/// When [userId] is not provided, it updates current user profile.
/// Otherwise, it updates user with provided [userId].
///
/// Available methods:
/// - `updateUser` - updates user data
/// - `removeUser` - removes user, cannot remove current user
///
class UserUpdateCubit extends IUpdateCubit {
  UserUpdateCubit({
    this.userId,
    required this.usersRepository,
  });

  final String? userId;
  final IUsersRepository usersRepository;

  /// Updates user data
  void updateUser(UserUpdateDto userUpdateDto) async {
    try {
      if (userId != null) {
        await usersRepository.updateUser(userId!, userUpdateDto);
      } else {
        await usersRepository.updateMyProfile(userUpdateDto);
      }
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to update user');
    }
  }

  /// Removes user
  void removeUser() async {
    try {
      if (userId != null) {
        await usersRepository.removeUser(userId!);
      } else {
        throw Exception('Cannot remove current user');
      }
      emit(const UpdateSuccess());
    } catch (e) {
      error(e, 'Failed to remove user');
    }
  }
}
