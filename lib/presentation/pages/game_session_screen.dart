import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cities/domain/domain.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../bloc/game_session_bloc.dart';
import '../bloc/settings_cubit.dart';

/// Leaves the game back to Home. Pops when the game was pushed (so Home's
/// `await push(...)` resolves and its stats card refreshes with the just-played
/// session); falls back to a direct navigation if there's nothing to pop (e.g.
/// deep-linked straight into a game).
void _leaveToHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// Game screen — a chat-style history of named cities with a fixed input,
/// timer, and score (game_design.md §3). Styled to the shared design.
class GameSessionScreen extends StatefulWidget {
  const GameSessionScreen({super.key});

  @override
  State<GameSessionScreen> createState() => _GameSessionScreenState();
}

class _GameSessionScreenState extends State<GameSessionScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// Guards the one-time auto-start. The round is kicked off from
  /// [didChangeDependencies] (not [initState]) because [_start] reads the app
  /// locale via `context.locale`, an inherited-widget lookup that isn't allowed
  /// during initState.
  bool _started = false;

  /// The last hint we auto-played, so a fresh hint suggestion is played exactly
  /// once (the state carrying it is re-emitted on every timer tick).
  String? _lastAutoHint;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _start();
    }
  }

  /// Starts a round using the current Settings (city-list → mode) and the app
  /// locale (→ display language, independent of mode). The countdown always runs
  /// (game_design.md §2 — the timer is a fixed loss condition).
  void _start() {
    final settings = context.read<SettingsCubit>().state;
    final language = AppLanguage.fromCode(context.locale.languageCode);
    context.read<GameSessionBloc>().add(
      StartSession(userId: 'local', mode: settings.mode, language: language),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<GameSessionBloc>().add(ValidateAnswer(cityName: text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<GameSessionBloc, GameSessionState>(
          listener: (context, state) {
            if (state is! GameSessionInProgress) return;
            // A hint isn't shown to the player — it's typed into the input and
            // sent on their behalf. Play each fresh suggestion once.
            final hint = state.hint;
            if (hint != null && hint != _lastAutoHint) {
              _lastAutoHint = hint;
              _controller.text = hint;
              _submit();
            } else if (hint == null) {
              _lastAutoHint = null;
            }
            if (_scrollController.hasClients) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
          },
          builder: (context, state) {
            if (state is GameSessionInProgress) {
              return _buildBoard(context, state);
            }
            if (state is GameSessionEnded) {
              return _GameOverView(score: state.score, onPlayAgain: _restart);
            }
            if (state is GameSessionFailure) {
              return _ErrorView(message: state.message, onRetry: _restart);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _restart() => _start();

  Widget _buildBoard(BuildContext context, GameSessionInProgress state) {
    // Streak = number of cities the player has chained (their own messages).
    final streak = state.history.where((m) => !m.isBot).length;
    return Column(
      children: [
        _GameHeader(
          seconds: state.timerSeconds,
          // Lifetime best for this mode, from persisted UserStats.
          highscore: state.highScore,
          onSurrender: () => context.read<GameSessionBloc>().add(
            EndSession(sessionId: state.session.id),
          ),
        ),
        _StatPills(streak: streak, score: state.session.score),
        Expanded(
          child: state.history.isEmpty
              ? const SizedBox.expand()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: state.history.length,
                  itemBuilder: (_, i) => _CityBubble(message: state.history[i]),
                ),
        ),
        if (_rejectionMessage(state.lastOutcome) != null)
          _FeedbackBanner(message: _rejectionMessage(state.lastOutcome)!),
        _TurnBanner(requiredLetter: state.requiredLetter),
        _InputBar(controller: _controller, onSubmit: _submit, onHint: _hint),
      ],
    );
  }

  void _hint() => context.read<GameSessionBloc>().add(const UseHint());

  /// A short, localized message for a rejected answer, or null when the last
  /// outcome was accepted / absent.
  String? _rejectionMessage(ValidationOutcome? outcome) {
    if (outcome == null || outcome.isAccepted) return null;
    switch (outcome.status) {
      case AnswerStatus.notFound:
        return 'game.not_found'.tr();
      case AnswerStatus.wrongLetter:
        return 'game.wrong_letter'.tr();
      case AnswerStatus.alreadyUsed:
        return 'game.already_used'.tr();
      case AnswerStatus.accepted:
        return null;
    }
  }
}

/// Top bar: back button, CityBot identity, surrender, and a timer badge.
/// (Score and streak live in the pills row below.)
class _GameHeader extends StatelessWidget {
  final int seconds;
  final int highscore;
  final VoidCallback onSurrender;
  const _GameHeader({
    required this.seconds,
    required this.highscore,
    required this.onSurrender,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => _leaveToHome(context),
          ),
          // CityBot identity: teal avatar + name and live score.
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'game.citybot'.tr(),
                style: baloo(size: 17, weight: FontWeight.w700),
              ),
              // Lifetime best for this mode (persisted UserStats).
              Text(
                '${'game.highscore'.tr()} $highscore',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onSurrender,
            icon: const Icon(Icons.flag_outlined),
            color: AppColors.inkSoft,
            tooltip: 'game.surrender'.tr(),
          ),
          const SizedBox(width: 2),
          _TimerBadge(seconds: seconds),
        ],
      ),
    );
  }
}

/// The live streak/score chips, shown as rounded pills under the header.
class _StatPills extends StatelessWidget {
  final int streak;
  final int score;
  const _StatPills({required this.streak, required this.score});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Pill(
            label: 'game.streak'.tr(),
            value: '$streak',
            background: AppColors.purple.withValues(alpha: 0.14),
            foreground: AppColors.purple,
          ),
          const SizedBox(width: 10),
          _Pill(
            label: 'game.score'.tr(),
            value: '$score',
            background: AppColors.yellow,
            foreground: AppColors.ink,
          ),
        ],
      ),
    );
  }
}

