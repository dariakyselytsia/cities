import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/city_model.dart';
import '../data/models/game_session_model.dart';
import '../data/models/user_model.dart';
import '../data/models/user_stats_model.dart';

/// Provides third-party singletons that injectable cannot construct directly.
@module
abstract class RegisterModule {
  /// Opens the Isar database once at startup and registers it as a singleton.
  ///
  /// `@preResolve` makes injectable await this future during
  /// [configureDependencies], so every repository can synchronously inject the
  /// ready `Isar` instance. Embedded models (e.g. `GameSessionSummaryModel`) are
  /// not passed here — only top-level `@Collection` schemas.
  @preResolve
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [
        CityModelSchema,
        GameSessionModelSchema,
        UserModelSchema,
        UserStatsModelSchema,
      ],
      directory: dir.path,
    );
  }
}
