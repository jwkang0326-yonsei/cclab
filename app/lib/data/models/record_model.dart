import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String id;
  final String userId;
  final String churchId;
  final String groupId;
  final String bibleRange; // e.g., "Matthew 1"
  final DateTime date;
  final String? meditation;
  final DateTime createdAt;

  const RecordModel({
    required this.id,
    required this.userId,
    required this.churchId,
    required this.groupId,
    required this.bibleRange,
    required this.date,
    this.meditation,
    required this.createdAt,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      id: json['id'] as String,
      userId: json['user_uid'] as String,
      churchId: json['church_id'] as String,
      groupId: json['group_id'] as String,
      bibleRange: json['bible_range'] as String,
      date: (json['date'] as Timestamp).toDate(), // Or String check
      meditation: json['meditation'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uid': userId,
      'church_id': churchId,
      'group_id': groupId,
      'bible_range': bibleRange,
      'date': Timestamp.fromDate(date),
      'meditation': meditation,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}
