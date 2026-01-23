import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/record_model.dart';
import 'church_repository.dart'; // for firestoreProvider

class RecordRepository {
  final FirebaseFirestore _firestore;

  RecordRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> createRecord(RecordModel record) async {
    await _firestore.collection('records').doc(record.id).set(record.toJson());
  }

  Stream<List<RecordModel>> watchValues(String userId) {
    return _firestore
        .collection('records')
        .where('user_uid', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RecordModel.fromJson(doc.data())).toList();
    });
  }
}

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(firestore: ref.watch(firestoreProvider));
});
