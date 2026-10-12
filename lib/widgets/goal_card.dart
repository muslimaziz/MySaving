import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'progress_bar.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String targetDate;

  const GoalCard({
    super.key,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  @override
  Widget build(BuildContext context) {
    // Perhitungan persentase progress
    double progress = targetAmount > 0 ? (currentAmount / targetAmount) : 0;
    int percentage = (progress * 100).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  targetDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${CurrencyFormatter.convertToIdr(currentAmount, 0)} / ${CurrencyFormatter.convertToIdr(targetAmount, 0)}',
                  style: TextStyle(
                fontSize: 14,
                    color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ProgressBar(progress: progress),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
