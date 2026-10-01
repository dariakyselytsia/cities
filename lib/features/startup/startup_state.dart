import 'package:equatable/equatable.dart';

import '../../data/city_loader.dart';
import '../../engine/city_catalog.dart';

/// App startup: the city data is loading, ready, or failed to load.
sealed class StartupState extends Equatable {
  const StartupState();
}

final class StartupLoading extends StartupState {
  const StartupLoading();

  @override
  List<Object?> get props => const [];
}

final class StartupReady extends StartupState {
  const StartupReady(this.catalog);

  final CityCatalog catalog;

  @override
  List<Object?> get props => [catalog];
}

final class StartupFailed extends StartupState {
  const StartupFailed(this.failure);

  final CityLoadFailure failure;

  @override
  List<Object?> get props => [failure];
}
