import 'package:meta/meta.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/models/paginated.dto.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/repositories/interfaces.dart';

/// A bloc that manages the state of a list with teams.
class UsersListBloc extends IGetListBloc<User, FindUsersArgs> {
  UsersListBloc({
    required IUsersRepository usersRepository,
    required super.args,
  })  : _usersRepository = usersRepository,
        super();

  final IUsersRepository _usersRepository;

  @override
  @visibleForOverriding
  Future<Paginated<User>> fetchData(int offset, bool getTotalCount) async {
    return await _usersRepository.findAll(
      args.copyWith(offset: () => state.data.length),
      state.totalCount == 0,
    );
  }

  @override
  @visibleForOverriding
  String? createErrorCode(Object error) {
    logger.error('Error while fetching users', error: error);
    return null;
  }
}
