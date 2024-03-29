import 'package:spk_app_frontend/common/models/paginated.dto.dart';

import 'package:spk_app_frontend/features/rabbits/models/dto/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';

abstract interface class IRabbitsRepository {
  Future<List<RabbitsGroup>> myRabbits();
  Future<Rabbit> rabbit(int id);
  Future<Paginated<RabbitsGroup>> findAll({
    bool totalCount = false,
    int? offset,
    int? limit,
  });
  Future<int> createRabbit(RabbitCreateDto rabbit);
  Future<int> updateRabbit(RabbitUpdateDto rabbit);
}