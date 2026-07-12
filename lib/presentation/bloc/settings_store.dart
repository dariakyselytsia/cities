import 'package:shared_preferences/shared_preferences.dart';

import 'settings_cubit.dart';

/// Persistence boundary for [SettingsState]. Kept as an interface so
/// [SettingsCubit] depends on the abstraction, not on `shared_preferences`
/// directly — this keeps the presentation logic testable with a fake store and
/// lets the storage backend swap (prefs → Isar) without touching the cubit.
abstract class SettingsStore {
  /// Returns the persisted settings, falling back to [SettingsState] defaults
  /// for any value that was never written.
  SettingsState load();

  /// Persists the given [state]. Fire-and-forget from the cubit's perspective.
  Future<void> save(SettingsState state);
}

/// [SharedPreferences]-backed [SettingsStore]. Stores each preference as a bool
/// under a stable key; a missing key means "use the default", so first launch
/// and forward-compatible new settings both degrade gracefully.
class SharedPrefsSettingsStore implements SettingsStore {
  final SharedPreferences _prefs;

  const SharedPrefsSettingsStore(this._prefs);

  static const String _kUkraineList = 'settings.ukraineList';
  static const String _kWorldList = 'settings.worldList';
  static const String _kSoundEnabled = 'settings.soundEnabled';

  @override
  SettingsState load() {
    const defaults = SettingsState();
    return SettingsState(
      ukraineList: _prefs.getBool(_kUkraineList) ?? defaults.ukraineList,
      worldList: _prefs.getBool(_kWorldList) ?? defaults.worldList,
      soundEnabled: _prefs.getBool(_kSoundEnabled) ?? defaults.soundEnabled,
    );
  }

  @override
  Future<void> save(SettingsState state) async {
    await _prefs.setBool(_kUkraineList, state.ukraineList);
    await _prefs.setBool(_kWorldList, state.worldList);
    await _prefs.setBool(_kSoundEnabled, state.soundEnabled);
  }
}
