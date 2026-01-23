import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/bible_constants.dart';
import '../models/group_goal_model.dart';
import '../models/group_map_state_model.dart';
import 'church_repository.dart'; // for firestoreProvider

class GroupGoalRepository {
  final FirebaseFirestore _firestore;

  GroupGoalRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  // Create a new goal and initialize the map state atomically


  Future<void> createGoal(GroupGoalModel goal) async {
    // 1. Create Goal Document
    await _firestore.collection('group_goals').doc(goal.id).set(goal.toJson());

    // 2. Initialize Map State using GOAL ID (1:1 with Goal)
    // We assume 1189 chapters for full bible, or calculate based on range.
    // For MVP, we initialize an empty map and let it populate lazily or init here.
    // Ideally, we should know the total chapters for progress calculation.
    
    // Calculate total chapters dynamically based on target range
    int totalChapters = BibleConstants.calculateTotalChapters(goal.targetRange); 

    final mapState = GroupMapStateModel(
      groupId: goal.groupId, // Keep reference to group
      chapters: {}, // Empty start
      stats: GroupMapStats(
        totalChapters: totalChapters,
        clearedCount: 0,
        userStats: {},
      ),
    );

    await _firestore.collection('group_map_state').doc(goal.id).set(mapState.toJson());
  }

  Stream<List<GroupGoalModel>> watchActiveGoals(String groupId) {
    return watchGoals(groupId: groupId, status: 'ACTIVE');
  }

  Stream<List<GroupGoalModel>> watchGoals({required String groupId, required String status}) {
    return _firestore
        .collection('group_goals')
        .where('group_id', isEqualTo: groupId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GroupGoalModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> updateGoalStatus(String goalId, String status) async {
    await _firestore.collection('group_goals').doc(goalId).update({
      'status': status,
    });
  }

  // Watch Map State by GOAL ID!!
  Stream<GroupMapStateModel> watchMapState(String goalId) {
    return _firestore
        .collection('group_map_state')
        .doc(goalId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception("Map state not found for goal $goalId");
      }
      return GroupMapStateModel.fromJson(doc.id, doc.data()!);
    });
  }

  Future<void> lockChapter({
    required String goalId,
    required String chapterKey,
    required String userId,
    required String userName,
  }) async {
    final mapRef = _firestore.collection('group_map_state').doc(goalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(mapRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentMap = GroupMapStateModel.fromJson(snapshot.id, data);
      final chapter = currentMap.chapters[chapterKey];

      // Validation
      if (chapter != null && chapter.status != 'OPEN') {
        if (chapter.status == 'LOCKED' && chapter.lockedBy == userId) {
             return; // Already locked by me
        }
        throw Exception("Chapter is already taken.");
      }

      // 1. Update Chapter Status
      final newStatus = ChapterStatus(
        status: 'LOCKED',
        lockedBy: userId,
        lockedAt: DateTime.now(),
      );

      // 2. Update User Stats (Locked Count ++)
      final userStat = currentMap.stats.userStats[userId] ?? 
          UserMapStat(userId: userId, displayName: userName, lastActiveAt: DateTime.now());
      
      final newUserStat = UserMapStat(
        userId: userId,
        displayName: userName,
        clearedCount: userStat.clearedCount,
        lockedCount: userStat.lockedCount + 1,
        lastActiveAt: DateTime.now(),
      );

      transaction.update(mapRef, {
        'chapters.$chapterKey': newStatus.toJson(),
        'stats.user_stats.$userId': newUserStat.toJson(),
      });
    });
  }

