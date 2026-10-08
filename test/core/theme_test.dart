import 'package:cities/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('positive buttons are teal by default (T27)', () {
    final theme = buildAppTheme();
    expect(
      theme.filledButtonTheme.style?.backgroundColor?.resolve({}),
      AppColors.teal,
    );
    expect(
      theme.textButtonTheme.style?.foregroundColor?.resolve({}),
      AppColors.tealDark,
    );
  });

  testWidgets('a FilledButton in the app is teal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: FilledButton(onPressed: () {}, child: const Text('Play')),
        ),
      ),
    );
    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, AppColors.teal);
  });
}
