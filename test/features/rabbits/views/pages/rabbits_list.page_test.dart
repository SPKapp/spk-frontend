import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';

import 'package:spk_app_frontend/app/bloc/app.bloc.dart';
import 'package:spk_app_frontend/common/views/views.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/rabbits/bloc/rabbits_list.bloc.dart';
import 'package:spk_app_frontend/features/rabbits/models/dto.dart';
import 'package:spk_app_frontend/features/rabbits/models/models.dart';
import 'package:spk_app_frontend/features/rabbits/views/pages/rabbits_list.page.dart';
import 'package:spk_app_frontend/features/rabbits/views/views/rabbits_list.view.dart';

class MockRabbitsListBloc extends MockBloc<RabbitsListEvent, RabbitsListState>
    implements RabbitsListBloc {}

class MockAppBlock extends MockBloc<AppEvent, AppState> implements AppBloc {}

void main() {
  group(RabbitsListPage, () {
    late RabbitsListBloc rabbitsListBloc;
    late AppBloc appBloc;

    setUp(() {
      rabbitsListBloc = MockRabbitsListBloc();
      appBloc = MockAppBlock();

      when(() => appBloc.state).thenReturn(const AppState.authenticated(
        CurrentUser(
          id: 1,
          uid: '123',
          token: '123',
          roles: [Role.volunteer],
          teamId: 1,
        ),
      ));

      when(() => rabbitsListBloc.args).thenReturn(const FindRabbitsArgs());
    });

    Widget buildWidget() {
      return MaterialApp(
        home: BlocProvider.value(
          value: appBloc,
          child: RabbitsListPage(
            rabbitsListBloc: (_) => rabbitsListBloc,
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
  });
}
