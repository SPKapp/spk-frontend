import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_one.cubit.interface.dart';
import 'package:spk_app_frontend/common/views/pages/get_one.page.dart';
import 'package:spk_app_frontend/common/views/views.dart';

class MockGetOneCubit extends MockCubit<GetOneState<String>>
    implements IGetOneCubit<String> {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(GetOnePage, () {
    late IGetOneCubit<String> getOneCubit;
    late GoRouter goRouter;

    setUp(() {
      getOneCubit = MockGetOneCubit();
      goRouter = MockGoRouter();

      when(() => goRouter.canPop()).thenReturn(false);
    });

    Widget buildWidget(GetOnePage<String, IGetOneCubit<String>> child) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider.value(
            value: getOneCubit,
            child: child,
          ),
        ),
      );
    }

    testWidgets('renders InitialView when GetOneInitial state is received',
        (WidgetTester tester) async {
      when(() => getOneCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            titleBuilder: (context, data) => 'Title Builder',
            errorInfo: 'Error Info',
            errorInfoBuilder: (context, errorCode) => 'Error Info Builder',
          ),
        ),
      );

      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsOneWidget);
      expect(find.text('Title Builder'), findsNothing);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder'), findsNothing);
      expect(find.byKey(const Key('testKey')), findsNothing);
    });

    testWidgets('renders FailureView when GetOneFailure state is received',
        (WidgetTester tester) async {
      when(() => getOneCubit.state)
          .thenReturn(const GetOneFailure(code: '404'));

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(
              data,
              key: const Key('testKey'),
            ),
            defaultTitle: 'Default Title',
            titleBuilder: (context, data) => 'Title Builder',
            errorInfo: 'Error Info',
            actions: const [Text('Action')],
            actionsBuilder: (context, data) => const [Text('Action Builder')],
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);

      expect(find.text('Default Title'), findsOneWidget);
      expect(find.text('Title Builder'), findsNothing);

      expect(find.text('Error Info'), findsOneWidget);
      expect(find.text('Error Info Builder'), findsNothing);
      expect(find.byKey(const Key('testKey')), findsNothing);

      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Action Builder'), findsNothing);
    });
    testWidgets(
        'renders FailureView when GetOneFailure state is received with custom error info builder',
        (WidgetTester tester) async {
      when(() => getOneCubit.state)
          .thenReturn(const GetOneFailure(code: '404'));

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            errorInfo: 'Error Info',
            errorInfoBuilder: (context, errorCode) =>
                'Error Info Builder $errorCode',
            actionsBuilder: (context, data) => const [Text('Action Builder')],
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);

      expect(find.text('Default Title'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder 404'), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsNothing);

      expect(find.text('Action Builder'), findsNothing);
    });

    testWidgets('renders ItemView when GetOneSuccess state is received',
        (WidgetTester tester) async {
      when(() => getOneCubit.state)
          .thenReturn(const GetOneSuccess(data: 'Data'));

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            errorInfo: 'Error Info',
            actions: const [Text('Action')],
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsOneWidget);
      expect(find.text('Title Builder'), findsNothing);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder'), findsNothing);

      expect(find.byKey(const Key('testKey')), findsOneWidget);

      expect(find.text('Action'), findsOneWidget);
    });

    testWidgets(
        'renders ItemView when GetOneSuccess state is received with custom title builder',
        (WidgetTester tester) async {
      when(() => getOneCubit.state)
          .thenReturn(const GetOneSuccess(data: 'Data'));

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            titleBuilder: (context, data) => 'Title Builder $data',
            errorInfo: 'Error Info',
            actions: const [Text('Action')],
            actionsBuilder: (context, data) => const [Text('Action Builder')],
          ),
        ),
      );

      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);

      expect(find.text('Default Title'), findsNothing);
      expect(find.text('Title Builder Data'), findsOneWidget);

      expect(find.text('Error Info'), findsNothing);
      expect(find.text('Error Info Builder'), findsNothing);

      expect(find.byKey(const Key('testKey')), findsOneWidget);

      expect(find.text('Action'), findsNothing);
      expect(find.text('Action Builder'), findsOneWidget);
    });

    testWidgets(
        'renders persistent footer buttons when GetOneSuccess state is received',
        (WidgetTester tester) async {
      when(() => getOneCubit.state)
          .thenReturn(const GetOneSuccess(data: 'Data'));

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            titleBuilder: (context, data) => 'Title Builder $data',
            errorInfo: 'Error Info',
            actions: const [Text('Action')],
            persistentFooterButtons: const [Text('Persistent Footer Button')],
            persistentFooterButtonsBuilder: (context, data) =>
                const [Text('Persistent Footer Button Builder')],
          ),
        ),
      );

      expect(find.text('Persistent Footer Button'), findsNothing);
      expect(find.text('Persistent Footer Button Builder'), findsOneWidget);
    });

    testWidgets(
        'renders persistent footer buttons when GetOneInitial state is received',
        (WidgetTester tester) async {
      when(() => getOneCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data, key: const Key('testKey')),
            defaultTitle: 'Default Title',
            titleBuilder: (context, data) => 'Title Builder $data',
            errorInfo: 'Error Info',
            actions: const [Text('Action')],
            persistentFooterButtons: const [Text('Persistent Footer Button')],
            persistentFooterButtonsBuilder: (context, data) =>
                const [Text('Persistent Footer Button Builder')],
          ),
        ),
      );

      expect(find.text('Persistent Footer Button'), findsOneWidget);
      expect(find.text('Persistent Footer Button Builder'), findsNothing);
    });

    testWidgets('displays drawer button', (WidgetTester tester) async {
      when(() => getOneCubit.state).thenReturn(const GetOneInitial());

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data),
            defaultTitle: 'Default Title',
            errorInfo: 'Error Info',
          ),
        ),
      );

      expect(find.byType(DrawerButton), findsOneWidget);
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      when(() => getOneCubit.state).thenReturn(const GetOneInitial());
      when(() => goRouter.canPop()).thenReturn(true);

      await tester.pumpWidget(
        buildWidget(
          GetOnePage<String, IGetOneCubit<String>>(
            builder: (context, data) => Text(data),
            defaultTitle: 'Default Title',
            errorInfo: 'Error Info',
          ),
        ),
      );

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets(
        'should throw assertion errorInfo and errorInfoBuilder are null',
        (WidgetTester tester) async {
      expect(
        () => GetOnePage<String, IGetOneCubit<String>>(
          builder: (context, data) => Text(data),
          defaultTitle: 'Default Title',
        ),
        throwsAssertionError,
      );
    });
  });
}
