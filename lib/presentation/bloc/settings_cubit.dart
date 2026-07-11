import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cities/domain/domain.dart';

/// App-wide gameplay preferences (not the app locale — that's easy_localization).
///
/// NOTE: in-memory only for now; persisting across launches (shared_preferences
/// or Isar via the User settings use cases) is a later step.
class SettingsState extends Equatable {
  /// City lists to draw matches from. The domain models a single [GameMode], so
  /// for MVP: Ukraine-only → [GameMode.ukraine]; otherwise (World, or both) →
  /// [GameMode.world]. A true merged "both" pool is a future domain change.
  final bool ukraineList;
  final bool worldList;

  /// Whether the countdown timer runs (off = untimed practice).
  final bool timerEnabled;

  /// Sound effects (not consumed yet — no audio system wired).
  final bool soundEnabled;

  const SettingsState({
    this.ukraineList = true,
    this.worldList = true,
    this.timerEnabled = true,
    this.soundEnabled = true,
  });

  /// The effective game mode a new round should start in.
  GameMode get mode =>
      (ukraineList && !worldList) ? GameMode.ukraine : GameMode.world;

  SettingsState copyWith({
    bool? ukraineList,
    bool? worldList,
    bool? timerEnabled,
    bool? soundEnabled,
  }) {
    return SettingsState(
      ukraineList: ukraineList ?? this.ukraineList,
      worldList: worldList ?? this.worldList,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  @override
  List<Object?> get props => [ukraineList, worldList, timerEnabled, soundEnabled];
}

/// Holds and mutates [SettingsState]. Screens read it via `context.watch` and
/// mutate via these methods.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  /// Toggles the Ukraine list, keeping at least one list selected.
  void toggleUkraineList() {
    final next = !state.ukraineList;
    if (!next && !state.worldList) return; // never leave both unchecked
    emit(state.copyWith(ukraineList: next));
  }

  /// Toggles the World list, keeping at least one list selected.
  void toggleWorldList() {
    final next = !state.worldList;
    if (!next && !state.ukraineList) return; // never leave both unchecked
    emit(state.copyWith(worldList: next));
  }

  void setTimerEnabled(bool value) =>
      emit(state.copyWith(timerEnabled: value));

  void setSoundEnabled(bool value) =>
      emit(state.copyWith(soundEnabled: value));
}
