import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/theme.dart';
import '../../engine/city_list.dart';
import '../../engine/difficulty.dart';
import 'setup_cubit.dart';

/// Opens the setup sheet (game_design §2.1): the city list, the difficulty
/// and Start. It opens with the last choice ([SetupCubit]).
Future<void> showSetupSheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: AppColors.background,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
  ),
  builder: (_) => const SetupSheet(),
);

/// The setup sheet's content.
class SetupSheet extends StatelessWidget {
  const SetupSheet({super.key});

  static const _listIcons = {
    CityListKind.ukraine: Icons.location_city_rounded,
    CityListKind.world: Icons.public_rounded,
  };

  static const _difficultyIcons = {
    Difficulty.easy: Icons.sentiment_satisfied_rounded,
    Difficulty.medium: Icons.psychology_rounded,
    Difficulty.hard: Icons.local_fire_department_rounded,
  };

  /// Starts the game: closes the sheet and opens the game for [setup].
  void _start(BuildContext context, GameSetup setup) {
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.push(Routes.gameFor(setup.list, setup.difficulty));
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SetupCubit>();
    return BlocBuilder<SetupCubit, GameSetup>(
      builder: (context, setup) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'setup.title'.tr(),
                textAlign: TextAlign.center,
                style: heading(size: 24, weight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              _SectionLabel('setup.list'.tr()),
              Row(
                children: [
                  for (final (i, list) in CityListKind.values.indexed) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _Option(
                        icon: _listIcons[list] ?? Icons.place_rounded,
                        title: 'list.${list.name}'.tr(),
                        subtitle: 'setup.list_desc.${list.name}'.tr(),
                        selected: setup.list == list,
                        onTap: () => cubit.selectList(list),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              _SectionLabel('setup.difficulty'.tr()),
              for (final difficulty in Difficulty.values) ...[
                _Option(
                  icon: _difficultyIcons[difficulty] ?? Icons.tune_rounded,
                  title: 'difficulty.${difficulty.name}'.tr(),
                  subtitle: 'setup.difficulty_desc.${difficulty.name}'.tr(),
                  trailing: 'setup.turn_time'.tr(
                    namedArgs: {'seconds': '${difficulty.turnTime.inSeconds}'},
                  ),
                  selected: setup.difficulty == difficulty,
                  onTap: () => cubit.selectDifficulty(difficulty),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () => _start(context, setup),
                child: Text('setup.start'.tr()),
              ),
            ],
          ),
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

/// A selectable card: teal border and check when [selected].
class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  /// A short note on the right, e.g. the seconds per turn.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = selected ? AppColors.tealDark : AppColors.inkSoft;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? AppColors.teal.withValues(alpha: 0.10)
            : AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.input),
          side: BorderSide(
            color: selected ? AppColors.teal : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: heading(size: 17)),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing case final trailing?) ...[
                  const SizedBox(width: 8),
                  Text(trailing, style: heading(size: 14, color: accent)),
                ],
                if (selected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.teal,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
