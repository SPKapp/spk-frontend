import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/features/users/bloc/users_list.bloc.dart';
import 'package:spk_app_frontend/features/users/models/dto.dart';

class UsersListFilters extends StatefulWidget {
  const UsersListFilters({
    super.key,
    required this.args,
  });

  final FindUsersArgs args;

  @override
  State<UsersListFilters> createState() => _UsersListFiltersState();
}

class _UsersListFiltersState extends State<UsersListFilters> {
  late FindUsersArgs args = widget.args;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0,
      heightFactor: 0.7,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filtruj użytkowników',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('Wszyscy'),
                    selected: args.isActive == null,
                    onSelected: (bool selected) {
                      setState(() {
                        args = args.copyWith(isActive: () => null);
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Aktywni'),
                    selected: args.isActive == true,
                    onSelected: (bool selected) {
                      setState(() {
                        args = args.copyWith(isActive: () => true);
                      });
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Nieaktywni'),
                    selected: args.isActive == false,
                    onSelected: (bool selected) {
                      setState(() {
                        args = args.copyWith(isActive: () => false);
                      });
                    },
                  ),
                ],
              ),
              const Padding(
                // TODO: Implement filters
                padding: EdgeInsets.all(8.0),
                child: Text('Jakie filtry są potrzebne?'),
              ),
              FilledButton.tonal(
                onPressed: () {
                  context.read<UsersListBloc>().add(RefreshList(args));
                  context.pop();
                },
                child: const Text('Filtruj'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
