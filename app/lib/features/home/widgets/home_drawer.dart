import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          userAsync.when(
            data: (user) => UserAccountsDrawerHeader(
              accountName: Text(
                user?.name ?? '사용자',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.email ?? ''),
                  if (user?.position != null)
                    Text(
                      user!.position!,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (user?.name?.isNotEmpty == true ? user!.name![0] : 'U'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
            ),
            loading: () => const DrawerHeader(child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const DrawerHeader(child: Text('Error')),
          ),
          
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('프로필 설정'),
            subtitle: const Text('이름 및 직책 수정'),
            onTap: () {
              context.pop(); // Drawer 닫기
              context.push('/profile-setup');
            },
          ),
          
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("로그아웃"),
                  content: const Text("정말 로그아웃 하시겠습니까?"),
                  actions: [
                    TextButton(onPressed: () => context.pop(), child: const Text("취소")),
                    TextButton(
                      onPressed: () async {
                        context.pop(); // Dialog 닫기
                        // Drawer는 닫을 필요 없이 리다이렉트됨
                        await ref.read(authRepositoryProvider).signOut();
                      },
                      child: const Text("로그아웃", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_off, color: Colors.grey),
            title: const Text('회원 탈퇴', style: TextStyle(color: Colors.grey)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("회원 탈퇴"),
                  content: const Text("정말 탈퇴하시겠습니까?\n계정과 모든 데이터가 삭제되며 복구할 수 없습니다."),
                  actions: [
                    TextButton(onPressed: () => context.pop(), child: const Text("취소")),
                    TextButton(
                      onPressed: () async {
                        try {
                          final user = ref.read(authRepositoryProvider).currentUser;
                          if (user != null) {
                            final uid = user.uid;
                            // 1. Firestore 데이터 삭제
                            await ref.read(userRepositoryProvider).deleteUser(uid);
                            // 2. Auth 계정 삭제
                            await ref.read(authRepositoryProvider).deleteAccount();
                            
                            if (context.mounted) {
                              context.pop(); // Dialog 닫기
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            context.pop(); // Dialog 닫기
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('탈퇴 실패: $e\n다시 로그인 후 시도해주세요.')),
                            );
                          }
                        }
                      },
                      child: const Text("탈퇴", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}
