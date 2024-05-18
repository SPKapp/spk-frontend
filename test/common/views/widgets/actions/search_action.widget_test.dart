import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/search.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/widgets/actions.dart';

class MockGetListbloc extends MockBloc<SearchEvent, SearchState<String>>
    implements ISearchBloc<String> {}

void main() {
  group(SearchAction, () {
    late ISearchBloc<String> searchBloc;

    setUp(() {
      searchBloc = MockGetListbloc();
    });

    Widget buildWidget(SearchAction<String, ISearchBloc<String>> child) {
      return MaterialApp(
        home: BlocProvider.value(
          value: searchBloc,
          child: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('renders SimpleSearchAction widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      expect(find.byType(SimpleSearchAction), findsOneWidget);
    });

    testWidgets('calls onClear when clear button is pressed',
        (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchInitial());

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      verify(() => searchBloc.add(const ClearSearch())).called(1);
    });

    testWidgets('calls RefreshSearch when query changes',
        (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchInitial());

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      verify(() => searchBloc.add(const RefreshSearch('test'))).called(1);
    });

    testWidgets('renders SearchInitial state', (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchInitial());

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('searchInitial')), findsOneWidget);
    });

    testWidgets('renders SearchFailure state', (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchFailure(code: '500'));

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('renders SearchFailure state errorInfoBuilder',
        (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchFailure(code: '500'));

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfoBuilder: (context, errorCode) {
              return 'Error $errorCode';
            },
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      verify(() => searchBloc.add(const RefreshSearch('test'))).called(1);

      expect(find.text('Error 500'), findsOneWidget);
    });

    test('should throw an error if errorInfo and errorInfoBuilder are null',
        () {
      expect(
        () => SearchAction<String, ISearchBloc<String>>(
          itemBuilder: (context, item) => Text(item),
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders SearchSuccess state', (WidgetTester tester) async {
      when(() => searchBloc.state).thenReturn(SearchSuccess(
        query: 'Item',
        data: const ['Item 1', 'Item 2'],
        hasReachedMax: true,
        totalCount: 2,
      ));

      await tester.pumpWidget(
        buildWidget(
          SearchAction<String, ISearchBloc<String>>(
            errorInfo: 'Error',
            itemBuilder: (context, item) => Text(item),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Item');
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });
  });
}
