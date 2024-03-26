import 'package:spk_app_frontend/features/users/models/dto.dart';

abstract interface class IUsersRepository {
  Future<int> createUser(UserCreateDto user);
}
