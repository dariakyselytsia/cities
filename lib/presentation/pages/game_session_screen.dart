import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cities/domain/domain.dart';
import '../bloc/game_session_bloc.dart';

/// Main game session screen, maps BLoC state to stateless widgets.
class GameSessionScreen extends StatelessWidget {
  const GameSessionScreen({super.key});

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
            // Single board state: score, timer, and the last verdict/hint inline.
            return GameBoardWidget(state: state);
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
  const GameSessionStartWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Example: hardcoded userId/mode for demo; replace with real input as needed
          context.read<GameSessionBloc>().add(
            StartSession(userId: 'user1', mode: GameMode.ukraine),
          );
        },
        child: const Text('Start Game'),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class GameBoardWidget extends StatefulWidget {
  final GameSessionInProgress state;
  const GameBoardWidget({super.key, required this.state});

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

  /// Short inline feedback for the last answer verdict.
  String _feedbackFor(ValidationOutcome outcome) {
    switch (outcome.status) {
      case AnswerStatus.accepted:
        return 'Correct! +${outcome.points}';
      case AnswerStatus.notFound:
        return 'No such city';
      case AnswerStatus.wrongLetter:
        return 'Wrong starting letter';
      case AnswerStatus.alreadyUsed:
        return 'Already used this round';
    }
  }

  @override
  Widget build(BuildContext context) {
    final GameSession session = widget.state.session;
    final ValidationOutcome? outcome = widget.state.lastOutcome;
    final String? hint = widget.state.hint;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Score: ${session.score}   •   ${widget.state.timerSeconds} s'),
          if (outcome != null) ...[
            const SizedBox(height: 8),
            Text(_feedbackFor(outcome)),
          ],
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text('Hint: $hint'),
          ],
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
                  context.read<GameSessionBloc>().add(const UseHint());
                },
                child: const Text('Hint'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<GameSessionBloc>().add(
                    EndSession(sessionId: session.id),
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

class SessionRevivedWidget extends StatelessWidget {
  const SessionRevivedWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Session Revived!'));
}

class EndSessionWidget extends StatelessWidget {
  const EndSessionWidget({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Session Ended'));
}

class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorWidget({super.key, required this.message, required this.onRetry});
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
              StartSession(userId: 'user1', mode: GameMode.ukraine),
            );
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
