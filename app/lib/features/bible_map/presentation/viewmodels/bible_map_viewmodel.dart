import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/group_goal_repository.dart';
import '../../../../data/models/group_map_state_model.dart';
import '../../../../data/repositories/user_repository.dart';

// Simple Stream Provider for the State
final bibleMapStateProvider = StreamProvider.family<GroupMapStateModel, String>((ref, goalId) {
  return ref.watch(groupGoalRepositoryProvider).watchMapState(goalId);
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
}
