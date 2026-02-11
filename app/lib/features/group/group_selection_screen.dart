import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/group_model.dart';
import '../../data/services/last_group_service.dart';
import 'viewmodels/group_selection_view_model.dart';

/// 다중 그룹 사용자를 위한 그룹 선택 화면
class GroupSelectionScreen extends ConsumerWidget {
  const GroupSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupSelectionViewModelProvider);
    final viewModel = ref.read(groupSelectionViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('그룹 선택'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(context, ref, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    GroupSelectionState state,
    GroupSelectionViewModel viewModel,
  ) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('오류: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.refresh,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.groups.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.groups.length,
        itemBuilder: (context, index) {
          final group = state.groups[index];
          final isLastGroup = group.id == state.lastGroupId;
          
          return _buildGroupCard(
            context,
            ref,
            group,
            isLastGroup,
            viewModel,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              '소속된 그룹이 없습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '그룹을 만들거나 초대 링크를 통해 가입하세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/group'),
              icon: const Icon(Icons.add),
              label: const Text('그룹 만들기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    bool isLastGroup,
    GroupSelectionViewModel viewModel,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLastGroup ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLastGroup
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _onGroupSelected(context, ref, group, viewModel),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 그룹 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLastGroup
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  size: 28,
                  color: isLastGroup
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(width: 16),
              // 그룹 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isLastGroup)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '최근',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '멤버 ${group.memberCount}명',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              // 화살표
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onGroupSelected(
    BuildContext context,
    WidgetRef ref,
    GroupModel group,
    GroupSelectionViewModel viewModel,
  ) async {
    await viewModel.selectGroup(group.id);
    
    // currentGroupIdProvider 업데이트 (Notifier 패턴)
    ref.read(currentGroupIdProvider.notifier).setGroupId(group.id);
    
    // 홈 화면으로 이동
    if (context.mounted) {
      context.go('/home');
    }
  }
}
