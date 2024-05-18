import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/common/views/widgets/lists/list_card.widget.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbits_list.page.dart';

class MockRabbitsListBloc
    extends MockBloc<GetListEvent, GetListState<RabbitGroup>>
    implements RabbitsListBloc {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockGoRouter extends Mock implements GoRouter {
  @override
  bool canPop() => true;
}

void main() {
  group(RabbitsListPage, () {
    late RabbitsListBloc rabbitsListBloc;
    late AuthCubit authCubit;
    late GoRouter goRouter;

    setUp(() {
      rabbitsListBloc = MockRabbitsListBloc();
      authCubit = MockAuthCubit();
      goRouter = MockGoRouter();

      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: const [Role.volunteer],
          teamId: 1,
        ),
      );

      when(() => rabbitsListBloc.args).thenReturn(const FindRabbitsArgs());
    });

    Widget buildWidget({bool? volunteerView}) {
      return MaterialApp(
        home: InheritedGoRouter(
          goRouter: goRouter,
          child: BlocProvider.value(
            value: authCubit,
            child: RabbitsListPage(
              rabbitsListBloc: (_) => rabbitsListBloc,
              volunteerView: volunteerView ?? true,
            ),
          ),
        ),
      );
    }

    testWidgets(
        'RabbitsListPage should dispaly CircularProgressIndicator when state is RabbitsListInitial',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListCard), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display "Failed to fetch rabbits" when state is RabbitsListFailure',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListFailure());
      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListCard), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'RabbitsListPage should display RabbitsListView when state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer(
        (_) => GetListSuccess(
          data: const [RabbitGroup(id: 'id', rabbits: [])],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListCard), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should not rebuild when state is RabbitsListInitial and previous state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          GetListInitial<RabbitGroup>(),
        ]),
        initialState: GetListSuccess<RabbitGroup>(
          data: const [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Brak królików.'), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display SnackBar with error and not rebuild',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          GetListFailure<RabbitGroup>(
            data: const [RabbitGroup(id: '1', rabbits: [])],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
        initialState: GetListSuccess<RabbitGroup>(
          data: const [RabbitGroup(id: '1', rabbits: [])],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListCard), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should display search and filters buttons',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('searchAction')), findsOneWidget);
      expect(find.byKey(const Key('filterAction')), findsOneWidget);
    });

    testWidgets('should display volunteer view title',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.text('Moje Króliki'), findsOneWidget);
    });

    testWidgets('should display rabbits view title',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: false,
      ));

      expect(find.text('Króliki'), findsOneWidget);
    });

    testWidgets('should display floating action button',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: const [Role.admin],
        ),
      );

      await widgetTester.pumpWidget(buildWidget(volunteerView: false));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should not display floating action button',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: true,
      ));

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
        'should not display floating action button when volunteerView is false',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer((_) => GetListInitial());
      when(() => authCubit.currentUser).thenReturn(
        CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: const [Role.regionRabbitObserver],
          observerRegions: const [1],
        ),
      );

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: false,
      ));

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
