import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../bloc/settings_cubit.dart';
import '../widgets/settings_widgets.dart';

/// Settings screen (game_design.md §3), styled to the design: language,
/// city-list selection, and gameplay toggles.
///
/// Language is wired to easy_localization; the city-list and gameplay toggles
/// are held in [SettingsCubit] and drive the next game round. (Not yet persisted
/// across launches — that's a later step.)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isUk = context.locale.languageCode == 'uk';
    final cubit = context.read<SettingsCubit>();
    final settings = context.watch<SettingsCubit>().state;

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

            // CITY LIST — multi-select, teal checks; drives the game mode.
            SettingsSectionLabel('settings.city_list'.tr()),
            SettingsCard(
              children: [
                SettingsRow(
                  title: 'settings.world_cities'.tr(),
                  subtitle: 'settings.world_cities_desc'.tr(),
                  trailing: TealCheck(checked: settings.worldList),
                  onTap: cubit.toggleWorldList,
                ),
                const Divider(height: 1),
                SettingsRow(
                  title: 'settings.ukrainian_cities'.tr(),
                  subtitle: 'settings.ukrainian_cities_desc'.tr(),
                  trailing: TealCheck(checked: settings.ukraineList),
                  onTap: cubit.toggleUkraineList,
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
                    value: settings.soundEnabled,
                    activeThumbColor: AppColors.coral,
                    onChanged: cubit.setSoundEnabled,
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
