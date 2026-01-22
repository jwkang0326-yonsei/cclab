import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/group_repository.dart';
import 'viewmodels/group_view_model.dart';
import 'widgets/group_create_bottom_sheet.dart';
import 'widgets/group_bible_map_tab.dart';

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));

        if (user.groupId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('그룹')),
            body: _buildNoGroupView(context, ref, user!),
          );
        }

        if (user.groupStatus == 'pending') {
          return Scaffold(
            appBar: AppBar(title: const Text('그룹')),
            body: _buildPendingView(context, user),
          );
        }

        // Group Exists and User is Active - Show Admin/Detail View
        final isLeader = user.role == 'leader';
        final tabs = [
          const Tab(text: '목표'),
          const Tab(text: '구성원'),
          if (isLeader) const Tab(text: '가입 요청'),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('그룹 관리'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    final inviteLink = 'withbible://invite/group/${user.groupId}';
                    Share.share('우리 그룹에 초대합니다! 링크를 클릭해 가입하세요:\n$inviteLink');
                  },
                ),
              ],
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                tabs: tabs,
              ),
            ),
            body: TabBarView(
              children: [
                GroupBibleMapTab(groupId: user.groupId!, isLeader: isLeader),
                _buildActiveMembersTab(ref, user.groupId!),
                if (isLeader) _buildPendingMembersTab(ref, user.groupId!),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('에러 발생: $e'))),
    );
  }

  Widget _buildNoGroupView(BuildContext context, WidgetRef ref, UserModel user) {
    // 1. If user has no church, show guidance to join church (or create group directly if allowed)
    // Currently assuming users usually join church first via Invite Code.
    if (user.churchId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.church_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              '아직 교회에 소속되지 않았습니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '홈 화면의 설정이나 초대 코드를 통해\n교회에 먼저 가입해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            // Optional: Button to go to onboarding or create church
          ],
        ),
      );
    }

    // 2. Fetch Church Groups
    final groupsAsync = ref.watch(churchGroupsProvider(user.churchId!));

    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('그룹 목록 로딩 에러: $e')),
      data: (groups) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateGroupSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('새 그룹 만들기'),
          ),
          body: groups.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.group_off_outlined, size: 80, color: Colors.grey),
                      const SizedBox(height: 24),
                      const Text(
                        '개설된 그룹이 없습니다.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '첫 번째 그룹을 만들어보세요!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // Fab space
                  itemCount: groups.length + 1, // Header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '참여할 그룹을 선택하세요',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }

                    final group = groups[index - 1];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text('${group.memberCount}'),
                        ),
                        title: Text(
                            group.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('생성일: ${group.createdAt.toString().split(' ')[0]}'),
                        trailing: FilledButton.tonal(
                          onPressed: () async {
                            final shouldJoin = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('${group.name} 가입'),
                                content: const Text('이 그룹에 가입하시겠습니까?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('가입하기')),
                                ],
                              ),
                            );

                            if (shouldJoin == true) {
                              try {
                                await ref.read(groupRepositoryProvider).joinGroup(
                                  userId: user.uid,
                                  groupId: group.id,
                                );
                                // Refresh current user to update UI
                                ref.invalidate(currentUserProfileProvider);
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('가입 요청이 전송되었습니다.')),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('가입 실패: $e')),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text('가입'),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildActiveMembersTab(WidgetRef ref, String groupId) {
    final activeMembersAsync = ref.watch(activeGroupMembersProvider(groupId));
    
    return activeMembersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('소속된 구성원이 없습니다.'));
        }
        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(child: Text(member.name?[0] ?? '?')),
              title: Text(member.name ?? member.email),
              subtitle: Text(member.email),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPendingMembersTab(WidgetRef ref, String groupId) {
    final pendingMembersAsync = ref.watch(pendingGroupMembersProvider(groupId));

    return pendingMembersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('대기 중인 가입 요청이 없습니다.'));
        }
        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(child: Text(member.name?[0] ?? '?')),
              title: Text(member.name ?? member.email),
              subtitle: Text(member.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveMember(ref, member.uid, groupId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _rejectMember(ref, member.uid, groupId),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPendingView(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pending_actions, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            '가입 승인 대기 중입니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '그룹 리더의 승인을 기다리고 있습니다.\n잠시만 기다려주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _approveMember(WidgetRef ref, String userId, String groupId) async {
    await ref.read(groupRepositoryProvider).updateMemberStatus(
      userId: userId, 
      status: 'active'
    );
    ref.invalidate(pendingGroupMembersProvider(groupId));
    ref.invalidate(activeGroupMembersProvider(groupId));
  }

  Future<void> _rejectMember(WidgetRef ref, String userId, String groupId) async {
    await ref.read(groupRepositoryProvider).updateMemberStatus(
      userId: userId, 
      status: 'rejected'
    );
    ref.invalidate(pendingGroupMembersProvider(groupId));
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const GroupCreateBottomSheet(),
    );
  }
}