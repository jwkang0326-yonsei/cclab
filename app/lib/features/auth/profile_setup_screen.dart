import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final userRepo = ref.read(userRepositoryProvider);
      final userModel = await userRepo.getUser(user.uid);
      if (userModel != null) {
        setState(() {
          _nameController.text = userModel.name ?? user.displayName ?? '';
          _positionController.text = userModel.position ?? '';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final position = _positionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final userRepo = ref.read(userRepositoryProvider);
        // 기존 정보 가져와서 병합
        final existingUser = await userRepo.getUser(user.uid);
        
        if (existingUser != null) {
          final updatedUser = UserModel(
            uid: existingUser.uid,
            email: existingUser.email,
            name: name,
            churchId: existingUser.churchId,
            groupId: existingUser.groupId,
            groupStatus: existingUser.groupStatus,
            role: existingUser.role,
            position: position.isNotEmpty ? position : null,
          );
          await userRepo.createUser(updatedUser);
          
          if (mounted) {
             // churchId가 없으면 Onboarding, 있으면 Home
             if (updatedUser.churchId == null) {
               context.go('/onboarding');
             } else {
               context.go('/');
             }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필 설정')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '원활한 서비스 이용을 위해\n이름과 직책을 설정해주세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: '직책 (선택)',
                hintText: '예: 목사, 장로, 성도',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('저장하고 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
