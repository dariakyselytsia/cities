import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';

/// Home screen (game_design.md §3): map placeholder, Play, Leaderboard, Settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'home.settings'.tr(),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // World-map placeholder (future: interactive map).
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(AppRadii.hero),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.public_rounded,
                          size: 140,
                          color: AppColors.coral,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'app_title'.tr(),
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium,
                  ),
                  const SizedBox(height: 32),
                  _GlowButton(
                    label: 'home.play'.tr(),
                    color: AppColors.coral,
                    glow: AppColors.coralGlow,
                    icon: Icons.play_arrow_rounded,
                    onTap: () => context.push(Routes.game),
                  ),
                  const SizedBox(height: 16),
                  _GlowButton(
                    label: 'home.leaderboard'.tr(),
                    color: AppColors.teal,
                    glow: AppColors.tealGlow,
                    icon: Icons.leaderboard_rounded,
                    onTap: () => context.push(Routes.leaderboard),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A rounded, full-width button with a colored drop-glow — the primary CTA
/// style from the design.
class _GlowButton extends StatelessWidget {
  final String label;
  final Color color;
  final List<BoxShadow> glow;
  final IconData icon;
  final VoidCallback onTap;

  const _GlowButton({
    required this.label,
    required this.color,
    required this.glow,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: glow,
      ),
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 58),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: baloo(size: 18, weight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
