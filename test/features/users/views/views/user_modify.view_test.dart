import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spk_app_frontend/common/views/widgets/form_fields.dart';

import 'package:spk_app_frontend/features/users/views/views/user_modify.view.dart';

void main() {
  group(UserModifyView, () {
    late FieldControlers fieldControlers;

    setUp(() {
      fieldControlers = FieldControlers();
    });

    tearDown(() {
      fieldControlers.dispose();
    });

    testWidgets('UserModifyView should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UserModifyView(editControlers: fieldControlers),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(4));
      expect(find.byKey(const Key('firstnameTextField')), findsOneWidget);
      expect(find.byKey(const Key('lastnameTextField')), findsOneWidget);
      expect(find.byKey(const Key('emailTextField')), findsOneWidget);
      expect(find.byKey(const Key('phoneTextField')), findsOneWidget);
    });

    testWidgets('UserModifyView should validate form fields',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: formKey,
            child: UserModifyView(editControlers: fieldControlers),
          ),
        ),
      );

      // Test empty fields
      await tester.tap(find.byKey(const Key('firstnameTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('firstnameTextField')),
        '',
      );

      await tester.tap(find.byKey(const Key('lastnameTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('lastnameTextField')),
        '',
      );

      await tester.tap(find.byKey(const Key('emailTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('emailTextField')),
        '',
      );

      await tester.tap(find.byKey(const Key('phoneTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('phoneTextField')),
        '',
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Pole nie może być puste.'), findsNWidgets(4));
    });

    testWidgets('UserTextField should validate email',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: formKey,
            child: UserModifyView(editControlers: fieldControlers),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('emailTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('emailTextField')),
        'invalidemail',
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Niepoprawny email'), findsOneWidget);
    });

    testWidgets('UserTextField should validate phone number',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: formKey,
            child: UserModifyView(editControlers: fieldControlers),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('phoneTextField')));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('phoneTextField')),
        '1234567',
      );

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Niepoprawny numer telefonu.'), findsOneWidget);
    });

    testWidgets('UserTextField should validate all fields',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Form(
            key: formKey,
            child: UserModifyView(editControlers: fieldControlers),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('firstnameTextField')));
      await tester.pump();
      await tester.enterText(
          find.byKey(const Key('firstnameTextField')), 'John');

      await tester.tap(find.byKey(const Key('lastnameTextField')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('lastnameTextField')), 'Doe');

      await tester.tap(find.byKey(const Key('emailTextField')));
      await tester.pump();
      await tester.enterText(
          find.byKey(const Key('emailTextField')), 'email@example.com');

      await tester.tap(find.byKey(const Key('phoneTextField')));
      await tester.pump();
      await tester.enterText(
          find.byKey(const Key('phoneTextField')), '123456789');

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Pole nie może być puste.'), findsNothing);
      expect(find.text('Niepoprawny email'), findsNothing);
      expect(find.text('Niepoprawny numer telefonu.'), findsNothing);
    });
  });
}
