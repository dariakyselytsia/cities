import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../setup/setup_sheet.dart';
import '../stats/stats_cubit.dart';

/// Home (game_design §3.1): the hero, the Міста wordmark and tagline, a
/// lifetime-stats card that opens Statistics, a big Play button (it opens
/// the setup sheet), and Statistics / Settings icons.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: LayoutBuilder(
                    builder: (context, constraints) => _body(
                      context,
                      compact: constraints.maxHeight < _compactBelow,
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

  /// Below this height the full layout doesn't fit, and Play would need a
  /// scroll (an iPhone SE / 320 × 568 phone has about 480).
  static const double _compactBelow = 640;

  /// Everything under the top icons, centered. [compact] shrinks the hero
  /// and the gaps so Play stays on screen on small phones (T21).
  Widget _body(BuildContext context, {required bool compact}) {
    final textTheme = Theme.of(context).textTheme;
    final gap = compact ? 16.0 : 28.0;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 8, 24, compact ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroArt(compact: compact),
            SizedBox(height: gap),
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
            SizedBox(height: compact ? 16 : 24),
            _StatCard(onTap: () => context.push(Routes.stats)),
            SizedBox(height: gap),
            _PlayButton(onTap: () => showSetupSheet(context)),
          ],
        ),
      ),
    );
  }
}

/// Decorative hero: soft color blobs behind the brand badge.
class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.compact});

  /// A shorter hero with a smaller badge, for small phones.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 110 : 260,
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
          Align(child: BrandBadge(size: compact ? 88 : 120)),
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

/// Lifetime stats: the longest chain and cities discovered, both lists
/// together. It updates when a game ends. Tapping it opens Statistics.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsCubit>().state;
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
                    Expanded(
                      child: _stat(
                        context,
                        stats.longestChain,
                        'home.best_chain'.tr(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _stat(
                        context,
                        stats.discoveredIds.length,
                        'home.cities_discovered'.tr(),
                      ),
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

/// The big teal Play call-to-action.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: AppColors.tealGlow,
      ),
      child: Material(
        color: AppColors.teal,
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
