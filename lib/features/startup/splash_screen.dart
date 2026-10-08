import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/theme.dart';

/// Shown while the city data loads (well under a second on most phones).
///
/// The badge sits at the exact center of the screen, like on the native
/// launch screens (T21), so the hand-over from the platform's splash to
/// this one doesn't jump; the title and the spinner appear under it.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(
        children: [
          // Two equal halves around the badge keep it centered.
          const Spacer(),
          const BrandBadge(),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('app_title'.tr(), style: textTheme.displayLarge),
                    const SizedBox(height: 20),
                    const SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.coral,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'startup.loading'.tr(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
