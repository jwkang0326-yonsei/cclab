import 'package:flutter/material.dart';

class GrowthTreeWidget extends StatelessWidget {
  const GrowthTreeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light Green
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.park, // Tree icon placeholder
            size: 100,
            color: Color(0xFF2E7D32), // Forest Green
          ),
          const SizedBox(height: 16),
          Text(
            'Lv.3 푸른 묘목',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          const Text('다음 단계까지 3일 남았어요!'),
        ],
      ),
    );
  }
}
