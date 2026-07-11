import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../widgets/settings_widgets.dart';

/// Settings screen (game_design.md §3), styled to the design: language,
/// city-list selection, and gameplay toggles.
///
/// SCOPE NOTE: language toggle is wired to easy_localization and is live. The
/// city-list selection and gameplay toggles are UI-only local state for now —
/// they are not yet persisted to a domain preference (that lands with the
/// User settings use cases / a SettingsBloc).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _worldCities = true;
  bool _ukrainianCities = true;
  bool _soundEffects = true;
  bool _turnTimer = true;

  @override
  Widget build(BuildContext context) {
    final isUk = context.locale.languageCode == 'uk';
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // LANGUAGE — single choice, coral radios.
            SettingsSectionLabel('settings.language'.tr()),
            SettingsCard(
              children: [
                SettingsRow(
                  title: 'English',
                  trailing: CoralRadio(selected: !isUk),
                  onTap: () => context.setLocale(const Locale('en')),
                ),
                const Divider(height: 1),
                SettingsRow(
                  title: 'Українська',
                  trailing: CoralRadio(selected: isUk),
                  onTap: () => context.setLocale(const Locale('uk')),
                ),
              ],
            ),

            // CITY LIST — multi-select, teal checks.
            SettingsSectionLabel('settings.city_list'.tr()),
            SettingsCard(
              children: [
                SettingsRow(
                  title: 'settings.world_cities'.tr(),
                  subtitle: 'settings.world_cities_desc'.tr(),
                  trailing: TealCheck(checked: _worldCities),
                  onTap: () => setState(() => _worldCities = !_worldCities),
                ),
                const Divider(height: 1),
                SettingsRow(
                  title: 'settings.ukrainian_cities'.tr(),
                  subtitle: 'settings.ukrainian_cities_desc'.tr(),
                  trailing: TealCheck(checked: _ukrainianCities),
                  onTap: () =>
                      setState(() => _ukrainianCities = !_ukrainianCities),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(
                'settings.city_list_hint'.tr(),
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 12),
              ),
            ),

            // GAMEPLAY — toggles.
            SettingsSectionLabel('settings.gameplay'.tr()),
            SettingsCard(
              children: [
                SettingsRow(
                  title: 'settings.sound_effects'.tr(),
                  trailing: Switch(
                    value: _soundEffects,
                    activeThumbColor: AppColors.coral,
                    onChanged: (v) => setState(() => _soundEffects = v),
                  ),
                ),
                const Divider(height: 1),
                SettingsRow(
                  title: 'settings.turn_timer'.tr(),
                  trailing: Switch(
                    value: _turnTimer,
                    activeThumbColor: AppColors.coral,
                    onChanged: (v) => setState(() => _turnTimer = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
