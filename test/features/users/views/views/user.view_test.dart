import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/views/user.view.dart';

void main() {
  group(UserView, () {
    Widget buildWidget(bool active) {
      return MaterialApp(
        home: Scaffold(
          body: UserView(
            user: User(
              id: '1',
              firstName: 'John',
              lastName: 'Doe',
              email: 'email@example.com',
              phone: '123456789',
              active: active,
            ),
            roleInfo: RoleInfo([]),
          ),
        ),
      );
    }

    testWidgets('renders UserView correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(true),
      );

      expect(find.text('email@example.com'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text('Tutaj będzie adres'), findsOneWidget);
      expect(find.text('Brak przyznanych uprawnień'), findsOneWidget);
      expect(find.text('Użytkownik jest dezaktywowany'), findsNothing);
    });

    testWidgets('renders deactivated user message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(false),
      );

      expect(find.text('email@example.com'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text('Tutaj będzie adres'), findsOneWidget);
      expect(find.text('Brak przyznanych uprawnień'), findsOneWidget);
      expect(find.text('Użytkownik jest dezaktywowany'), findsOneWidget);
    });
  });
}
