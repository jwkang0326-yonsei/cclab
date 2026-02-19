import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/bible_content_service.dart';
import '../../../../data/models/bible_verse_model.dart';

/// 성경 본문 읽기 바텀시트
/// 챕터 탭 시 열리며, 성경 읽기 / 읽기 완료 기능 제공
class BibleReadingBottomSheet extends ConsumerStatefulWidget {
  final String bookKey;
  final String bookName;
  final int chapterNum;
  final bool isAlreadyCompleted;
  final VoidCallback onComplete;

  const BibleReadingBottomSheet({
    super.key,
    required this.bookKey,
    required this.bookName,
    required this.chapterNum,
    required this.isAlreadyCompleted,
    required this.onComplete,
  });

  @override
  ConsumerState<BibleReadingBottomSheet> createState() =>
      _BibleReadingBottomSheetState();
}

class _BibleReadingBottomSheetState
    extends ConsumerState<BibleReadingBottomSheet> {
  bool _isReadingMode = false;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: _isReadingMode ? 0.9 : 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Colors.brown[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.bookName} ${widget.chapterNum}장',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '개역한글',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isReadingMode)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isReadingMode = false;
                          });
                        },
                        icon: const Icon(Icons.close),
                        color: Colors.grey[600],
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 본문 영역
              Expanded(
                child: _isReadingMode
                    ? _buildReadingContent(scrollController)
                    : _buildActionButtons(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 초기 액션 버튼 화면 (성경 읽기 + 읽기 완료)
  Widget _buildActionButtons(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 성경 읽기 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _isReadingMode = true;
                  });
                },
                icon: Icon(Icons.auto_stories, color: Colors.brown[700]),
                label: Text(
                  '성경 읽기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.brown[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 읽기 완료 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.isAlreadyCompleted || _isCompleting
                    ? null
                    : _handleComplete,
                icon: Icon(
                  widget.isAlreadyCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                ),
                label: Text(
                  widget.isAlreadyCompleted ? '이미 완료됨' : '읽기 완료',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: widget.isAlreadyCompleted
                      ? Colors.grey
                      : Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성경 본문 읽기 모드
  Widget _buildReadingContent(ScrollController scrollController) {
    final chapterContent = ref.watch(
      bibleChapterContentProvider(
        (bookKey: widget.bookKey, chapter: widget.chapterNum),
      ),
    );

    return chapterContent.when(
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('성경 본문을 불러오는 중...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                '성경 본문을 불러올 수 없습니다.\n인터넷 연결을 확인해 주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(
                    bibleChapterContentProvider(
                      (bookKey: widget.bookKey, chapter: widget.chapterNum),
                    ),
                  );
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (content) => Column(
        children: [
          // 성경 본문
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: content.verses.length,
              itemBuilder: (context, index) {
                final verse = content.verses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 절 번호
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${verse.verse}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[400],
                          ),
                        ),
                      ),
                      // 본문
                      Expanded(
                        child: Text(
                          verse.text,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.7,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 하단 읽기 완료 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: widget.isAlreadyCompleted || _isCompleting
                      ? null
                      : _handleComplete,
                  icon: Icon(
                    widget.isAlreadyCompleted
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                  ),
                  label: Text(
                    widget.isAlreadyCompleted ? '이미 완료됨' : '읽기 완료',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: widget.isAlreadyCompleted
                        ? Colors.grey
                        : Colors.green[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 읽기 완료 처리
  void _handleComplete() {
    setState(() {
      _isCompleting = true;
    });

    widget.onComplete();

    // 잠시 후 바텀시트 닫기
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

/// 바텀시트를 열기 위한 헬퍼 함수
void showBibleReadingBottomSheet({
  required BuildContext context,
  required String bookKey,
  required String bookName,
  required int chapterNum,
  required bool isAlreadyCompleted,
  required VoidCallback onComplete,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BibleReadingBottomSheet(
      bookKey: bookKey,
      bookName: bookName,
      chapterNum: chapterNum,
      isAlreadyCompleted: isAlreadyCompleted,
      onComplete: onComplete,
    ),
  );
}
