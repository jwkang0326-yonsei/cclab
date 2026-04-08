import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/common/main_layout.dart';
import '../features/home/home_screen.dart';
import '../features/group/group_screen.dart';
import '../features/group/group_selection_screen.dart';
import '../features/group/join_group_screen.dart';
import '../features/bible_map/presentation/pages/create_goal_screen.dart';
import '../features/bible_map/presentation/pages/bible_map_screen.dart';
import '../features/statistics/statistics_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/auth/create_church_screen.dart';
import '../features/auth/profile_setup_screen.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(currentUserProfileProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // 1. Check Auth State
      if (authState.isLoading || authState.hasError) return null;
      final isAuthenticated = authState.value != null;
      
      final isLoginRoute = state.matchedLocation == '/login';
      final isOnboardingRoute = state.matchedLocation.startsWith('/onboarding');
      final isProfileSetupRoute = state.matchedLocation == '/profile-setup';
      final isGroupSelectionRoute = state.matchedLocation == '/group-selection';
      final isInviteRoute = state.matchedLocation.startsWith('/invite');

      // 2. Unauthenticated User -> Login
      if (!isAuthenticated) {
        return isLoginRoute ? null : '/login';
      }

      // 3. Authenticated User -> Check Profile
      if (userProfileAsync.isLoading) return null;
      final userProfile = userProfileAsync.value;

      // Case A: Profile Setup Needed (Name is missing) -> Profile Setup
      final needsProfileSetup = userProfile != null && 
          (userProfile.name == null || userProfile.name!.isEmpty);

      if (needsProfileSetup) {
        return isProfileSetupRoute ? null : '/profile-setup';
      }
      
      if (isProfileSetupRoute) return null;
      
      // Case B: No Church ID -> Onboarding (but allow Invite links)
      if (userProfile != null && userProfile.churchId == null) {
        // 만약 초대 링크로 들어왔다면 온보딩보다 가입 화면을 우선시함
        if (isInviteRoute) return null;
        return isOnboardingRoute ? null : '/onboarding';
      }

      // Case C: Fully Authenticated & Set up
      // If user is at login/onboarding, redirect to Home (unless they have a target invite)
      if (isLoginRoute || isOnboardingRoute) {
        return isInviteRoute ? null : '/home';
      }
      
      // Allow other authenticated routes (including /invite and /group-selection)
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'create-church',
            builder: (context, state) => const CreateChurchScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/group-selection',
        builder: (context, state) => const GroupSelectionScreen(),
      ),
      GoRoute(
        path: '/invite/group/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return JoinGroupScreen(groupId: groupId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/group',
                builder: (context, state) => const GroupScreen(),
                routes: [
                  GoRoute(
                    path: 'create-goal/:groupId',
                    builder: (context, state) => CreateGoalScreen(
                      groupId: state.pathParameters['groupId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'bible-map/:goalId',
                    builder: (context, state) => BibleMapScreen(
                      goalId: state.pathParameters['goalId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/report',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});