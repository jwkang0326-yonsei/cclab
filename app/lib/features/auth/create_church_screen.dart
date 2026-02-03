import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeChecked = false;
  String? _errorText;
  String? _codeErrorText;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    if (code.length < 4) {
      setState(() => _codeErrorText = '4자 이상 입력해주세요.');
      return;
    }

    final isAvailable = await ref.read(churchRepositoryProvider).checkInviteCodeAvailability(code);
    setState(() {
      _isCodeChecked = isAvailable;
      _codeErrorText = isAvailable ? null : '이미 사용 중인 코드입니다.';
    });
  }

  Future<void> _createChurch() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();

    if (name.isEmpty) {
      setState(() => _errorText = '교회 이름을 입력해주세요.');
      return;
    }
    
    if (code.isNotEmpty && !_isCodeChecked) {
      await _checkCode();
      if (_codeErrorText != null) return;
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
        inviteCode: code.isNotEmpty ? code : null,
      );

      // 2. Update User's Church ID and Role
      await ref.read(userRepositoryProvider).updateChurchId(user.uid, church.id);
      await ref.read(userRepositoryProvider).updateUserRole(user.uid, 'admin');

      if (mounted) {
        // Show Success Dialog with Copy Code
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('교회 생성 완료!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('교회가 성공적으로 개척되었습니다.\n아래 초대 코드를 복사하여 성도님들을 초대하세요.'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        church.inviteCode,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
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
                  context.pop(); // Close dialog
                  // AppRouter will redirect to Home automatically
                },
                child: const Text('시작하기'),
              ),
            ],
          ),
        );
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
        child: SingleChildScrollView(
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
                '교회 이름과 초대 코드를 설정해주세요.\n생성한 분이 관리자가 됩니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Church Name Input
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

              // Invite Code Input
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: '초대 코드 (선택)',
                        hintText: '예: LOVE2024',
                        errorText: _codeErrorText,
                        helperText: _isCodeChecked ? '사용 가능한 코드입니다.' : null,
                        helperStyle: const TextStyle(color: Colors.green),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.key),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => setState(() => _isCodeChecked = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _checkCode,
                      child: const Text('중복 확인'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '* 입력하지 않으면 자동으로 생성됩니다.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 40),
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
      ),
    );
  }
}
