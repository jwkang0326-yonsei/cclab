import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/features/group/join_group_screen.dart';
import '../../../lib/features/group/viewmodels/group_view_model.dart';
import '../../../lib/data/repositories/user_repository.dart';
import '../../../lib/data/models/user_model.dart';

// Mock classes would be needed for a full integration test.
// For now, we test the UI rendering.

void main() {
  testWidgets('JoinGroupScreen renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: JoinGroupScreen(groupId: 'test-group-1'),
        ),
      ),
    );

    expect(find.textContaining('test-group-1'), findsOneWidget);
    expect(find.text('가입하기'), findsOneWidget);
  });
}
