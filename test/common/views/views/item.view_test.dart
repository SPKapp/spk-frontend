import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/common/views/views/item.view.dart';

void main() {
  group(ItemView, () {
    testWidgets('ItemView should display child widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ItemView(
            child: const Text('Hello World'),
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('ItemView should call onRefresh when refreshing',
        (WidgetTester tester) async {
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ItemView(
            child: const Text('Hello World'),
            onRefresh: () async {
              refreshCalled = true;
            },
          ),
        ),
      );

      await tester.fling(
        find.text('Hello World'),
        const Offset(0.0, 200.0),
        1000.0,
      );
      await tester.pumpAndSettle();

      expect(refreshCalled, true);
    });
  });
}
