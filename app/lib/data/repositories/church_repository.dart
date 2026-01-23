import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/church_model.dart';

class ChurchRepository {
  final FirebaseFirestore _firestore;

  ChurchRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<ChurchModel?> getChurch(String id) async {
    try {
      final docSnapshot = await _firestore.collection('churches').doc(id).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return ChurchModel.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<ChurchModel?> verifyCode(String code) async {
    try {
      final querySnapshot = await _firestore
          .collection('churches')
          .where('invite_code', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ChurchModel.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      // Logging or error handling
      return null;
    }
  }

  Future<ChurchModel> createChurch({
    required String name,
    required String adminId,
  }) async {
    final docRef = _firestore.collection('churches').doc();
    final inviteCode = _generateRandomInviteCode();
    
    final church = ChurchModel(
      id: docRef.id,
      name: name,
      inviteCode: inviteCode,
      adminId: adminId,
      status: 'approved', // Test mode: auto-approve
      createdAt: DateTime.now(),
    );

    await docRef.set(church.toJson());
    return church;
  }

  String _generateRandomInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

// Providers
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final churchRepositoryProvider = Provider<ChurchRepository>((ref) {
  return ChurchRepository(firestore: ref.watch(firestoreProvider));
});
