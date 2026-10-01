import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../engine/match.dart';

/// The allowed letters for a message: «К», or «К» або «Е», or
/// «Н», «Е» або «Ц».
String quoteLetters(List<String> letters) {
  final quoted = [for (final l in letters) '«${l.toUpperCase()}»'];
  if (quoted.length < 2) return quoted.join();
  final last = quoted.removeLast();
  return '${quoted.join(', ')} ${'game.or'.tr()} $last';
}

/// "Your turn — «К»" (or «К» або «Е»), "Your turn — name any city", or
/// "CityBot is thinking…".
class TurnBanner extends StatelessWidget {
  const TurnBanner({super.key, required this.turn, required this.letters});

  final Side turn;

  /// The letters the player may answer with; empty when any will do.
  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    final isPlayerTurn = turn == Side.player;
    final text = switch ((isPlayerTurn, letters.isEmpty)) {
      (false, _) => 'game.bot_thinking'.tr(),
      (true, true) => 'game.your_turn_any'.tr(),
      (true, false) => 'game.your_turn_letter'.tr(
        namedArgs: {'letters': quoteLetters(letters)},
      ),
    };
    // Teal, not coral: coral reads as an error next to the rejection
    // banner and the low-time badge.
    final color = isPlayerTurn ? AppColors.tealDark : AppColors.inkSoft;
    final background = isPlayerTurn ? AppColors.teal : AppColors.inkSoft;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPlayerTurn ? Icons.edit_rounded : Icons.smart_toy_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: heading(size: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Why the last answer was rejected, shown inline above the turn banner
/// (game_design §2.4).
class RejectionBanner extends StatelessWidget {
  const RejectionBanner({
    super.key,
    required this.reason,
    required this.letters,
  });

  final RejectionReason reason;

  /// The letters the player may answer with.
  final List<String> letters;

  @override
  Widget build(BuildContext context) {
    final message = switch (reason) {
      RejectionReason.empty => 'game.rejection.empty'.tr(),
      RejectionReason.notInList => 'game.rejection.not_in_list'.tr(),
      RejectionReason.wrongLetter => 'game.rejection.wrong_letter'.tr(
        namedArgs: {'letters': quoteLetters(letters)},
      ),
      RejectionReason.alreadyUsed => 'game.rejection.already_used'.tr(),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.rejectionBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: AppColors.coral,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
