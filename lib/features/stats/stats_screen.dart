import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/player_data.dart';
import '../../engine/city.dart';
import '../../engine/city_catalog.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';
import '../setup/setup_sheet.dart';
import 'statistics.dart';
import 'stats_cubit.dart';

/// Statistics (game_design §3.6): a summary, the record in each of the six
/// list × difficulty modes, and how much of each list the player has
/// discovered. It follows [StatsCubit], so it's current after every game.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  /// Each list's color, here and in its progress bar.
  static Color colorOf(CityListKind list) => switch (list) {
    CityListKind.ukraine => AppColors.purple,
    CityListKind.world => AppColors.teal,
  };

  /// The share of a list discovered, with one decimal so the first cities
  /// of thousands don't show as 0%; a share that still rounds to 0.0% shows
  /// as "< 0.1%", so a city you found always counts.
  static String formatShare(Discovery discovery, String locale) {
    const smallest = 0.001;
    final percent = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: 1,
    );
    return discovery.found > 0 && discovery.fraction < smallest
        ? '< ${percent.format(smallest)}'
        : percent.format(discovery.fraction);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // Discovery counts the cities playable in the app's language.
    final language = locale.languageCode == 'uk'
        ? NameLanguage.uk
        : NameLanguage.en;
    final catalog = context.read<CityCatalog>();
    return Scaffold(
      appBar: AppBar(title: Text('statistics.title'.tr())),
      body: SafeArea(
        child: BlocBuilder<StatsCubit, PlayerData>(
          builder: (context, data) {
            final stats = Statistics.of(
              data,
              ukraine: catalog.index(CityListKind.ukraine, language),
              world: catalog.index(CityListKind.world, language),
            );
            if (stats.isEmpty) return const _EmptyStats();
            return _StatsContent(stats: stats, locale: locale.toString());
          },
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats, required this.locale});

  final Statistics stats;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final count = NumberFormat.decimalPattern(locale);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _TileRow(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.sports_esports_rounded,
                value: count.format(stats.gamesPlayed),
                label: 'statistics.games_played'.tr(),
                color: AppColors.purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                icon: Icons.emoji_events_rounded,
                value: count.format(stats.gamesWon),
                label: 'statistics.games_won'.tr(),
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                icon: Icons.percent_rounded,
                value: NumberFormat.percentPattern(
                  locale,
                ).format(stats.winRate),
                label: 'statistics.win_rate'.tr(),
                color: AppColors.tealDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _TileRow(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.local_fire_department_rounded,
                value: count.format(stats.longestChain),
                label: 'statistics.longest_chain'.tr(),
                color: AppColors.coral,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                icon: Icons.location_city_rounded,
                value: count.format(stats.citiesDiscovered),
                label: 'statistics.cities_discovered'.tr(),
                color: AppColors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle('statistics.records'.tr()),
        _RecordsCard(records: stats.records, count: count),
        const SizedBox(height: 24),
        _SectionTitle('statistics.discovery'.tr()),
        _Card(
          child: Column(
            children: [
              for (final list in CityListKind.values) ...[
                if (list != CityListKind.values.first)
                  const SizedBox(height: 18),
                _DiscoveryRow(
                  list: list,
                  discovery:
                      stats.discovery[list] ??
                      const Discovery(found: 0, total: 0),
                  locale: locale,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Summary tiles side by side, as tall as the tallest (a label may wrap).
class _TileRow extends StatelessWidget {
  const _TileRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

/// A tinted icon, a big value and a caption.
class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value, style: heading(size: 22, weight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// The six modes: a row per difficulty, a column per list. Each cell shows
/// wins : losses and the best score.
class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.records, required this.count});

  final Map<GameSetup, ModeRecord> records;
  final NumberFormat count;

  @override
  Widget build(BuildContext context) {
    final small = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft);
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(flex: 4),
              for (final list in CityListKind.values)
                Expanded(
                  flex: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(StatsScreen.colorOf(list)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'list.${list.name}'.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: heading(size: 15),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          for (final difficulty in Difficulty.values) ...[
            const Divider(height: 22, color: AppColors.surfaceAlt),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'difficulty.${difficulty.name}'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final list in CityListKind.values)
                  Expanded(
                    flex: 5,
                    child: _RecordCell(
                      record:
                          records[GameSetup(
                            list: list,
                            difficulty: difficulty,
                          )] ??
                          const ModeRecord(),
                      count: count,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // What the numbers mean.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 4,
            children: [
              _Legend(AppColors.green, 'statistics.wins'.tr(), small),
              _Legend(AppColors.coral, 'statistics.losses'.tr(), small),
              _Legend(AppColors.yellow, 'statistics.best_score'.tr(), small),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordCell extends StatelessWidget {
  const _RecordCell({required this.record, required this.count});

  final ModeRecord record;
  final NumberFormat count;

  @override
  Widget build(BuildContext context) {
    if (record.wins + record.losses == 0) {
      return Center(
        child: Text('—', style: heading(size: 18, color: AppColors.disabled)),
      );
    }
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: count.format(record.wins),
                style: heading(size: 18, color: AppColors.green),
              ),
              TextSpan(
                text: ' : ',
                style: heading(size: 18, color: AppColors.inkSoft),
              ),
              TextSpan(
                text: count.format(record.losses),
                style: heading(size: 18, color: AppColors.coral),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.format(record.bestScore),
            style: heading(size: 13, weight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

/// One list: its name, "found of total", a bar, and the percentage.
class _DiscoveryRow extends StatelessWidget {
  const _DiscoveryRow({
    required this.list,
    required this.discovery,
    required this.locale,
  });

  final CityListKind list;
  final Discovery discovery;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = StatsScreen.colorOf(list);
    final count = NumberFormat.decimalPattern(locale);
    final small = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Dot(color),
            const SizedBox(width: 8),
            Expanded(
              child: Text('list.${list.name}'.tr(), style: heading(size: 16)),
            ),
            Text(
              StatsScreen.formatShare(discovery, locale),
              style: heading(size: 16, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: discovery.fraction,
            minHeight: 10,
            color: color,
            backgroundColor: AppColors.surfaceAlt,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'statistics.discovery_count'.tr(
            namedArgs: {
              'found': count.format(discovery.found),
              'total': count.format(discovery.total),
            },
          ),
          style: small,
        ),
      ],
    );
  }
}

/// A new player: what will appear here, and a way to start.
class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.teal,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'statistics.empty_title'.tr(),
              textAlign: TextAlign.center,
              style: heading(size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'statistics.empty_text'.tr(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => showSetupSheet(context),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('home.play'.tr()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(text, style: heading(size: 18)),
  );
}

/// A white rounded card.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadii.card),
    ),
    child: child,
  );
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.text, this.style);

  final Color color;
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Dot(color),
      const SizedBox(width: 6),
      Text(text, style: style),
    ],
  );
}
