import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spk_app_frontend/common/views/views/list.view.dart';

void main() {
  group(AppListView, () {
    final List<int> items = [1, 2, 3];
    String emptyMessage = 'No results.';
    Widget itemBuilder(dynamic item) {
      return Text(
        item.toString(),
        key: Key('Item $item'),
      );
    }

    Widget buildWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(
          body: child,
        ),
      );
    }

    testWidgets('renders empty message when items are empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: const [],
            hasReachedMax: true,
            onRefresh: () async {},
            onFetch: () {},
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      expect(find.text(emptyMessage), findsOneWidget);
    });

    testWidgets('should call onRefresh when RefreshIndicator is triggered',
        (WidgetTester tester) async {
      bool isRefreshed = false;
      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: const [],
            hasReachedMax: true,
            onRefresh: () async {
              isRefreshed = true;
            },
            onFetch: () {},
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      await tester.fling(
        find.text(emptyMessage),
        const Offset(0.0, 400.0),
        1000.0,
      );
      await tester.pumpAndSettle();

      // Verify that onRefresh is called
      expect(isRefreshed, isTrue);
    });

    testWidgets('renders ListView when items are not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: items,
            hasReachedMax: true,
            onRefresh: () async {},
            onFetch: () {},
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      expect(find.byKey(const Key('appListView')), findsOneWidget);
      for (int item in items) {
        expect(find.byKey(Key('Item $item')), findsOneWidget);
      }
    });

    testWidgets('should call onRefresh when ListView is displayed',
        (WidgetTester tester) async {
      bool isRefreshed = false;
      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: items,
            hasReachedMax: true,
            onRefresh: () async {
              isRefreshed = true;
            },
            onFetch: () {},
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      await tester.fling(
        find.byKey(const Key('appListView')),
        const Offset(0.0, 400.0),
        1000.0,
      );
      await tester.pumpAndSettle();

      expect(isRefreshed, isTrue);
    });

    testWidgets('should call onFetch when screen is not scrollable',
        (WidgetTester tester) async {
      bool isFetched = false;
      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: items,
            hasReachedMax: false,
            onRefresh: () async {},
            onFetch: () {
              isFetched = true;
            },
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 501));

      expect(isFetched, isTrue);
    });

    testWidgets('should call onFetch when screen is scrollable',
        (WidgetTester tester) async {
      bool isFetched = false;

      tester.view.physicalSize = const Size(50, 50);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildWidget(
          AppListView<int>(
            items: items,
            hasReachedMax: false,
            onRefresh: () async {},
            onFetch: () {
              isFetched = true;
            },
            emptyMessage: emptyMessage,
            itemBuilder: itemBuilder,
          ),
        ),
      );

      await tester.dragUntilVisible(
        find.byType(CircularProgressIndicator),
        find.byKey(const Key('appListView')),
        const Offset(0.0, -300.0),
      );
      await tester.pump();

      expect(isFetched, isTrue);
    });
  });
}
