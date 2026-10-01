import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../engine/city_list.dart';
import '../../../engine/difficulty.dart';

/// At or below this many seconds, the timer badge turns coral.
const int _lowTimeSeconds = 5;

/// Top bar: back, CityBot with the game's list and difficulty, Give up and
/// the timer badge. Without [secondsLeft] (the game is over) there is no
/// timer and no Give up.
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.list,
    required this.difficulty,
    required this.onBack,
    this.secondsLeft,
    this.isCounting = false,
    this.onGiveUp,
  });

  final CityListKind list;
  final Difficulty difficulty;
  final VoidCallback onBack;
  final int? secondsLeft;

  /// The countdown is running (the player's turn).
  final bool isCounting;
  final VoidCallback? onGiveUp;

  @override
  Widget build(BuildContext context) {
    final seconds = secondsLeft;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
          ),
          const _BotAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('game.citybot'.tr(), style: heading(size: 17)),
                Text(
                  '${'list.${list.name}'.tr()} · '
                  '${'difficulty.${difficulty.name}'.tr()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onGiveUp case final onGiveUp?)
            IconButton(
              onPressed: onGiveUp,
              icon: const Icon(Icons.flag_outlined),
              color: AppColors.inkSoft,
              tooltip: 'game.give_up'.tr(),
            ),
          if (seconds != null) ...[
            const SizedBox(width: 2),
            _TimerBadge(seconds: seconds, isCounting: isCounting),
          ],
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({required this.seconds, required this.isCounting});

  final int seconds;
  final bool isCounting;

  @override
  Widget build(BuildContext context) {
    final low = isCounting && seconds <= _lowTimeSeconds;
    final ring = isCounting ? AppColors.coral : AppColors.disabled;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: low ? AppColors.coral : AppColors.card,
        border: Border.all(color: ring, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$seconds',
        style: heading(
          size: 17,
          weight: FontWeight.w800,
          color: low
              ? Colors.white
              : (isCounting ? AppColors.ink : AppColors.inkSoft),
        ),
      ),
    );
  }
}

/// The chain and score pills under the header.
class StatPills extends StatelessWidget {
  const StatPills({super.key, required this.chain, required this.score});

  final int chain;
  final int score;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Pill(
            label: 'game.chain'.tr(),
            value: '$chain',
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

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
            style: heading(
              size: 15,
              weight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
