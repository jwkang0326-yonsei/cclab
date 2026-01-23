import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/group_goal_model.dart';
import '../../../data/models/group_map_state_model.dart';
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
        if (goal.readingMethod == 'collaborative') {
          return _buildCollaborativeTasks(context, ref, state, currentUser);
        } else {
          return _buildDistributedTasks(context, ref, state, currentUser);
        }
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDistributedTasks(BuildContext context, WidgetRef ref, GroupMapStateModel state, dynamic currentUser) {
    // Filter Locked Chapters by Me
    final myLockedChapters = state.chapters.entries.where((entry) {
      return entry.value.status == 'LOCKED' && entry.value.lockedBy == currentUser.uid;
    }).toList();

    if (myLockedChapters.isEmpty) return const SizedBox.shrink();

    // Group by Book and get the minimum chapter for each book
    final Map<String, int> bookMinChapter = {}; 

    for (final entry in myLockedChapters) {
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

    // Sort books by the predefined Bible order
    final allBooks = [...BibleConstants.oldTestament, ...BibleConstants.newTestament];
    final sortedBookKeys = bookMinChapter.keys.toList()
      ..sort((a, b) {
        final indexA = allBooks.indexWhere((book) => book['key'] == a);
        final indexB = allBooks.indexWhere((book) => book['key'] == b);
        return indexA.compareTo(indexB);
      });
    
    return Column(
      children: sortedBookKeys.map((bookKey) {
        final chapterNum = bookMinChapter[bookKey]!;
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
          isCollaborative: false,
          onComplete: () {
            _completeChapter(context, ref, goal.id, bookKey, chapterNum, false);
          },
        );
      }).toList(),
    );
  }

  Widget _buildCollaborativeTasks(BuildContext context, WidgetRef ref, GroupMapStateModel state, dynamic currentUser) {
    final allBooks = [...BibleConstants.oldTestament, ...BibleConstants.newTestament];
    
    String? targetBookKey;
    int? targetChapterNum;

    // Find the first unread chapter for the current user within the goal range
    for (final book in allBooks) {
      final bookKey = book['key'] as String;
      
      // Check range
      if (!_isBookInRange(bookKey, goal.targetRange)) continue;

      final chapterCount = book['chapters'] as int;
      
      for (int i = 1; i <= chapterCount; i++) {
        final key = "${bookKey}_$i";
        final status = state.chapters[key];
        
        final isCompletedByMe = status != null && 
                                status.completedUsers.contains(currentUser.uid); // removed status.completedUsers != null check if it's non-nullable in model
        
        if (!isCompletedByMe) {
          targetBookKey = bookKey;
          targetChapterNum = i;
          break; // Found the chapter!
        }
      }
      if (targetBookKey != null) break; // Found the book!
    }

    if (targetBookKey == null || targetChapterNum == null) return const SizedBox.shrink(); // Check both

    final bookName = BibleConstants.getBookName(targetBookKey);
    final totalChapters = BibleConstants.getChapterCount(targetBookKey);

    // Calculate cleared count for this book by this user (Collaborative logic)
    int clearedCount = 0;
    for (int i = 1; i <= totalChapters; i++) {
      final key = "${targetBookKey}_$i";
      final status = state.chapters[key];
      if (status != null && 
          status.completedUsers.contains(currentUser.uid)) {
        clearedCount++;
      }
    }

    return TodayBibleCard(
      key: ValueKey("${targetBookKey}_$targetChapterNum"),
      bookName: bookName,
      chapterNum: targetChapterNum,
      goalTitle: goal.title, // Just show title, card color distinguishes mode
      clearedCount: clearedCount,
      totalChapters: totalChapters,
      isCollaborative: true,
      onComplete: () {
        _completeChapter(context, ref, goal.id, targetBookKey!, targetChapterNum!, true);
      },
    );
  }

  bool _isBookInRange(String bookKey, List<String> targetRange) {
    if (targetRange.isEmpty) return true;
    final range = targetRange.first;
    
    if (range == 'Genesis-Revelation') return true;
    if (range == 'Genesis-Malachi') {
      return BibleConstants.oldTestament.any((b) => b['key'] == bookKey);
    }
    if (range == 'Matthew-Revelation') {
      return BibleConstants.newTestament.any((b) => b['key'] == bookKey);
    }
    return range == bookKey;
  }

  Future<void> _completeChapter(BuildContext context, WidgetRef ref, String goalId, String book, int chapter, bool isCollaborative) async {
    try {
      if (isCollaborative) {
         await ref.read(bibleMapControllerProvider).toggleCollaborativeCompletion(
          goalId: goalId,
          book: book,
          chapter: chapter,
        );
      } else {
        await ref.read(bibleMapControllerProvider).completeChapter(
          goalId: goalId,
          book: book,
          chapter: chapter,
        );
      }
      
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
