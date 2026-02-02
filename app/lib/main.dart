import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  print('🚀 WithBible App Starting... 🚀');
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Replace with your actual Kakao Native App Key
  KakaoSdk.init(
    nativeAppKey: '6601bfa9517db3b3df2c056a0cbb5ce1',
    javaScriptAppKey: '0a98e689cf34da6ffe56a55bc882022c',
  );
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase Initialized Successfully');
  } catch (e) {
    print('❌ Firebase Initialization Failed: $e');
  }

  runApp(const ProviderScope(child: WithBibleApp()));
}

class WithBibleApp extends ConsumerWidget {
  const WithBibleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'WithBible',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}