import 'package:flutter_test/flutter_test.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/presentation/bloc/settings_cubit.dart';

void main() {
  group('SettingsCubit', () {
    late SettingsCubit cubit;

    setUp(() => cubit = SettingsCubit());

    test('defaults to both lists on → World mode, timed, sound on', () {
      expect(cubit.state.ukraineList, isTrue);
      expect(cubit.state.worldList, isTrue);
      expect(cubit.state.mode, GameMode.world);
      expect(cubit.state.timerEnabled, isTrue);
    });

    test('Ukraine-only selection resolves to Ukraine mode', () {
      cubit.toggleWorldList(); // world off, ukraine on
      expect(cubit.state.worldList, isFalse);
      expect(cubit.state.mode, GameMode.ukraine);
    });

    test('World checked (with or without Ukraine) resolves to World mode', () {
      cubit.toggleUkraineList(); // ukraine off, world on
      expect(cubit.state.mode, GameMode.world);
    });

    test('never leaves both lists unchecked', () {
      cubit.toggleUkraineList(); // ukraine off (world still on)
      cubit.toggleWorldList(); // would leave both off → ignored
      expect(cubit.state.worldList, isTrue);
      expect(cubit.state.ukraineList, isFalse);
    });

    test('timer and sound toggles update state', () {
      cubit.setTimerEnabled(false);
      cubit.setSoundEnabled(false);
      expect(cubit.state.timerEnabled, isFalse);
      expect(cubit.state.soundEnabled, isFalse);
    });
  });
}
