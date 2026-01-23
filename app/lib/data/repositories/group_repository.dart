import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/user_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore;

  GroupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> createGroup(GroupModel group) async {
    final docRef = await _firestore.collection('groups').add(group.toMap());
    return docRef.id;
  }

  Future<GroupModel?> getGroup(String groupId) async {
    final docSnapshot = await _firestore.collection('groups').doc(groupId).get();
    
    if (docSnapshot.exists && docSnapshot.data() != null) {
      return GroupModel.fromFirestore(docSnapshot);
    }
    return null;
  }

  Future<void> joinGroup({required String userId, required String groupId}) async {
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (groupId.isEmpty) throw ArgumentError('groupId cannot be empty');
    
    await _firestore.collection('users').doc(userId).update({
      'groupId': groupId,
      'groupStatus': 'pending',
    });
  }

  Future<List<UserModel>> getMembers({required String groupId, String? status}) async {
    Query query = _firestore.collection('users').where('groupId', isEqualTo: groupId);
    
    if (status != null) {
      query = query.where('groupStatus', isEqualTo: status);
    }
    
    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateMemberStatus({required String userId, required String status}) async {
    await _firestore.collection('users').doc(userId).update({
      'groupStatus': status,
    });
  }
  Future<List<GroupModel>> getGroupsByChurch(String churchId) async {
    final querySnapshot = await _firestore
        .collection('groups')
        .where('churchId', isEqualTo: churchId)
        // .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList();
  }
}

final groupRepositoryProvider = Provider<GroupRepository>((ref) => GroupRepository());

final churchGroupsProvider = FutureProvider.family<List<GroupModel>, String>((ref, churchId) {
  return ref.watch(groupRepositoryProvider).getGroupsByChurch(churchId);
});