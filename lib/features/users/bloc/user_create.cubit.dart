import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:spk_app_frontend/common/services/logger.service.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user_create.state.dart';

/// Cubit responsible for managing the state of user creation.
///
/// Available functions:
/// - [createUser] - creates a new user with the given [user] data
///
/// Available states:
/// - [UserCreateInitial] - initial state
/// - [UserCreated] - the user has been created successfully
/// - [UserCreateFailure] - an error occurred while creating the user
class UserCreateCubit extends Cubit<UserCreateState> {
  UserCreateCubit({
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UserCreateInitial());

  final IUsersRepository _usersRepository;
  final logger = LoggerService();

  /// Creates a new user with the given [user] data.
  void createUser(UserCreateDto user) async {
    try {
      final id = await _usersRepository.createUser(user);
      emit(
        UserCreated(
          userId: id,
        ),
      );
    } catch (e) {
      logger.error('Error while creating user: $e');
      emit(
        const UserCreateFailure(),
      );
      emit(
        const UserCreateInitial(),
      );
    }
  }
}
