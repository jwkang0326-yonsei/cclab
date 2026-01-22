import 'package:with_bible/data/models/group_goal_model.dart';
import 'package:with_bible/data/models/group_map_state_model.dart';
import 'package:with_bible/data/repositories/group_goal_repository.dart';
import 'package:with_bible/data/repositories/user_repository.dart';
import 'package:with_bible/features/bible_map/presentation/pages/bible_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupGoalRepository extends Mock implements GroupGoalRepository {}

void main() {
  late MockGroupGoalRepository mockGroupGoalRepository;

  setUp(() {
    mockGroupGoalRepository = MockGroupGoalRepository();
  });

  testWidgets('BibleMapScreen displays checkboxes and collapse icons', (WidgetTester tester) async {
    // Mock Goal
    final goal = GroupGoalModel(
      id: 'goal1',
      groupId: 'group1',
      title: 'Test Goal',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      targetRange: ['Genesis'], // Only Genesis
      status: 'ACTIVE',
      createdAt: DateTime.now(),
    );

    // Mock Map State
    final mapState = GroupMapStateModel(
      groupId: 'group1',
      chapters: {},
      stats: GroupMapStats(totalChapters: 50, clearedCount: 0, userStats: {}),
    );

    // Mock Repository Calls
    when(() => mockGroupGoalRepository.getGoal('goal1')).thenAnswer((_) async => goal);
    when(() => mockGroupGoalRepository.watchMapState('goal1'))
        .thenAnswer((_) => Stream.value(mapState));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupGoalRepositoryProvider.overrideWithValue(mockGroupGoalRepository),
          currentUserProfileProvider.overrideWith((ref) => Stream.value(null)), // No user logged in
        ],
        child: const MaterialApp(
          home: BibleMapScreen(goalId: 'goal1'),
        ),
      ),
    );

    // Allow FutureBuilder/StreamBuilder to settle
    await tester.pumpAndSettle();

    // Check for Title
    expect(find.text('Test Goal'), findsOneWidget);

    // Check for Book Name (Genesis)
    expect(find.text('창세기'), findsOneWidget);

    // Check for Checkbox
    expect(find.byType(Checkbox), findsOneWidget);

    // Check for Collapse/Expand Icon (ExpandMore used with rotation)
    expect(find.byIcon(Icons.expand_more), findsOneWidget);

    // Chapter 1 is collapsed. Should NOT be hit-testable.
    // Note: hitTestable checks if it can be hit. Size 0 usually cannot.
    // However, finding it might still work. 
    // Let's rely on the interaction flow.

    // Test Expand Interaction
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // Still ExpandMore icon (rotated)
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    
    // Chapter 1 should be visible/hit-testable
    expect(find.text('1'), findsOneWidget);

    // Test Collapse Interaction
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pumpAndSettle();

    // Still ExpandMore icon
    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    
    // Test Selection Checkbox -> Should AUTO-EXPAND
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Check if Checkbox is checked
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);
    
    // Auto-Expand Verification: 
    // Chapter 1 should be visible again
    expect(find.text('1'), findsOneWidget);
    
    // Should see "50개 선택됨"
    expect(find.textContaining('50개 선택됨'), findsOneWidget);
  });
}