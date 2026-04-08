import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/church_repository.dart';
import '../../../data/models/church_model.dart';

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
            subtitle: const Text('이름 및 직분 수정'),
            onTap: () {
              context.pop(); // Drawer 닫기
              context.push('/profile-setup');
            },
          ),

          if (userAsync.value?.churchId != null && userAsync.value?.churchId != 'none')
            ListTile(
              leading: const Icon(Icons.person_add_alt_outlined),
              title: const Text('성도 초대하기'),
              subtitle: const Text('교회 초대 코드 확인 및 공유'),
              onTap: () async {
                final churchId = userAsync.value!.churchId!;
                final church = await ref.read(churchRepositoryProvider).getChurch(churchId);
                if (church != null && context.mounted) {
                  context.pop(); // Close drawer
                  _showInviteCodeDialog(context, church);
                }
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
          const SizedBox(height: 10),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '0.0.0';
              final buildNumber = snapshot.data?.buildNumber ?? '0';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'v$version+$buildNumber | 2026-02-11 배포',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  void _showInviteCodeDialog(BuildContext context, ChurchModel church) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${church.name} 초대하기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('아래 초대 코드를 성도님들께 공유하여\n함께 성경 읽기를 시작해 보세요!'),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    church.inviteCode,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: '코드 복사',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: church.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('초대 코드가 복사되었습니다.')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final message = '''
[위드바이블] 우리 교회 성경 읽기 모임에 초대합니다! 📖

💒 교회명: ${church.name}
🔑 초대 코드: ${church.inviteCode}

앱 설치 후 위 코드를 입력하여 저희와 함께 믿음의 여정을 시작해 보세요! ✨
''';
              Share.share(message);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share, size: 18),
                SizedBox(width: 4),
                Text('초대장 보내기'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
