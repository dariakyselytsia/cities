import 'package:flutter/material.dart';

import 'theme.dart';

/// A selectable card for one choice among a few (the setup sheet, Settings):
/// teal border and check when [selected].
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  /// The icon on the left, tinted teal when selected…
  final IconData? icon;

  /// …or any widget instead, e.g. a flag.
  final Widget? leading;
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
                leading ?? Icon(icon, color: accent),
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
