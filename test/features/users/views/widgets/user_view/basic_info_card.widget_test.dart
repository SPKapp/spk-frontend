import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_view/basic_info_card.widget.dart';

void main() {
  group(BasicInfoCard, () {
    Widget buildWidget(User user) {
      return MaterialApp(
        home: Scaffold(
          body: BasicInfoCard(user: user),
        ),
      );
    }

    testWidgets('renders email when user has email',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(const User(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'test@example.com',
      )));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('renders "Brak adresu email" when user does not have email',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(const User(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
      )));

      expect(find.text('Brak adresu email'), findsOneWidget);
      expect(find.text('test@example.com'), findsNothing);
    });

    testWidgets('renders phone when user has phone number',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(const User(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        phone: '123456789',
      )));

      expect(find.text('Telefon'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
    });

    testWidgets(
        'renders "Brak numeru telefonu" when user does not have phone number',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(const User(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
      )));

      expect(find.text('Brak numeru telefonu'), findsOneWidget);
      expect(find.text('123456789'), findsNothing);
    });
  });
}
