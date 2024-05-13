import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/common/services/logger.service.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user.state.dart';

/// Cubit responsible for managing the user state.
///
/// This cubit is used to fetch a user with the given [userId].
/// Or if [userId] is null, it fetches the currently logged in user.
///
/// Available functions:
/// - [fetchUser] - fetches a user
/// - [refreshUser] - restarts fetching the user
///
/// Available states:
/// - [UserInitial] - initial state
/// - [UserSuccess] - user was fetched successfully
/// - [UserFailure] - user fetching failed
class UserCubit extends Cubit<UserState> {
  UserCubit({
    this.userId,
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UserInitial());

  final String? userId;
  final IUsersRepository _usersRepository;
  final logger = LoggerService();

  /// Fetches a user with the given [userId].
  /// Emits new state only if data was changed.
  void fetchUser() async {
    try {
      late final User user;
      if (userId != null) {
        user = await _usersRepository.findOne(userId!);
      } else {
        user = await _usersRepository.findMyProfile();
      }
      emit(
        UserSuccess(
          user: user,
        ),
      );
    } catch (e) {
      logger.error(e);
      emit(
        const UserFailure(),
      );
    }
  }

  /// Restarts fetching the user.
  /// Always emits new state.
  void refreshUser() async {
    emit(
      const UserInitial(),
    );
    fetchUser();
  }
}
