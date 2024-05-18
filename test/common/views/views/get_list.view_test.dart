import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/views/get_list.view.dart';

class MockListBloc extends MockBloc<GetListEvent, GetListState<String>>
    implements IGetListBloc<String, String> {}

void main() {
  group(GetListView, () {
    late IGetListBloc<String, String> bloc;

    setUp(() {
      bloc = MockListBloc();
    });

    Widget buildWidget(
        GetListView<String, String, IGetListBloc<String, String>> child) {
      return MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('renders InitialView when GetListInitial state is received',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(GetListInitial<String>());

      await tester.pumpWidget(
        buildWidget(
          GetListView<String, String, IGetListBloc<String, String>>(
            errorInfo: 'Error',
            builder: (context, data) => Container(),
          ),
        ),
      );

      expect(find.byType(InitialView), findsOneWidget);
    });

    testWidgets('renders FailureView when GetListFailure state is received',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(GetListFailure<String>());

      await tester.pumpWidget(
        buildWidget(
          GetListView<String, String, IGetListBloc<String, String>>(
            errorInfo: 'Error',
            builder: (context, data) => Container(),
          ),
        ),
      );

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });
    testWidgets(
        'renders FailureView when GetListFailure state is received with errorInfoBuilder',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(GetListFailure<String>(code: '500'));
      await tester.pumpWidget(
        buildWidget(
          GetListView<String, String, IGetListBloc<String, String>>(
            errorInfoBuilder: (context, errorCode) => 'Error $errorCode',
            builder: (context, data) => Container(),
          ),
        ),
      );

      expect(find.byType(FailureView), findsOneWidget);
      expect(find.text('Error 500'), findsOneWidget);
    });

    test('should throw an error if errorInfo and errorInfoBuilder are null',
        () {
      expect(
        () => GetListView<String, String, IGetListBloc<String, String>>(
          builder: (context, data) => Container(),
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
        'renders builder function when GetListSuccess state is received',
        (WidgetTester tester) async {
      when(() => bloc.state).thenReturn(
        GetListSuccess<String>(
          data: const ['Test 1'],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );

      await tester.pumpWidget(
        buildWidget(
          GetListView<String, String, IGetListBloc<String, String>>(
            errorInfo: 'Error',
            builder: (context, data) => ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(data[index]),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test 1'), findsOneWidget);
    });
  });
}
