import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/di.dart';

import 'presentation/pages/game_session_screen.dart';
import 'presentation/bloc/game_session_bloc.dart';
import 'domain/usecases/start_game_session_usecase.dart';
import 'domain/usecases/validate_city_answer_usecase.dart';
import 'domain/usecases/use_hint_usecase.dart';
import 'domain/usecases/revive_session_usecase.dart';
import 'domain/usecases/end_game_session_usecase.dart';
import 'domain/entities/game_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    BlocProvider(
      create: (_) => GameSessionBloc(
        startGameSessionUseCase: getIt<StartGameSessionUseCase>(),
        validateCityAnswerUseCase: getIt<ValidateCityAnswerUseCase>(),
        useHintUseCase: getIt<UseHintUseCase>(),
        reviveSessionUseCase: getIt<ReviveSessionUseCase>(),
        endGameSessionUseCase: getIt<EndGameSessionUseCase>(),
      ),
      child: const MaterialApp(home: GameSessionScreen()),
    ),
  );
}
