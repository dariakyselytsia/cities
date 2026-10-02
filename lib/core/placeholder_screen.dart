import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

/// A screen that isn't built yet: a titled app bar and a friendly
/// "coming soon", so navigation can be wired before the screen exists.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.titleKey,
    required this.icon,
  });

  /// The translation key of the title.
  final String titleKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titleKey.tr())),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.disabled),
            const SizedBox(height: 12),
            Text(
              'common.coming_soon'.tr(),
              style: heading(size: 20, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
