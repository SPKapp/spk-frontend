import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter/material.dart';
import 'package:spk_app_frontend/common/bloc/interfaces/get_list.bloc.interface.dart';
import 'package:spk_app_frontend/common/views/views.dart';

import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';
import 'package:spk_app_frontend/features/regions/views/common/inject_regions_list.widget.dart';

class MockRegionsListBloc extends MockBloc<GetListEvent, GetListState<Region>>
    implements RegionsListBloc {}

void main() {
  group(InjectRegionsList, () {
    late RegionsListBloc regionsListBloc;

    setUp(() {
      regionsListBloc = MockRegionsListBloc();
    });

    Widget buildWidget() {
      return MaterialApp(
        home: InjectRegionsList(
          regionsListBloc: (_) => regionsListBloc,
          builder: (context, regions) => const Text('Test'),
        ),
      );
    }

    testWidgets('renders InitialView when RegionsListInitial state',
        (WidgetTester tester) async {
      when(() => regionsListBloc.state).thenReturn(GetListInitial());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Test'), findsNothing);
      expect(find.byType(InitialView), findsOneWidget);
      expect(find.byType(FailureView), findsNothing);
    });

    testWidgets('renders FailureView when RegionsListFailure state',
        (WidgetTester tester) async {
      when(() => regionsListBloc.state).thenReturn(GetListFailure());

      await tester.pumpWidget(buildWidget());

      expect(find.text('Test'), findsNothing);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsOneWidget);
    });

    testWidgets('renders buildChild when RegionsListSuccess state',
        (WidgetTester tester) async {
      when(() => regionsListBloc.state).thenReturn(GetListSuccess(
        data: const [],
        hasReachedMax: true,
        totalCount: 0,
      ));

      await tester.pumpWidget(buildWidget());

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(InitialView), findsNothing);
      expect(find.byType(FailureView), findsNothing);
    });
  });
}
