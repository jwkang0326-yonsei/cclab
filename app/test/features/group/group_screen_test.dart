import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lib/features/group/group_screen.dart';
import '../../../lib/data/repositories/user_repository.dart';
import '../../../lib/data/models/user_model.dart';

void main() {
  testWidgets('GroupScreen shows "Create Group" button when user has no group', (tester) async {
    // Arrange
    final mockUser = UserModel(
      uid: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      churchId: 'church-1',
      groupId: null, // No group
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
        child: const MaterialApp(
          home: GroupScreen(),
        ),
      ),
    );

    // Act
    await tester.pump(); // Start stream
    await tester.pump(); // Finish stream

    // Assert
    expect(find.text('새로운 그룹을 만들거나 초대 링크를 통해 가입해보세요.'), findsOneWidget);
    expect(find.text('새 그룹 만들기'), findsOneWidget);
  });

  testWidgets('GroupScreen shows group detail view when user has a group', (tester) async {
    // Arrange
    final mockUser = UserModel(
      uid: 'user-1',
      email: 'test@example.com',
      name: 'Test User',
      churchId: 'church-1',
      groupId: 'group-123', // Has group
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProfileProvider.overrideWith((ref) => Stream.value(mockUser)),
        ],
        child: const MaterialApp(
          home: GroupScreen(),
        ),
      ),
    );

    // Act
    await tester.pump();
    await tester.pump();

    // Assert
    expect(find.textContaining('그룹 ID: group-123'), findsOneWidget);
    expect(find.textContaining('상세 정보 및 승인 대기 목록 노출 예정'), findsOneWidget);
  });
}
