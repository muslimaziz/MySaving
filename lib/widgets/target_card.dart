import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_icons.dart';
import '../../utils/format_helper.dart';
import 'app_progress_bar.dart';

/// Kartu target horizontal ala desain:
/// thumbnail 112px + badge Aktif/Selesai + nominal + persen + progress bar.
class TargetCard extends StatelessWidget {
  final Goal goal;
  final double saved;
  final VoidCallback onTap;

  const TargetCard({
    super.key,
    required this.goal,
    required this.saved,
    required this.onTap,
  });

  double get progress =>
      goal.targetPrice > 0 ? (saved / goal.targetPrice).clamp(0.0, 1.0) : 0.0;

  bool get completed => progress >= 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail foto / placeholder
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFE4EFE9),
                    gradient: goal.image != null && goal.image!.isNotEmpty
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE7EFE7), Color(0xFFC9DDCE)],
                          ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      if (goal.image != null && goal.image!.isNotEmpty)
                        Image.file(
                          File(goal.image!),
                          width: 112,
                          height: 112,
                          cacheWidth: 336,
                          fit: BoxFit.cover,
                        )
                      else
                        Center(
                          child: AppIcons.fromAsset(
                            AppIcons.target,
                            size: 36,
                            color: const Color(0xFF46685B),
                          ),
                        ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: completed
                                ? AppColors.successBg
                                : const Color(0xE6FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            completed ? 'Selesai' : 'Aktif',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: completed
                                  ? AppColors.success
                                  : const Color(0xFF4C5D57),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AppIcons.fromAsset(
                              AppIcons.calendar,
                              size: 13,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                AppFormat.prettyDate(goal.targetDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: AppFormat.rupiah(saved),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' / ${AppFormat.rupiah(goal.targetPrice)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.faint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppProgressBar(value: progress),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
