import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Shown when the city data can't be loaded. The app never crashes on bad or
/// missing data (CLAUDE.md); this explains the problem and offers a retry.
class LoadErrorScreen extends StatelessWidget {
  const LoadErrorScreen({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.travel_explore_rounded,
                  size: 64,
                  color: AppColors.coral,
                ),
                const SizedBox(height: 24),
                Text(
                  'startup.error_title'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'startup.error_body'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: onRetry,
                  child: Text('startup.retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
