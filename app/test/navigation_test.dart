import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:with_bible/main.dart';
import 'package:with_bible/data/repositories/auth_repository.dart';
import 'package:with_bible/data/repositories/user_repository.dart';
import 'package:with_bible/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  testWidgets('Navigation should have 3 tabs and switch screens (Authenticated)', (WidgetTester tester) async {
    final mockUser = MockUser();
    
    // Create a mock user model with churchId (to pass redirect check)
    final tUser = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      name: 'Test',
      churchId: 'test-church',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override auth state to return a logged-in user
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          // Override user profile to return a valid user with churchId
          currentUserProfileProvider.overrideWith((ref) => Stream.value(tUser)),
        ],
        child: const WithBibleApp(),
      ),
    );
    
    await tester.pumpAndSettle();

    // 1. 하단 탭 바 존재 확인
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // 2. 탭 3개 확인
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.bar_chart), findsOneWidget);

    // 3. 초기 화면(홈) 확인
    expect(find.textContaining('환영합니다'), findsOneWidget);

    // 4. '그룹' 탭 클릭
    await tester.tap(find.byIcon(Icons.people));
    await tester.pumpAndSettle();

    // 5. '그룹' 화면으로 전환 확인
    expect(find.text('그룹 화면'), findsOneWidget);
  });
}