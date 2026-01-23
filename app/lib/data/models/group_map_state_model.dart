import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMapStateModel {
  final String groupId;
  final Map<String, ChapterStatus> chapters;
  final GroupMapStats stats; // New: Top-level stats

  const GroupMapStateModel({
    required this.groupId,
    required this.chapters,
    required this.stats,
  });

  factory GroupMapStateModel.fromJson(String id, Map<String, dynamic> json) {
    final chaptersMap = json['chapters'] as Map<String, dynamic>? ?? {};
    final statsMap = json['stats'] as Map<String, dynamic>? ?? {};

    return GroupMapStateModel(
      groupId: id,
      chapters: chaptersMap.map(
        (key, value) => MapEntry(key, ChapterStatus.fromJson(value)),
      ),
      stats: GroupMapStats.fromJson(statsMap),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapters': chapters.map((key, value) => MapEntry(key, value.toJson())),
      'stats': stats.toJson(),
    };
  }
}

class GroupMapStats {
  final int totalChapters;
  final int clearedCount;
  final Map<String, UserMapStat> userStats;

  const GroupMapStats({
    required this.totalChapters,
    required this.clearedCount,
    required this.userStats,
  });

  factory GroupMapStats.fromJson(Map<String, dynamic> json) {
    final userStatsMap = json['user_stats'] as Map<String, dynamic>? ?? {};
    return GroupMapStats(
      totalChapters: json['total_chapters'] as int? ?? 0,
      clearedCount: json['cleared_count'] as int? ?? 0,
      userStats: userStatsMap.map(
        (key, value) => MapEntry(key, UserMapStat.fromJson(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_chapters': totalChapters,
      'cleared_count': clearedCount,
      'user_stats': userStats.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

class UserMapStat {
  final String userId;
  final String displayName;
  final int clearedCount;
  final int lockedCount;
  final DateTime lastActiveAt;

  const UserMapStat({
    required this.userId,
    required this.displayName,
    this.clearedCount = 0,
    this.lockedCount = 0,
    required this.lastActiveAt,
  });

  factory UserMapStat.fromJson(Map<String, dynamic> json) {
    return UserMapStat(
      userId: json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? 'Unknown',
      clearedCount: json['cleared_count'] as int? ?? 0,
      lockedCount: json['locked_count'] as int? ?? 0,
      lastActiveAt: json['last_active_at'] != null 
          ? (json['last_active_at'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'cleared_count': clearedCount,
      'locked_count': lockedCount,
      'last_active_at': Timestamp.fromDate(lastActiveAt),
    };
  }
}

class ChapterStatus {
  final String status; // 'OPEN', 'LOCKED', 'CLEARED'
  
  // History Fields
  final String? lockedBy;
  final DateTime? lockedAt;
  final String? clearedBy;
  final DateTime? clearedAt;
  
  // Collaborative Reading Field
  final List<String> completedUsers;

  const ChapterStatus({
    required this.status,
    this.lockedBy,
    this.lockedAt,
    this.clearedBy,
    this.clearedAt,
    this.completedUsers = const [],
  });

  factory ChapterStatus.fromJson(Map<String, dynamic> json) {
    return ChapterStatus(
      status: json['status'] as String,
      lockedBy: json['locked_by'] as String?,
      lockedAt: json['locked_at'] != null ? (json['locked_at'] as Timestamp).toDate() : null,
      clearedBy: json['cleared_by'] as String?,
      clearedAt: json['cleared_at'] != null ? (json['cleared_at'] as Timestamp).toDate() : null,
      completedUsers: (json['completed_users'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'locked_by': lockedBy,
      'locked_at': lockedAt != null ? Timestamp.fromDate(lockedAt!) : null,
      'cleared_by': clearedBy,
      'cleared_at': clearedAt != null ? Timestamp.fromDate(clearedAt!) : null,
      'completed_users': completedUsers,
    };
  }
}
