import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../lib/data/models/group_membership_model.dart';
import '../../../lib/data/repositories/group_membership_repository.dart';

void main() {
  group('GroupMembershipRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GroupMembershipRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = GroupMembershipRepository(firestore: fakeFirestore);
    });

    test('getMyGroups should return empty list for user with no memberships', () async {
      final groups = await repository.getMyGroups('user-123');
      expect(groups, isEmpty);
    });

    test('joinGroup should add membership with pending status', () async {
      // Act
      await repository.joinGroup(
        userId: 'user-123',
        groupId: 'group-456',
      );

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('user-123')
          .collection('group_memberships')
          .doc('group-456')
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['status'], 'pending');
      expect(doc.data()?['role'], 'member');
    });

    test('joinAsLeader should add membership with active status and leader role', () async {
      // Act
      await repository.joinAsLeader(
        userId: 'user-123',
        groupId: 'group-456',
      );

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('user-123')
          .collection('group_memberships')
          .doc('group-456')
          .get();

      expect(doc.exists, true);
      expect(doc.data()?['status'], 'active');
      expect(doc.data()?['role'], 'leader');
    });

    test('getMyGroups should return all group memberships', () async {
      // Arrange: 2개 그룹에 가입
      await repository.joinAsLeader(userId: 'user-123', groupId: 'group-1');
      await repository.joinGroup(userId: 'user-123', groupId: 'group-2');

      // Act
      final groups = await repository.getMyGroups('user-123');

      // Assert
      expect(groups.length, 2);
      expect(groups.map((g) => g.groupId).toSet(), {'group-1', 'group-2'});
    });

    test('getActiveGroups should only return active memberships', () async {
      // Arrange: 1개 active, 1개 pending
      await repository.joinAsLeader(userId: 'user-123', groupId: 'group-1');
      await repository.joinGroup(userId: 'user-123', groupId: 'group-2');

      // Act
      final activeGroups = await repository.getActiveGroups('user-123');

      // Assert
      expect(activeGroups.length, 1);
      expect(activeGroups.first.groupId, 'group-1');
      expect(activeGroups.first.status, 'active');
    });

    test('leaveGroup should remove membership document', () async {
      // Arrange
      await repository.joinGroup(userId: 'user-123', groupId: 'group-456');

      // Act
      await repository.leaveGroup(userId: 'user-123', groupId: 'group-456');

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('user-123')
          .collection('group_memberships')
          .doc('group-456')
          .get();

      expect(doc.exists, false);
    });

    test('updateMembershipStatus should update status field', () async {
      // Arrange
      await repository.joinGroup(userId: 'user-123', groupId: 'group-456');

      // Act
      await repository.updateMembershipStatus(
        userId: 'user-123',
        groupId: 'group-456',
        status: 'active',
      );

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('user-123')
          .collection('group_memberships')
          .doc('group-456')
          .get();

      expect(doc.data()?['status'], 'active');
    });

    test('updateMembershipRole should update role field', () async {
      // Arrange
      await repository.joinGroup(userId: 'user-123', groupId: 'group-456');

      // Act
      await repository.updateMembershipRole(
        userId: 'user-123',
        groupId: 'group-456',
        role: 'admin',
      );

      // Assert
      final doc = await fakeFirestore
          .collection('users')
          .doc('user-123')
          .collection('group_memberships')
          .doc('group-456')
          .get();

      expect(doc.data()?['role'], 'admin');
    });

    test('joinGroup should throw when userId is empty', () async {
      expect(
        () => repository.joinGroup(userId: '', groupId: 'group-456'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('joinGroup should throw when groupId is empty', () async {
      expect(
        () => repository.joinGroup(userId: 'user-123', groupId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
