import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_session_bloc.dart';

/// Main game session screen, maps BLoC state to stateless widgets.
class GameSessionScreen extends StatelessWidget {
  const GameSessionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameSessionBloc, GameSessionState>(
        builder: (context, state) {
          if (state is GameSessionInitial) {
            return const GameSessionStartWidget();
          } else if (state is GameSessionLoading) {
            return const LoadingWidget();
          } else if (state is GameSessionInProgress) {
            return GameBoardWidget(
              session: state.session,
              timer: state.timerSeconds,
            );
          } else if (state is AnswerValidated) {
            return AnswerFeedbackWidget(isCorrect: state.isCorrect);
          } else if (state is HintUsed) {
            return HintWidget(suggestedCity: state.suggestedCity);
          } else if (state is SessionRevived) {
            return const SessionRevivedWidget();
          } else if (state is GameSessionEnded) {
            return const EndSessionWidget();
          } else if (state is GameSessionFailure) {
            return ErrorWidget(
              message: state.message,
              onRetry: () {
                // TODO: Implement retry logic
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

/// Placeholder stateless widgets for each state.
class GameSessionStartWidget extends StatelessWidget {
  const GameSessionStartWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Example: hardcoded userId/mode for demo; replace with real input as needed
          context.read<GameSessionBloc>().add(
            StartSession(userId: 'user1', mode: 'UA'),
          );
        },
        child: const Text('Start Game'),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator());
}

class GameBoardWidget extends StatefulWidget {
  final dynamic session;
  final int timer;
  const GameBoardWidget({Key? key, required this.session, required this.timer})
    : super(key: key);

  @override
  State<GameBoardWidget> createState() => _GameBoardWidgetState();
}

class _GameBoardWidgetState extends State<GameBoardWidget> {
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Score: ${widget.session.score}   •   ${widget.timer} s'),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(labelText: 'Enter city name'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<GameSessionBloc>().add(
                    ValidateAnswer(cityName: _answerController.text),
                  );
                  _answerController.clear();
                },
                child: const Text('Submit'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<GameSessionBloc>().add(UseHint());
                },
                child: const Text('Hint'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<GameSessionBloc>().add(
                    EndSession(sessionId: widget.session.id),
                  );
                },
                child: const Text('End'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnswerFeedbackWidget extends StatelessWidget {
  final bool isCorrect;
  const AnswerFeedbackWidget({Key? key, required this.isCorrect})
    : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text(isCorrect ? 'Correct!' : 'Wrong!'));
}

class HintWidget extends StatelessWidget {
  final String? suggestedCity;
  const HintWidget({Key? key, this.suggestedCity}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Hint: ${suggestedCity ?? "-"}'));
}

class SessionRevivedWidget extends StatelessWidget {
  const SessionRevivedWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Center(child: Text('Session Revived!'));
}

class EndSessionWidget extends StatelessWidget {
  const EndSessionWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Center(child: Text('Session Ended'));
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorWidget({Key? key, required this.message, required this.onRetry})
    : super(key: key);
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $message'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // For demo, just restart session; in real app, retry last failed action
            context.read<GameSessionBloc>().add(
              StartSession(userId: 'user1', mode: 'UA'),
            );
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
