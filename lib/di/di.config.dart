// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cities/data/repositories/city_repository_impl.dart' as _i840;
import 'package:cities/data/repositories/game_session_repository_impl.dart'
    as _i303;
import 'package:cities/data/repositories/user_repository_impl.dart' as _i616;
import 'package:cities/data/repositories/user_stats_repository_impl.dart'
    as _i733;
import 'package:cities/di/register_module.dart' as _i827;
import 'package:cities/domain/repositories/city_repository.dart' as _i385;
import 'package:cities/domain/repositories/game_session_repository.dart'
    as _i255;
import 'package:cities/domain/repositories/user_repository.dart' as _i408;
import 'package:cities/domain/repositories/user_stats_repository.dart' as _i562;
import 'package:cities/domain/usecases/end_game_session_usecase.dart' as _i163;
import 'package:cities/domain/usecases/end_game_session_usecase_impl.dart'
    as _i388;
import 'package:cities/domain/usecases/revive_session_usecase.dart' as _i399;
import 'package:cities/domain/usecases/revive_session_usecase_impl.dart'
    as _i193;
import 'package:cities/domain/usecases/start_game_session_usecase.dart'
    as _i230;
import 'package:cities/domain/usecases/start_game_session_usecase_impl.dart'
    as _i681;
import 'package:cities/domain/usecases/use_hint_usecase.dart' as _i196;
import 'package:cities/domain/usecases/use_hint_usecase_impl.dart' as _i164;
import 'package:cities/domain/usecases/validate_city_answer_usecase.dart'
    as _i991;
import 'package:cities/domain/usecases/validate_city_answer_usecase_impl.dart'
    as _i549;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:isar_community/isar.dart' as _i214;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i214.Isar>(
      () => registerModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i255.GameSessionRepository>(
      () => _i303.GameSessionRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i562.UserStatsRepository>(
      () => _i733.UserStatsRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i385.CityRepository>(
      () => _i840.CityRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i408.UserRepository>(
      () => _i616.UserRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i991.ValidateCityAnswerUseCase>(
      () => _i549.ValidateCityAnswerUseCaseImpl(gh<_i385.CityRepository>()),
    );
    gh.lazySingleton<_i163.EndGameSessionUseCase>(
      () => _i388.EndGameSessionUseCaseImpl(gh<_i255.GameSessionRepository>()),
    );
    gh.lazySingleton<_i196.UseHintUseCase>(
      () => _i164.UseHintUseCaseImpl(gh<_i385.CityRepository>()),
    );
    gh.lazySingleton<_i399.ReviveSessionUseCase>(
      () => _i193.ReviveSessionUseCaseImpl(gh<_i255.GameSessionRepository>()),
    );
    gh.lazySingleton<_i230.StartGameSessionUseCase>(
      () => _i681.StartGameSessionUseCaseImpl(
        gh<_i385.CityRepository>(),
        gh<_i255.GameSessionRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i827.RegisterModule {}
