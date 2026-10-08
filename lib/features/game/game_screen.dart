import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../data/player_store.dart';
import '../../engine/city.dart';
import '../../engine/city_catalog.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';
import '../../engine/letter_rule.dart';
import '../../engine/match.dart';
import '../settings/settings_cubit.dart';
import 'game_cubit.dart';
import 'game_state.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/game_over_view.dart';
import 'widgets/give_up_dialog.dart';
import 'widgets/game_header.dart';
import 'widgets/input_bar.dart';
import 'widgets/out_of_time_view.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/turn_banner.dart';

/// The game route: builds a [GameCubit] for the chosen setup, with city
/// names in the app's language (game_design §2.4) and who starts from
/// Settings, and starts it.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.list, required this.difficulty});

  final CityListKind list;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode == 'uk'
        ? NameLanguage.uk
        : NameLanguage.en;
    final index = context.read<CityCatalog>().index(list, language);
    final firstTurn = context.read<SettingsCubit>().state.firstTurn;
    return BlocProvider(
      create: (context) {
        final random = Random();
        return GameCubit(
          createMatch: (discoveredIds) => Match(
            index: index,
            difficulty: difficulty,
            random: random,
            discoveredIds: discoveredIds,
            firstTurn: firstTurn,
          ),
          store: context.read<PlayerStore>(),
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
  final _chatScroll = ScrollController();

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
    _chatScroll.dispose();
    super.dispose();
  }

  GameCubit get _cubit => context.read<GameCubit>();

  void _submit() => _cubit.submit(_input.text);

  /// Asks before giving up; true when the player confirmed. Either way the
  /// player stays: a give-up shows the results, like any other end.
  Future<bool> _confirmGiveUp() async {
    final chain = switch (_cubit.state) {
      GamePlaying(:final chain) => chain,
      _ => 0,
    };
    final confirmed = await showGiveUpDialog(context, chain: chain);
    if (!confirmed || !mounted) return false;
    _cubit.giveUp();
    return true;
  }

  /// Back mid-game is giving up, so it asks first; then the results show.
  Future<void> _onBlockedPop() async {
    await _confirmGiveUp();
  }

  /// Back to the screen below (Home), or to Home when the game was opened
  /// directly by its link.
  void _leave() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      GoRouter.maybeOf(context)?.go(Routes.home);
    }
  }

  /// What the listener saw last, to react to changes only (the state is
  /// re-emitted on every timer tick).
  int _historyLength = 0;
  Side? _turn;
  bool _paused = false;
  int _rejections = 0;

  void _onState(BuildContext context, GameState state) {
    if (state is! GamePlaying) {
      _turn = null;
      return;
    }
    final history = state.history;
    final grew = history.length > _historyLength;
    // An accepted answer or a hint: the typed text is done with.
    if (grew && history.last.side == Side.player) {
      _input.clear();
      if (!history.last.isHint) HapticFeedback.lightImpact();
    }
    if (state.rejections > _rejections) HapticFeedback.heavyImpact();
    // A new city or the bot's "typing" bubble: bring the newest message
    // into view if the player scrolled up the chat.
    if (grew || (state.turn == Side.bot && _turn != Side.bot)) {
      _scrollToNewest();
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
    _rejections = state.rejections;
  }

  void _scrollToNewest() {
    if (!_chatScroll.hasClients || _chatScroll.offset <= 0) return;
    _chatScroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
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
        // The Out-of-time moment is dark, status bar included.
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: state is OutOfTime
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: state is OutOfTime ? AppColors.ink : null,
            body: SafeArea(
              child: switch (state) {
                GameLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                GamePlaying() => _board(state),
                OutOfTime() => OutOfTimeView(
                  chain: state.result.chain,
                  onSeeResults: _cubit.showResults,
                ),
                GameOver() => _ended(state),
              },
            ),
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
          onBack: _onBlockedPop,
          onGiveUp: _confirmGiveUp,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < _compactBoardBelow;
              final rejection = state.lastRejection;
              return Stack(
                children: [
                  Column(
                    children: [
                      if (!compact)
                        StatPills(chain: state.chain, score: state.score),
                      Expanded(
                        child: _chat(
                          state.history,
                          state.letterMarks,
                          isBotThinking:
                              state.turn == Side.bot && !state.isPaused,
                        ),
                      ),
                      if (rejection != null)
                        RejectionBanner(
                          key: ValueKey(state.rejections),
                          reason: rejection,
                          letters: letters,
                        ),
                      // Compact: the typing bubble already says CityBot
                      // is thinking.
                      if (!compact ||
                          (rejection == null && state.turn == Side.player))
                        TurnBanner(
                          turn: state.turn,
                          letters: letters,
                          compact: compact,
                        ),
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
                    Positioned.fill(
                      child: PauseOverlay(onResume: _cubit.resume),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Below this height (a short phone with the keyboard open) the board
  /// turns compact, so the city to answer stays visible (T21): no chain and
  /// score pills, a slimmer turn banner only on the player's turn, and a
  /// rejection shown in place of it rather than above it.
  static const double _compactBoardBelow = 320;

  Widget _ended(GameOver state) {
    return Column(
      children: [
        GameHeader(
          list: widget.list,
          difficulty: widget.difficulty,
          onBack: _leave,
        ),
        Expanded(
          child: GameOverView(
            state: state,
            language: widget.language,
            onPlayAgain: _cubit.start,
            onHome: _leave,
          ),
        ),
      ],
    );
  }

  /// Newest at the bottom: a reversed list stays scrolled to the latest
  /// city, also when the keyboard opens. Only the newest city has its
  /// letters marked: that's the one to answer. While CityBot thinks, its
  /// "typing" bubble is the newest message.
  Widget _chat(
    List<Turn> history,
    LetterMarks? marks, {
    required bool isBotThinking,
  }) {
    final typing = isBotThinking ? 1 : 0;
    return ListView.builder(
      controller: _chatScroll,
      reverse: true,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      itemCount: history.length + typing,
      itemBuilder: (_, i) {
        if (i < typing) return const ThinkingBubble();
        final n = i - typing;
        return ChatBubble(
          turn: history[history.length - 1 - n],
          language: widget.language,
          marks: n == 0 ? marks : null,
        );
      },
    );
  }
}
