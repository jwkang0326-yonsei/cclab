import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/group_goal_repository.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/models/group_goal_model.dart';

// AsyncNotifier without arguments
class CreateGoalViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op
  }

  Future<void> createGoal({
    required String groupId,
    required String title,
    required String type,
    required String readingMethod,
    required List<String> targetRange,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final newGoal = GroupGoalModel(
        id: const Uuid().v4(),
        groupId: groupId,
        title: title,
        targetRange: targetRange,
        startDate: startDate,
        endDate: endDate,
        createdAt: DateTime.now(),
        status: 'ACTIVE',
        readingMethod: readingMethod,
      );

      await ref.read(groupGoalRepositoryProvider).createGoal(newGoal);
    });
  }
}

final createGoalViewModelProvider = AsyncNotifierProvider<CreateGoalViewModel, void>(() {
  return CreateGoalViewModel();
});
