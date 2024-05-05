import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbits_list.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class MockRabbitsListBloc extends MockBloc<RabbitsListEvent, RabbitsListState>
    implements RabbitsListBloc {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group(RabbitsListPage, () {
    late RabbitsListBloc rabbitsListBloc;
    late AuthCubit authCubit;

    setUp(() {
      rabbitsListBloc = MockRabbitsListBloc();
      authCubit = MockAuthCubit();

      when(() => authCubit.currentUser).thenReturn(
        const CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: [Role.volunteer],
          teamId: 1,
        ),
      );

      when(() => rabbitsListBloc.args).thenReturn(const FindRabbitsArgs());
    });

    Widget buildWidget({bool? volunteerView}) {
      return MaterialApp(
        home: BlocProvider.value(
          value: authCubit,
          child: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
            volunteerView: volunteerView ?? true,
          ),
        ),
      );
    }

    testWidgets(
        'RabbitsListPage should dispaly CircularProgressIndicator when state is RabbitsListInitial',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(RabbitsListView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display "Failed to fetch rabbits" when state is RabbitsListFailure',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListFailure());
      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets(
        'RabbitsListPage should display RabbitsListView when state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state).thenAnswer(
        (_) => const RabbitsListSuccess(
          rabbitGroups: [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should not rebuild when state is RabbitsListInitial and previous state is RabbitsListSuccess',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          const RabbitsListInitial(),
        ]),
        initialState: const RabbitsListSuccess(
          rabbitGroups: [],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets(
        'RabbitsListPage should display SnackBar with error and not rebuild',
        (WidgetTester widgetTester) async {
      whenListen(
        rabbitsListBloc,
        Stream.fromIterable([
          const RabbitsListFailure(
            rabbitGroups: [RabbitGroup(id: 1, rabbits: [])],
            hasReachedMax: true,
            totalCount: 0,
          ),
        ]),
        initialState: const RabbitsListSuccess(
          rabbitGroups: [RabbitGroup(id: 1, rabbits: [])],
          hasReachedMax: true,
          totalCount: 0,
        ),
      );

      await widgetTester.pumpWidget(buildWidget());

      await widgetTester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RabbitsListView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should display search and filters buttons',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.byKey(const Key('searchAction')), findsOneWidget);
      expect(find.byKey(const Key('filterAction')), findsOneWidget);
    });

    testWidgets('should display volunteer view title',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(buildWidget());

      expect(find.text('Moje Króliki'), findsOneWidget);
    });

    testWidgets('should display rabbits view title',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: false,
      ));

      expect(find.text('Króliki'), findsOneWidget);
    });

    testWidgets('should display floating action button',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      when(() => authCubit.currentUser).thenReturn(
        const CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: [
            Role.admin,
          ],
        ),
      );

      await widgetTester.pumpWidget(buildWidget(volunteerView: false));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should not display floating action button',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: true,
      ));

      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets(
        'should not display floating action button when volunteerView is false',
        (WidgetTester widgetTester) async {
      when(() => rabbitsListBloc.state)
          .thenAnswer((_) => const RabbitsListInitial());
      when(() => authCubit.currentUser).thenReturn(
        const CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: [Role.regionRabbitObserver],
          observerRegions: [1],
        ),
      );

      await widgetTester.pumpWidget(buildWidget(
        volunteerView: false,
      ));

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
