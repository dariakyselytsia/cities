import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';
import '../game/game_screen.dart';

/// Placeholder Home — replaced by the real Home screen in T14.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('app_title'.tr(), style: textTheme.displayLarge),
            const SizedBox(height: 32),
            // Temporary route (T12): a fixed Ukraine / Medium game. T14
            // replaces it with the router and T15 with the setup sheet.
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const GameScreen(
                    list: CityListKind.ukraine,
                    difficulty: Difficulty.medium,
                  ),
                ),
              ),
              child: Text('home.play'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
