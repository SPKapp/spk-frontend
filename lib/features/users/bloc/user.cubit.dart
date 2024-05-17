import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// Cubit responsible for managing the user state.
///
/// This cubit is used to fetch a user with the given [userId].
/// Or if [userId] is null, it fetches the currently logged in user.
class UserCubit extends IGetOneCubit<User> {
  UserCubit({
    this.userId,
    required IUsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super();

  final String? userId;
  final IUsersRepository _usersRepository;

  /// Fetches a user with the given [userId].
  /// Emits new state only if data was changed.
  @override
  void fetch() async {
    try {
      late final User user;
      if (userId != null) {
        user = await _usersRepository.findOne(userId!);
      } else {
        user = await _usersRepository.findMyProfile();
      }
      emit(
        GetOneSuccess(data: user),
      );
    } catch (e) {
      logger.error('Failed to fetch user', error: e);
      emit(const GetOneFailure());
    }
  }
}
