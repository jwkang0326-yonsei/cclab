class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? churchId;
  final String? groupId;
  final String? groupStatus; // 'pending', 'active', 'rejected'
  final String role; // 'member', 'leader', 'admin'

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.churchId,
    this.groupId,
    this.groupStatus,
    this.role = 'member',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      churchId: json['church_id'],
      groupId: json['groupId'],
      groupStatus: json['groupStatus'],
      role: json['role'] ?? 'member',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'church_id': churchId,
      'groupId': groupId,
      'groupStatus': groupStatus,
      'role': role,
    };
  }
}