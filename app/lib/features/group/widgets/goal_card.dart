import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/group_goal_model.dart';
import '../../../data/repositories/group_goal_repository.dart';
import '../../bible_map/presentation/viewmodels/bible_map_viewmodel.dart';

class GoalCard extends ConsumerWidget {
  final GroupGoalModel goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapStateAsync = ref.watch(bibleMapStateProvider(goal.id));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title & Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.targetRange.join(', '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'toggle_hide') {
                      final newStatus = goal.status == 'ACTIVE' ? 'HIDDEN' : 'ACTIVE';
                      ref.read(groupGoalRepositoryProvider).updateGoalStatus(goal.id, newStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(newStatus == 'HIDDEN' ? '목표를 숨겼습니다.' : '목표를 복구했습니다.')),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'toggle_hide',
                        child: Text(goal.status == 'ACTIVE' ? '숨기기' : '보관함에서 복구'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar & Stats
            mapStateAsync.when(
              data: (state) {
                final total = state.stats.totalChapters;
                final cleared = state.stats.clearedCount;
                final progress = total > 0 ? cleared / total : 0.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "진행률 ${(progress * 100).toInt()}%",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueAccent),
                        ),
                        Text(
                          "$cleared / $total 장",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentHistory(context, state.stats.userStats),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(minHeight: 8),
              error: (e, _) => Text("데이터 로드 실패: $e", style: const TextStyle(fontSize: 10, color: Colors.red)),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  context.push('/group/bible-map/${goal.id}');
                },
                icon: const Icon(Icons.map, size: 18),
                label: const Text("성경 읽기 예약하기"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, Map<String, dynamic> userStatsMap) {
    // Logic: Filter lastActiveAt > 7 days ago, Sort Desc, Take 3
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    // We assume userStatsMap is Map<String, UserMapStat> but coming from JSON logic it might be dynamic in model
    // In Model: final Map<String, UserMapStat> userStats;
    // So it is strongly typed.
    
    final recentUsers = userStatsMap.values
        .where((stat) => stat.lastActiveAt.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));

    final top3 = recentUsers.take(3).toList();

    if (top3.isEmpty) {
      return const SizedBox.shrink(); // No history to show
    }

    return Row(
      children: [
        Text("최근 활동: ", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(width: 4),
        Expanded(
          child: SizedBox(
            height: 30,
            child: Stack(
              children: List.generate(top3.length, (index) {
                final user = top3[index];
                return Positioned(
                  left: index * 20.0,
                  child: Tooltip(
                    message: "${user.displayName} (최근 활동: ${_formatDate(user.lastActiveAt)})",
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.primaries[user.displayName.hashCode % Colors.primaries.length],
                        child: Text(
                          user.displayName.isNotEmpty ? user.displayName[0] : '?',
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.month}/${date.day}";
  }
}
