import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/church_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/models/church_model.dart';

import 'package:go_router/go_router.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  // 앱스토어 스크린샷용 더미 데이터
  static const bool _isScreenshotMode = false; // 릴리즈 전 false로 변경
  static const String _dummyName = '김성경';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final displayName = _isScreenshotMode ? _dummyName : user.name;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요,',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${displayName}님, 환영합니다',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (user.churchId != null && user.churchId != 'none') ...[
                    const SizedBox(height: 8),
                    _ChurchGroupInfo(
                      churchId: user.churchId!,
                      groupId: user.groupId,
                      role: user.role,
                      position: user.position,
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu),
              tooltip: "메뉴",
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

class _ChurchGroupInfo extends ConsumerWidget {
  final String churchId;
  final String? groupId;
  final String role;
  final String? position;

  const _ChurchGroupInfo({
    required this.churchId,
    this.groupId,
    required this.role,
    this.position,
  });

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return '관리자';
      case 'leader':
        return '리더';
      case 'member':
        return '성도';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Future.wait<dynamic>([
        ref.read(churchRepositoryProvider).getChurch(churchId),
        if (groupId != null) 
          ref.read(groupRepositoryProvider).getGroup(groupId!)
        else 
          Future.value(null),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 20); // Placeholder height

        final data = snapshot.data as List<dynamic>;
        final church = data[0] as ChurchModel?; 
        final group = data.length > 1 ? data[1] : null;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoBadge(
              icon: Icons.verified_user_outlined, 
              text: position ?? _getRoleDisplayName(role),
              backgroundColor: role == 'admin' ? Colors.amber.withOpacity(0.2) : null,
            ),
            if (church != null)
              _ChurchBadge(church: church),
            if (group != null)
              _GroupBadge(groupName: group.name),
          ],
        );
      },
    );
  }
}

/// 교회 배지 - 탭 시 초대 코드 확인 및 복사 팝업
class _ChurchBadge extends StatelessWidget {
  final ChurchModel church;

  const _ChurchBadge({required this.church});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _showInviteCodeDialog(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.church, size: 14, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 6),
            Text(
              church.name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  void _showInviteCodeDialog(BuildContext context) {
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

/// 그룹 배지 - 탭 시 그룹 선택 화면으로 이동
class _GroupBadge extends StatelessWidget {
  final String groupName;

  const _GroupBadge({required this.groupName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () {
        // 그룹 선택 화면으로 이동
        context.push('/group-selection');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              groupName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.swap_horiz, size: 12, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? backgroundColor;

  const _InfoBadge({
    required this.icon, 
    required this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
