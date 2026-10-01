import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/city_loader.dart';
import 'startup_state.dart';

/// Loads the city data once at launch, and again on "Try again".
class StartupCubit extends Cubit<StartupState> {
  StartupCubit(this._loader) : super(const StartupLoading());

  final CityLoader _loader;

  /// Loads the catalog. Safe to call again after a failure.
  Future<void> load() async {
    emit(const StartupLoading());
    final result = await _loader.load();
    if (isClosed) return;
    emit(switch (result) {
      CitiesLoaded(:final catalog) => StartupReady(catalog),
      CitiesLoadFailed(:final failure) => StartupFailed(failure),
    });
  }
}
