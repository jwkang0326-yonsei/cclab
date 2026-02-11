import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_membership_model.dart';
import '../models/group_model.dart';

/// 다중 그룹 멤버십 관리를 위한 Repository
/// Firestore 서브컬렉션: users/{userId}/group_memberships/{groupId}
class GroupMembershipRepository {
  final FirebaseFirestore _firestore;

  GroupMembershipRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 내가 속한 모든 그룹 멤버십 조회
  Future<List<GroupMembershipModel>> getMyGroups(String userId) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .get();

    return snapshot.docs
        .map((doc) => GroupMembershipModel.fromFirestore(doc))
        .toList();
  }

  /// 내 그룹 멤버십 스트림 (실시간 업데이트)
  Stream<List<GroupMembershipModel>> getMyGroupsStream(String userId) {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupMembershipModel.fromFirestore(doc))
            .toList());
  }

  /// 활성 상태(active)인 그룹만 조회
  Future<List<GroupMembershipModel>> getActiveGroups(String userId) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .where('status', isEqualTo: 'active')
        .get();

    return snapshot.docs
        .map((doc) => GroupMembershipModel.fromFirestore(doc))
        .toList();
  }

  /// 그룹 가입 요청 (pending 상태로 추가)
  Future<void> joinGroup({
    required String userId,
    required String groupId,
    String role = 'member',
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (groupId.isEmpty) throw ArgumentError('groupId cannot be empty');

    final membership = GroupMembershipModel(
      groupId: groupId,
      role: role,
      status: 'pending',
      joinedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .doc(groupId)
        .set(membership.toMap());
  }

  /// 그룹 생성 시 리더로 바로 가입 (active 상태)
  Future<void> joinAsLeader({
    required String userId,
    required String groupId,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (groupId.isEmpty) throw ArgumentError('groupId cannot be empty');

    final membership = GroupMembershipModel(
      groupId: groupId,
      role: 'leader',
      status: 'active',
      joinedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .doc(groupId)
        .set(membership.toMap());
  }

  /// 그룹 탈퇴
  Future<void> leaveGroup({
    required String userId,
    required String groupId,
  }) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (groupId.isEmpty) throw ArgumentError('groupId cannot be empty');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .doc(groupId)
        .delete();
  }

  /// 멤버십 상태 업데이트 (pending → active)
  Future<void> updateMembershipStatus({
    required String userId,
    required String groupId,
    required String status,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .doc(groupId)
        .update({'status': status});
  }

  /// 멤버십 역할 업데이트 (member → admin)
  Future<void> updateMembershipRole({
    required String userId,
    required String groupId,
    required String role,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('group_memberships')
        .doc(groupId)
        .update({'role': role});
  }

  /// 내 활성 그룹 목록과 그룹 상세 정보 함께 조회
  Future<List<GroupModel>> getMyGroupsWithDetails(String userId) async {
    final memberships = await getActiveGroups(userId);
    
    if (memberships.isEmpty) return [];

    final groupIds = memberships.map((m) => m.groupId).toList();
    
    // Firestore 'in' 쿼리는 최대 30개까지 지원
    final List<GroupModel> groups = [];
    for (var i = 0; i < groupIds.length; i += 30) {
      final batch = groupIds.sublist(
        i,
        i + 30 > groupIds.length ? groupIds.length : i + 30,
      );
      
      final snapshot = await _firestore
          .collection('groups')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      
      groups.addAll(
        snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)),
      );
    }
    
    return groups;
  }
}

// Riverpod Providers
final groupMembershipRepositoryProvider = Provider<GroupMembershipRepository>(
  (ref) => GroupMembershipRepository(),
);

/// 현재 로그인 사용자의 활성 그룹 목록 Provider
final myActiveGroupsProvider = FutureProvider<List<GroupModel>>((ref) async {
  // TODO: authStateProvider에서 userId 가져오기
  // final userId = ref.watch(authStateProvider).value?.uid;
  // if (userId == null) return [];
  // return ref.watch(groupMembershipRepositoryProvider).getMyGroupsWithDetails(userId);
  return [];
});
