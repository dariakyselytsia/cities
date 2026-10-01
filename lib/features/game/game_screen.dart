import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../engine/city.dart';
import '../../engine/city_catalog.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';
import '../../engine/letter_rule.dart';
import '../../engine/match.dart';
import 'game_cubit.dart';
import 'game_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/game_over_view.dart';
import 'widgets/game_header.dart';
import 'widgets/input_bar.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/turn_banner.dart';

/// The game route: builds a [GameCubit] for the chosen setup, with city
/// names in the app's language (game_design §2.4), and starts it.
class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.list,
    required this.difficulty,
    this.firstTurn = Side.bot,
  });

  final CityListKind list;
  final Difficulty difficulty;
  final Side firstTurn;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode == 'uk'
        ? NameLanguage.uk
        : NameLanguage.en;
    final index = context.read<CityCatalog>().index(list, language);
    return BlocProvider(
      create: (_) {
        final random = Random();
        return GameCubit(
          createMatch: (discoveredIds) => Match(
            index: index,
            difficulty: difficulty,
            random: random,
            discoveredIds: discoveredIds,
            firstTurn: firstTurn,
          ),
          random: random,
        )..start();
      },
      child: GameView(list: list, difficulty: difficulty, language: language),
    );
  }
}

/// The chat-style game board (game_design §3.3). It renders [GameCubit]'s
/// state and forwards the player's input; the rules stay in the cubit.
class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.list,
    required this.difficulty,
    required this.language,
  });

  final CityListKind list;
  final Difficulty difficulty;

  /// The language city names are shown in.
  final NameLanguage language;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  /// Pauses the game when the app leaves the foreground: a phone call, a
  /// notification, the app switcher. "Inactive" comes first on every
  /// platform, and it also hides the chat from the app switcher's preview.
  /// Resuming is the player's tap, not automatic.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onInactive: () => _cubit.pause());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  GameCubit get _cubit => context.read<GameCubit>();

  void _submit() => _cubit.submit(_input.text);

  /// Asks before giving up; true when the player confirmed.
  Future<bool> _confirmGiveUp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('game.give_up_title'.tr()),
        content: Text('game.give_up_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('game.keep_playing'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('game.give_up'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return false;
    _cubit.giveUp();
    return true;
  }

  /// Leaving mid-game is giving up, so it asks first.
  Future<void> _onBlockedPop() async {
    if (await _confirmGiveUp() && mounted) Navigator.pop(context);
  }

  /// What the listener saw last, to react to changes only (the state is
  /// re-emitted on every timer tick).
  int _historyLength = 0;
  Side? _turn;
  bool _paused = false;

  void _onState(BuildContext context, GameState state) {
    if (state is! GamePlaying) {
      _turn = null;
      return;
    }
    final history = state.history;
    // An accepted answer or a hint: the typed text is done with.
    if (history.length > _historyLength && history.last.side == Side.player) {
      _input.clear();
    }
    // Focus once per player turn (and again after a pause), so a keyboard
    // the player closed stays closed until their next turn.
    if (state.isPaused) {
      _focus.unfocus();
    } else if (state.turn == Side.player && (_turn != Side.player || _paused)) {
      _focus.requestFocus();
    }
    _historyLength = history.length;
    _turn = state.turn;
    _paused = state.isPaused;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: _onState,
      builder: (context, state) => PopScope(
        canPop: state is! GamePlaying,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _onBlockedPop();
        },
        child: Scaffold(
          body: SafeArea(
            child: switch (state) {
              GameLoading() => const Center(child: CircularProgressIndicator()),
              GamePlaying() => _board(state),
              GameOver() => _ended(state),
            },
          ),
        ),
      ),
    );
  }

  Widget _board(GamePlaying state) {
    final isPlayerTurn = state.turn == Side.player && !state.isPaused;
    final letters = [?state.requiredLetter, ...state.extraLetters];
    return Column(
      children: [
        GameHeader(
          list: widget.list,
          difficulty: widget.difficulty,
          secondsLeft: state.secondsLeft,
          isCounting: isPlayerTurn,
          onBack: () => Navigator.maybePop(context),
          onGiveUp: _confirmGiveUp,
        ),
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  StatPills(chain: state.chain, score: state.score),
                  Expanded(child: _chat(state.history, state.letterMarks)),
                  if (state.lastRejection case final reason?)
                    RejectionBanner(reason: reason, letters: letters),
                  TurnBanner(turn: state.turn, letters: letters),
                  InputBar(
                    controller: _input,
                    focusNode: _focus,
                    canSend: isPlayerTurn,
                    hintsLeft: state.hintsLeft,
                    onSubmit: _submit,
                    onHint: _cubit.hint,
                  ),
                ],
              ),
              if (state.isPaused)
                Positioned.fill(child: PauseOverlay(onResume: _cubit.resume)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ended(GameOver state) {
    return Column(
      children: [
        GameHeader(
          list: widget.list,
          difficulty: widget.difficulty,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: GameOverView(
            state: state,
            language: widget.language,
            onPlayAgain: _cubit.start,
            onHome: () => Navigator.maybePop(context),
          ),
        ),
      ],
    );
  }

  /// Newest at the bottom: a reversed list stays scrolled to the latest
  /// city without a scroll controller. Only the newest city has its letters
  /// marked: that's the one to answer.
  Widget _chat(List<Turn> history, LetterMarks? marks) => ListView.builder(
    reverse: true,
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
    itemCount: history.length,
    itemBuilder: (_, i) => ChatBubble(
      turn: history[history.length - 1 - i],
      language: widget.language,
      marks: i == 0 ? marks : null,
    ),
  );
}
