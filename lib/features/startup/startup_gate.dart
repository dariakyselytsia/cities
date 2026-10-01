import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../engine/city_catalog.dart';
import 'load_error_screen.dart';
import 'splash_screen.dart';
import 'startup_cubit.dart';
import 'startup_state.dart';

/// Shows the splash while the city data loads, the error screen if it fails,
/// and otherwise [child] (the app's navigator), with the [CityCatalog]
/// provided above it.
///
/// It sits in `MaterialApp.builder`, so every route can read the catalog
/// with `context.read<CityCatalog>()`.
class StartupGate extends StatelessWidget {
  const StartupGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupCubit, StartupState>(
      builder: (context, state) => switch (state) {
        StartupLoading() => const SplashScreen(),
        StartupFailed() => LoadErrorScreen(
          onRetry: () => context.read<StartupCubit>().load(),
        ),
        StartupReady(:final catalog) => RepositoryProvider<CityCatalog>.value(
          value: catalog,
          child: child,
        ),
      },
    );
  }
}
