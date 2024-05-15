import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spk_app_frontend/common/bloc/theme.cubit.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group(ThemeCubit, () {
    late ThemeCubit themeCubit;
    late Storage storage;

    setUp(() {
      storage = MockStorage();

      when(
        () => storage.write(any(), any<dynamic>()),
      ).thenAnswer((_) async {});
      HydratedBloc.storage = storage;

      themeCubit = ThemeCubit();
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is ThemeMode.system', () {
      expect(themeCubit.state, equals(ThemeMode.system));
    });

    test('initial state from storage is ThemeMode.dark', () {
      when(() => storage.read('ThemeCubit'))
          .thenReturn({'themeMode': ThemeMode.dark.index});

      themeCubit = ThemeCubit();

      expect(themeCubit.state, equals(ThemeMode.dark));
    });

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.light] when updateTheme is called with ThemeMode.light',
      build: () => themeCubit,
      act: (cubit) => cubit.updateTheme(ThemeMode.light),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.dark] when updateTheme is called with ThemeMode.dark',
      build: () => themeCubit,
      act: (cubit) => cubit.updateTheme(ThemeMode.dark),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.system] when updateTheme is called with ThemeMode.system',
      build: () => themeCubit,
      act: (cubit) => cubit.updateTheme(ThemeMode.system),
      expect: () => [ThemeMode.system],
    );
  });
}
