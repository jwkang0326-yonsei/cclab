import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_repository.dart'; // Import for currentUser check

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(
      user.toJson(),
      SetOptions(merge: true),
    );
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> updateChurchId(String uid, String churchId) async {
    await _firestore.collection('users').doc(uid).set({
      'church_id': churchId,
    }, SetOptions(merge: true));
  }

  Future<void> updateGroupId(String uid, String groupId, String status) async {
    await _firestore.collection('users').doc(uid).update({
      'groupId': groupId,
      'groupStatus': status,
    });
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> watchUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }
}

// Providers
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(firestore: ref.watch(firestoreProvider));
});

// Stream provider for the currently authenticated user's profile
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(userRepositoryProvider).watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});
