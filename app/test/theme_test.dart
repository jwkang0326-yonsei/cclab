import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_bible/main.dart';

void main() {
  testWidgets('Theme should apply Modern Gardening colors and fonts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WithBibleApp()),
    );

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    final ThemeData? theme = app.theme;

    // Verify Primary Color (Green tone)
    // Avoid using .value deprecated comparison, verify Color directly
    expect(theme?.colorScheme.primary, equals(const Color(0xFF2E7D32)));

    // Verify Background Color
    expect(theme?.scaffoldBackgroundColor, equals(const Color(0xFFF5F5DC)));
  });
}
