/// 사용자별 읽기 통계 데이터 모델
class UserReadingStatsModel {
  final String userId;
  final String displayName;
  final Map<String, int> dailyReadings; // { "2026-01-01": 3, "2026-01-02": 5 }
  final int currentStreak; // 현재 연속 읽기 일수
  final int longestStreak; // 최장 연속 읽기 기록
  final int totalChaptersRead; // 총 읽은 장 수
  final int totalReadingDays; // 총 읽은 일수

  const UserReadingStatsModel({
    required this.userId,
    required this.displayName,
    required this.dailyReadings,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalChaptersRead = 0,
    this.totalReadingDays = 0,
  });

  /// dailyReadings에서 통계 계산
  factory UserReadingStatsModel.fromDailyReadings({
    required String userId,
    required String displayName,
    required Map<String, int> dailyReadings,
  }) {
    // 총 읽은 장 수
    final totalChapters = dailyReadings.values.fold<int>(0, (sum, count) => sum + count);
    
    // 총 읽은 일 수 (1장 이상 읽은 날)
    final totalDays = dailyReadings.values.where((count) => count > 0).length;

    // 연속 읽기 계산
    final streaks = _calculateStreaks(dailyReadings);

    return UserReadingStatsModel(
      userId: userId,
      displayName: displayName,
      dailyReadings: dailyReadings,
      currentStreak: streaks['current'] ?? 0,
      longestStreak: streaks['longest'] ?? 0,
      totalChaptersRead: totalChapters,
      totalReadingDays: totalDays,
    );
  }

  /// 연속 읽기 계산 (현재 연속, 최장 연속)
  static Map<String, int> _calculateStreaks(Map<String, int> dailyReadings) {
    if (dailyReadings.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // 날짜 정렬
    final dates = dailyReadings.keys.toList()..sort();
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final yesterdayStr = () {
      final yesterday = today.subtract(const Duration(days: 1));
      return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    }();

    for (final dateStr in dates) {
      if ((dailyReadings[dateStr] ?? 0) == 0) continue;

      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final diff = date.difference(lastDate!).inDays;
        if (diff == 1) {
          tempStreak++;
        } else {
          // 연속 끊김
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
      lastDate = date;
    }

    // 마지막 streak 확인
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    // 현재 연속 계산 (오늘 또는 어제까지 읽었으면 유효)
    if (dailyReadings.containsKey(todayStr) || dailyReadings.containsKey(yesterdayStr)) {
      currentStreak = tempStreak;
    } else {
      currentStreak = 0;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }
}

/// 팀 전체 읽기 통계
class TeamReadingStatsModel {
  final String groupId;
  final Map<String, int> dailyReadings; // 팀 전체의 일별 읽기 수
  final int totalChaptersRead;
  final int totalGoals;
  final int completedGoals;
  final List<UserReadingStatsModel> memberStats; // 멤버별 통계 (순위용)

  const TeamReadingStatsModel({
    required this.groupId,
    required this.dailyReadings,
    this.totalChaptersRead = 0,
    this.totalGoals = 0,
    this.completedGoals = 0,
    this.memberStats = const [],
  });
}
