import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spk_app_frontend/features/auth/auth.dart';
import 'package:spk_app_frontend/features/regions/bloc/regions_list.bloc.dart';
import 'package:spk_app_frontend/features/regions/models/models.dart';

import 'package:spk_app_frontend/features/users/models/models.dart';
import 'package:spk_app_frontend/features/users/views/widgets/user_view/roles_card.widget.dart';

class MockRegionsBloc extends MockBloc<RegionsListEvent, RegionsListState>
    implements RegionsListBloc {}

void main() {
  group(RolesCard, () {
    late RegionsListBloc regionsListBloc;

    setUp(() {
      regionsListBloc = MockRegionsBloc();

      when(() => regionsListBloc.state).thenReturn(
        const RegionsListSuccess(
          regions: [
            Region(id: '1', name: 'Region 1'),
            Region(id: '2', name: 'Region 2'),
          ],
          hasReachedMax: true,
          totalCount: 1,
        ),
      );
    });

    Widget buildWidget(List<RoleEntity>? roles) {
      return MaterialApp(
        home: Scaffold(
          body: RolesCard(
            roleInfo: RoleInfo(roles),
            regionsListBloc: (_) => regionsListBloc,
          ),
        ),
      );
    }

    testWidgets(
        'displays "Brak przyznanych uprawnień" when roleInfo has no roles',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget([]));

      expect(find.text('Brak przyznanych uprawnień'), findsOneWidget);
    });

    testWidgets('displays "Administrator" role when roleInfo.isAdmin is true',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(buildWidget([const RoleEntity(role: Role.admin)]));

      expect(find.text('Administrator'), findsOneWidget);
    });

    testWidgets(
        'displays "Wolontariusz" role when roleInfo.isVolunteer is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
          [const RoleEntity(role: Role.volunteer, additionalInfo: '1')]));

      expect(find.text('Wolontariusz'), findsOneWidget);
    });

    testWidgets(
        'displays "Menedżer regionu" role when roleInfo.managerRegions is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget(
          [const RoleEntity(role: Role.regionManager, additionalInfo: '1')]));

      expect(find.text('Menedżer regionu'), findsOneWidget);
      expect(find.text('Region 1'), findsOneWidget);
    });

    testWidgets(
        'displays "Obserwator regionu" role when roleInfo.observerRegions is not empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget([
        const RoleEntity(role: Role.regionRabbitObserver, additionalInfo: '1')
      ]));

      expect(find.text('Obserwator regionu'), findsOneWidget);
      expect(find.text('Region 1'), findsOneWidget);
    });
  });
}
