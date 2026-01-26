import 'package:flutter/material.dart';

/// 연속 읽기 격려 메시지 위젯
class StreakMessage extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakMessage({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _getMessage();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getGradientColors(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getGradientColors().first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                message.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (currentStreak > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('현재 연속', '$currentStreak일'),
                _buildStatItem('최장 기록', '$longestStreak일'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  _StreakMessageData _getMessage() {
    if (currentStreak == 0) {
      return _StreakMessageData(
        emoji: '📖',
        title: '오늘 성경을 읽어볼까요?',
        subtitle: '작은 시작이 큰 변화를 만듭니다',
      );
    } else if (currentStreak == 1) {
      return _StreakMessageData(
        emoji: '🌱',
        title: '좋은 시작이에요!',
        subtitle: '내일도 함께 읽어보아요',
      );
    } else if (currentStreak < 7) {
      return _StreakMessageData(
        emoji: '🔥',
        title: '$currentStreak일 연속 읽기 중!',
        subtitle: '꾸준함이 쌓이고 있어요',
      );
    } else if (currentStreak < 14) {
      return _StreakMessageData(
        emoji: '💪',
        title: '$currentStreak일 연속! 대단해요!',
        subtitle: '일주일 넘게 이어오고 있어요',
      );
    } else if (currentStreak < 30) {
      return _StreakMessageData(
        emoji: '⭐',
        title: '$currentStreak일 연속 달성!',
        subtitle: '정말 멋진 습관이 되어가고 있어요',
      );
    } else if (currentStreak < 100) {
      return _StreakMessageData(
        emoji: '🎉',
        title: '$currentStreak일 연속! 축하해요!',
        subtitle: '한 달 넘게 이어온 놀라운 여정',
      );
    } else {
      return _StreakMessageData(
        emoji: '🏆',
        title: '$currentStreak일 연속! 전설이네요!',
        subtitle: '100일 이상의 놀라운 기록',
      );
    }
  }

  List<Color> _getGradientColors() {
    if (currentStreak == 0) {
      return [Colors.grey[600]!, Colors.grey[700]!];
    } else if (currentStreak < 7) {
      return [const Color(0xFF4CAF50), const Color(0xFF2E7D32)];
    } else if (currentStreak < 14) {
      return [const Color(0xFFFF9800), const Color(0xFFE65100)];
    } else if (currentStreak < 30) {
      return [const Color(0xFF2196F3), const Color(0xFF1565C0)];
    } else {
      return [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)];
    }
  }
}

class _StreakMessageData {
  final String emoji;
  final String title;
  final String subtitle;

  _StreakMessageData({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
