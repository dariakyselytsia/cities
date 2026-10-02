import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../setup/setup_sheet.dart';

/// Home (game_design §3.1): the hero, the Міста wordmark and tagline, a
/// lifetime-stats card that opens Statistics, a big Play button (it opens
/// the setup sheet), and Statistics / Settings icons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                // Pinned to the top; the rest is centered below.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _RoundIconButton(
                        icon: Icons.bar_chart_rounded,
                        tooltip: 'statistics.title'.tr(),
                        onTap: () => context.push(Routes.stats),
                      ),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: Icons.settings_rounded,
                        tooltip: 'settings.title'.tr(),
                        onTap: () => context.push(Routes.settings),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _HeroArt(),
                          const SizedBox(height: 28),
                          Text(
                            'app_title'.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.displayLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'home.tagline'.tr(),
                            textAlign: TextAlign.center,
                            style: heading(
                              size: 15,
                              weight: FontWeight.w600,
                              color: AppColors.coral,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _StatCard(onTap: () => context.push(Routes.stats)),
                          const SizedBox(height: 28),
                          _PlayButton(onTap: () => showSetupSheet(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative hero: soft color blobs behind a coral location-pin badge.
class _HeroArt extends StatelessWidget {
  const _HeroArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Big blobs that run well past the screen edges.
          Positioned(
            left: -170,
            top: 40,
            child: _blob(320, AppColors.teal.withValues(alpha: 0.28)),
          ),
          Positioned(right: -180, top: 0, child: _blob(340, AppColors.yellow)),
          Align(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(36),
                boxShadow: AppColors.coralGlow,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 68,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Lifetime stats: the longest chain and cities discovered. Zeros until T18
/// records results. Tapping it opens Statistics.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.landscape_rounded, color: AppColors.purple),
              const SizedBox(width: 14),
              // Top-aligned, so the numbers line up when a label wraps.
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _stat(context, 0, 'home.best_chain'.tr())),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _stat(context, 0, 'home.cities_discovered'.tr()),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, int value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$value', style: heading(size: 22, weight: FontWeight.w800)),
      Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
      ),
    ],
  );
}

/// The big coral Play call-to-action.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: AppColors.coralGlow,
      ),
      child: Material(
        color: AppColors.coral,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.play'.tr(),
                        style: heading(size: 20, color: Colors.white),
                      ),
                      Text(
                        'home.play_sub'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small circular icon button on the cream surface.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: AppColors.ink),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
