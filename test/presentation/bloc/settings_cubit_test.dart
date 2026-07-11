import 'package:flutter_test/flutter_test.dart';

import 'package:cities/domain/domain.dart';
import 'package:cities/presentation/bloc/settings_cubit.dart';
import 'package:cities/presentation/bloc/settings_store.dart';

/// In-memory [SettingsStore] that records the last saved state — stands in for
/// the shared_preferences-backed store so persistence can be asserted without a
/// real platform channel.
class FakeSettingsStore implements SettingsStore {
  SettingsState? initial;
  SettingsState? saved;

  FakeSettingsStore({this.initial});

  @override
  SettingsState load() => initial ?? const SettingsState();

  @override
  Future<void> save(SettingsState state) async => saved = state;
}

void main() {
  group('SettingsCubit', () {
    late SettingsCubit cubit;

    setUp(() => cubit = SettingsCubit());

    test('defaults to both lists on → World mode, sound on', () {
      expect(cubit.state.ukraineList, isTrue);
      expect(cubit.state.worldList, isTrue);
      expect(cubit.state.mode, GameMode.world);
      expect(cubit.state.soundEnabled, isTrue);
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

    test('sound toggle updates state', () {
      cubit.setSoundEnabled(false);
      expect(cubit.state.soundEnabled, isFalse);
    });
  });

  group('SettingsCubit persistence', () {
    test('loads its initial state from the store', () {
      final store = FakeSettingsStore(
        initial: const SettingsState(
          ukraineList: true,
          worldList: false,
          soundEnabled: false,
        ),
      );

      final cubit = SettingsCubit(store: store);

      expect(cubit.state.worldList, isFalse);
      expect(cubit.state.mode, GameMode.ukraine);
      expect(cubit.state.soundEnabled, isFalse);
    });

    test('persists to the store on every change', () {
      final store = FakeSettingsStore();
      final cubit = SettingsCubit(store: store);

      cubit.setSoundEnabled(false);
      expect(store.saved?.soundEnabled, isFalse);

      cubit.toggleWorldList(); // world off, ukraine on
      expect(store.saved?.worldList, isFalse);
      expect(store.saved?.soundEnabled, isFalse); // prior change retained
    });

    test('a no-op toggle (would leave both lists off) is not persisted', () {
      final store = FakeSettingsStore(
        initial: const SettingsState(ukraineList: false, worldList: true),
      );
      final cubit = SettingsCubit(store: store);

      cubit.toggleWorldList(); // ignored: would leave both unchecked
      expect(store.saved, isNull);
      expect(cubit.state.worldList, isTrue);
    });
  });
}
