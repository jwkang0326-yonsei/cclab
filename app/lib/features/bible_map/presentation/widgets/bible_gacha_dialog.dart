import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BibleGachaDialog extends StatefulWidget {
  final List<Map<String, dynamic>> availableBooks;
  final Function(Map<String, dynamic> book) onConfirm;

  const BibleGachaDialog({
    super.key,
    required this.availableBooks,
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
  Map<String, dynamic> _currentDisplayBook = {};
  late Map<String, dynamic> _finalBook;
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _finalBook = (List<Map<String, dynamic>>.from(widget.availableBooks)..shuffle()).first;
    _currentDisplayBook = widget.availableBooks.first;

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
        _currentDisplayBook = widget.availableBooks[Random().nextInt(widget.availableBooks.length)];
      });
      count++;
      
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
        _currentDisplayBook = _finalBook;
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
                  shape: BoxShape.circle,
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
            width: 340,
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
                  "오늘 읽을 성경 뽑기",
                  style: TextStyle(
                    fontSize: 18,
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
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSpinning ? Icons.casino : Icons.auto_stories,
                      size: 80,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Result Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentDisplayBook['name'] ?? "",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _isSpinning ? Colors.grey : Colors.orange[900],
                        ),
                      ),
                      if (!_isSpinning) ...[
                        const SizedBox(height: 4),
                        Text(
                          "1장 ~ ${_currentDisplayBook['chapters']}장",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange[700],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                
                if (!_isSpinning) ...[
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      _currentDisplayBook['summary'] ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                
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
                              widget.onConfirm(_finalBook);
                              Navigator.pop(context);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "이 성경책 예약하기",
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
                    "오늘 주실 말씀을 찾고 있어요...",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          
          // Celebration Effect
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
