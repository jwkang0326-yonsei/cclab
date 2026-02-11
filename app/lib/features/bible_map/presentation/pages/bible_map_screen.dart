import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../viewmodels/bible_map_viewmodel.dart';
import '../../../../data/models/group_map_state_model.dart';
import '../../../../data/models/group_goal_model.dart';
import '../../../../data/repositories/group_goal_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/constants/bible_constants.dart';
import '../widgets/bible_gacha_dialog.dart';

// Provider to fetch Goal Details
final goalDetailsProvider = FutureProvider.family<GroupGoalModel?, String>((ref, goalId) async {
  return ref.watch(groupGoalRepositoryProvider).getGoal(goalId);
});

class BibleMapScreen extends ConsumerStatefulWidget {
  final String goalId;

  const BibleMapScreen({super.key, required this.goalId});

  @override
  ConsumerState<BibleMapScreen> createState() => _BibleMapScreenState();
}

class _BibleMapScreenState extends ConsumerState<BibleMapScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  // Selection Mode State
  bool _isSelectionMode = false;
  String? _selectionStartKey; 
  // Flattened list of all chapter keys in the current filtered view for easy range calculation
  final List<String> _flattenedKeys = [];

  Set<String> _selectedKeys = {}; 
  final Set<String> _collapsedBookKeys = {};

  @override
  void initState() {
    super.initState();
    // 기본으로 모든 책을 접은 상태로 시작
    for (final book in BibleConstants.oldTestament) {
      _collapsedBookKeys.add(book['key'] as String);
    }
    for (final book in BibleConstants.newTestament) {
      _collapsedBookKeys.add(book['key'] as String);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapStateAsync = ref.watch(bibleMapStateProvider(widget.goalId));
    final goalAsync = ref.watch(goalDetailsProvider(widget.goalId));

    return Scaffold(
      appBar: AppBar(title: const Text('성경 읽기 지도')), // Updated Title
      body: mapStateAsync.when(
        data: (mapState) {
          return goalAsync.when(
            data: (goal) {
               if (goal == null) return const Center(child: Text("목표를 찾을 수 없습니다."));
               return _buildMapContent(mapState, goal);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text("Goal Error: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Map Error: $e')),
      ),
      // Bottom Action Bar for Selection
      bottomNavigationBar: _selectedKeys.isNotEmpty 
        ? SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                   Expanded(
                     child: Text(
                       "${_selectedKeys.length}개 선택됨",
                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent),
                     ),
                   ),
                   TextButton(
                     onPressed: _exitSelectionMode,
                     child: const Text("취소", style: TextStyle(color: Colors.grey)),
                   ),
                   const SizedBox(width: 8),
                   ElevatedButton(
                     onPressed: _bulkLock,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blueAccent,
                       foregroundColor: Colors.white,
                       elevation: 0,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                     ),
                     child: const Text("읽기 예약하기", style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                ],
              ),
            ),
          )
        : null,
      floatingActionButton: _isSelectionMode ? null : mapStateAsync.when(
        data: (mapState) {
          final openChapters = mapState.chapters.entries
              .where((e) => e.value.status == 'OPEN')
              .map((e) => e.key)
              .toList();
          
          if (openChapters.isEmpty) return null;

          return FloatingActionButton.extended(
            onPressed: () => _showGacha(context, openChapters),
            backgroundColor: Colors.orange[800],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.Casino),
            label: const Text("말씀 뽑기", style: TextStyle(fontWeight: FontWeight.bold)),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }

  void _showGacha(BuildContext context, List<String> openChapters) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BibleGachaDialog(
        openChapterKeys: openChapters,
        onConfirm: (key) {
          ref.read(bibleMapControllerProvider).lockChapters(
            goalId: widget.goalId,
            chapterKeys: [key],
          ).then((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("뽑은 말씀을 예약했습니다. 화이팅!")),
              );
            }
          });
        },
      ),
    );
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectionStartKey = null;
      _selectedKeys.clear();
      HapticFeedback.lightImpact();
    });
  }

  // --- Bulk Operations ---
  Future<void> _bulkLock() async {
    if (_selectedKeys.isEmpty) return;
    try {
      await ref.read(bibleMapControllerProvider).lockChapters(
        goalId: widget.goalId,
        chapterKeys: _selectedKeys.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("선택한 챕터를 예약했습니다.")));
        _exitSelectionMode();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류가 발생했습니다: $e")));
    }
  }

  Widget _buildMapContent(GroupMapStateModel? mapState, GroupGoalModel goal) {
    if (mapState == null) {
      return const Center(child: Text("진행 상황을 불러올 수 없습니다."));
    }

    final List<Map<String, dynamic>> filteredBooks = _getFilteredBooks(goal.targetRange);
    
    // Re-generate flattened keys 
    _generateFlattenedKeys(filteredBooks);

    return Column(
      children: [
        if (!_isSelectionMode) ...[ 
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                 Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                 const SizedBox(height: 8),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("진행률: ${((mapState.stats.clearedCount / mapState.stats.totalChapters) * 100).toStringAsFixed(1)}%"),
                    Text("${mapState.stats.clearedCount} / ${mapState.stats.totalChapters}장"),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mapState.stats.totalChapters > 0 
                        ? mapState.stats.clearedCount / mapState.stats.totalChapters 
                        : 0,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return _buildBookSection(book, mapState, goal.readingMethod);
            },
          ),
        ),
      ],
    );
  }

  void _generateFlattenedKeys(List<Map<String, dynamic>> books) {
    _flattenedKeys.clear();
    for (final book in books) {
      final key = book['key'];
      final count = book['chapters'];
      for (int i = 1; i <= count; i++) {
        _flattenedKeys.add("${key}_$i");
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredBooks(List<String> targetRange) {
    final allBooks = [...BibleConstants.oldTestament, ...BibleConstants.newTestament];
    
    if (targetRange.isEmpty) return allBooks; 

    final range = targetRange.first;
    
    if (range == 'Genesis-Revelation') return allBooks;
    if (range == 'Genesis-Malachi') return BibleConstants.oldTestament;
    if (range == 'Matthew-Revelation') return BibleConstants.newTestament;
    
    final filtered = allBooks.where((book) => book['key'] == range).toList();
    if (filtered.isNotEmpty) return filtered;

    return allBooks; 
  }

  Widget _buildBookSection(Map<String, dynamic> book, GroupMapStateModel mapState, String readingMethod) {
    final bookName = book['name']; 
    final bookKey = book['key'];   
    final chapterCount = book['chapters'];
    final isCollaborative = readingMethod == 'collaborative';

    // Check if all chapters are selected for this book
    bool allSelected = true;
    bool isFullyOccupied = true;
    final Set<String> distinctOwners = {};

    for (int i = 1; i <= chapterCount; i++) {
      final key = "${bookKey}_$i";
      final status = mapState.chapters[key];
      
      // Selection Check
      if (!_selectedKeys.contains(key)) {
        allSelected = false;
      }
      
      // Occupation Check (Only relevant for Distributed mode)
      if (!isCollaborative) {
        if (status == null || status.status == 'OPEN') {
          isFullyOccupied = false;
        } else {
          final owner = status.clearedBy ?? status.lockedBy;
          if (owner != null) distinctOwners.add(owner);
        }
      } else {
        // In collaborative mode, 'Fully Occupied' concept is different or disabled for this view.
        isFullyOccupied = false; 
      }
    }
    
    // Determine Owner Name if single owner (Distributed only)
    String? ownerName;
    if (!isCollaborative && isFullyOccupied && distinctOwners.length == 1) {
       final ownerId = distinctOwners.first;
       ownerName = mapState.stats.userStats[ownerId]?.displayName;
       // Truncate if needed
       if (ownerName != null && ownerName.length > 3) {
         ownerName = ownerName.substring(0, 3);
       }
    }

    final isCollapsed = _collapsedBookKeys.contains(bookKey);

    return BookSection(
      bookKey: bookKey,
      bookName: bookName,
      chapterCount: chapterCount,
      isCollapsed: isCollapsed,
      allSelected: allSelected && _selectedKeys.isNotEmpty,
      isFullyOccupied: isFullyOccupied,
      ownerName: ownerName,
      mapState: mapState,
      onToggleCollapse: () => _toggleBookCollapse(bookKey),
      onToggleSelection: isCollaborative ? null : (value) => _toggleBookSelection(value, bookKey, chapterCount),
      buildChapterTile: (chapterNum) => _buildChapterTile(bookKey, bookName, chapterNum, mapState, readingMethod),
    );
  }

  void _toggleBookCollapse(String bookKey) {
    setState(() {
      if (_collapsedBookKeys.contains(bookKey)) {
        _collapsedBookKeys.remove(bookKey);
      } else {
        _collapsedBookKeys.add(bookKey);
      }
    });
  }

  void _toggleBookSelection(bool? value, String bookKey, int chapterCount) {
    setState(() {
      final shouldSelect = value ?? false;
      final bookChapterKeys = List.generate(chapterCount, (index) => "${bookKey}_${index + 1}");

      if (shouldSelect) {
        _selectedKeys.addAll(bookChapterKeys);
        _isSelectionMode = true;
      } else {
        _selectedKeys.removeAll(bookChapterKeys);
        if (_selectedKeys.isEmpty) {
          _isSelectionMode = false;
        }
      }
      HapticFeedback.lightImpact();
    });
  }

  Widget _buildChapterTile(String bookKey, String bookName, int chapterNum, GroupMapStateModel mapState, String readingMethod) {
    final key = "${bookKey}_$chapterNum"; 
    final status = mapState.chapters[key]; 
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final myUid = currentUser?.uid;
    final isCollaborative = readingMethod == 'collaborative';
    
    final isSelected = _selectedKeys.contains(key);
    // Highlight if it's the start point of a pending range
    final isStart = _selectionStartKey == key;

    Color tileColor = Colors.white; 
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.grey[700]!;
    Widget? content;
    
    if (isCollaborative) {
      // --- Collaborative Mode ---
      final completedUsers = status?.completedUsers ?? [];
      final isMine = myUid != null && completedUsers.contains(myUid);
      final count = completedUsers.length;

      if (count > 0) {
        tileColor = isMine ? Colors.green[50]! : Colors.blueAccent.withValues(alpha: 0.05);
        borderColor = isMine ? Colors.green[300]! : Colors.blueAccent.withValues(alpha: 0.2);
        textColor = isMine ? Colors.green[800]! : Colors.blueAccent;
        
        // Show "Me" as avatar if I read it, otherwise the first person who read it
        final displayUserId = isMine ? myUid : completedUsers.first;
        final userStat = mapState.stats.userStats[displayUserId];
        final name = userStat?.displayName ?? "?";
        final initial = name.isNotEmpty ? name[0] : "?";
        final avatarColor = Colors.primaries[displayUserId.hashCode % Colors.primaries.length];

        content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMine)
              const Icon(Icons.check_circle, color: Colors.green, size: 12)
            else
              const SizedBox(height: 12), // Space for visual consistency
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 7,
                  backgroundColor: avatarColor,
                  child: Text(
                    initial, 
                    style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
                if (count > 1) ...[
                  const SizedBox(width: 1),
                  Text(
                    "+${count - 1}", 
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)
                  ),
                ]
              ],
            ),
          ],
        );
      }
    } else {
      // --- Distributed Mode (Existing Logic) ---
      if (status != null) {
        final isMine = (status.status == 'CLEARED' && status.clearedBy == myUid) || 
                       (status.status == 'LOCKED' && status.lockedBy == myUid);
        
        String? userName;
        if (status.status == 'CLEARED' && status.clearedBy != null) {
          userName = mapState.stats.userStats[status.clearedBy]?.displayName;
        } else if (status.status == 'LOCKED' && status.lockedBy != null) {
          userName = mapState.stats.userStats[status.lockedBy]?.displayName;
        }
        
        // Truncate name if too long
        if (userName != null && userName.length > 3) {
          userName = userName.substring(0, 3);
        }

        if (status.status == 'CLEARED') {
          tileColor = isMine ? Colors.green[100]! : Colors.grey[200]!;
          borderColor = isMine ? Colors.green[400]! : Colors.grey[400]!;
          textColor = isMine ? Colors.green[800]! : Colors.grey[600]!;
          content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, color: textColor, size: 16),
              if (userName != null)
                Text(
                  userName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        } else if (status.status == 'LOCKED') {
          tileColor = isMine ? Colors.orange[50]! : Colors.grey[100]!;
          borderColor = isMine ? Colors.orange[300]! : Colors.grey[300]!;
          textColor = isMine ? Colors.orange[800]! : Colors.grey[600]!;
          content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isMine ? Icons.lock_outline : Icons.lock, color: textColor, size: 16),
              if (userName != null)
                Text(
                  userName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          );
        }
      }
    }
    
    // Selection Overrides (Only Distributed or if we enable selection for collaborative later)
    if (!isCollaborative && isSelected) {
      tileColor = Colors.blueAccent.withValues(alpha: 0.2);
      borderColor = Colors.blueAccent;
      textColor = Colors.blueAccent;
      content = null; 
    }
    
    if (!isCollaborative && isStart) {
      borderColor = Colors.blueAccent;
      tileColor = Colors.blueAccent.withValues(alpha: 0.4);
      textColor = Colors.blueAccent;
      content = null;
    }

    // Default Content (Chapter Number)
    content ??= Text("$chapterNum", style: TextStyle(fontWeight: FontWeight.bold, color: textColor));

    return GestureDetector(
      onTap: () {
        _handleTap(key, bookKey, bookName, chapterNum, status, mapState, widget.goalId, readingMethod);
      },
      onLongPress: () {
        if (isCollaborative && status != null && status.completedUsers.isNotEmpty) {
           final names = status.completedUsers.map((uid) {
             return mapState.stats.userStats[uid]?.displayName ?? "알 수 없음";
           }).join(", ");
           
           ScaffoldMessenger.of(context).hideCurrentSnackBar();
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text("$bookName ${chapterNum}장 읽은 사람: $names"),
               duration: const Duration(seconds: 3),
             ),
           );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: (isSelected || isStart) ? 2 : 1),
        ),
        child: Center(child: content),
      ),
    );
  }

  void _handleTap(
    String key, 
    String bookKey,
    String bookName, 
    int chapterNum, 
    ChapterStatus? status, 
    GroupMapStateModel mapState, 
    String goalId,
    String readingMethod
  ) {
     final isCollaborative = readingMethod == 'collaborative';

     if (isCollaborative) {
       // --- Collaborative Tap Logic: Instant Toggle ---
       ref.read(bibleMapControllerProvider).toggleCollaborativeCompletion(
         goalId: goalId, 
         book: bookKey, 
         chapter: chapterNum
       ).catchError((e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("오류: $e")));
       });
       
       return;
     }

     // --- Distributed Tap Logic (Existing) ---
     final currentUser = ref.watch(currentUserProfileProvider).value;
     final myUid = currentUser?.uid;

     // 1. Check if occupied by others
     if (status != null) {
       bool isOthers = false;
       String? ownerName;
       DateTime? date;
       String action = "";

       if (status.status == 'CLEARED' && status.clearedBy != myUid) {
         isOthers = true;
         ownerName = mapState.stats.userStats[status.clearedBy]?.displayName ?? "알 수 없음";
         date = status.clearedAt;
         action = "읽음";
       } else if (status.status == 'LOCKED' && status.lockedBy != myUid) {
         isOthers = true;
         ownerName = mapState.stats.userStats[status.lockedBy]?.displayName ?? "알 수 없음";
         date = status.lockedAt;
         action = "예약함";
       }

       if (isOthers) {
         // Show Info Toast/SnackBar
         String dateStr = date != null 
             ? "${date.month}월 ${date.day}일 ${date.hour}시" 
             : "";
         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text("$ownerName님이 $dateStr에 $action"),
             duration: const Duration(seconds: 2),
             behavior: SnackBarBehavior.floating,
           ),
         );
         return; // Do not select
       }
     }

     // 2. Normal Selection Logic (Open or Mine)
     if (_selectionStartKey == null) {
       setState(() {
         _isSelectionMode = true;
         _selectionStartKey = key;
         _selectedKeys.add(key); // Merge instead of reset
         HapticFeedback.selectionClick();
       });
     } else {
       final startKey = _selectionStartKey!;
       
       if (key == startKey) {
         // Toggle off single item and reset startKey
         setState(() {
           _selectionStartKey = null;
           _selectedKeys.remove(key);
           if (_selectedKeys.isEmpty) _isSelectionMode = false;
           HapticFeedback.lightImpact();
         });
       } else {
         final startIndex = _flattenedKeys.indexOf(startKey);
         final endIndex = _flattenedKeys.indexOf(key);
         
         if (startIndex != -1 && endIndex != -1) {
           final min = startIndex < endIndex ? startIndex : endIndex;
           final max = startIndex > endIndex ? startIndex : endIndex;
           
           final newRange = _flattenedKeys.sublist(min, max + 1).toSet();
           
           setState(() {
             _selectedKeys.addAll(newRange); // Merge
             _selectionStartKey = null; 
             HapticFeedback.mediumImpact();
           });
         }
       }
     }
  }
}

