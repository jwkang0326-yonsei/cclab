import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자의 그룹 멤버십 정보를 나타내는 모델
/// Firestore 경로: users/{userId}/group_memberships/{groupId}
class GroupMembershipModel {
  final String groupId;
  final String role;      // 'leader' | 'admin' | 'member'
  final String status;    // 'pending' | 'active'
  final DateTime joinedAt;

  GroupMembershipModel({
    required this.groupId,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'role': role,
      'status': status,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory GroupMembershipModel.fromMap(Map<String, dynamic> map, String id) {
    return GroupMembershipModel(
      groupId: id,
      role: map['role'] ?? 'member',
      status: map['status'] ?? 'pending',
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
    );
  }

  factory GroupMembershipModel.fromFirestore(DocumentSnapshot doc) {
    return GroupMembershipModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  GroupMembershipModel copyWith({
    String? groupId,
    String? role,
    String? status,
    DateTime? joinedAt,
  }) {
    return GroupMembershipModel(
      groupId: groupId ?? this.groupId,
      role: role ?? this.role,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
