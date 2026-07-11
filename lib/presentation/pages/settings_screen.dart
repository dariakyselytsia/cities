import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Settings screen (game_design.md §3): language toggle + mode selector.
///
/// PLACEHOLDER layout — to be restyled per the shared visual design. The
/// language toggle is wired to easy_localization; the mode selector is not yet
/// bound to persisted preferences (that lands with the User settings use cases).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUk = context.locale.languageCode == 'uk';
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text('settings.language'.tr())),
          SegmentedButton<String>(
            // Language names shown as endonyms (each in its own script).
            segments: const [
              ButtonSegment(value: 'uk', label: Text('Українська')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {isUk ? 'uk' : 'en'},
            onSelectionChanged: (sel) => context.setLocale(Locale(sel.first)),
          ),
        ],
      ),
    );
  }
}
