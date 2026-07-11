import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';

/// Home screen (game_design.md §3): map placeholder, Play, Leaderboard, Settings.
///
/// PLACEHOLDER layout — to be restyled per the shared visual design. Navigation
/// and localization wiring here are the real deliverable.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'home.settings'.tr(),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Static world-map placeholder (future: interactive map).
            const Icon(Icons.public, size: 120),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.push(Routes.game),
              child: Text('home.play'.tr()),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.push(Routes.leaderboard),
              child: Text('home.leaderboard'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
