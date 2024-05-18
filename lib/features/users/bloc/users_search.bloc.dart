import 'package:meta/meta.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/search.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// This bloc is used to search for users
///
/// It uses the [IUsersRepository] to fetch the users
class UsersSearchBloc extends ISearchBloc<User> {
  UsersSearchBloc({
    required IUsersRepository usersRepository,
    required FindUsersArgs args,
  })  : _usersRepository = usersRepository,
        _args = args;

  final IUsersRepository _usersRepository;
  final FindUsersArgs _args;

  @override
  @visibleForOverriding
  Future<Paginated<User>> fetchData(bool getTotalCount) async {
    return await _usersRepository.findAll(
      _args.copyWith(
        offset: () => state.data.length,
        name: () => state.query,
      ),
      getTotalCount,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error while fetching users', error: error);
    return null;
  }
}
