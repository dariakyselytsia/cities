import 'package:cities/features/game/widgets/give_up_dialog.dart';
import 'package:cities/features/game/widgets/out_of_time_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/test_app.dart';

/// The Out-of-time screen at `/`, and the give-up dialog at `/dialog`.
GoRouter _router() => GoRouter(
  routes: [
    for (final (path, child) in [
      ('/', OutOfTimeView(chain: 12, onSeeResults: () {})),
      ('/dialog', const GiveUpDialog(chain: 12)),
    ])
      GoRoute(
        path: path,
        builder: (_, _) => Scaffold(body: SafeArea(child: child)),
      ),
  ],
);

void main() {
  for (final locale in const [Locale('uk'), Locale('en')]) {
    testWidgets('on a small phone (320 × 568) in ${locale.languageCode}, '
        'Out of time and the give-up dialog fit', (tester) async {
      tester.view.physicalSize = const Size(640, 1136);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final router = _router();
      await pumpLocalized(
        tester,
        localizedTestApp(router, startLocale: locale),
      );
      expect(find.byType(OutOfTimeView), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(tester.takeException(), isNull);

      router.go('/dialog');
      await tester.pumpAndSettle();
      expect(find.byType(GiveUpDialog), findsOneWidget);
      expect(find.textContaining('12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
