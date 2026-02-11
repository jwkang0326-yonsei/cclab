import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/bible_constants.dart';

class BibleGachaDialog extends StatefulWidget {
  final List<String> openChapterKeys;
  final Function(String key) onConfirm;

  const BibleGachaDialog({
    super.key,
    required this.openChapterKeys,
    required this.onConfirm,
  });

  @override
  State<BibleGachaDialog> createState() => _BibleGachaDialogState();
}

class _BibleGachaDialogState extends State<BibleGachaDialog> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late AnimationController _revealController;
  
  bool _isSpinning = true;
  String _currentDisplayKey = "";
  late String _finalKey;
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _finalKey = (widget.openChapterKeys..shuffle()).first;
    _currentDisplayKey = widget.openChapterKeys.first;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _startSlotMachine();
  }

  void _startSlotMachine() {
    int count = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      setState(() {
        _currentDisplayKey = widget.openChapterKeys[Random().nextInt(widget.openChapterKeys.length)];
      });
      count++;
      
      // Gradually slow down
      if (count > 20) {
        timer.cancel();
        _stopAndReveal();
      }
    });
  }

  void _stopAndReveal() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _currentDisplayKey = _finalKey;
      });
      _shakeController.stop();
      _revealController.forward();
      HapticFeedback.heavyImpact();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _glowController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  String _formatKey(String key) {
    if (key.isEmpty) return "";
    final parts = key.split('_');
    final bookKey = parts[0];
    final chapter = parts[1];
    
    final allBooks = [...BibleConstants.oldTestament, ...BibleConstants.newTestament];
    final book = allBooks.firstWhere((b) => b['key'] == bookKey, orElse: () => {'name': bookKey});
    
    return "${book['name']} ${chapter}장";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxType.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3 * (1 - _glowController.value)),
                      blurRadius: 50 * _glowController.value,
                      spreadRadius: 20 * _glowController.value,
                    )
                  ],
                ),
              );
            },
          ),

          // Main Card
          Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "오늘의 말씀 뽑기",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Animated Icon
                RotationTransition(
                  turns: Tween(begin: -0.02, end: 0.02).animate(_shakeController),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      shape: BoxType.circle,
                    ),
                    child: Icon(
                      _isSpinning ? Icons.Casino : Icons.menu_book,
                      size: 80,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Result Text
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatKey(_currentDisplayKey),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isSpinning ? Colors.grey : Colors.orange[900],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Action Buttons
                if (!_isSpinning)
                  ScaleTransition(
                    scale: _revealController,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: () {
                              widget.onConfirm(_finalKey);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "이 말씀으로 예약하기",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("다음에 뽑을게요", style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    "말씀을 고르고 있습니다...",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          
          // Particles / Celebration Effect
          if (!_isSpinning)
             const IgnorePointer(child: _CelebrationEffect()),
        ],
      ),
    );
  }
}

class _CelebrationEffect extends StatelessWidget {
  const _CelebrationEffect();

  @override
  Widget build(BuildContext context) {
    // Simple mock celebration with icons
    return Stack(
      children: List.generate(10, (index) {
        final rand = Random();
        return AnimatedAlign(
          duration: const Duration(seconds: 1),
          alignment: Alignment(rand.nextDouble() * 2 - 1, rand.nextDouble() * 2 - 1),
          child: Icon(Icons.star, color: Colors.amber.withOpacity(0.5), size: 20),
        );
      }),
    );
  }
}
