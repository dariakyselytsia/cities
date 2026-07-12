import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:cities/domain/domain.dart';
import '../../core/theme.dart';
import '../../di/di.dart';

/// Statistics screen (game_design.md §5), styled to the shared design: a summary
/// row (cities discovered / longest streak / games played), per-mode high
/// scores, and the recent-session history — all from persisted [UserStats].
///
/// SCOPE NOTE: "Most used cities", per-country percentages, and favorite country
/// are not shown yet — those need city-id→name resolution and percent
/// computation that the stats fold does not populate (see CLAUDE.md roadmap).
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /// Fetched once per screen entry so the numbers reflect the latest recorded
  /// session without re-fetching on every rebuild.
  late final Future<Result<UserStats>> _future = getIt<GetUserStatsUseCase>()();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('statistics.title'.tr())),
      body: SafeArea(
        child: FutureBuilder<Result<UserStats>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final stats = switch (snapshot.data) {
              Success(:final value) => value,
              _ => null,
            };
            if (stats == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    'statistics.no_sessions'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.inkSoft),
                  ),
                ),
              );
            }
            return _StatsContent(stats: stats);
          },
        ),
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final UserStats stats;
  const _StatsContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    // Most recent session first.
    final sessions = stats.sessionHistory.reversed.toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.location_city_rounded,
                value: '${stats.usedCityIds.length}',
                label: 'statistics.cities_discovered'.tr(),
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                icon: Icons.local_fire_department_rounded,
                value: '${stats.longestStreak}',
                label: 'statistics.longest_streak'.tr(),
                color: AppColors.coral,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                icon: Icons.sports_esports_rounded,
                value: '${stats.sessionHistory.length}',
                label: 'statistics.games_played'.tr(),
                color: AppColors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _SectionTitle('statistics.high_scores'.tr()),
        const SizedBox(height: 10),
        _Card(
          child: Column(
            children: [
              _ScoreRow(
                label: 'statistics.ukraine'.tr(),
                score: stats.highScoreUA,
                color: AppColors.purple,
              ),
              const Divider(height: 20),
              _ScoreRow(
                label: 'statistics.world'.tr(),
                score: stats.highScoreWorld,
                color: AppColors.teal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle('statistics.recent_sessions'.tr()),
        const SizedBox(height: 10),
        if (sessions.isEmpty)
          _Card(
            child: Text(
              'statistics.no_sessions'.tr(),
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          )
        else
          for (final s in sessions) ...[
            _SessionRow(summary: s),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

/// A colored icon tile with a big value and a caption — the summary row.
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
          Text(value, style: baloo(size: 22, weight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text, style: baloo(size: 18, weight: FontWeight.w700));
}

/// A rounded white container used for grouped rows.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreRow({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        Text('$score', style: baloo(size: 20, weight: FontWeight.w800)),
      ],
    );
  }
}

/// One recent-session row: a mode chip, its unique-city count, and the score.
class _SessionRow extends StatelessWidget {
  final GameSessionSummary summary;
  const _SessionRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    // `mode` is the stored token ('UA' / 'WORLD'); map it to localized copy.
    final isUA = GameMode.fromStorage(summary.mode).isUkraine;
    final modeLabel =
        isUA ? 'statistics.ukraine'.tr() : 'statistics.world'.tr();
    final modeColor = isUA ? AppColors.purple : AppColors.teal;
    return _Card(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              modeLabel,
              style: TextStyle(
                color: modeColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'statistics.cities_count'.tr(args: ['${summary.uniqueCities}']),
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
            ),
          ),
          Text('${summary.score}', style: baloo(size: 18, weight: FontWeight.w800)),
        ],
      ),
    );
  }
}
