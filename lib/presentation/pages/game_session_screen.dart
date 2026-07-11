import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:cities/domain/domain.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../bloc/game_session_bloc.dart';
import '../bloc/settings_cubit.dart';

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
            if (state is GameSessionInProgress &&
                _scrollController.hasClients) {
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
    return Column(
      children: [
        _GameHeader(
          score: state.session.score,
          seconds: state.timerSeconds,
          onSurrender: () => context.read<GameSessionBloc>().add(
            EndSession(sessionId: state.session.id),
          ),
        ),
        _TurnBanner(requiredLetter: state.requiredLetter),
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
        if (state.hint != null) _HintChip(city: state.hint!),
        if (_rejectionMessage(state.lastOutcome) != null)
          _FeedbackBanner(message: _rejectionMessage(state.lastOutcome)!),
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

/// Top bar: back button, score, surrender, and a circular timer badge.
class _GameHeader extends StatelessWidget {
  final int score;
  final int seconds;
  final VoidCallback onSurrender;
  const _GameHeader({
    required this.score,
    required this.seconds,
    required this.onSurrender,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.go(Routes.home),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${'game.score'.tr()}  $score',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSurrender,
            child: Text(
              'game.surrender'.tr(),
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ),
          const SizedBox(width: 4),
          _TimerBadge(seconds: seconds),
        ],
      ),
    );
  }
}

/// The turn cue: "Your turn — start with «X»", or an opening prompt when any
/// city is allowed.
class _TurnBanner extends StatelessWidget {
  final String? requiredLetter;
  const _TurnBanner({required this.requiredLetter});

  @override
  Widget build(BuildContext context) {
    final text = requiredLetter == null
        ? 'game.opening'.tr()
        : '${'game.your_turn'.tr()} — ${'game.start_with'.tr()} «$requiredLetter»';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bolt_rounded, size: 18, color: AppColors.ink),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
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
        child: Text(
          message.text,
          style: TextStyle(
            color: isBot ? AppColors.ink : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _HintChip extends StatelessWidget {
  final String city;
  const _HintChip({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.ink),
          const SizedBox(width: 8),
          Text(
            '${'game.hint'.tr()}: $city',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
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
        color: const Color(0xFFFFE1DC),
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
                color: Color(0xFFA1341C),
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
              onPressed: () => context.go(Routes.home),
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
