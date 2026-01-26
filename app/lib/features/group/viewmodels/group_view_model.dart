import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../domain/usecases/create_group_usecase.dart';
import '../../../data/repositories/user_repository.dart';

// groupRepositoryProvider is now imported from group_repository.dart

final createGroupUseCaseProvider = Provider<CreateGroupUseCase>((ref) {
  return CreateGroupUseCase(
    ref.watch(groupRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

class GroupViewModel extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createGroup(String name) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) throw Exception('User profile not found');
      if (userProfile.churchId == null) throw Exception('No church assigned');

      await ref.read(createGroupUseCaseProvider).execute(
        churchId: userProfile.churchId!,
        name: name,
        leaderUid: userProfile.uid,
      );
      
      // Force refresh of user profile to reflect new group assignment
      ref.invalidate(currentUserProfileProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinGroup(String groupId) async {
    state = const AsyncValue.loading();
    try {
      final userProfile = ref.read(currentUserProfileProvider).value;
      if (userProfile == null) throw Exception('User profile not found');

      await ref.read(groupRepositoryProvider).joinGroup(
        userId: userProfile.uid, 
        groupId: groupId,
      );
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final groupViewModelProvider = NotifierProvider<GroupViewModel, AsyncValue<void>>(() {
  return GroupViewModel();
});

final pendingGroupMembersProvider = StreamProvider.family<List<UserModel>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getMembersStream(groupId: groupId, status: 'pending');
});

final activeGroupMembersProvider = StreamProvider.family<List<UserModel>, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).getMembersStream(groupId: groupId, status: 'active');
});