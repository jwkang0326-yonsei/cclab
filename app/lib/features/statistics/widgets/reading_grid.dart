import 'package:flutter/material.dart';

/// GitHub 스타일의 읽기 기여도 그리드 위젯
class ReadingGrid extends StatefulWidget {
  final Map<String, int> dailyReadings;
  final int weeksToShow;

  const ReadingGrid({
    super.key,
    required this.dailyReadings,
    this.weeksToShow = 20, // 사용하지 않음, 하위 호환성 유지
  });

  @override
  State<ReadingGrid> createState() => _ReadingGridState();
}

class _ReadingGridState extends State<ReadingGrid> {
  late ScrollController _scrollController;
  
  // 그리드 설정
  final double cellSize = 11.0;
  final double cellSpacing = 2.0;
  final int totalWeeks = 52; // 약 12개월
  final int pastWeeks = 26;  // 과거 6개월

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 빌드 후 스크롤을 중앙(오늘)으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCenter() {
    if (!_scrollController.hasClients) return;
    
    final cellWidth = cellSize + cellSpacing;
    // 과거 26주 지점이 중앙에 오도록 스크롤
    // 요일 레이블 너비(20) + 간격(4) 고려
    final centerOffset = (pastWeeks * cellWidth) - (MediaQuery.of(context).size.width / 2) + 24;
    
    if (centerOffset > 0 && _scrollController.position.maxScrollExtent >= centerOffset) {
      _scrollController.jumpTo(centerOffset);
    } else if (centerOffset > 0) {
      // 최대 스크롤 범위가 centerOffset보다 작으면 최대치로
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent / 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    
    // 오늘의 요일 (1=월, 7=일)
    final todayWeekday = today.weekday;
    // 이번 주 월요일
    final thisMonday = today.subtract(Duration(days: todayWeekday - 1));
    
    // 시작일: 과거 26주 전 월요일
    final startDate = thisMonday.subtract(Duration(days: pastWeeks * 7));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 레이블과 그리드를 함께 스크롤
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 월 레이블
              _buildMonthLabels(startDate),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 요일 레이블
                  _buildDayLabels(),
                  const SizedBox(width: 4),
                  // 그리드
                  _buildGrid(startDate, today),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 범례
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthLabels(DateTime startDate) {
    final labels = <Widget>[];
    final cellWidth = cellSize + cellSpacing;
    
    // 요일 레이블 너비만큼 왼쪽 패딩
    labels.add(const SizedBox(width: 20));
    
    int? lastMonth;
    int consecutiveWeeks = 0;
    
    for (int week = 0; week < totalWeeks; week++) {
      final weekStart = startDate.add(Duration(days: week * 7));
      
      if (lastMonth != weekStart.month) {
        // 이전 월 레이블 추가 (연속 주 수만큼 너비)
        if (lastMonth != null && consecutiveWeeks > 0) {
          labels.add(
            SizedBox(
              width: cellWidth * consecutiveWeeks,
              child: Text(
                _monthName(lastMonth),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          );
        }
        lastMonth = weekStart.month;
        consecutiveWeeks = 1;
      } else {
        consecutiveWeeks++;
      }
    }
    
    // 마지막 월 레이블 추가
    if (lastMonth != null && consecutiveWeeks > 0) {
      labels.add(
        SizedBox(
          width: cellWidth * consecutiveWeeks,
          child: Text(
            _monthName(lastMonth),
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ),
      );
    }
    
    return Row(children: labels);
  }

  Widget _buildDayLabels() {
    // 월=1, 화=2, 수=3, 목=4, 금=5, 토=6, 일=7
    // 표시 순서: 월, 화, 수, 목, 금, 토, 일
    final days = ['월', '화', '수', '목', '금', '토', '일'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days.map((d) {
        return SizedBox(
          width: 16,
          height: cellSize + cellSpacing,
          child: Center(
            child: Text(
              d,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrid(DateTime startDate, DateTime today) {
    final weeks = <Widget>[];
    
    for (int week = 0; week < totalWeeks; week++) {
      final days = <Widget>[];
      for (int day = 0; day < 7; day++) {
        final currentDate = startDate.add(Duration(days: week * 7 + day));
        final dateStr = _formatDate(currentDate);
        final count = widget.dailyReadings[dateStr] ?? 0;
        final isFuture = currentDate.isAfter(today);
        final isToday = _formatDate(currentDate) == _formatDate(today);

        days.add(
          Tooltip(
            message: isFuture ? '' : '$dateStr: $count장',
            child: Container(
              width: cellSize,
              height: cellSize,
              margin: EdgeInsets.all(cellSpacing / 2),
              decoration: BoxDecoration(
                color: isFuture ? Colors.grey.withOpacity(0.1) : _getColor(count),
                borderRadius: BorderRadius.circular(2),
                border: isToday 
                    ? Border.all(color: Colors.blue, width: 1.5)
                    : Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
              ),
            ),
          ),
        );
      }
      weeks.add(Column(children: days));
    }

    return Row(children: weeks);
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('적게', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        const SizedBox(width: 4),
        for (int level = 0; level <= 4; level++)
          Container(
            width: cellSize,
            height: cellSize,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: _getLevelColor(level),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 4),
        Text('많이', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Color _getColor(int count) {
    if (count == 0) return _getLevelColor(0);
    if (count <= 1) return _getLevelColor(1);
    if (count <= 3) return _getLevelColor(2);
    if (count <= 5) return _getLevelColor(3);
    return _getLevelColor(4);
  }

  Color _getLevelColor(int level) {
    const colors = [
      Color(0xFFEBEDF0), // 0: 없음
      Color(0xFF9BE9A8), // 1: 연한 초록
      Color(0xFF40C463), // 2: 중간 초록
      Color(0xFF30A14E), // 3: 진한 초록
      Color(0xFF216E39), // 4: 매우 진한 초록
    ];
    return colors[level.clamp(0, 4)];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const names = ['', '1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    return names[month];
  }
}