  Future<void> completeChapter({
    required String goalId,
    required String chapterKey,
    required String userId,
  }) async {
    final mapRef = _firestore.collection('group_map_state').doc(goalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(mapRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentMap = GroupMapStateModel.fromJson(snapshot.id, data);
      final chapter = currentMap.chapters[chapterKey];

      // Validation
      if (chapter != null && chapter.status == 'LOCKED') {
         if (chapter.lockedBy != userId) {
           throw Exception("You cannot complete a chapter locked by someone else.");
         }
      }

      // 1. Update Chapter Status
      final newStatus = ChapterStatus(
        status: 'CLEARED',
        lockedBy: chapter?.lockedBy, // Preserve history
        lockedAt: chapter?.lockedAt,
        clearedBy: userId,
        clearedAt: DateTime.now(),
      );

      // 2. Update Group Stats (Total Cleared ++)
      final currentStats = currentMap.stats;
      final newClearedCount = currentStats.clearedCount + 1;

      // 3. Update User Stats (Locked --, Cleared ++)
      final userStat = currentStats.userStats[userId]!; // Should exist if locked
      final newUserStat = UserMapStat(
        userId: userId,
        displayName: userStat.displayName,
        clearedCount: userStat.clearedCount + 1,
        lockedCount: userStat.lockedCount > 0 ? userStat.lockedCount - 1 : 0,
        lastActiveAt: DateTime.now(),
      );

      transaction.update(mapRef, {
        'chapters.$chapterKey': newStatus.toJson(),
        'stats.cleared_count': newClearedCount,
        'stats.user_stats.$userId': newUserStat.toJson(),
      });
    });
  }
  Future<void> toggleCollaborativeChapterCompletion({
    required String goalId,
    required String chapterKey,
    required String userId,
    required String userName,
  }) async {
    final mapRef = _firestore.collection('group_map_state').doc(goalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(mapRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentMap = GroupMapStateModel.fromJson(snapshot.id, data);
      final chapter = currentMap.chapters[chapterKey];
      
      final List<String> currentCompletedUsers = chapter?.completedUsers ?? [];
      final bool isCompleted = currentCompletedUsers.contains(userId);
      
      List<String> newCompletedUsers = List.from(currentCompletedUsers);
      int userClearedDelta = 0;

      if (isCompleted) {
        // Remove user (Undo completion)
        newCompletedUsers.remove(userId);
        userClearedDelta = -1;
      } else {
        // Add user (Complete)
        newCompletedUsers.add(userId);
        userClearedDelta = 1;
      }

      // 1. Update Chapter Status
      // For collaborative, we might want to set 'status' to CLEARED if at least one person read it, 
      // or keep it OPEN but use completedUsers list. Let's keep status OPEN or infer it.
      // But to be consistent with Distributed mode visualization, let's keep status as is 
      // or set to CLEARED if everyone finished (future feature).
      // For now, we update 'completed_users' field.
      
      final newStatus = ChapterStatus(
        status: chapter?.status ?? 'OPEN', // Keep existing status or default
        lockedBy: chapter?.lockedBy,
        lockedAt: chapter?.lockedAt,
        clearedBy: chapter?.clearedBy,
        clearedAt: DateTime.now(), // Update timestamp for recent activity
        completedUsers: newCompletedUsers,
      );

      // 2. Update User Stats
      final userStat = currentMap.stats.userStats[userId] ?? 
          UserMapStat(userId: userId, displayName: userName, lastActiveAt: DateTime.now());
      
      final newUserStat = UserMapStat(
        userId: userId,
        displayName: userName,
        clearedCount: userStat.clearedCount + userClearedDelta, // Increment or Decrement
        lockedCount: userStat.lockedCount,
        lastActiveAt: DateTime.now(),
      );

      // 3. Update Global Cleared Count (Unique Coverage)
      int globalClearedDelta = 0;
      if (isCompleted) {
        // Removing user
        if (newCompletedUsers.isEmpty) {
          // No one left, so it's no longer cleared
          globalClearedDelta = -1;
        }
      } else {
        // Adding user
        if (currentCompletedUsers.isEmpty) {
          // First one to clear it
          globalClearedDelta = 1;
        }
      }
      
      final newGlobalCleared = currentMap.stats.clearedCount + globalClearedDelta;

      transaction.update(mapRef, {
        'chapters.$chapterKey': newStatus.toJson(),
        'stats.user_stats.$userId': newUserStat.toJson(),
        'stats.cleared_count': newGlobalCleared, 
      });
    });
  }

