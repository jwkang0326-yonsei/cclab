import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/home_header.dart';
import 'widgets/today_bible_card.dart';
import '../../data/repositories/user_repository.dart';
import '../group/widgets/group_bible_map_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Need user profile to get groupId
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, 
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 30),
                
                userProfileAsync.when(
                  data: (user) {
                    if (user != null && user.groupId != null && user.groupStatus == 'active') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GroupBibleMapTab(
                            groupId: user.groupId!, 
                            isLeader: user.role == 'leader',
                            shrinkWrap: true,
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    }
                    return const SizedBox.shrink(); 
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const TodayBibleCard(),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    "Build: 2026-01-22 15:35",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 50), 
              ],
            ),
          ),
        ),
        floatingActionButton: userProfileAsync.value?.role == 'leader' 
          ? FloatingActionButton.extended(
              onPressed: () {
                final groupId = userProfileAsync.value!.groupId;
                if (groupId != null) {
                  context.push('/group/create-goal/$groupId');
                }
              },
              icon: const Icon(Icons.add_task),
              label: const Text('새 목표 설정'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            )
          : null,
      ),
    );
  }
}
