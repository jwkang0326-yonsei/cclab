import 'package:cloud_firestore/cloud_firestore.dart';

class ChurchModel {
  final String id;
  final String name;
  final String inviteCode;
  final String adminId;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  const ChurchModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
    required this.status,
    required this.createdAt,
  });

  factory ChurchModel.fromJson(Map<String, dynamic> json) {
    return ChurchModel(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      adminId: json['admin_id'] as String? ?? '', // Default to empty if missing for backward compatibility
      status: json['status'] as String? ?? 'approved', // Default to approved for existing
      createdAt: json['created_at'] != null 
          ? (json['created_at'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'admin_id': adminId,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ChurchModel &&
      other.id == id &&
      other.name == name &&
      other.inviteCode == inviteCode &&
      other.adminId == adminId &&
      other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, name, inviteCode, adminId, status);
}
