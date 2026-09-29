import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Placeholder Home — replaced by the real Home screen in T14.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Text('app_title'.tr(), style: textTheme.displayLarge),
      ),
    );
  }
}
