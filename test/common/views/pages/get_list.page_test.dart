import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/pages/get_list.page.dart';
import 'package:spk_app_frontend/common/views/views.dart';

class MockGetListbloc extends MockBloc<GetListEvent, GetListState<String>>
    implements IGetListBloc<String, String> {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(GetListPage, () {
    late IGetListBloc<String, String> getListPage;
    late GoRouter goRouter;

    setUp(() {
      getListPage = MockGetListbloc();
      goRouter = MockGoRouter();

      when(() => goRouter.canPop()).thenReturn(false);

      when(() => getListPage.args).thenReturn('args');
    });

    Widget buildWidget(
        GetListPage<String, String, IGetListBloc<String, String>> child) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider.value(
            value: getListPage,
            child: child,
          ),
        ),
      );
    }

    testWidgets('renders correctly with initial state',
        (WidgetTester tester) async {
      when(() => getListPage.state).thenReturn(GetListInitial<String>());

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            itemBuilder: (context, item) =>
                Text(item, key: const Key('testKey')),
            emptyMessage: 'Empty Message',
          ),
        ),
      );

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder'), findsNothing);
      expect(find.byKey(const Key('testKey')), findsNothing);
      expect(find.text('Empty Message'), findsNothing);
    });

    testWidgets('renders correctly with failure state',
        (WidgetTester tester) async {
      when(() => getListPage.state)
          .thenReturn(GetListFailure<String>(code: '500'));

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            itemBuilder: (context, item) =>
                Text(item, key: const Key('testKey')),
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsOneWidget);
      expect(find.text('Error Info Builder'), findsNothing);
      expect(find.byKey(const Key('testKey')), findsNothing);
    });

    testWidgets('renders correctly with failure state and errorInfoBuilder',
        (WidgetTester tester) async {
      when(() => getListPage.state)
          .thenReturn(GetListFailure<String>(code: '500'));

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            errorInfoBuilder: (context, errorCode) =>
                'Error Info Builder $errorCode',
            itemBuilder: (context, item) =>
                Text(item, key: const Key('testKey')),
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder 500'), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsNothing);
    });

    testWidgets('renders correctly with success state',
        (WidgetTester tester) async {
      when(() => getListPage.state).thenReturn(
        GetListSuccess<String>(
          data: const ['Item 1', 'Item 2'],
          hasReachedMax: true,
          totalCount: 2,
        ),
      );

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            itemBuilder: (context, item) => Text(item),
            floatingActionButton: const Text('Floating Action Button'),
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder 500'), findsNothing);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Floating Action Button'), findsOneWidget);
    });

    testWidgets('renders correctly with success state and empty message',
        (WidgetTester tester) async {
      when(() => getListPage.state).thenReturn(
        GetListSuccess<String>(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            itemBuilder: (context, item) => Text(item),
            emptyMessage: 'Empty Message',
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder 500'), findsNothing);
      expect(find.text('Empty Message'), findsOneWidget);
    });

    testWidgets('should display filters when filterBuilder is provided',
        (WidgetTester tester) async {
      when(() => getListPage.state).thenReturn(
        GetListSuccess<String>(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await tester.pumpWidget(
        buildWidget(
          GetListPage<String, String, IGetListBloc<String, String>>(
            title: 'Default Title',
            errorInfo: 'Error Info',
            itemBuilder: (context, item) => Text(item),
            filterBuilder: (context, args, callback) => TextButton(
              onPressed: () => callback(args),
              child: const Text('Filters'),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('filterAction')));
      await tester.pumpAndSettle();

      expect(find.text('Filters'), findsOneWidget);

      await tester.tap(find.text('Filters'));

      verify(() => getListPage.add(const RefreshList('args'))).called(1);
    });

    testWidgets(
        'should throw an error when errorInfo and errorInfoBuilder '
        'are not provided', (WidgetTester tester) async {
      when(() => getListPage.state)
          .thenReturn(GetListFailure<String>(code: '500'));

      expect(
        () => GetListPage<String, String, IGetListBloc<String, String>>(
          title: 'Default Title',
          itemBuilder: (context, item) => Text(item, key: const Key('testKey')),
        ),
        throwsAssertionError,
      );
    });
  });
}
