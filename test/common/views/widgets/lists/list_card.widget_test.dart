import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';

void main() {
  group(ListCard, () {
    testWidgets('ListCard should render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListCard(
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify that the ListCard renders correctly
      expect(find.byType(ListCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });
}
