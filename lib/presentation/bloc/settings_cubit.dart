import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cities/domain/domain.dart';

import 'settings_store.dart';

/// App-wide gameplay preferences (not the app locale — that's easy_localization).
class SettingsState extends Equatable {
  /// City lists to draw matches from. The domain models a single [GameMode], so
  /// for MVP: Ukraine-only → [GameMode.ukraine]; otherwise (World, or both) →
  /// [GameMode.world]. A true merged "both" pool is a future domain change.
  final bool ukraineList;
  final bool worldList;

  /// Sound effects (not consumed yet — no audio system wired).
  final bool soundEnabled;

  const SettingsState({
    this.ukraineList = true,
    this.worldList = true,
    this.soundEnabled = true,
  });

  /// The effective game mode a new round should start in.
  GameMode get mode =>
      (ukraineList && !worldList) ? GameMode.ukraine : GameMode.world;

  SettingsState copyWith({
    bool? ukraineList,
    bool? worldList,
    bool? soundEnabled,
  }) {
    return SettingsState(
      ukraineList: ukraineList ?? this.ukraineList,
      worldList: worldList ?? this.worldList,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [ukraineList, worldList, soundEnabled];
}

/// Holds and mutates [SettingsState]. Screens read it via `context.watch` and
/// mutate via these methods.
///
/// When a [SettingsStore] is supplied, the initial state is loaded from it and
/// every change is persisted, so choices survive app restarts. Without a store
/// (e.g. in unit tests) it behaves as an in-memory holder starting from
/// [SettingsState] defaults.
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsStore? _store;

  SettingsCubit({SettingsStore? store})
    : _store = store,
      super(store?.load() ?? const SettingsState());

  /// Emits [next] and persists it (if a store is configured). Persistence is
  /// fire-and-forget: the UI updates immediately and the write completes in the
  /// background.
  void _apply(SettingsState next) {
    emit(next);
    _store?.save(next);
  }

  /// Toggles the Ukraine list, keeping at least one list selected.
  void toggleUkraineList() {
    final next = !state.ukraineList;
    if (!next && !state.worldList) return; // never leave both unchecked
    _apply(state.copyWith(ukraineList: next));
  }

  /// Toggles the World list, keeping at least one list selected.
  void toggleWorldList() {
    final next = !state.worldList;
    if (!next && !state.ukraineList) return; // never leave both unchecked
    _apply(state.copyWith(worldList: next));
  }

  void setSoundEnabled(bool value) =>
      _apply(state.copyWith(soundEnabled: value));
}
