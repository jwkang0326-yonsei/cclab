import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_reading_stats_model.dart';
import '../../../data/models/group_map_state_model.dart';
import '../../../data/repositories/group_goal_repository.dart';
import '../../../data/repositories/church_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 통계 조회 파라미터
class UserStatsParams {
  final String userId;
  final String groupId;
  final String userName;

  UserStatsParams({
    required this.userId,
    required this.groupId,
    required this.userName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          groupId == other.groupId;

  @override
  int get hashCode => userId.hashCode ^ groupId.hashCode;
}

/// 사용자 읽기 통계 Provider
final userReadingStatsProvider = StreamProvider.family<UserReadingStatsModel, UserStatsParams>((ref, params) async* {
  final firestore = ref.watch(firestoreProvider);
  
  // 해당 그룹의 모든 Goal 조회
  final goalsSnapshot = await firestore
      .collection('group_goals')
      .where('group_id', isEqualTo: params.groupId)
      .get();

  if (goalsSnapshot.docs.isEmpty) {
    yield UserReadingStatsModel(
      userId: params.userId,
      displayName: params.userName,
      dailyReadings: {},
    );
    return;
  }

  // 각 Goal의 map_state에서 사용자의 읽기 기록 수집
  final Map<String, int> dailyReadings = {};

  for (final goalDoc in goalsSnapshot.docs) {
    final goalId = goalDoc.id;
    
    final mapStateDoc = await firestore
        .collection('group_map_state')
        .doc(goalId)
        .get();

    if (!mapStateDoc.exists) continue;

    final mapState = GroupMapStateModel.fromJson(mapStateDoc.id, mapStateDoc.data()!);
    
    // 각 챕터에서 사용자가 완료한 기록 추출
    for (final entry in mapState.chapters.entries) {
      final chapter = entry.value;
      
      // distributive mode: clearedBy 확인
      if (chapter.clearedBy == params.userId && chapter.clearedAt != null) {
        final dateStr = _formatDate(chapter.clearedAt!);
        dailyReadings[dateStr] = (dailyReadings[dateStr] ?? 0) + 1;
      }
      
      // collaborative mode: completedUsers 확인
      if (chapter.completedUsers.contains(params.userId) && chapter.clearedAt != null) {
        final dateStr = _formatDate(chapter.clearedAt!);
        // 이미 카운트되지 않았다면 추가
        if (chapter.clearedBy != params.userId) {
          dailyReadings[dateStr] = (dailyReadings[dateStr] ?? 0) + 1;
        }
      }
    }
  }

  yield UserReadingStatsModel.fromDailyReadings(
    userId: params.userId,
    displayName: params.userName,
    dailyReadings: dailyReadings,
  );
});

/// 팀 통계 데이터
class TeamStatsData {
  final String groupId;
  final Map<String, int> dailyReadings;
  final int totalChaptersRead;
  final int activeGoalsCount;
  final List<MemberStat> memberStats;

  TeamStatsData({
    required this.groupId,
    required this.dailyReadings,
    required this.totalChaptersRead,
    required this.activeGoalsCount,
    required this.memberStats,
  });
}

class MemberStat {
  final String userId;
  final String displayName;
  final int clearedCount;

  MemberStat({
    required this.userId,
    required this.displayName,
    required this.clearedCount,
  });
}

/// 팀 읽기 통계 Provider
final teamReadingStatsProvider = StreamProvider.family<TeamStatsData, String>((ref, groupId) async* {
  final firestore = ref.watch(firestoreProvider);
  
  // 해당 그룹의 모든 Goal 조회
  final goalsSnapshot = await firestore
      .collection('group_goals')
      .where('group_id', isEqualTo: groupId)
      .get();

  if (goalsSnapshot.docs.isEmpty) {
    yield TeamStatsData(
      groupId: groupId,
      dailyReadings: {},
      totalChaptersRead: 0,
      activeGoalsCount: 0,
      memberStats: [],
    );
    return;
  }

  final Map<String, int> teamDailyReadings = {};
  final Map<String, MemberStat> memberStatsMap = {};
  int totalCleared = 0;
  int activeGoals = 0;

  for (final goalDoc in goalsSnapshot.docs) {
    final goalId = goalDoc.id;
    final goalData = goalDoc.data();
    
    if (goalData['status'] == 'ACTIVE') {
      activeGoals++;
    }

    final mapStateDoc = await firestore
        .collection('group_map_state')
        .doc(goalId)
        .get();

    if (!mapStateDoc.exists) continue;

    final mapState = GroupMapStateModel.fromJson(mapStateDoc.id, mapStateDoc.data()!);
    
    // 팀 전체 일별 읽기 수집
    for (final entry in mapState.chapters.entries) {
      final chapter = entry.value;
      
      if (chapter.clearedAt != null) {
        final dateStr = _formatDate(chapter.clearedAt!);
        teamDailyReadings[dateStr] = (teamDailyReadings[dateStr] ?? 0) + 1;
        totalCleared++;
      }
    }

    // 멤버별 통계 수집
    for (final userStatEntry in mapState.stats.userStats.entries) {
      final userId = userStatEntry.key;
      final userStat = userStatEntry.value;
      
      if (memberStatsMap.containsKey(userId)) {
        final existing = memberStatsMap[userId]!;
        memberStatsMap[userId] = MemberStat(
          userId: userId,
          displayName: existing.displayName,
          clearedCount: existing.clearedCount + userStat.clearedCount,
        );
      } else {
        memberStatsMap[userId] = MemberStat(
          userId: userId,
          displayName: userStat.displayName,
          clearedCount: userStat.clearedCount,
        );
      }
    }
  }

  // 순위별 정렬
  final sortedMembers = memberStatsMap.values.toList()
    ..sort((a, b) => b.clearedCount.compareTo(a.clearedCount));

  yield TeamStatsData(
    groupId: groupId,
    dailyReadings: teamDailyReadings,
    totalChaptersRead: totalCleared,
    activeGoalsCount: activeGoals,
    memberStats: sortedMembers,
  );
});

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
