import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/church_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/auth_repository.dart';

import 'package:go_router/go_router.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(currentUserProfileProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '안녕하세요,',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${user.name}님, 환영합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (user.churchId != null) ...[
                  const SizedBox(height: 8),
                  _ChurchGroupInfo(
                    churchId: user.churchId!,
                    groupId: user.groupId,
                    role: user.role,
                  ),
                ]
              ],
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("로그아웃"),
                    content: const Text("정말 로그아웃 하시겠습니까?"),
                    actions: [
                      TextButton(onPressed: () => context.pop(), child: const Text("취소")),
                      TextButton(
                        onPressed: () async {
                          context.pop();
                          await ref.read(authRepositoryProvider).signOut();
                        },
                        child: const Text("로그아웃", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: "로그아웃",
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

  const _ChurchGroupInfo({
    required this.churchId,
    this.groupId,
    required this.role,
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
        final church = data[0]; 
        final group = data.length > 1 ? data[1] : null;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoBadge(
              icon: Icons.verified_user_outlined, 
              text: _getRoleDisplayName(role),
              backgroundColor: role == 'admin' ? Colors.amber.withOpacity(0.2) : null,
            ),
            if (church != null)
              _InfoBadge(icon: Icons.church, text: church.name),
            if (group != null)
              _InfoBadge(icon: Icons.people, text: group.name),
          ],
        );
      },
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
