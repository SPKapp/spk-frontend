import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';

import 'package:spk_app_frontend/features/rabbits/bloc/rabbit_create.cubit.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbit_create.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbit_modify.view.dart';

import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';

class MockRabbitCreateCubbit extends MockCubit<RabbitCreateState>
    implements RabbitCreateCubit {}

class MockRegionsListBloc extends MockBloc<RegionsListEvent, RegionsListState>
    implements RegionsListBloc {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group(RabbitCreatePage, () {
    late RabbitCreateCubit rabbitCreateCubit;
    late RegionsListBloc regionsListBloc;
    late AppBloc appBloc;
    late GoRouter goRouter;

    setUpAll(() {
      registerFallbackValue(RabbitCreateDto(name: 'rabbitName'));
    });

    setUp(() {
      rabbitCreateCubit = MockRabbitCreateCubbit();
      regionsListBloc = MockRegionsListBloc();
      appBloc = MockAppBloc();
      goRouter = MockGoRouter();

      when(() => rabbitCreateCubit.state)
          .thenAnswer((_) => const RabbitCreateInitial());

      when(() => appBloc.state).thenAnswer(
        (_) => const AppState.authenticated(
          CurrentUser(
            uid: '1',
            token: 'token',
            roles: [Role.regionManager],
            regions: [1],
          ),
        ),
      );
    });

    testWidgets('should render correctly without regions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppBloc>.value(
            value: appBloc,
            child: RabbitCreatePage(
              rabbitCreateCubit: (_) => rabbitCreateCubit,
            ),
          ),
        ),
      );

      expect(find.text('Dodaj królika'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(RabbitModifyView), findsOneWidget);
      expect(find.byKey(const Key('regionDropdown')), findsNothing);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    group('with regions', () {
      setUp(() {
        when(() => appBloc.state).thenAnswer(
          (_) => const AppState.authenticated(
            CurrentUser(
              uid: '1',
              token: 'token',
              roles: [Role.admin],
              regions: [1, 2],
            ),
          ),
        );
      });

      testWidgets('should display InitialView when loading',
          (WidgetTester tester) async {
        when(() => regionsListBloc.state).thenAnswer(
          (_) => const RegionsListInitial(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: RabbitCreatePage(
                rabbitCreateCubit: (_) => rabbitCreateCubit,
                regionsListBloc: (_) => regionsListBloc,
              ),
            ),
          ),
        );

        expect(find.byType(InitialView), findsOneWidget);
      });

      testWidgets('should display FailureView when loading fails',
          (WidgetTester tester) async {
        when(() => regionsListBloc.state).thenAnswer(
          (_) => const RegionsListFailure(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: RabbitCreatePage(
                rabbitCreateCubit: (_) => rabbitCreateCubit,
                regionsListBloc: (_) => regionsListBloc,
              ),
            ),
          ),
        );

        expect(find.byType(FailureView), findsOneWidget);
      });

      testWidgets('should refresh regions when retry button is pressed',
          (WidgetTester tester) async {
        when(() => regionsListBloc.state).thenAnswer(
          (_) => const RegionsListFailure(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: RabbitCreatePage(
                rabbitCreateCubit: (_) => rabbitCreateCubit,
                regionsListBloc: (_) => regionsListBloc,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Spróbuj ponownie'));

        verify(() => regionsListBloc.add(const RefreshRegions())).called(1);
      });

      testWidgets('should render correctly with regions',
          (WidgetTester tester) async {
        when(() => regionsListBloc.state).thenAnswer(
          (_) => const RegionsListSuccess(
            regions: [
              Region(id: 1, name: 'Region 1'),
              Region(id: 2, name: 'Region 2'),
            ],
            hasReachedMax: true,
            totalCount: 2,
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: RabbitCreatePage(
                rabbitCreateCubit: (_) => rabbitCreateCubit,
                regionsListBloc: (_) => regionsListBloc,
              ),
            ),
          ),
        );

        expect(find.text('Dodaj królika'), findsOneWidget);
        expect(find.byType(Form), findsOneWidget);
        expect(find.byType(RabbitModifyView), findsOneWidget);
        expect(find.byKey(const Key('regionDropdown')), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      });
    });

    testWidgets('should create rabbit when form is submitted',
        (WidgetTester tester) async {
      whenListen(
        rabbitCreateCubit,
        Stream.fromIterable([
          const RabbitCreated(
            rabbitId: 1,
          )
        ]),
        initialState: const RabbitCreateInitial(),
      );

      when(() => goRouter.pushReplacement(any()))
          .thenAnswer((_) async => Object());

      final editControlers = FieldControlers();
      editControlers.nameControler.text = 'rabbitName';

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: goRouter,
            child: BlocProvider<AppBloc>.value(
              value: appBloc,
              child: RabbitCreatePage(
                rabbitCreateCubit: (_) => rabbitCreateCubit,
                editControlers: editControlers,
              ),
            ),
          ),
        ),
      );

      final sendButton = find.byIcon(Icons.send_rounded);
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Królik został dodany'), findsOneWidget);

      verify(
        () => rabbitCreateCubit.createRabbit(
          any(
            that: isA<RabbitCreateDto>()
                .having((dto) => dto.regionId, 'regionId', 1),
          ),
        ),
      ).called(1);
      verify(() => goRouter.pushReplacement('/rabbit/1')).called(1);
    });

    testWidgets('should show error message when rabbit creation fails',
        (WidgetTester tester) async {
      whenListen(
        rabbitCreateCubit,
        Stream.fromIterable([const RabbitCreateFailure()]),
        initialState: const RabbitCreateInitial(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AppBloc>.value(
            value: appBloc,
            child: RabbitCreatePage(
              rabbitCreateCubit: (_) => rabbitCreateCubit,
            ),
          ),
        ),
      );

      final sendButton = find.byIcon(Icons.send_rounded);
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Nie udało się dodać królika'), findsOneWidget);
    });
  });
}
