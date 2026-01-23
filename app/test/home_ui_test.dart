import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:with_bible/features/home/home_screen.dart';

void main() {
  testWidgets('Home screen should display tree and today card', (WidgetTester tester) async {
    // 1. Pump HomeScreen (Wrapped in Material App)
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HomeScreen()),
      ),
    );

    // 2. 인사말 확인 (Header)
    expect(find.textContaining('환영합니다'), findsOneWidget);

    // 3. 나무 위젯 확인 (Key 또는 Icon으로 식별)
    expect(find.byKey(const Key('growth_tree_widget')), findsOneWidget);

    // 4. 오늘의 성경 카드 확인
    expect(find.text('오늘의 말씀'), findsOneWidget);
    expect(find.text('창세기 1장'), findsOneWidget); // Mock Data
  });
}
