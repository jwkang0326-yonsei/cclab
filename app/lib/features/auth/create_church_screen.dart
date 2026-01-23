import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/church_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

class CreateChurchScreen extends ConsumerStatefulWidget {
  const CreateChurchScreen({super.key});

  @override
  ConsumerState<CreateChurchScreen> createState() => _CreateChurchScreenState();
}

class _CreateChurchScreenState extends ConsumerState<CreateChurchScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createChurch() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorText = '교회 이름을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user == null) {
        throw Exception('로그인이 필요합니다.');
      }

      // 1. Create Church
      final church = await ref.read(churchRepositoryProvider).createChurch(
        name: name,
        adminId: user.uid,
      );

      // 2. Update User's Church ID and Role
      await ref.read(userRepositoryProvider).updateChurchId(user.uid, church.id);
      await ref.read(userRepositoryProvider).updateUserRole(user.uid, 'admin');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${church.name}가 생성되었습니다!')),
        );
        // AppRouter will redirect to Home automatically
      }
    } catch (e) {
      setState(() {
        _errorText = '교회 생성 중 오류가 발생했습니다: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('교회 개척하기')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '새로운 교회를 등록합니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '교회 이름을 입력하면 즉시 생성되며,\n생성한 분이 관리자가 됩니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '교회 이름',
                hintText: '예: 위드바이블 교회',
                errorText: _errorText,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.church),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _createChurch,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('교회 생성 및 시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}
