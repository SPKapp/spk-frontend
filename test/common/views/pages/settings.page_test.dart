import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/bloc/theme.cubit.dart';
import 'package:spk_app_frontend/common/views/pages/settings.page.dart';

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  group(SettingsPage, () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = MockThemeCubit();

      when(() => themeCubit.state).thenReturn(ThemeMode.system);
    });

    Widget buildWidget() {
      return MaterialApp(
        home: BlocProvider.value(
          value: themeCubit,
          child: SettingsPage(drawer: Container()),
        ),
      );
    }

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Ustawienia'), findsOneWidget);
      expect(find.text('Motyw'), findsOneWidget);
      expect(find.text('Systemowy'), findsOneWidget);
      expect(find.text('Jasny'), findsOneWidget);
      expect(find.text('Ciemny'), findsOneWidget);
    });

    testWidgets('updates theme correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byKey(const Key('darkButton')));
      await tester.pump();

      verify(() => themeCubit.updateTheme(ThemeMode.dark)).called(1);

      await tester.tap(find.byKey(const Key('lightButton')));
      await tester.pump();

      verify(() => themeCubit.updateTheme(ThemeMode.light)).called(1);
    });
  });
}
