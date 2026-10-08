import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// The "Out of time!" moment after a timeout (T27): a dark screen with the
/// empty timer and the chain the player built, then the results.
///
/// A Future revive ("watch an ad for more time", game_design Future) goes
/// above the button. Until ads exist there is none.
class OutOfTimeView extends StatelessWidget {
  const OutOfTimeView({
    super.key,
    required this.chain,
    required this.onSeeResults,
  });

  /// How many cities the player named.
  final int chain;
  final VoidCallback onSeeResults;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const _EmptyTimer(),
          const SizedBox(height: 24),
          Text(
            'game.out_of_time.title'.tr(),
            textAlign: TextAlign.center,
            style: heading(
              size: 30,
              weight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'game.out_of_time.body'.tr(),
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$chain',
                  style: heading(size: 26, weight: FontWeight.w800),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'game.out_of_time.chain'.tr(),
                    style: text.bodyLarge?.copyWith(color: AppColors.inkSoft),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSeeResults,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Text('game.out_of_time.see_results'.tr()),
            ),
          ),
        ],
      ),
    );
  }
}

/// The turn timer, run down to zero.
class _EmptyTimer extends StatelessWidget {
  const _EmptyTimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.coral, width: 4),
        ),
        child: Text(
          '0',
          style: heading(
            size: 26,
            weight: FontWeight.w800,
            color: AppColors.coral,
          ),
        ),
      ),
    );
  }
}
