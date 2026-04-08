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

    _startBibleFlipping();
  }

  void _startBibleFlipping() {
    int count = 0;
    int maxCount = 25;
    
    void flip() {
      if (!mounted) return;
      
      setState(() {
        _currentDisplayBook = widget.availableBooks[Random().nextInt(widget.availableBooks.length)];
      });
      count++;
      
      if (count < maxCount) {
        // 점점 느려지는 효과 (Exponential backoff style)
        int delay = 50 + (pow(count / maxCount, 3) * 300).toInt();
        _timer = Timer(Duration(milliseconds: delay), flip);
        
        // 햅틱 피드백 (책장 넘기는 느낌)
        if (count % 2 == 0) {
          HapticFeedback.lightImpact();
        }
      } else {
        _stopAndReveal();
      }
    }
    
    flip();
  }

  void _stopAndReveal() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _currentDisplayBook = _finalBook;
      });
      _shakeController.stop();
      _revealController.forward();
      HapticFeedback.mediumImpact();
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
              color: const Color(0xFFFDFCFB), // Soft Paper color
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "오늘의 말씀 묵상",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037), // Brown 800
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Animated Icon
                ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.05).animate(
                    CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut)
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEBE9), // Brown 50
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD7CCC8), width: 1),
                    ),
                    child: Icon(
                      Icons.auto_stories,
                      size: 80,
                      color: const Color(0xFF8D6E63), // Brown 400
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Result Text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _currentDisplayBook['name'] ?? "",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _isSpinning ? Colors.grey[400] : const Color(0xFF3E2723), // Brown 900
                          fontFamily: 'NanumMyeongjo', // 만약 폰트가 있다면 명조체가 더 어울림
                        ),
                      ),
                      if (!_isSpinning) ...[
                        const SizedBox(height: 8),
                        Text(
                          "1장 ~ ${_currentDisplayBook['chapters']}장",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF795548), // Brown 500
                            letterSpacing: 1.2,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                
                if (!_isSpinning) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _currentDisplayBook['summary'] ?? "",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.brown[400],
                        height: 1.6,
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
                              backgroundColor: const Color(0xFF5D4037), // Brown 700
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "말씀 예약하기",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "다음에 묵상할게요", 
                            style: TextStyle(color: Colors.brown[300], fontSize: 14)
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    "오늘 주실 말씀을 기다립니다...",
                    style: TextStyle(
                      color: Colors.brown[300], 
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          
          // Celebration Effect (Subtle Light instead of Stars)
          if (!_isSpinning)
             const IgnorePointer(child: _GlowEffect()),
        ],
      ),
    );
  }
}

class _GlowEffect extends StatelessWidget {
  const _GlowEffect();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        radialGradient: RadialGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
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
