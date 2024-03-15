import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:spk_app_frontend/common/services/gql.service.dart';
import 'package:spk_app_frontend/features/rabbits/models/rabbit.model.dart';
import 'package:spk_app_frontend/features/rabbits/models/rabbits_group.model.dart';

part 'rabbits.event.dart';
part 'rabbits.state.dart';

class RabbitsBloc extends Bloc<RabbitsEvent, RabbitsState> {
  RabbitsBloc() : super(const RabbitsState()) {
    on<RabbitsFeached>(_onRabbitsFeached);
  }

  Future<void> _onRabbitsFeached(
      RabbitsFeached event, Emitter<RabbitsState> emit) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == RabbitsStatus.initial) {
        final rabbits = await _fetchRabbits();
        return emit(RabbitsState(
          status: RabbitsStatus.success,
          rabbits: rabbits,
          hasReachedMax: false,
        ));
      }
      final rabbits = await _fetchRabbits();
      emit(rabbits.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: RabbitsStatus.success,
              rabbits: List.of(state.rabbits)..addAll(rabbits),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: RabbitsStatus.failure));
    }
  }

  Future<List<RabbitsGroup>> _fetchRabbits() async {
    print('fetching rabbits');

    graphQLClient
        .query(QueryOptions(
      document: gql('''
        query {
  rabbitGroups {
    data {
      id
      region {
        id
        name
      }
    }
    offset
    limit
    totalCount
  }
}
      '''),
    ))
        .then((value) {
      print("HELLO");
      print(value.data);
    }).catchError((error) {
      print(error);
    });

    return Future.delayed(const Duration(seconds: 1), () {
      return List.generate(10, (i) {
        return RabbitsGroup(
          id: i,
          rabbits: const [
            Rabbit(id: 1, name: 'Rabbit 1'),
            Rabbit(id: 2, name: 'Rabbit 2'),
          ],
        );
      });
    });
  }
}
