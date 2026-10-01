import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../engine/match.dart';

/// The end of the game under the chat: win or loss, why, the score, and
/// Play again / Home. The full game-over view (cities named, new cities
/// discovered) comes in T13.
class GameEndPanel extends StatelessWidget {
  const GameEndPanel({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onHome,
  });

  final MatchResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final color = result.isWin ? AppColors.green : AppColors.coral;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                result.isWin ? Icons.emoji_events_rounded : Icons.flag_rounded,
                color: color,
                size: 32,
              ),
              const SizedBox(width: 10),
              Text(
                result.isWin ? 'game.win'.tr() : 'game.loss'.tr(),
                style: heading(size: 26, weight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'game.outcome.${result.outcome.name}'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
          ),
          const SizedBox(height: 4),
          Text(
            'game.final_score'.tr(namedArgs: {'score': '${result.score}'}),
            style: heading(size: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onHome,
                  child: Text('game.home'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onPlayAgain,
                  child: Text('game.play_again'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
