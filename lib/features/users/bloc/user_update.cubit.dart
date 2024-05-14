import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user_update.state.dart';

class UserUpdateCubit extends Cubit<UserUpdateState> {
  UserUpdateCubit({
    this.userId,
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UserUpdateInitial());

  final String? userId;
  final IUsersRepository _usersRepository;
  final logger = LoggerService();

  void updateUser(UserUpdateDto userUpdateDto) async {
    try {
      emit(const UserUpdateInitial());
      if (userId != null) {
        await _usersRepository.updateUser(userId!, userUpdateDto);
      } else {
        await _usersRepository.updateMyProfile(userUpdateDto);
      }
      emit(const UserUpdated());
    } catch (e) {
      logger.error('Failed to update user', error: e);
      emit(const UserUpdateFailure());
    }
  }
}
