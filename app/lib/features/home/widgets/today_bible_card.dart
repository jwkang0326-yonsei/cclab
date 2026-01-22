import 'package:flutter/material.dart';

class TodayBibleCard extends StatefulWidget {
  final String bookName;
  final int chapterNum;
  final String goalTitle;
  final int clearedCount;
  final int totalChapters;
  final VoidCallback onComplete;

  const TodayBibleCard({
    super.key,
    required this.bookName,
    required this.chapterNum,
    required this.goalTitle,
    required this.clearedCount,
    required this.totalChapters,
    required this.onComplete,
  });

  @override
  State<TodayBibleCard> createState() => _TodayBibleCardState();
}

class _TodayBibleCardState extends State<TodayBibleCard> {
  bool _isCompleting = false;

  Future<void> _handleComplete() async {
    setState(() {
      _isCompleting = true;
    });

    // Animation delay (Reduced to 1/3 for faster feel)
    await Future.delayed(const Duration(milliseconds: 260));

    if (mounted) {
      widget.onComplete();
      // We don't reset _isCompleting immediately to prevent flicker before card removal
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalChapters > 0 ? widget.clearedCount / widget.totalChapters : 0.0;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.goalTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.bookmark_border, color: Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.bookName} ${widget.chapterNum}장',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Book Progress Info
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blueAccent.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${widget.clearedCount}/${widget.totalChapters} (${(progress * 100).toInt()}%)",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: FilledButton.icon(
                  onPressed: _isCompleting ? null : _handleComplete,
                  icon: _isCompleting 
                      ? const Icon(Icons.check, color: Colors.white)
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isCompleting ? '완료!' : '읽기 완료'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: _isCompleting ? Colors.green : Colors.blueAccent,
                    disabledBackgroundColor: Colors.green, // Keep green when disabled during delay
                    disabledForegroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
