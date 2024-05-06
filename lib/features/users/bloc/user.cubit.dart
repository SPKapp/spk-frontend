import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

part 'user.state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({
    required this.userId,
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UserInitial());

  final int userId;
  final IUsersRepository _usersRepository;

  /// Fetches a user with the given [userId].
  /// Emits new state only if data was changed.
  void fetchUser() async {
    try {
      final user = await _usersRepository.findOne(userId);
      emit(
        UserSuccess(
          user: user,
        ),
      );
    } catch (e) {
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