/// A single rounded "label value" chip.
class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color foreground;
  const _Pill({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: foreground.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// The turn cue: "Your turn → start with «X»", or an opening prompt when any
/// city is allowed.
class _TurnBanner extends StatelessWidget {
  final String? requiredLetter;
  const _TurnBanner({required this.requiredLetter});

  @override
  Widget build(BuildContext context) {
    // requiredLetter is set only on the player's turn (cleared while CityBot
    // moves), so a null value means it's CityBot's turn — no letter cue then.
    final isPlayerTurn = requiredLetter != null;
    final text = isPlayerTurn
        ? '${'game.your_turn'.tr()} → ${'game.start_with'.tr()} «$requiredLetter»'
        : 'game.bot_turn'.tr();
    final color = isPlayerTurn ? AppColors.coral : AppColors.inkSoft;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPlayerTurn
                ? Icons.play_arrow_rounded
                : Icons.smart_toy_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final int seconds;
  const _TimerBadge({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final low = seconds <= 5;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: low ? AppColors.coral : AppColors.card,
        border: Border.all(color: AppColors.coral, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$seconds',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: low ? Colors.white : AppColors.ink,
        ),
      ),
    );
  }
}

/// A player city, shown as a right-aligned coral chat bubble.
/// A chat bubble for one named city: right-aligned coral for the player,
/// left-aligned card for CityBot.
class _CityBubble extends StatelessWidget {
  final ChatMessage message;
  const _CityBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isBot ? AppColors.card : AppColors.coral,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isBot ? 4 : 18),
            bottomRight: Radius.circular(isBot ? 18 : 4),
          ),
        ),
        child: _firstLetterHighlighted(
          message.text,
          baseColor: isBot ? AppColors.ink : Colors.white,
          // The chain letter — accented so the player can read the flow.
          accentColor: isBot ? AppColors.coral : AppColors.purple,
        ),
      ),
    );
  }

  /// Renders [text] with its first character in [accentColor] and the rest in
  /// [baseColor], so the starting letter of each city stands out.
  Widget _firstLetterHighlighted(
    String text, {
    required Color baseColor,
    required Color accentColor,
  }) {
    const style = TextStyle(fontWeight: FontWeight.w600, fontSize: 15);
    if (text.isEmpty) {
      return Text(text, style: style.copyWith(color: baseColor));
    }
    return Text.rich(
      TextSpan(
        style: style.copyWith(color: baseColor),
        children: [
          TextSpan(
            text: text.characters.first,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: text.characters.skip(1).toString()),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final String message;
  const _FeedbackBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.rejectionBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.coral),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.rejectionInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed bottom input: hint button, text field, send button.
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onHint;
  const _InputBar({
    required this.controller,
    required this.onSubmit,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onHint,
            icon: const Icon(Icons.lightbulb_outline_rounded),
            color: AppColors.purple,
            tooltip: 'game.hint'.tr(),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(hintText: 'game.enter_city'.tr()),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverView extends StatelessWidget {
  final int score;
  final VoidCallback onPlayAgain;
  const _GameOverView({required this.score, required this.onPlayAgain});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag_rounded, size: 72, color: AppColors.coral),
            const SizedBox(height: 16),
            Text('game.game_over'.tr(), style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              '${'game.final_score'.tr()}: $score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onPlayAgain,
              child: Text('game.play_again'.tr()),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _leaveToHome(context),
              child: Text('game.home'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.inkSoft),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: Text('game.play_again'.tr())),
          ],
        ),
      ),
    );
  }
}
