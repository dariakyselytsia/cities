import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

/// Global service locator.
final GetIt getIt = GetIt.instance;

/// Initializes every injectable dependency (repositories, use cases, and the
/// pre-resolved [Isar] singleton). Call once from `main()` before `runApp`.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
