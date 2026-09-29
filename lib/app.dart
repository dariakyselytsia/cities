import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/home/home_screen.dart';

/// Root widget: localization + theme. Routing (`go_router`) arrives with the
/// Home screen in T14.
class CitiesApp extends StatelessWidget {
  const CitiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => 'app_title'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
