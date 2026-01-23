import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'viewmodels/group_view_model.dart';

class JoinGroupScreen extends ConsumerWidget {
  final String groupId;

  const JoinGroupScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupViewModelProvider);
    final isLoading = state is AsyncLoading;

    ref.listen(groupViewModelProvider, (previous, next) {
      if (next is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('가입 요청이 전송되었습니다.')),
        );
        // Navigate to home or group screen to see status
        context.go('/group');
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가입 실패: ${next.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('그룹 가입')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.group_add, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text(
                '그룹 (ID: $groupId) 에\n가입하시겠습니까?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '가입 요청 후 리더의 승인이 필요합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: isLoading 
                    ? null 
                    : () => ref.read(groupViewModelProvider.notifier).joinGroup(groupId),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('가입하기'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('취소하고 홈으로 이동'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}