class BookSection extends StatefulWidget {
  final String bookKey;
  final String bookName;
  final int chapterCount;
  final bool isCollapsed;
  final bool allSelected;
  final bool isFullyOccupied;
  final String? ownerName;
  final GroupMapStateModel mapState;
  final VoidCallback onToggleCollapse;
  final ValueChanged<bool?>? onToggleSelection;
  final Widget Function(int chapterNum) buildChapterTile;

  const BookSection({
    super.key,
    required this.bookKey,
    required this.bookName,
    required this.chapterCount,
    required this.isCollapsed,
    required this.allSelected,
    required this.isFullyOccupied,
    this.ownerName,
    required this.mapState,
    required this.onToggleCollapse,
    this.onToggleSelection,
    required this.buildChapterTile,
  });

  @override
  State<BookSection> createState() => _BookSectionState();
}

class _BookSectionState extends State<BookSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (!widget.isCollapsed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(BookSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCollapsed != widget.isCollapsed) {
      if (widget.isCollapsed) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BOOK HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.grey[100],
          width: double.infinity,
          child: Row(
            children: [
              if (widget.isFullyOccupied)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.lock, color: Colors.grey, size: 20),
                )
              else
                Checkbox(
                  value: widget.allSelected,
                  onChanged: widget.onToggleSelection,
                ),
              Expanded(
                child: InkWell(
                  onTap: widget.onToggleCollapse,
                  child: Row(
                    children: [
                      Text(
                        widget.bookName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16, 
                          color: widget.isFullyOccupied ? Colors.grey : Colors.black87
                        ),
                      ),
                      if (widget.ownerName != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  widget.ownerName!.isNotEmpty ? widget.ownerName![0] : '?',
                                  style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.ownerName!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                  child: const Icon(Icons.expand_more),
                ),
                onPressed: widget.onToggleCollapse,
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          axisAlignment: -1.0,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.chapterCount,
            itemBuilder: (context, index) {
              final chapterNum = index + 1;
              return widget.buildChapterTile(chapterNum); 
            },
          ),
        ),
      ],
    );
  }
}
