import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- TEMPORARY TEST DATA BUTTON ---
            TextButton(
              onPressed: () async {
                final firestore = ref.read(firestoreProvider);
                await firestore.collection('churches').doc('test_church').set({
                  'id': 'test_church',
                  'name': '창천교회 (테스트)',
                  'invite_code': 'TEST1234',
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('테스트 데이터(TEST1234)가 생성되었습니다.')),
                  );
                }
              },
              child: const Text('[임시] 테스트 데이터 생성'),
            ),
            const SizedBox(height: 20),
            // ----------------------------------
            // Logo or App Name
            Text(
              'WithBible',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '함께 읽고, 함께 자라나는 말씀 숲',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 80),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    // 1. Google Login
                    final UserCredential? credential = await ref.read(authRepositoryProvider).signInWithGoogle();
                    
                    if (credential != null && credential.user != null) {
                      final user = credential.user!;
                      final userRepo = ref.read(userRepositoryProvider);
                      
                      // Check if user already exists
                      final existingUser = await userRepo.getUser(user.uid);
                      
                      if (existingUser == null) {
                        // Create User only if new
                        final userModel = UserModel(
                          uid: user.uid,
                          email: user.email ?? '',
                          name: user.displayName ?? 'Unknown',
                        );
                        await userRepo.createUser(userModel);
                      } else {
                        // User exists. Check for missing data (Smart Sync)
                        bool needsUpdate = false;
                        String? newName = existingUser.name;
                        String newEmail = existingUser.email;

                        // Update name if missing in DB but available in Google
                        if ((existingUser.name == null || existingUser.name!.isEmpty) && 
                            user.displayName != null && user.displayName!.isNotEmpty) {
                          newName = user.displayName;
                          needsUpdate = true;
                        }

                        // Update email if missing in DB but available in Google
                        if (existingUser.email.isEmpty && user.email != null && user.email!.isNotEmpty) {
                          newEmail = user.email!;
                          needsUpdate = true;
                        }

                        if (needsUpdate) {
                          final updatedUser = UserModel(
                            uid: user.uid,
                            email: newEmail,
                            name: newName,
                            // Preserve other fields
                            churchId: existingUser.churchId,
                            groupId: existingUser.groupId,
                            groupStatus: existingUser.groupStatus,
                            role: existingUser.role,
                          );
                          // Use createUser which has SetOptions(merge: true)
                          await userRepo.createUser(updatedUser);
                          if (context.mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('사용자 정보를 최신 상태로 동기화했습니다.')),
                            );
                          }
                        }
                      }
                      
                      // Navigation is handled by AppRouter redirect
                    } else {
                       if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인 취소됨')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인 에러: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Google로 시작하기'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: theme.colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Version Info
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }
                final info = snapshot.data!;
                return Text(
                  'v${info.version}+${info.buildNumber} (Build: 2026-01-20 14:15)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}