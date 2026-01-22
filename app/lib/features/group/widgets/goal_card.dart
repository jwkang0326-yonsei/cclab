import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For DateFormat
import '../../../data/models/group_goal_model.dart';
import '../../../data/models/group_map_state_model.dart';
import '../../../data/repositories/group_goal_repository.dart';
import '../../bible_map/presentation/viewmodels/bible_map_viewmodel.dart';
import '../../../core/constants/bible_constants.dart';

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
                    _buildDetailedHistory(context, state),
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

  Widget _buildDetailedHistory(BuildContext context, GroupMapStateModel state) {
    // 1. Identify Top 3 Recent Users
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final sortedUsers = state.stats.userStats.values
        .where((u) => u.lastActiveAt.isAfter(sevenDaysAgo))
        .toList()
      ..sort((a, b) => b.lastActiveAt.compareTo(a.lastActiveAt));
    
    final top3Users = sortedUsers.take(3).toList();

    if (top3Users.isEmpty) return const SizedBox.shrink();

    // 2. Find Last Read Chapter for these users
    // Map<UserId, ChapterInfo>
    final Map<String, _ChapterInfo> lastReads = {};

    for (final entry in state.chapters.entries) {
      final status = entry.value;
      if (status.status == 'CLEARED' && status.clearedBy != null && status.clearedAt != null) {
        final userId = status.clearedBy!;
        // Only care if this user is in top 3
        if (top3Users.any((u) => u.userId == userId)) {
           if (!lastReads.containsKey(userId) || 
               status.clearedAt!.isAfter(lastReads[userId]!.clearedAt)) {
             
             // Parse Key "Book_Chapter"
             final parts = entry.key.split('_');
             if (parts.length == 2) {
               lastReads[userId] = _ChapterInfo(
                 bookKey: parts[0],
                 chapterNum: parts[1],
                 clearedAt: status.clearedAt!,
               );
             }
           }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("최근 활동", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...top3Users.map((user) {
          final info = lastReads[user.userId];
          final bookName = info != null ? BibleConstants.getBookName(info.bookKey) : "";
          final chapter = info?.chapterNum ?? "";
          final timeStr = info != null ? _formatRelativeTime(info.clearedAt) : "";

          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.primaries[user.displayName.hashCode % Colors.primaries.length],
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0] : '?',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                if (info != null) ...[
                  Text(
                    "• $bookName ${chapter}장",
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const Spacer(),
                  Text(
                    timeStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ] else ...[
                  const Spacer(),
                  Text(
                    "활동 기록 없음",
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ]
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return "${diff.inMinutes}분 전";
      }
      return "오늘";
    } else if (diff.inDays == 1) {
      return "어제";
    } else if (diff.inDays < 7) {
      return "${diff.inDays}일 전";
    } else {
      return DateFormat('MM.dd').format(date);
    }
  }
}

class _ChapterInfo {
  final String bookKey;
  final String chapterNum;
  final DateTime clearedAt;
  _ChapterInfo({required this.bookKey, required this.chapterNum, required this.clearedAt});
}