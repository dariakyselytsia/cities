import 'package:flutter/material.dart';

import '../../core/placeholder_screen.dart';

/// Settings: language, who starts, About (T16). A placeholder until then.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const PlaceholderScreen(
    titleKey: 'settings.title',
    icon: Icons.settings_rounded,
  );
}
