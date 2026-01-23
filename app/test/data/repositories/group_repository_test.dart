import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../lib/data/models/group_model.dart';
import '../../../lib/data/repositories/group_repository.dart';

void main() {
  group('GroupRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GroupRepository groupRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      groupRepository = GroupRepository(firestore: fakeFirestore);
    });

    test('createGroup should add a group to Firestore', () async {
      final newGroup = GroupModel(
        id: '',
        churchId: 'church-123',
        name: 'Youth Cell 1',
        leaderUid: 'user-123',
        memberCount: 1,
        createdAt: DateTime.now(),
      );

      final groupId = await groupRepository.createGroup(newGroup);

      final docSnapshot = await fakeFirestore.collection('groups').doc(groupId).get();
      expect(docSnapshot.exists, true);
      expect(docSnapshot.data()?['name'], 'Youth Cell 1');
      expect(docSnapshot.data()?['leaderUid'], 'user-123');
    });

    test('getGroup should return group data', () async {
      final groupData = {
        'churchId': 'church-123',
        'name': 'Youth Cell 1',
        'leaderUid': 'user-123',
        'memberCount': 1,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      final docRef = await fakeFirestore.collection('groups').add(groupData);
      
      final group = await groupRepository.getGroup(docRef.id);
      
      expect(group, isNotNull);
      expect(group!.id, docRef.id);
      expect(group.name, 'Youth Cell 1');
    });

    test('joinGroup should update user document with groupId and status', () async {
      // Arrange
      await fakeFirestore.collection('users').doc('user-1').set({
        'name': 'Test User',
      });

      // Act
      await groupRepository.joinGroup(userId: 'user-1', groupId: 'group-123');

      // Assert
      final userDoc = await fakeFirestore.collection('users').doc('user-1').get();
      expect(userDoc.data()?['groupId'], 'group-123');
      expect(userDoc.data()?['groupStatus'], 'pending');
    });
  });
}
