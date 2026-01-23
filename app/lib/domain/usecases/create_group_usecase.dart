import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';

class CreateGroupUseCase {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;

  CreateGroupUseCase(this._groupRepository, this._userRepository);

  Future<String> execute({
    required String churchId,
    required String name,
    required String leaderUid,
  }) async {
    // 1. Validate inputs (e.g., name length)
    if (name.trim().isEmpty) {
      throw Exception('Group name cannot be empty');
    }

    // 2. Create GroupModel
    final newGroup = GroupModel(
      id: '', // Will be assigned by Firestore
      churchId: churchId,
      name: name.trim(),
      leaderUid: leaderUid,
      memberCount: 1, // Leader is the first member
      createdAt: DateTime.now(),
    );

    // 3. Save to Repository
    final groupId = await _groupRepository.createGroup(newGroup);

    // 4. Update User's Group ID and Status (Auto-join as leader)
    // Also set role to 'leader'
    await _userRepository.updateGroupId(leaderUid, groupId, 'active');
    await _userRepository.updateUserRole(leaderUid, 'leader');

    return groupId;
  }
}
