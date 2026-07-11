import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Leaderboard screen (game_design.md §3): Ukraine / World tabs, local high
/// score, and (future) global rankings from Supabase.
///
/// PLACEHOLDER layout — to be restyled per the shared visual design. Data
/// fetching is not wired yet (Supabase integration is a later step).
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('leaderboard.title'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(text: 'leaderboard.ukraine_tab'.tr()),
              Tab(text: 'leaderboard.world_tab'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('leaderboard.your_high_score'.tr())),
            Center(child: Text('leaderboard.your_high_score'.tr())),
          ],
        ),
      ),
    );
  }
}
