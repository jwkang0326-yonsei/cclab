import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_repository.dart';
import 'reading_grid.dart';
import 'statistics_providers.dart';

/// 팀 통계 탭
class TeamStatisticsTab extends ConsumerWidget {
  const TeamStatisticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null || user.groupId == null) {
          return const Center(
            child: Text('그룹에 가입한 후 통계를 확인할 수 있습니다.'),
          );
        }

        return _TeamStatisticsContent(groupId: user.groupId!);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }
}

class _TeamStatisticsContent extends ConsumerWidget {
  final String groupId;

  const _TeamStatisticsContent({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(teamReadingStatsProvider(groupId));

    return statsAsync.when(
      data: (stats) => _buildContent(context, stats),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('팀 통계를 불러오는 중 오류가 발생했습니다: $e')),
    );
  }

  Widget _buildContent(BuildContext context, TeamStatsData stats) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 팀 전체 진행률 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '팀 전체 진행률',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stats.totalChaptersRead}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        '장 완료',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TeamStatItem(
                      label: '진행 중 목표',
                      value: '${stats.activeGoalsCount}',
                    ),
                    _TeamStatItem(
                      label: '참여 멤버',
                      value: '${stats.memberStats.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 팀 읽기 현황
          Text(
            '팀 읽기 현황',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: ReadingGrid(
              dailyReadings: stats.dailyReadings,
              weeksToShow: 20,
            ),
          ),
          const SizedBox(height: 24),

          // 멤버별 순위
          Text(
            '멤버별 기여도',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (stats.memberStats.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      '아직 읽기 기록이 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(() {
              int displayRank = 0;
              int? prevClearedCount;

              return stats.memberStats.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;

                if (prevClearedCount != member.clearedCount) {
                  displayRank = index + 1;
                  prevClearedCount = member.clearedCount;
                }

                return _MemberRankCard(
                  rank: displayRank,
                  name: member.displayName,
                  chaptersRead: member.clearedCount,
                  isTopThree: displayRank <= 3,
                );
              });
            })(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _TeamStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _TeamStatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _MemberRankCard extends StatelessWidget {
  final int rank;
  final String name;
  final int chaptersRead;
  final bool isTopThree;

  const _MemberRankCard({
    required this.rank,
    required this.name,
    required this.chaptersRead,
    required this.isTopThree,
  });

  @override
  Widget build(BuildContext context) {
    final medalEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTopThree
            ? Colors.amber.withOpacity(0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree
              ? Colors.amber.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: medalEmoji != null
                ? Text(medalEmoji, style: const TextStyle(fontSize: 24))
                : Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
          ),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$chaptersRead장',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTopThree ? Colors.amber[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
