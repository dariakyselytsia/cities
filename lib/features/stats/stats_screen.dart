import 'package:flutter/material.dart';

import '../../core/placeholder_screen.dart';

/// Statistics (T19). A placeholder until then.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
    titleKey: 'statistics.title',
    icon: Icons.bar_chart_rounded,
  );
}
