import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    required this.completed,
    required this.totalFavorites,
    required this.percentage,
    super.key,
  });

  final int completed;
  final int totalFavorites;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Your Progress for Favourite books',
            style: TextStyle(fontSize: 14, color: Color(0xFF000000)),
          ),
          const SizedBox(height: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                '$completed/$totalFavorites',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF121212),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.track_changes, color: Color(0xFF000000), size: 16),
              SizedBox(width: 4),
              Text(
                'Your Progress',
                style: TextStyle(fontSize: 12, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CustomProgressBar(progress: (percentage / 100).clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final double progress;
  const _CustomProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFFE8820C)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
