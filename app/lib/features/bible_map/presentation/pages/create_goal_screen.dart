import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/bible_constants.dart';
import '../viewmodels/create_goal_viewmodel.dart';
import 'package:flutter/services.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  final String groupId;

  const CreateGoalScreen({super.key, required this.groupId});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  // State
  Set<String> _selectedScope = {'NewTestament'}; // Default: NT
  DateTimeRange? _dateRange;
  String? _selectedCustomBookKey; // For 'Custom' scope
  String? _selectedCustomBookName;
  Set<String> _readingMethodSelection = {'distributed'}; // Default: Distributed

  @override
  void initState() {
    super.initState();
    // Default Date Range: Today ~ +30 days
    final now = DateTime.now();
    _dateRange = DateTimeRange(start: now, end: now.add(const Duration(days: 90)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _onScopeChanged(Set<String> newSelection) {
    setState(() {
      _selectedScope = newSelection;
      if (!newSelection.contains('Custom')) {
        _selectedCustomBookKey = null;
        _selectedCustomBookName = null;
      }
    });

    if (newSelection.contains('Custom')) {
      _showBookSelectionModal();
    }
  }

  void _showBookSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return DefaultTabController(
              length: 2, // OT / NT
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40, 
                    height: 4, 
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),
                  const Text("읽으실 성경을 선택해주세요", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  const TabBar(
                    tabs: [Tab(text: "구약"), Tab(text: "신약")],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBookList(BibleConstants.oldTestament, scrollController),
                        _buildBookList(BibleConstants.newTestament, scrollController),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books, ScrollController controller) {
    return ListView.builder(
      controller: controller,
      itemCount: books.length,
      itemBuilder: (context, index) {
         final book = books[index];
         return ListTile(
           title: Text(book['name']),
           trailing: Text("${book['chapters']}장", style: const TextStyle(color: Colors.grey)),
           onTap: () {
             setState(() {
               _selectedCustomBookKey = book['key'];
               _selectedCustomBookName = book['name'];
             });
             Navigator.pop(context);
           },
         );
      },
    );
  }

  Future<void> _pickDateRange() async {
    DateTime? tempStart = _dateRange?.start;
    DateTime? tempEnd = _dateRange?.end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text("진행 기간 선택", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 20),
                    ListTile(
                      title: const Text("시작일"),
                      subtitle: Text(tempStart == null ? "선택 안됨" : DateFormat('yyyy.MM.dd').format(tempStart!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempStart ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => tempStart = picked);
                        }
                      },
                    ),
                    ListTile(
                      title: const Text("종료일"),
                      subtitle: Text(tempEnd == null ? "선택 안됨" : DateFormat('yyyy.MM.dd').format(tempEnd!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempEnd ?? (tempStart?.add(const Duration(days: 90)) ?? DateTime.now()),
                          firstDate: tempStart ?? DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setModalState(() => tempEnd = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (tempStart != null && tempEnd != null)
                          ? () {
                              setState(() {
                                _dateRange = DateTimeRange(start: tempStart!, end: tempEnd!);
                              });
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("기간 저장하기", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_dateRange == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('기간을 선택해주세요.')));
        return;
      }
      
      final scope = _selectedScope.first;
      if (scope == 'Custom' && _selectedCustomBookKey == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('읽으실 성경(낱권)을 선택해주세요.')));
         return;
      }

      List<String> targetRange = [];
      String type = '';

      switch (scope) {
        case 'Whole':
          type = 'whole';
          targetRange = ['Genesis-Revelation'];
          break;
        case 'OldTestament':
          type = 'old_testament';
          targetRange = ['Genesis-Malachi'];
          break;
        case 'NewTestament':
          type = 'new_testament';
          targetRange = ['Matthew-Revelation'];
          break;
        case 'Custom':
          type = 'book';
          targetRange = [_selectedCustomBookKey!];
          break;
      }

      await ref.read(createGoalViewModelProvider.notifier).createGoal(
            groupId: widget.groupId,
            title: _titleController.text,
            type: type,
            readingMethod: _readingMethodSelection.first,
            targetRange: targetRange,
            startDate: _dateRange!.start,
            endDate: _dateRange!.end,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('성경 통독 목표가 생성되었습니다!')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createGoalViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('새 목표 설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Goal Title
              Text("목표 제목", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '예: 2026년 우리셀 신약 통독',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => value == null || value.isEmpty ? '제목을 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),

              // 2. Reading Method (New)
              Text("진행 방식", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'distributed', 
                    label: Text('나눠서 읽기'), 
                    icon: Icon(Icons.call_split),
                    tooltip: '각자 구역을 맡아 빠르게 완독합니다',
                  ),
                  ButtonSegment(
                    value: 'collaborative', 
                    label: Text('함께 읽기'), 
                    icon: Icon(Icons.groups),
                    tooltip: '모두가 같은 본문을 함께 읽습니다',
                  ),
                ],
                selected: _readingMethodSelection,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _readingMethodSelection = newSelection;
                  });
                },
                showSelectedIcon: false,
              ),
              const SizedBox(height: 8),
              Text(
                _readingMethodSelection.first == 'distributed'
                    ? "• 공동체가 성경 전체를 분담하여 빠르게 완독하는 방식입니다.\n• 챕터별로 담당자(예약)를 정할 수 있습니다."
                    : "• 공동체가 같은 본문을 함께 읽으며 은혜를 나누는 방식입니다.\n• 누구나 자유롭게 읽고 체크할 수 있습니다.",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 24),

              // 3. Scope Selection
              Text("통독 범위", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Whole', label: Text('전체'), icon: Icon(Icons.menu_book)),
                  ButtonSegment(value: 'OldTestament', label: Text('구약')),
                  ButtonSegment(value: 'NewTestament', label: Text('신약')),
                  ButtonSegment(value: 'Custom', label: Text('낱권')),
                ],
                selected: _selectedScope,
                onSelectionChanged: _onScopeChanged,
                showSelectedIcon: false, 
              ),
              if (_selectedScope.contains('Custom')) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: _showBookSelectionModal,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                      color: theme.primaryColor.withOpacity(0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCustomBookName ?? "터치하여 성경 선택하기",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: _selectedCustomBookName == null ? Colors.grey : theme.primaryColor
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),

              // 3. Date Range
              Text("진행 기간", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                       const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                       const SizedBox(width: 12),
                       Expanded(
                         child: Text(
                           _dateRange == null 
                             ? "기간 설정하기" 
                             : "${DateFormat('yyyy.MM.dd').format(_dateRange!.start)} ~ ${DateFormat('yyyy.MM.dd').format(_dateRange!.end)}",
                           style: const TextStyle(fontSize: 16),
                         ),
                       ),
                       if (_dateRange != null)
                          Text(
                            "${_dateRange!.duration.inDays + 1}일간",
                            style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: ElevatedButton(
            onPressed: state.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: state.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('목표 생성하기'),
          ),
        ),
      ),
    );
  }
}
