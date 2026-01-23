import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/features/group/group_admin_screen.dart';
import '../../../lib/data/models/user_model.dart';
import '../../../lib/features/group/viewmodels/group_view_model.dart';
import 'group_admin_logic_test.dart';

void main() {
  testWidgets('GroupAdminScreen displays pending members', (tester) async {
    final mockRepo = MockGroupRepository();
    final pendingMembers = [
      UserModel(uid: 'u1', name: 'Pending User', email: 'u1@test.com', groupId: 'g1', groupStatus: 'pending'),
    ];

    when(mockRepo.getMembers(groupId: 'g1', status: 'pending'))
        .thenAnswer((_) async => pendingMembers);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(
          home: GroupAdminScreen(groupId: 'g1'),
        ),
      ),
    );

    // Initial load
    await tester.pump(); 
    // Async load
    await tester.pump();

    expect(find.text('Pending User'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
