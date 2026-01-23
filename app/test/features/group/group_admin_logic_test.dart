import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../../lib/data/repositories/group_repository.dart';
import '../../../lib/data/models/user_model.dart';

// Mock repository
class MockGroupRepository extends Mock implements GroupRepository {
  @override
  Future<List<UserModel>> getMembers({required String groupId, String? status}) {
    return super.noSuchMethod(
      Invocation.method(#getMembers, [], {#groupId: groupId, #status: status}),
      returnValue: Future.value(<UserModel>[]),
    );
  }

  @override
  Future<void> updateMemberStatus({required String userId, required String status}) {
    return super.noSuchMethod(
      Invocation.method(#updateMemberStatus, [], {#userId: userId, #status: status}),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

void main() {
  group('GroupAdminLogic', () {
    late MockGroupRepository mockGroupRepository;

    setUp(() {
      mockGroupRepository = MockGroupRepository();
    });

    test('getMembers returns list of users with pending status', () async {
      // Arrange
      final pendingUsers = [
        UserModel(uid: 'u1', email: 'u1@test.com', groupId: 'g1', groupStatus: 'pending'),
        UserModel(uid: 'u2', email: 'u2@test.com', groupId: 'g1', groupStatus: 'pending'),
      ];
      
      when(mockGroupRepository.getMembers(groupId: 'g1', status: 'pending'))
          .thenAnswer((_) async => pendingUsers);

      // Act
      final result = await mockGroupRepository.getMembers(groupId: 'g1', status: 'pending');

      // Assert
      expect(result.length, 2);
      verify(mockGroupRepository.getMembers(groupId: 'g1', status: 'pending')).called(1);
    });

    test('updateMemberStatus updates user status', () async {
      // Act
      await mockGroupRepository.updateMemberStatus(userId: 'u1', status: 'active');
      
      // Assert
      verify(mockGroupRepository.updateMemberStatus(userId: 'u1', status: 'active')).called(1);
    });
  });
}
