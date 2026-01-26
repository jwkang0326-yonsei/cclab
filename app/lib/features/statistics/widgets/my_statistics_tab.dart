import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_reading_stats_model.dart';
import '../../../data/repositories/user_repository.dart';
import 'reading_grid.dart';
import 'streak_message.dart';
import 'statistics_providers.dart';

/// 나의 통계 탭
class MyStatisticsTab extends ConsumerWidget {
  const MyStatisticsTab({super.key});

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
        
        return _MyStatisticsContent(
          userId: user.uid,
          groupId: user.groupId!,
          userName: user.name ?? '나',
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }
}

class _MyStatisticsContent extends ConsumerWidget {
  final String userId;
  final String groupId;
  final String userName;

  const _MyStatisticsContent({
    required this.userId,
    required this.groupId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userReadingStatsProvider(
      UserStatsParams(userId: userId, groupId: groupId, userName: userName),
    ));

    return statsAsync.when(
      data: (stats) => _buildContent(context, stats),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('통계를 불러오는 중 오류가 발생했습니다: $e')),
    );
  }

  Widget _buildContent(BuildContext context, UserReadingStatsModel stats) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 연속 읽기 메시지
          StreakMessage(
            currentStreak: stats.currentStreak,
            longestStreak: stats.longestStreak,
          ),
          const SizedBox(height: 24),

          // 읽기 현황 헤더
          Text(
            '나의 읽기 현황',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // GitHub 스타일 그리드
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

          // 통계 요약 카드
          Text(
            '통계 요약',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.menu_book,
                  label: '총 읽은 장',
                  value: '${stats.totalChaptersRead}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  label: '읽은 일수',
                  value: '${stats.totalReadingDays}',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: '현재 연속',
                  value: '${stats.currentStreak}일',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events,
                  label: '최장 연속',
                  value: '${stats.longestStreak}일',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
