import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Asks before giving up, over a blurred game. Completes with `true` when
/// the player gave up.
///
/// [chain] is how many cities the player has named: the warning says that
/// chain ends.
Future<bool> showGiveUpDialog(
  BuildContext context, {
  required int chain,
}) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: AppColors.ink.withValues(alpha: 0.45),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: GiveUpDialog(chain: chain),
      ),
    ) ??
    false;

/// The give-up card (T27). "Keep playing" is the big teal action, since
/// staying is what we'd like; giving up is the quieter coral one.
class GiveUpDialog extends StatelessWidget {
  const GiveUpDialog({super.key, required this.chain});

  final int chain;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadii.input),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppColors.coral,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'game.give_up_title'.tr(),
              textAlign: TextAlign.center,
              style: heading(size: 24, weight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              chain == 0
                  ? 'game.give_up_body_no_chain'.tr()
                  : 'game.give_up_body'.tr(namedArgs: {'chain': '$chain'}),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkSoft,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('game.keep_playing'.tr()),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.coralDeep),
              child: Text('game.give_up'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
