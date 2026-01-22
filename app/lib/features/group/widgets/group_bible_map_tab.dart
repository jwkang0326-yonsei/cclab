import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_goal_model.dart';
import '../../../data/repositories/group_goal_repository.dart';
import 'goal_card.dart';

class GroupBibleMapTab extends ConsumerStatefulWidget {
  final String groupId;
  final bool isLeader;
  final bool shrinkWrap;

  const GroupBibleMapTab({
    super.key,
    required this.groupId,
    required this.isLeader,
    this.shrinkWrap = false,
  });

  @override
  ConsumerState<GroupBibleMapTab> createState() => _GroupBibleMapTabState();
}

class _GroupBibleMapTabState extends ConsumerState<GroupBibleMapTab> {
  bool _showHidden = false;

  @override
  Widget build(BuildContext context) {
    final status = _showHidden ? 'HIDDEN' : 'ACTIVE';
    final goalsAsync = ref.watch(groupGoalsProvider(GoalsFilter(groupId: widget.groupId, status: status)));
    final scrollPhysics = widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null;
    
    return goalsAsync.when(
      data: (goals) {
        if (goals.isEmpty) {
          // Empty State with Filter Toggle
          return ListView(
            shrinkWrap: widget.shrinkWrap,
            physics: scrollPhysics,
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildFilterBar(),
              const SizedBox(height: 64),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showHidden ? Icons.archive_outlined : Icons.map_outlined,
                      size: 64,
                      color: Colors.grey
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showHidden 
                          ? "숨겨진 목표가 없습니다." 
                          : "현재 진행 중인 성경 통독 목표가 없습니다.",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (!widget.isLeader && !_showHidden) 
                      const Text("그룹 리더가 목표를 설정할 때까지 기다려주세요."),
                  ],
                ),
              ),
            ],
          );
        }

        // List with Filter Header
        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: scrollPhysics,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: goals.length + 1, // +1 for Filter Header
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildFilterBar();
            }
            final goal = goals[index - 1];
            return GoalCard(goal: goal);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilterChip(
          label: const Text("숨긴 목표 보기"),
          selected: _showHidden,
          onSelected: (value) {
            setState(() {
              _showHidden = value;
            });
          },
          showCheckmark: true,
          selectedColor: Colors.grey[300],
        ),
      ],
    );
  }
}

// Filter Object for Family Provider
class GoalsFilter {
  final String groupId;
  final String status;
  GoalsFilter({required this.groupId, required this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalsFilter &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          status == other.status;

  @override
  int get hashCode => groupId.hashCode ^ status.hashCode;
}

final groupGoalsProvider = StreamProvider.family<List<GroupGoalModel>, GoalsFilter>((ref, filter) {
  return ref.watch(groupGoalRepositoryProvider).watchGoals(groupId: filter.groupId, status: filter.status);
});
