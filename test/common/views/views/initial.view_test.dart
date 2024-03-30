import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views/initial.view.dart';

void main() {
  group(InitialView, () {
    testWidgets('InitialView displays CircularProgressIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: InitialView(),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
