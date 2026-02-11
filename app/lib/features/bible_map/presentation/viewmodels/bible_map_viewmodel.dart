import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/repositories/group_goal_repository.dart';
import '../../../../data/models/group_map_state_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Stream Provider for the State with User Name Sync
final bibleMapStateProvider = StreamProvider.family<GroupMapStateModel, String>((ref, goalId) async* {
  final stream = ref.watch(groupGoalRepositoryProvider).watchMapState(goalId);
  final firestore = ref.watch(firestoreProvider);

  await for (final mapState in stream) {
    // Collect User IDs
    final userStats = mapState.stats.userStats;
    if (userStats.isEmpty) {
      yield mapState;
      continue;
    }

    final userIds = userStats.keys.toList();
    final Map<String, String> latestNames = {};

    // Fetch latest names in chunks of 10
    for (var i = 0; i < userIds.length; i += 10) {
      final end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
      final chunk = userIds.sublist(i, end);

      try {
        final usersSnapshot = await firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in usersSnapshot.docs) {
          final data = doc.data();
          if (data['name'] != null && data['name'].toString().isNotEmpty) {
            latestNames[doc.id] = data['name'];
          }
        }
      } catch (e) {
        print("Error fetching user names: $e");
      }
    }

    // Update Display Names in UserStats (Create new UserMapStat objects)
    if (latestNames.isNotEmpty) {
      for (final entry in latestNames.entries) {
        final uid = entry.key;
        final newName = entry.value;
        if (userStats.containsKey(uid)) {
          final oldStat = userStats[uid]!;
          // Update displayName if changed
          if (oldStat.displayName != newName) {
             userStats[uid] = UserMapStat(
               userId: oldStat.userId,
               displayName: newName,
               clearedCount: oldStat.clearedCount,
               lockedCount: oldStat.lockedCount,
               lastActiveAt: oldStat.lastActiveAt,
             );
          }
        }
      }
    }

    yield mapState;
  }
});

// We can keep the controller logic here or in UI. 
// A Controller provider to handle logic is cleaner than UI calling repo directly.
final bibleMapControllerProvider = Provider((ref) => BibleMapController(ref));

class BibleMapController {
  final Ref _ref;
  BibleMapController(this._ref);

  Future<void> lockChapter({
    required String goalId,
    required String book,
    required int chapter,
  }) async {
    final key = "${book}_$chapter";
    try {
      final user = _ref.read(currentUserProfileProvider).value;
      if (user == null) throw Exception("User not logged in");

      await _ref.read(groupGoalRepositoryProvider).lockChapter(
        goalId: goalId,
        chapterKey: key,
        userId: user.uid,
        userName: user.name ?? "Anonymous",
      );
    } catch (e) {
      print("Lock Error: $e");
      rethrow;
    }
  }

  Future<void> completeChapter({
    required String goalId,
    required String book,
    required int chapter,
  }) async {
    final key = "${book}_$chapter";
    try {
      final user = _ref.read(currentUserProfileProvider).value;
      if (user == null) throw Exception("User not logged in");

      await _ref.read(groupGoalRepositoryProvider).completeChapter(
        goalId: goalId,
        chapterKey: key,
        userId: user.uid,
      );
    } catch (e) {
      print("Complete Error: $e");
      rethrow;
    }
  }

  Future<void> lockChapters({
    required String goalId,
    required List<String> chapterKeys,
  }) async {
    try {
      final user = _ref.read(currentUserProfileProvider).value;
      if (user == null) throw Exception("User not logged in");

      await _ref.read(groupGoalRepositoryProvider).lockChapters(
        goalId: goalId,
        chapterKeys: chapterKeys,
        userId: user.uid,
        userName: user.name ?? "Anonymous",
      );
    } catch (e) {
      print("Bulk Lock Error: $e");
      rethrow;
    }
  }

  Future<void> completeChapters({
    required String goalId,
    required List<String> chapterKeys,
  }) async {
    try {
      final user = _ref.read(currentUserProfileProvider).value;
      if (user == null) throw Exception("User not logged in");

      await _ref.read(groupGoalRepositoryProvider).completeChapters(
        goalId: goalId,
        chapterKeys: chapterKeys,
        userId: user.uid,
      );
    } catch (e) {
      print("Bulk Complete Error: $e");
      rethrow;
    }
  }

    Future<void> toggleCollaborativeCompletion({
      required String goalId,
      required String book,
      required int chapter,
    }) async {
      final key = "${book}_$chapter";
      try {
        final user = _ref.read(currentUserProfileProvider).value;
        if (user == null) throw Exception("User not logged in");
  
        await _ref.read(groupGoalRepositoryProvider).toggleCollaborativeChapterCompletion(
          goalId: goalId, 
          chapterKey: key, 
          userId: user.uid, 
          userName: user.name ?? "Anonymous",
        );
      } catch (e) {
        print("Collaborative Toggle Error: $e");
        rethrow;
      }
    }
  
    // --- Gacha Logic ---
    String? pickRandomChapterKey(GroupMapStateModel mapState) {
      final openChapters = mapState.chapters.entries
          .where((e) => e.value.status == 'OPEN')
          .map((e) => e.key)
          .toList();
  
      if (openChapters.isEmpty) return null;
  
      openChapters.shuffle();
      return openChapters.first;
    }
  }
