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
  testWidgets('Initial initialization test', (WidgetTester tester) async {
    final mockUser = MockUser();
    const tUser = UserModel(
      uid: 'test-uid',
      email: 'test@example.com',
      name: 'Test',
      churchId: 'test-church',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentUserProfileProvider.overrideWith((ref) => Stream.value(tUser)),
        ],
        child: const WithBibleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('환영합니다'), findsOneWidget);
  });
}