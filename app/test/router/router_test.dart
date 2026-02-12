import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:with_bible/router/app_router.dart';
import 'package:with_bible/data/repositories/auth_repository.dart';
import 'package:with_bible/data/repositories/user_repository.dart';
import 'package:with_bible/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  testWidgets('Router navigates to JoinGroupScreen on /invite/group/:id', (tester) async {
    // Arrange
    final mockUser = MockUser();
    final mockUserModel = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      name: 'Test User',
      churchId: 'church-1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentUserProfileProvider.overrideWith((ref) => Stream.value(mockUserModel)),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify we are at home (Scaffold should be present)
    expect(find.byType(Scaffold), findsOneWidget);

    // Act: Navigate to deep link
    final context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).go('/invite/group/group-123');
    await tester.pumpAndSettle();

    // Assert: We expect to see '그룹 가입' text (Title of JoinGroupScreen)
    // This assertion fails currently because the route is not added.
    expect(find.text('그룹 가입'), findsOneWidget); 
  });
}