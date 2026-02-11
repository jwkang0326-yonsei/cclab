import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/group_membership_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/group_model.dart';
import '../../../data/services/last_group_service.dart';
import '../../../data/repositories/auth_repository.dart';

/// 그룹 선택 화면의 상태
class GroupSelectionState {
  final List<GroupModel> groups;
  final String? lastGroupId;
  final bool isLoading;
  final String? error;

  const GroupSelectionState({
    this.groups = const [],
    this.lastGroupId,
    this.isLoading = false,
    this.error,
  });

  GroupSelectionState copyWith({
    List<GroupModel>? groups,
    String? lastGroupId,
    bool? isLoading,
    String? error,
  }) {
    return GroupSelectionState(
      groups: groups ?? this.groups,
      lastGroupId: lastGroupId ?? this.lastGroupId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 그룹 선택 화면 ViewModel (Riverpod 3.x Notifier 패턴)
class GroupSelectionViewModel extends Notifier<GroupSelectionState> {
  @override
  GroupSelectionState build() {
    // build() 완료 후 그룹 목록 로드 (순환 의존성 방지)
    Future.microtask(() => _loadGroups());
    return const GroupSelectionState(isLoading: true);
  }

  /// 내 그룹 목록 로드
  Future<void> _loadGroups() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authState = ref.read(authStateProvider);
      final userId = authState.value?.uid;
      
      if (userId == null) {
        state = state.copyWith(isLoading: false, groups: []);
        return;
      }
      
      // 1. 먼저 새 서브컬렉션에서 그룹 목록 시도
      final membershipRepository = ref.read(groupMembershipRepositoryProvider);
      List<GroupModel> groups = await membershipRepository.getMyGroupsWithDetails(userId);
      
      // 2. 새 서브컬렉션이 비어있으면 기존 UserModel.groupId 사용 (마이그레이션 전 fallback)
      if (groups.isEmpty) {
        final userProfile = ref.read(currentUserProfileProvider).value;
        if (userProfile?.groupId != null) {
          final groupRepository = ref.read(groupRepositoryProvider);
          final group = await groupRepository.getGroup(userProfile!.groupId!);
          if (group != null) {
            groups = [group];
          }
        }
      }
      
      String? lastGroupId;
      try {
        final lastGroupService = ref.read(lastGroupServiceProvider);
        lastGroupId = lastGroupService.getLastGroupId();
      } catch (e) {
        // lastGroupServiceProvider가 아직 초기화되지 않은 경우 무시
      }
      
      state = state.copyWith(
        groups: groups,
        lastGroupId: lastGroupId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 그룹 선택 시 호출
  Future<void> selectGroup(String groupId) async {
    try {
      final lastGroupService = ref.read(lastGroupServiceProvider);
      await lastGroupService.setLastGroupId(groupId);
      state = state.copyWith(lastGroupId: groupId);
    } catch (e) {
      // 저장 실패해도 진행
    }
  }

  /// 새로고침
  Future<void> refresh() => _loadGroups();
}

/// GroupSelectionViewModel Provider
final groupSelectionViewModelProvider =
    NotifierProvider<GroupSelectionViewModel, GroupSelectionState>(
  GroupSelectionViewModel.new,
);

