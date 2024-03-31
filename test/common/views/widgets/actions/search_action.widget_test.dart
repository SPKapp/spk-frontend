import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/widgets/actions/search_action.widget.dart';

void main() {
  group(SearchAction, () {
    testWidgets('renders IconButton with search icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(),
                  onClear: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls showSearch when IconButton is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(
                    key: const Key('testKey'),
                  ),
                  onClear: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });

    testWidgets('renders IconButton with clear icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(),
                  onClear: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('calls onClear when clear IconButton is pressed',
        (WidgetTester tester) async {
      bool onClearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(),
                  onClear: () {
                    onClearCalled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(onClearCalled, isTrue);
    });

    testWidgets('calls close and onClear when back IconButton is pressed',
        (WidgetTester tester) async {
      bool onClearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(
                    key: const Key('testKey'),
                  ),
                  onClear: () {
                    onClearCalled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(onClearCalled, isTrue);
      expect(find.byKey(const Key('testKey')), findsNothing);
    });

    testWidgets(
        'calls generateResults with correct empty query in buildSuggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(
                    key: Key(query.toString()),
                  ),
                  onClear: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('')), findsOneWidget);
    });

    testWidgets('calls onClear when clear IconButton is pressed',
        (WidgetTester tester) async {
      bool onClearCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(),
                  onClear: () {
                    onClearCalled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(onClearCalled, isTrue);
    });

    testWidgets('calls generateResults with correct query in buildSuggestions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                SearchAction(
                  generateResults: (context, query) => Container(
                    key: Key(query.toString()),
                  ),
                  onClear: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('test')), findsAny);
    });
  });
}
