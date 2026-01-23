import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/home_header.dart';
import 'widgets/home_today_tasks.dart';
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
          child: userProfileAsync.when(
            data: (user) {
               return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: const HomeHeader(),
                    ),
                    if (user != null && user.groupId != null && user.groupStatus == 'active') ...[
                      TabBar(
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: const [
                          Tab(text: "체크"),
                          Tab(text: "목표"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Check (Reading Tasks)
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  HomeTodayTasks(groupId: user.groupId!),
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
                            // Tab 2: Goals
                            GroupBibleMapTab(
                              groupId: user.groupId!, 
                              isLeader: user.role == 'leader',
                              shrinkWrap: false,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                       // Fallback for no group/inactive
                       const Expanded(child: Center(child: Text("그룹에 가입하거나 승인을 기다려주세요.")))
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text("Error: $e")),
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
