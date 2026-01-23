import 'package:cloud_firestore/cloud_firestore.dart';

class GroupGoalModel {
  final String id;
  final String groupId;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> targetRange; // e.g. ["Matthew", "Mark"] or ["NewTestament"]
  final DateTime createdAt;
  final String status; // 'ACTIVE', 'COMPLETED', 'ARCHIVED'
  final String readingMethod; // 'distributed' (default) or 'collaborative'
  final int totalClearedCount;
  final int activeParticipantCount;
  final Map<String, int> dailyStats;
  final DateTime? updatedAt;

  const GroupGoalModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.targetRange,
    required this.createdAt,
    this.status = 'ACTIVE',
    this.readingMethod = 'distributed',
    this.totalClearedCount = 0,
    this.activeParticipantCount = 0,
    this.dailyStats = const {},
    this.updatedAt,
  });

  factory GroupGoalModel.fromJson(Map<String, dynamic> json) {
    return GroupGoalModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      startDate: (json['start_date'] as Timestamp).toDate(),
      endDate: (json['end_date'] as Timestamp).toDate(),
      targetRange: List<String>.from(json['target_range'] as List),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'ACTIVE',
      readingMethod: json['reading_method'] as String? ?? 'distributed',
      totalClearedCount: json['total_cleared_count'] as int? ?? 0,
      activeParticipantCount: json['active_participant_count'] as int? ?? 0,
      dailyStats: Map<String, int>.from(json['daily_stats'] as Map? ?? {}),
      updatedAt: json['updated_at'] != null ? (json['updated_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'title': title,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'target_range': targetRange,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status,
      'reading_method': readingMethod,
      'total_cleared_count': totalClearedCount,
      'active_participant_count': activeParticipantCount,
      'daily_stats': dailyStats,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
