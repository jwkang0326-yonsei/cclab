import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/widgets/home_drawer.dart';
import 'widgets/my_statistics_tab.dart';
import 'widgets/team_statistics_tab.dart';

/// 통계 메인 화면
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              '통계',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: '나의 통계'),
                Tab(text: '팀 통계'),
              ],
            ),
          ),
          endDrawer: const HomeDrawer(),
          body: const TabBarView(
            children: [
              MyStatisticsTab(),
              TeamStatisticsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
