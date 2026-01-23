import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String churchId;
  final String name;
  final String leaderUid;
  final int memberCount;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.churchId,
    required this.name,
    required this.leaderUid,
    this.memberCount = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'churchId': churchId,
      'name': name,
      'leaderUid': leaderUid,
      'memberCount': memberCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupModel(
      id: id,
      churchId: map['churchId'] ?? '',
      name: map['name'] ?? '',
      leaderUid: map['leaderUid'] ?? '',
      memberCount: map['memberCount'] ?? 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    return GroupModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
