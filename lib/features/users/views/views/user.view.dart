import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/bloc/user.cubit.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_view.dart';

class UserView extends StatelessWidget {
  const UserView({
    super.key,
    required this.user,
    required this.roleInfo,
  });

  final User user;
  final RoleInfo roleInfo;

  @override
  Widget build(BuildContext context) {
    return ItemView(
      onRefresh: () async {
        // skip initial state
        Future cubit = context.read<UserCubit>().stream.skip(1).first;
        context.read<UserCubit>().refreshUser();
        return cubit;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user.active == false)
            AppCard(
              child: ListTile(
                title: Text(
                  'Użytkownik jest dezaktywowany',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          BasicInfoCard(
            user: user,
          ),
          const AppCard(
            child: ListTile(
              title: Text('Tutaj będzie adres'),
              leading: Icon(FontAwesomeIcons.addressCard),
            ),
          ),
          RolesCard(roleInfo: roleInfo),
        ],
      ),
    );
  }
}
