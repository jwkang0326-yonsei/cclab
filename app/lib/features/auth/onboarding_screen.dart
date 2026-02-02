import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/church_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  
  // State to toggle between initial selection and code input
  bool _showCodeInput = false;

  Future<void> _verifyAndJoin() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorText = '코드를 입력해주세요.';
      });
      return;
    }

    try {
      // 1. Verify Code
      final church = await ref.read(churchRepositoryProvider).verifyCode(code);
      
      if (church != null) {
        // 2. Get Current User ID
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          // 3. Update User's Church ID
          await ref.read(userRepositoryProvider).updateChurchId(user.uid, church.id);
          
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${church.name}에 오신 것을 환영합니다!')), 
            );
          }
        }
      } else {
        setState(() {
          _errorText = '유효하지 않은 초대 코드입니다.';
        });
      }
    } catch (e) {
      setState(() {
        _errorText = '오류: $e'; // Show detailed error for debugging
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
      appBar: AppBar(
        title: const Text('교회 선택하기'),
        leading: _showCodeInput 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _showCodeInput = false),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃 (처음으로)',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              // AppRouter matches auth state change and redirects to Login
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _showCodeInput ? _buildCodeInputView(theme) : _buildSelectionView(theme),
      ),
    );
  }

  Widget _buildSelectionView(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '환영합니다!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '함께 걸을 준비가 되셨나요?\n해당하는 항목을 선택해주세요.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 48),
        
        _buildActionCard(
          theme: theme,
          icon: Icons.key_outlined,
          title: '초대 코드가 있어요',
          subtitle: '우리 교회에서 받은 코드를 입력해주세요.',
          onTap: () => setState(() => _showCodeInput = true),
          isPrimary: true,
        ),
        const SizedBox(height: 20),
        _buildActionCard(
          theme: theme,
          icon: Icons.church_outlined,
          title: '새로운 교회 등록하기',
          subtitle: '위드바이블에 우리 교회를 새롭게 등록해요.',
          onTap: () => context.go('/onboarding/create-church'),
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildCodeInputView(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Add some top padding to centering looks good when scrolling isn't needed
          const SizedBox(height: 48), 
          Text(
            '초대 코드를 입력해주세요',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '코드를 입력하시면 해당 교회로\n자동 연결됩니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              labelText: '초대 코드 입력',
              hintText: '예: WITHBIBLE12',
              errorText: _errorText,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
            ),
            textCapitalization: TextCapitalization.characters,
            onSubmitted: (_) => _verifyAndJoin(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _verifyAndJoin,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('참여하기'),
          ),
          // Add extra padding at bottom for keyboard
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: isPrimary ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      type: MaterialType.canvas,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? theme.colorScheme.primary : Colors.grey[300]!,
              width: isPrimary ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                size: 32, 
                color: isPrimary ? theme.colorScheme.onPrimaryContainer : Colors.grey[700]
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPrimary ? theme.colorScheme.onPrimaryContainer : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPrimary ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8) : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right, 
                color: isPrimary ? theme.colorScheme.onPrimaryContainer : Colors.grey
              ),
            ],
          ),
        ),
      ),
    );
  }
}
