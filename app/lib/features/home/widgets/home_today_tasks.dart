import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_goal_model.dart';
import '../../../data/repositories/group_goal_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../bible_map/presentation/viewmodels/bible_map_viewmodel.dart';
import '../../../core/constants/bible_constants.dart';
import 'today_bible_card.dart';

class HomeTodayTasks extends ConsumerWidget {
  final String groupId;

  const HomeTodayTasks({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch ACTIVE goals only
    final goalsAsync = ref.watch(activeGoalsStreamProvider(groupId));

    return goalsAsync.when(
      data: (goals) {
        if (goals.isEmpty) return const SizedBox.shrink();
        
        return Column(
          children: goals.map((goal) => SingleGoalTasks(goal: goal)).toList(),
        );
      },
      loading: () => const SizedBox.shrink(), // Don't show loader on home to avoid flicker
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

final activeGoalsStreamProvider = StreamProvider.family<List<GroupGoalModel>, String>((ref, groupId) {
  return ref.watch(groupGoalRepositoryProvider).watchActiveGoals(groupId);
});

class SingleGoalTasks extends ConsumerWidget {
  final GroupGoalModel goal;

  const SingleGoalTasks({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapStateAsync = ref.watch(bibleMapStateProvider(goal.id));
    final currentUser = ref.watch(currentUserProfileProvider).value;

    if (currentUser == null) return const SizedBox.shrink();

    return mapStateAsync.when(
      data: (state) {
        // Filter Locked Chapters by Me
        final myLockedChapters = state.chapters.entries.where((entry) {
          return entry.value.status == 'LOCKED' && entry.value.lockedBy == currentUser.uid;
        }).toList();

        if (myLockedChapters.isEmpty) return const SizedBox.shrink();

        // Group by Book
        final Map<String, int> bookMinChapter = {}; // bookKey -> minChapter

        for (final entry in myLockedChapters) {
          // Key format: "BookKey_ChapterNum"
          final parts = entry.key.split('_');
          if (parts.length != 2) continue;
          
          final bookKey = parts[0];
          final chapterNum = int.tryParse(parts[1]) ?? 0;

          if (!bookMinChapter.containsKey(bookKey)) {
            bookMinChapter[bookKey] = chapterNum;
          } else {
            if (chapterNum < bookMinChapter[bookKey]!) {
              bookMinChapter[bookKey] = chapterNum;
            }
          }
        }

        // Sort by Book Order (using BibleConstants indices?) 
        // For MVP, just keys or insertion order. Map iteration is insertion order (usually).
        
        return Column(
          children: bookMinChapter.entries.map((entry) {
            final bookKey = entry.key;
            final chapterNum = entry.value;
            final bookName = BibleConstants.getBookName(bookKey);
            final totalChapters = BibleConstants.getChapterCount(bookKey);

            // Calculate cleared count for this book by this user
            int clearedCount = 0;
            for (int i = 1; i <= totalChapters; i++) {
              final key = "${bookKey}_$i";
              final chapterStatus = state.chapters[key];
              if (chapterStatus != null && 
                  chapterStatus.status == 'CLEARED' && 
                  chapterStatus.clearedBy == currentUser.uid) {
                clearedCount++;
              }
            }

            return TodayBibleCard(
              key: ValueKey("${bookKey}_$chapterNum"),
              bookName: bookName,
              chapterNum: chapterNum,
              goalTitle: goal.title,
              clearedCount: clearedCount,
              totalChapters: totalChapters,
              onComplete: () {
                _completeChapter(context, ref, goal.id, bookKey, chapterNum);
              },
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _completeChapter(BuildContext context, WidgetRef ref, String goalId, String book, int chapter) async {
    try {
      await ref.read(bibleMapControllerProvider).completeChapter(
        goalId: goalId,
        book: book,
        chapter: chapter,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("읽기 완료! 수고하셨습니다.")));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
      }
    }
  }
}
