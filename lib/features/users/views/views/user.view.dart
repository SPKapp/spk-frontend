import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/card.widget.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_view.dart';

class UserView extends StatelessWidget {
  const UserView({
    super.key,
    required this.user,
    required this.roleInfo,
    this.errorWidget,
  });

  final User user;
  final RoleInfo roleInfo;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (errorWidget != null) errorWidget!,
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
        // const AppCard(
        //   child: ListTile(
        //     title: Text('Tutaj będzie adres'),
        //     leading: Icon(FontAwesomeIcons.addressCard),
        //   ),
        // ),
        RolesCard(roleInfo: roleInfo),
      ],
    );
  }
}
