import 'package:flutter/material.dart';
import 'package:focusmate/core/constants/app_colors.dart';

/// Shows today's task completion progress with a linear bar and counts.
class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  double get _progress =>
      total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);

  String get _motivationText {
    if (total == 0) return 'Add your first task to get started!';
    if (completed == 0) return 'You\'ve got this. Start strong!';
    if (_progress < 0.5) return 'Great start, keep going!';
    if (_progress < 1.0) return 'Almost there, you\'re doing great!';
    return '🎉 All done! Amazing work today!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Progress",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _motivationText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
