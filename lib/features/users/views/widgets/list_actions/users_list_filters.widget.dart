import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/features/users/models/dto.dart';

class UsersListFilters extends StatefulWidget {
  const UsersListFilters({
    super.key,
    required this.args,
    required this.onFilter,
  });

  final FindUsersArgs args;
  final Function(FindUsersArgs) onFilter;

  @override
  State<UsersListFilters> createState() => _UsersListFiltersState();
}

class _UsersListFiltersState extends State<UsersListFilters> {
  late FindUsersArgs args = widget.args;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          FilledButton.tonal(
            onPressed: () {
              widget.onFilter(args);
              context.pop();
            },
            child: const Text('Filtruj'),
          ),
        ],
      ),
    );
  }
}
