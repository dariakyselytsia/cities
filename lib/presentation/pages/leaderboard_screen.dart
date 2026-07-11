import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// A single leaderboard row (stub shape until Supabase/local scores are wired).
class _Entry {
  final int rank;
  final String name;
  final String initials;
  final int score;
  final Color color;
  final bool isYou;
  const _Entry(
    this.rank,
    this.name,
    this.initials,
    this.score,
    this.color, {
    this.isYou = false,
  });
}

/// Leaderboard screen (game_design.md §3), styled to the design: Weekly/Global/
/// Friends tabs, a top-3 podium, and a ranked list.
///
/// SCOPE NOTE: data is placeholder. Local high scores + the global board
/// (Supabase) are not wired yet; the tabs currently show the same sample data.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _tab = 0;

  static const _entries = <_Entry>[
    _Entry(1, 'You', 'YOU', 1420, AppColors.yellow, isYou: true),
    _Entry(2, 'Jamie', 'JM', 1290, AppColors.teal),
    _Entry(3, 'Rosa', 'RS', 1105, AppColors.coral),
    _Entry(4, 'Leo T.', 'LT', 1180, AppColors.purple),
    _Entry(5, 'Aki K.', 'AK', 1062, AppColors.teal),
    _Entry(6, 'Dana P.', 'DP', 990, AppColors.coral),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'leaderboard.weekly'.tr(),
      'leaderboard.global'.tr(),
      'leaderboard.friends'.tr(),
    ];
    final podium = _entries.where((e) => e.rank <= 3).toList()
      ..sort((a, b) => a.rank.compareTo(b.rank));
    final rest = _entries.where((e) => e.rank > 3).toList();

    return Scaffold(
      appBar: AppBar(title: Text('leaderboard.title'.tr())),
      body: SafeArea(
        child: Column(
          children: [
            _PillTabs(
              tabs: tabs,
              selected: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 8),
            _Podium(entries: podium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                itemCount: rest.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _ListRow(entry: rest[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                '★ ${'leaderboard.footer_top'.tr()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-style segmented tabs; the active tab is a filled coral pill.
class _PillTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;
  const _PillTabs({
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == i ? AppColors.coral : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected == i ? Colors.white : AppColors.inkSoft,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The top-3 podium: rank 1 centered and tallest.
class _Podium extends StatelessWidget {
  final List<_Entry> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    _Entry? byRank(int r) {
      for (final e in entries) {
        if (e.rank == r) return e;
      }
      return null;
    }

    final first = byRank(1);
    final second = byRank(2);
    final third = byRank(3);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (second != null) _PodiumAvatar(entry: second, size: 56),
          if (first != null) _PodiumAvatar(entry: first, size: 72),
          if (third != null) _PodiumAvatar(entry: third, size: 56),
        ],
      ),
    );
  }
}

class _PodiumAvatar extends StatelessWidget {
  final _Entry entry;
  final double size;
  const _PodiumAvatar({required this.entry, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            entry.isYou ? 'leaderboard.you'.tr().toUpperCase() : entry.initials,
            style: TextStyle(
              color: entry.color == AppColors.yellow
                  ? AppColors.ink
                  : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.isYou ? 'leaderboard.you'.tr() : entry.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Text(
          '#${entry.rank}',
          style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
        ),
      ],
    );
  }
}

class _ListRow extends StatelessWidget {
  final _Entry entry;
  const _ListRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${entry.rank}',
              style: const TextStyle(
                color: AppColors.inkSoft,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              entry.initials,
              style: TextStyle(
                color: entry.color == AppColors.yellow
                    ? AppColors.ink
                    : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
