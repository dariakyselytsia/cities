import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../engine/city.dart';
import '../game_state.dart';

/// The end of a game (game_design §2.7): win or loss and why, the score,
/// the cities the player named (new discoveries first), and Play again /
/// Home.
class GameOverView extends StatelessWidget {
  const GameOverView({
    super.key,
    required this.state,
    required this.language,
    required this.onPlayAgain,
    required this.onHome,
  });

  final GameOver state;

  /// The language city names are shown in.
  final NameLanguage language;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final newCities = state.newCities;
    final knownCities = state.knownCities;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            children: [
              _Verdict(isWin: result.isWin, outcome: result.outcome.name),
              const SizedBox(height: 24),
              _Totals(
                score: result.score,
                chain: result.chain,
                newCount: newCities.length,
              ),
              const SizedBox(height: 28),
              if (newCities.isNotEmpty) ...[
                _SectionTitle(
                  'game.over.new_title'.tr(),
                  icon: Icons.auto_awesome_rounded,
                  color: AppColors.tealDark,
                ),
                _CityChips(newCities, language: language, isNew: true),
                const SizedBox(height: 20),
              ],
              if (knownCities.isNotEmpty) ...[
                _SectionTitle(
                  newCities.isEmpty
                      ? 'game.over.named_title'.tr()
                      : 'game.over.named_again_title'.tr(),
                  icon: Icons.location_city_rounded,
                  color: AppColors.inkSoft,
                ),
                _CityChips(knownCities, language: language, isNew: false),
              ],
              if (state.namedCities.isEmpty)
                Text(
                  'game.over.none_named'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Row(
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
        ),
      ],
    );
  }
}

/// The big win/loss badge, title and reason.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.isWin, required this.outcome});

  final bool isWin;

  /// The `MatchOutcome` name, for its localized reason.
  final String outcome;

  @override
  Widget build(BuildContext context) {
    final color = isWin ? AppColors.green : AppColors.coral;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWin ? Icons.emoji_events_rounded : Icons.flag_rounded,
            color: color,
            size: 52,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isWin ? 'game.win'.tr() : 'game.loss'.tr(),
          style: heading(size: 34, weight: FontWeight.w800, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          'game.outcome.$outcome'.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
        ),
      ],
    );
  }
}

/// Score, chain and new cities, side by side.
class _Totals extends StatelessWidget {
  const _Totals({
    required this.score,
    required this.chain,
    required this.newCount,
  });

  final int score;
  final int chain;
  final int newCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Total(
          label: 'game.score'.tr(),
          value: score,
          background: AppColors.yellow,
          foreground: AppColors.ink,
        ),
        const SizedBox(width: 10),
        _Total(
          label: 'game.chain'.tr(),
          value: chain,
          background: AppColors.purple.withValues(alpha: 0.14),
          foreground: AppColors.purple,
        ),
        const SizedBox(width: 10),
        _Total(
          label: 'game.over.new_count'.tr(),
          value: newCount,
          background: AppColors.teal.withValues(alpha: 0.14),
          foreground: AppColors.tealDark,
        ),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final int value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadii.input),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: heading(
                size: 26,
                weight: FontWeight.w800,
                color: foreground,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.icon, required this.color});

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(text, style: heading(size: 17, color: color)),
        ],
      ),
    );
  }
}

/// City names as chips: teal for new discoveries, white for the rest.
class _CityChips extends StatelessWidget {
  const _CityChips(this.cities, {required this.language, required this.isNew});

  final List<City> cities;
  final NameLanguage language;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final city in cities)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isNew ? AppColors.teal : AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              city.name(language) ?? city.nameEn,
              style: heading(
                size: 15,
                color: isNew ? Colors.white : AppColors.ink,
              ),
            ),
          ),
      ],
    );
  }
}
