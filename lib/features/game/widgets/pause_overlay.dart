import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// How strongly the chat is blurred while paused: enough that no city name
/// can be read, so the stopped clock can't be used to study the chat.
const double _blurSigma = 12;

/// Covers the board while the game is paused (game_design §3.3): the chat is
/// blurred under a big pause icon, and a tap anywhere resumes.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'game.tap_to_resume'.tr(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onResume,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
            child: ColoredBox(
              color: AppColors.background.withValues(alpha: 0.6),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                        boxShadow: AppColors.tealGlow,
                      ),
                      child: const Icon(
                        Icons.pause_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'game.paused'.tr(),
                      style: heading(size: 28, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'game.tap_to_resume'.tr(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
