import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app_info.dart';
import '../../core/choice_tile.dart';
import '../../core/theme.dart';
import '../../engine/match.dart';
import 'settings_cubit.dart';

/// Settings (game_design §3.5): the language, who starts, and About with
/// the GeoNames attribution.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// The app's languages, each named in itself, with its flag.
  static const _languages = [
    (Locale('uk'), 'settings.language_uk', '🇺🇦'),
    (Locale('en'), 'settings.language_en', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;
    final cubit = context.read<SettingsCubit>();
    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            _SectionLabel('settings.language'.tr()),
            for (final (locale, name, flag) in _languages) ...[
              ChoiceTile(
                leading: Text(flag, style: const TextStyle(fontSize: 26)),
                title: name.tr(),
                subtitle: '${name}_desc'.tr(),
                selected: current == locale.languageCode,
                // easy_localization applies it everywhere and saves it.
                onTap: () => context.setLocale(locale),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 14),
            _SectionLabel('settings.first_turn'.tr()),
            BlocBuilder<SettingsCubit, Settings>(
              builder: (context, settings) => Column(
                children: [
                  for (final side in Side.values) ...[
                    ChoiceTile(
                      icon: side == Side.bot
                          ? Icons.smart_toy_rounded
                          : Icons.person_rounded,
                      title: 'settings.first_turn_${side.name}'.tr(),
                      subtitle: 'settings.first_turn_${side.name}_desc'.tr(),
                      selected: settings.firstTurn == side,
                      onTap: () => cubit.setFirstTurn(side),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionLabel('settings.about'.tr()),
            const _About(),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: heading(size: 16, color: AppColors.inkSoft)),
  );
}

/// The app and its version, the GeoNames CC BY 4.0 attribution, and the
/// open-source licenses.
class _About extends StatelessWidget {
  const _About();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.coral),
              const SizedBox(width: 8),
              Text('app_title'.tr(), style: heading(size: 18)),
              const Spacer(),
              Text(
                'settings.version'.tr(namedArgs: {'version': appVersion}),
                style: textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            'settings.geonames'.tr(
              namedArgs: {'site': geoNamesSite, 'license': ccByLicense},
            ),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'app_title'.tr(),
              applicationVersion: appVersion,
            ),
            icon: const Icon(Icons.description_outlined, size: 18),
            label: Text('settings.licenses'.tr()),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.tealDark,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