  // Fetch single goal for Map Screen details if needed
  Future<GroupGoalModel?> getGoal(String goalId) async {
    final doc = await _firestore.collection('group_goals').doc(goalId).get();
    if (!doc.exists) return null;
    return GroupGoalModel.fromJson(doc.data()!);
  }
  
  // Single Chapter Operations (Keep as is or refactor if needed, but keeping for backward capability if used elsewhere)
  // ... existing lockChapter/completeChapter ...

  // Batch Operations
  Future<void> lockChapters({
    required String goalId,
    required List<String> chapterKeys,
    required String userId,
    required String userName,
  }) async {
    final mapRef = _firestore.collection('group_map_state').doc(goalId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(mapRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentMap = GroupMapStateModel.fromJson(snapshot.id, data);
      
      final Map<String, dynamic> updates = {};
      int newLockedCount = 0;

      for (final key in chapterKeys) {
        final chapter = currentMap.chapters[key];
        
        // Skip if already cleared or locked 
        if (chapter != null && chapter.status != 'OPEN') {
           continue; 
        }
        
        final newStatus = ChapterStatus(
          status: 'LOCKED',
          lockedBy: userId,
          lockedAt: DateTime.now(),
        );
        updates['chapters.$key'] = newStatus.toJson();
        newLockedCount++;
      }
      
      if (newLockedCount == 0 && updates.isEmpty) return;

      final userStat = currentMap.stats.userStats[userId] ?? 
          UserMapStat(userId: userId, displayName: userName, lastActiveAt: DateTime.now());
      
      final newUserStat = UserMapStat(
        userId: userId,
        displayName: userName,
        clearedCount: userStat.clearedCount,
        lockedCount: userStat.lockedCount + newLockedCount,
        lastActiveAt: DateTime.now(),
      );

      updates['stats.user_stats.$userId'] = newUserStat.toJson();

      transaction.update(mapRef, updates);
    });
  }

  Future<void> completeChapters({
    required String goalId,
    required List<String> chapterKeys,
    required String userId,
  }) async {
    final mapRef = _firestore.collection('group_map_state').doc(goalId);

    await _firestore.runTransaction((transaction) async {
       final snapshot = await transaction.get(mapRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentMap = GroupMapStateModel.fromJson(snapshot.id, data);
      
      final Map<String, dynamic> updates = {};
      int addedClearedCount = 0;
      int removedLockedCount = 0;

      for (final key in chapterKeys) {
        final chapter = currentMap.chapters[key];
        
        bool canComplete = false;
        if (chapter == null || chapter.status == 'OPEN') {
          canComplete = true; 
        } else if (chapter.status == 'LOCKED' && chapter.lockedBy == userId) {
          canComplete = true; 
          removedLockedCount++;
        }
        
        if (!canComplete) continue; 

        final newStatus = ChapterStatus(
           status: 'CLEARED',
           lockedBy: chapter?.lockedBy ?? userId, 
           lockedAt: chapter?.lockedAt ?? DateTime.now(),
           clearedBy: userId,
           clearedAt: DateTime.now(),
        );
        
        updates['chapters.$key'] = newStatus.toJson();
        addedClearedCount++;
      }

      if (addedClearedCount == 0) return;

      final currentStats = currentMap.stats;
      final newGlobalCleared = currentStats.clearedCount + addedClearedCount;

      final userStat = currentStats.userStats[userId];
      final currentLocked = userStat?.lockedCount ?? 0;
      final currentCleared = userStat?.clearedCount ?? 0;
      
      final newUserStat = UserMapStat(
        userId: userId,
        displayName: userStat?.displayName ?? 'Unknown',
        clearedCount: currentCleared + addedClearedCount,
        lockedCount: (currentLocked - removedLockedCount) < 0 ? 0 : (currentLocked - removedLockedCount),
        lastActiveAt: DateTime.now(),
      );

      updates['stats.cleared_count'] = newGlobalCleared;
      updates['stats.user_stats.$userId'] = newUserStat.toJson();

      transaction.update(mapRef, updates);
    });
  }
}

// Providers
final groupGoalRepositoryProvider = Provider<GroupGoalRepository>((ref) {
  return GroupGoalRepository(firestore: ref.watch(firestoreProvider));
});
