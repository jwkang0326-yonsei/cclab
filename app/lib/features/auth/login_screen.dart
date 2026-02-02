import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  bool _isLoginMode = true; // 로그인/회원가입 모드 전환
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _syncUserToFirestore(
    String uid, {
    String? email,
    String? name,
    String provider = 'unknown',
  }) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      final existingUser = await userRepo.getUser(uid);
      bool isNewUser = false;

      if (existingUser == null) {
        // Create new user
        isNewUser = true;
        final userModel = UserModel(
          uid: uid,
          email: email ?? '',
          name: name,
        );
        await userRepo.createUser(userModel);
      } else {
        // Update existing user (Smart Sync)
        bool needsUpdate = false;
        String? newName = existingUser.name;
        String newEmail = existingUser.email;

        if ((existingUser.name == null || existingUser.name!.isEmpty) &&
            name != null &&
            name.isNotEmpty) {
          newName = name;
          needsUpdate = true;
        }

        if (existingUser.email.isEmpty && email != null && email.isNotEmpty) {
          newEmail = email;
          needsUpdate = true;
        }

        if (needsUpdate) {
          final updatedUser = UserModel(
            uid: uid,
            email: newEmail,
            name: newName,
            churchId: existingUser.churchId,
            groupId: existingUser.groupId,
            groupStatus: existingUser.groupStatus,
            role: existingUser.role,
            position: existingUser.position,
          );
          await userRepo.createUser(updatedUser);
        }
      }
      
      if (mounted) {
        // 신규 유저이거나 이름이 설정되지 않은 경우 프로필 설정 화면으로 이동
        // 직책(position)은 선택 사항이므로 체크하지 않음
        final needsProfileSetup = isNewUser || 
            existingUser?.name == null || 
            existingUser!.name!.isEmpty;
        
        if (needsProfileSetup) {
           context.go('/profile-setup');
        }
      }

    } catch (e) {
      print('Firestore Sync Error: $e');
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    _setLoading(true);
    try {
      UserCredential? credential;
      if (_isLoginMode) {
        credential = await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      } else {
        credential = await ref.read(authRepositoryProvider).signUpWithEmail(email, password);
      }

      if (credential != null && credential.user != null) {
        await _syncUserToFirestore(
          credential.user!.uid,
          email: credential.user!.email,
          name: credential.user!.displayName,
          provider: 'email',
        );
      }
    } catch (e) {
      _showErrorSnackBar(_isLoginMode ? '로그인 실패: $e' : '회원가입 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleAppleLogin() async {
    _setLoading(true);
    try {
      final UserCredential? credential = await ref.read(authRepositoryProvider).signInWithApple();
      if (credential != null && credential.user != null) {
        await _syncUserToFirestore(
          credential.user!.uid,
          email: credential.user!.email,
          name: credential.user!.displayName ?? 'Apple User',
          provider: 'apple',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Apple 로그인 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    _setLoading(true);
    try {
      final UserCredential? credential = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (credential != null && credential.user != null) {
        await _syncUserToFirestore(
          credential.user!.uid,
          email: credential.user!.email,
          name: credential.user!.displayName,
          provider: 'google',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Google 로그인 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _handleKakaoLogin() async {
    _setLoading(true);
    try {
      final kakaoUser = await ref.read(authRepositoryProvider).signInWithKakao();
      if (kakaoUser != null) {
        final auth = FirebaseAuth.instance;
        UserCredential cred = await auth.signInAnonymously();
        if (cred.user != null) {
          await _syncUserToFirestore(
            cred.user!.uid,
            email: kakaoUser.kakaoAccount?.email ?? '',
            name: kakaoUser.kakaoAccount?.profile?.nickname ?? 'Kakao User',
            provider: 'kakao',
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Kakao 로그인 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // Logo
                  Text(
                    'WithBible',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '함께 읽고, 함께 자라나는 말씀 숲',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Email Form
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: '이메일',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  _LoginButton(
                    text: _isLoginMode ? '로그인' : '회원가입',
                    backgroundColor: theme.colorScheme.primary,
                    textColor: Colors.white,
                    onPressed: _handleEmailAuth,
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLoginMode = !_isLoginMode),
                    child: Text(_isLoginMode ? '계정이 없으신가요? 회원가입' : '이미 계정이 있으신가요? 로그인'),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('또는 소셜 로그인', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                  ),

                  // Social Logins
                  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) ...[
                    _LoginButton(
                      text: 'Apple로 시작하기',
                      icon: Icons.apple,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      onPressed: _handleAppleLogin,
                    ),
                    const SizedBox(height: 12),
                  ],

                  _LoginButton(
                    text: 'Google로 시작하기',
                    icon: Icons.g_mobiledata,
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                    isOutlined: true,
                    onPressed: _handleGoogleLogin,
                  ),
                  const SizedBox(height: 12),

                  _LoginButton(
                    text: '카카오로 시작하기',
                    icon: Icons.chat_bubble,
                    backgroundColor: const Color(0xFFFEE500),
                    textColor: const Color(0xFF191919),
                    onPressed: _handleKakaoLogin,
                  ),
                  const SizedBox(height: 50),

                  // Version Info
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      return Text(
                        'v${snapshot.data!.version}+${snapshot.data!.buildNumber}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _LoginButton({
    required this.text,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined ? const BorderSide(color: Colors.grey) : BorderSide.none,
        ),
        elevation: isOutlined ? 0 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}