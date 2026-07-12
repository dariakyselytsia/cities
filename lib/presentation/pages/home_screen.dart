import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cities/domain/domain.dart';
import '../../core/router.dart';
import '../../core/theme.dart';
import '../../di/di.dart';

/// Home screen (game_design.md §3), styled to the shared design: decorative
/// hero art, the CITIES wordmark + tagline, a lifetime-stats card, and the two
/// primary CTAs — "Play vs Bot" (active) and "Play Online" (PvP, disabled until
/// multiplayer ships).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Lifetime stats for the card. Fetched once per screen entry (a fresh
  /// HomeScreen is built when returning from a finished game), so the numbers
  /// pick up the just-recorded session without flickering on unrelated rebuilds.
  late final Future<Result<UserStats>> _statsFuture =
      getIt<GetUserStatsUseCase>()();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top-right quick access to Leaderboard and Settings.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _RoundIconButton(
                        icon: Icons.leaderboard_rounded,
                        tooltip: 'home.leaderboard'.tr(),
                        onTap: () => context.push(Routes.leaderboard),
                      ),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: Icons.settings_rounded,
                        tooltip: 'home.settings'.tr(),
                        onTap: () => context.push(Routes.settings),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const _HeroArt(),
                  const SizedBox(height: 28),
                  Text(
                    'CITIES',
                    textAlign: TextAlign.center,
                    style: textTheme.displayLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'home.tagline'.tr(),
                    textAlign: TextAlign.center,
                    style: baloo(
                      size: 15,
                      weight: FontWeight.w600,
                      color: AppColors.coral,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<Result<UserStats>>(
                    future: _statsFuture,
                    builder: (context, snapshot) {
                      // Show 0 while loading or if the read failed — never crash
                      // the home screen on a stats miss.
                      final stats = switch (snapshot.data) {
                        Success(:final value) => value,
                        _ => null,
                      };
                      return _StatCard(
                        bestStreak: stats?.longestStreak ?? 0,
                        citiesPlayed: stats?.usedCityIds.length ?? 0,
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  _HomeCta(
                    label: 'home.play_vs_bot'.tr(),
                    subtitle: 'home.play_vs_bot_sub'.tr(),
                    icon: Icons.smart_toy_rounded,
                    color: AppColors.coral,
                    glow: AppColors.coralGlow,
                    onTap: () => context.push(Routes.game),
                  ),
                  const SizedBox(height: 16),
                  _HomeCta(
                    label: 'home.play_online'.tr(),
                    subtitle: 'home.play_online_sub'.tr(),
                    icon: Icons.public_rounded,
                    color: AppColors.teal,
                    glow: AppColors.tealGlow,
                    onTap: null, // PvP not available yet.
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.help_outline_rounded, size: 18),
                      label: Text('home.how_to_play'.tr()),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.inkSoft,
                        textStyle: baloo(size: 14, weight: FontWeight.w600),
                      ),
                    ),
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

/// Decorative hero: soft color blobs behind a coral location-pin badge —
/// the playful masthead from the design (no interactive map in the MVP).
class _HeroArt extends StatelessWidget {
  const _HeroArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Big soft blobs that spill well past the left edge and right corner.
          Positioned(
            left: -80,
            top: 34,
            child: _blob(210, AppColors.teal.withValues(alpha: 0.28)),
          ),
          Positioned(
            right: -80,
            top: -6,
            child: _blob(230, AppColors.yellow),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.coral,
                borderRadius: BorderRadius.circular(26),
                boxShadow: AppColors.coralGlow,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.white,
                size: 44,
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

/// A white card with two lifetime stats (best streak / cities played), read
/// from persisted [UserStats].
class _StatCard extends StatelessWidget {
  final int bestStreak;
  final int citiesPlayed;
  const _StatCard({required this.bestStreak, required this.citiesPlayed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.landscape_rounded, color: AppColors.purple),
          const SizedBox(width: 14),
          _stat('$bestStreak', 'home.best_streak'.tr()),
          const SizedBox(width: 24),
          _stat('$citiesPlayed', 'home.cities_played'.tr()),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: baloo(size: 22, weight: FontWeight.w800),
      ),
      Text(
        label,
        style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
      ),
    ],
  );
}

/// A large rounded call-to-action with a leading icon chip, a title, and a
/// subtitle. When [onTap] is null the button is shown disabled (muted, no glow)
/// — used for the not-yet-available PvP mode.
class _HomeCta extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<BoxShadow> glow;
  final VoidCallback? onTap;

  const _HomeCta({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.glow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = enabled ? color : AppColors.disabled;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.button),
        boxShadow: enabled ? glow : null,
      ),
      child: Material(
        color: bg,
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
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: baloo(
                          size: 18,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!enabled)
                  const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small circular icon button on the cream surface (top-bar navigation).
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

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
